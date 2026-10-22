variable "instance_name" {
  description = "Value of the Name tag of the EC2 instance"
  type        = string
  default     = "MyNewInstance"
}

variable "ec2_instance_type" {
  description = "AWS EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "docker_image_1" {
  description = "Docker Image Name"
  type        = string
  default     = "mohamedabdirazak/my_first_website"
}

variable "docker_image_2" {
  description = "Docker Image Name"
  type        = string
  default     = "mohamedabdirazak/challenge_task"
}

variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0224ce6f9504665ee" # Ubuntu Server
}

variable "domain_name" {
  type    = string
  default = "buildsphere.dev"
}

#variable "db_user" {
#    description = "Database username"
#    type = string
#    default = "admin"
#}

#variable "db_pass" {
#    description = "Database password"
#    type = string
#    sensitive = true
#}