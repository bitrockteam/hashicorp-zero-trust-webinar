resource "random_pet" "test" {
  length = 1
}

variable "boundary_release" {
  default     = "0.7.6"
  description = "The version of Boundary to install"
  type        = string
}

variable "cidr_block" {
  default     = "10.0.0.0/16"
  description = "The IPv4 network range for the VPC, in CIDR notation. For example, 10.0.0.0/16."
  type        = string
}

variable "controller_desired_capacity" {
  default     = 3
  description = "The capacity the controller Auto Scaling group attempts to maintain"
  type        = number
}

variable "controller_instance_type" {
  default     = "t3.small"
  description = "Specifies the instance type of the controller EC2 instance"
  type        = string
}

variable "controller_max_size" {
  default     = 3
  description = "The maximum size of the controller group"
  type        = number
}

variable "controller_min_size" {
  default     = 3
  description = "The minimum size of the controller group"
  type        = number
}

variable "private_subnets" {
  default     = []
  description = "List of private subnets"
  type        = list(string)
}

variable "public_subnets" {
  default     = []
  description = "List of public subnets"
  type        = list(string)
}

variable "tags" {
  default     = {}
  description = "One or more tags"
  type        = map(string)
}

variable "vpc_id" {
  default     = ""
  description = "The ID of the VPC"
  type        = string
}

variable "worker_desired_capacity" {
  default     = 3
  description = "The capacity the worker Auto Scaling group attempts to maintain"
  type        = number
}

variable "worker_instance_type" {
  default     = "t3.small"
  description = "Specifies the instance type of the worker EC2 instance"
  type        = string
}

variable "worker_max_size" {
  default     = 3
  description = "The maximum size of the worker group"
  type        = number
}

variable "worker_min_size" {
  default     = 3
  description = "The minimum size of the worker group"
  type        = number
}

variable "tls_cert_path" {
  default = "/etc/pki/tls/boundary/boundary.cert"
}

variable "tls_key_path" {
  default = "/etc/pki/tls/boundary/boundary.key"
}

variable "tls_disabled" {
  default = true
}

variable "region" {
  default = "us-east-1"
}

# Vault
variable "ami_filter_name" {
  type        = string
  default     = "*caravan-centos-image-os-*"
  description = "Regexp to find AMI to use built with caravan-baking"
}
variable "control_plane_instance_count" {
  type        = number
  default     = 3
  description = "Control plane instances number"
}

variable "volume_root_size" {
  type        = number
  default     = 20
  description = "Volume size of control plan root disk"
}

variable "volume_data_size" {
  type        = number
  default     = 20
  description = "Volume size of control plan data disk"
}

variable "volume_type" {
  type        = string
  default     = "gp3"
  description = "Volume type of disks"
}

variable "control_plane_machine_type" {
  type        = string
  default     = "t3.micro"
  description = "Control plane instance machine type"
}


