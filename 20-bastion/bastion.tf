resource "aws_instance" "this" {
  ami                    = "ami-0055977a6e828a4f4" # This is our devops-practice AMI ID
  vpc_security_group_ids = [data.aws_ssm_parameter.bastion_sg_id.value]
  instance_type          = "t3.micro"
  subnet_id   = local.public_subnet_id

  # 20GB is not enough
  root_block_device {
    volume_size = 50  # Set root volume size to 50GB
    volume_type = "gp3"  # Use gp3 for better performance (optional)
  }
  #user_data = file("bastion.sh")
  user_data = file("${path.module}/bastion.sh")

  
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-bastion"
    }
  )
}