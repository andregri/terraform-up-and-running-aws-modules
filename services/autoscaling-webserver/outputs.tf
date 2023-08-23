output "alb_dns_name" {
    description = "The domain name of the load balancer"
    value = aws_alb.web.dns_name
}

output "alb_security_group_id" {
    value = aws_security_group.alb.id
    description = "The ID of the Security Group attached to the load balancer"
}