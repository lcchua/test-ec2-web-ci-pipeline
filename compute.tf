module "lcchua-ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.0"

  name                        = "${var.stack_name}-${var.env}-ec2-server-${var.rnd_id}"
  instance_type               = var.settings.web_app.instance_type
  key_name                    = var.key_name
  monitoring                  = true
  vpc_security_group_ids      = [module.lcchua-security-group.security_group_id]
  subnet_id                   = module.lcchua-vpc.public_subnets[0]
  associate_public_ip_address = true

  user_data_replace_on_change = true    // to trigger a destroy and recreate
  user_data = file("${path.module}/ws_install.sh")

  tags = {
    group     = var.stack_name
    form_type = "Terraform Resources"
    Name      = "${var.stack_name}-${var.env}-ec2-server-${var.rnd_id}"
  }
}
output "lcchua-ec2-instance" {
  value = module.lcchua-ec2-instance.id
}
output "user-data" {
  description = "stw user data"
  value       = "${path.module}/ws_install.sh"
}