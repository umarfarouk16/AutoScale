output "alb_dns_name" {
  description = "ALB DNS name to access the web server"
  value       = aws_lb.web_alb.dns_name
}
