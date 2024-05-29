output "ubuntu_ami_id" {
  value = data.aws_ami.ubuntu.id
}

output "vpc_id" {
  value = data.aws_vpc.togetvpc_id.id
}

output "public_subnet_ids" {
  value = local.public_subnet_ids
}

output "target_group_arns" {
  value = [for tg in aws_lb_target_group.alb_tg : tg.arn]
}

output "alb_dns_name" {
  value = aws_lb.my_alb.dns_name
}
