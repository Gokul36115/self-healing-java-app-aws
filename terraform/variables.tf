variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "selfheal"
}

variable "vpc_cidr" {
  description = "IP range for the whole VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "IP range for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "my_ip_cidr" {
  description = "My home public IP in CIDR form, e.g. 49.1.2.3/32"
  type        = string
}

variable "instance_type" {
  description = "EC2 size (t3.small = 2 vCPU, 2 GB, x86)"
  type        = string
  default     = "t3.small"
}

variable "app_image" {
  description = "Docker image the EC2 will run"
  type        = string
  default     = "gokul36115/selfheal-app:v2"
}

variable "alert_email" {
  description = "Email address that receives CloudWatch alarm notifications"
  type        = string
}