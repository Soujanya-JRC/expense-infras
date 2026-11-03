module "mysql_sg" {
    #source = "../../aws-securitygroup"
    #source = githublink of that module"
    source = "git::https://github.com/DAWS-82S/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "mysql"
    sg_description = "created for mysql instance in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
}

module "bastion_sg" {
    #source = "../../aws-securitygroup"
    #source = githublink of that module"
    source = "git::https://github.com/DAWS-82S/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "bastion"
    sg_description = "created for bastion instance in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
}
#ports 22,443,1194,943---->vpn ports
module "vpn_sg" {
    #source = "../../aws-securitygroup"
    #source = githublink of that module"
    source = "git::https://github.com/DAWS-82S/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "vpn"
    sg_description = "created for vpn in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
}

module "alb_ingress_sg" {
    #source = "../../aws-securitygroup"
    #source = githublink of that module"
    source = "git::https://github.com/DAWS-82S/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "app-alb"
    sg_description = "created for backend alb in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    }

module "eks_control_plane_sg" {
    #source = "../../aws-securitygroup"
    #source = githublink of that module"
    source = "git::https://github.com/DAWS-82S/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "eks-control-plane"
    sg_description = "created for backend alb in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    }

module "eks_node_sg" {
    #source = "../../aws-securitygroup"
    #source = githublink of that module"
    source = "git::https://github.com/DAWS-82S/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "eks-node"
    sg_description = "created for backend alb in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    }

resource "aws_security_group_rule" "eks_control_plane_node" {
    type = "ingress"
    from_port         = 0
    protocol       = "-1"
    to_port           = 0
    source_security_group_id = module.eks_node_sg.sg_id
    security_group_id = module.eks_control_plane_sg.sg_id
}

resource "aws_security_group_rule" "eks_node_eks_control_plane" {
    type = "ingress"
    from_port         = 30000
    protocol       = "tcp"
    to_port           = 32767
    source_security_group_id = module.alb_ingress_sg.sg_id
    security_group_id = module.eks_node_sg.sg_id
}

resource "aws_security_group_rule" "node_alb_ingress" {
    type = "ingress"
    from_port         = 0
    protocol       = "-1"
    to_port           = 0
    source_security_group_id = module.eks_control_plane_sg.sg_id
    security_group_id = module.eks_node_sg.sg_id
}

resource "aws_security_group_rule" "node_vpc" {
    type = "ingress"
    from_port         = 0
    protocol       = "-1"
    to_port           = 0
    cidr_blocks =    ["10.0.0.0/16"]  #our private IP address range
    security_group_id = module.eks_node_sg.sg_id
}

resource "aws_security_group_rule" "node_bastion" {
    type = "ingress"
    from_port         = 22
    protocol       = "tcp"
    to_port           = 22
    source_security_group_id = module.bastion_sg.sg_id
    security_group_id = module.eks_node_sg.sg_id
}
# app alb  accepting traffic from bastion
resource "aws_security_group_rule" "alb_ingress_bastion" {
    type = "ingress"
    from_port         = 80
    protocol       = "tcp"
    to_port           = 80
    source_security_group_id = module.bastion_sg.sg_id
    security_group_id = module.alb_ingress_sg.sg_id
}

resource "aws_security_group_rule" "alb_ingress_bastion_https" {
    type = "ingress"
    from_port         = 443
    protocol       = "tcp"
    to_port           = 443
    source_security_group_id = module.bastion_sg.sg_id
    security_group_id = module.alb_ingress_sg.sg_id
}


resource "aws_security_group_rule" "alb_ingress_public_https" {
    type = "ingress"
    from_port         = 443
    protocol       = "tcp"
    to_port           = 443
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = module.alb_ingress_sg.sg_id
}

resource "aws_security_group_rule" "bastion_public" {
    type = "ingress"
    from_port         = 22
    protocol       = "tcp"
    to_port           = 22
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = module.bastion_sg.sg_id
}


resource "aws_security_group_rule" "mysql_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.mysql_sg.sg_id
}

resource "aws_security_group_rule" "mysql_eks_node" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.eks_node_sg.sg_id
  security_group_id = module.mysql_sg.sg_id
}

resource "aws_security_group_rule" "eks_control_plane_bastion" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.eks_control_plane_sg.sg_id
}
