variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "AppServerInstance"
}

variable "name" {
  description = "The name used to namespace all resources"
  type        = string
  default     = "doyinterraform-example"
}
variable "ami" {
  description = "The AMI to run on the instance"
  type        = string
  default     = "ami-052efd3df9dad4825"
}
variable "instance_type" {
  description = "The instance type to use"
  type        = string
  default     = "t2.micro"
}
variable "key_name" {
  description = "The Key Pair to associate with the EC2 instance"
  type        = string
  default     = "Test Key.pem"
}
variable "ssh_port" {
  description = "Open SSH access on this port"
  type        = number
  default     = 22
}
variable "allow_ssh_from_cidrs" {
  description = "Allow SSH access from these CIDR blocks"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "subnet_id_1" {
  type    = string
  default = "subnet-0adbaa80c9162c209"
}

variable "subnet_id_2" {
  type    = string
  default = "subnet-08c5c2856cd17f72f"
}