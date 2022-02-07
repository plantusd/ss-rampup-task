output "aws_vpc_main" {
  description = "Private subnet id"
  value       = aws_vpc.main.id
}
output "subnet-k8s-1a" {
  description = "k8s subnet id"
  value       = aws_subnet.subnet-k8s-1a.id
}

output "subnet-k8s-1b" {
  description = "k8s subnet id"
  value       = aws_subnet.subnet-k8s-1b.id
}
output "subnet-k8s-1c" {
  description = "k8s subnet id"
  value       = aws_subnet.subnet-k8s-1c.id
}

output "subnet-private-1a" {
  description = "Private subnet id"
  value       = aws_subnet.subnet-private-1a.id
}

output "subnet-private-1b" {
  description = "Private subnet id"
  value       = aws_subnet.subnet-private-1b.id
}

output "subnet-private-1c" {
  description = "Private subnet id"
  value       = aws_subnet.subnet-private-1c.id
}