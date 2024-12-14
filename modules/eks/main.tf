resource "aws_eks_cluster" "main" {
  name     = "${terraform.workspace}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = slice(var.subnet_ids, 0, var.node_groups[terraform.workspace].az_count)
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = {
    Name = "${terraform.workspace}-eks-cluster"
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = var.node_groups[terraform.workspace].name
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = slice(var.subnet_ids, 0, var.node_groups[terraform.workspace].az_count)

  scaling_config {
    desired_size = var.node_groups[terraform.workspace].desired_size
    max_size     = var.node_groups[terraform.workspace].max_size
    min_size     = var.node_groups[terraform.workspace].min_size
  }

  instance_types = [var.node_groups[terraform.workspace].instance_type]

  labels = {
    NodeGroup = var.node_groups[terraform.workspace].name
  }

  tags = {
    Name = "${terraform.workspace}-node-group"
  }
}

resource "aws_security_group" "eks_nodes" {
  name        = "${terraform.workspace}-eks-nodes-sg"
  description = "Security group for EKS nodes in ${terraform.workspace}"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${terraform.workspace}-eks-nodes-sg"
  }
}

# IAM roles remain mostly the same, just updated tags
resource "aws_iam_role" "eks_cluster" {
  name = "${terraform.workspace}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "${terraform.workspace}-eks-cluster-role"
  }
}

# Rest of the IAM configuration remains the same...