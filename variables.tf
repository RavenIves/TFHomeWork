#found in terraform.tfvars
variable "v-access-key" {}
variable "v-secret-key" {}

# Shareable information
variable "v-ami-image" {
    description = "AMI image"
    default = "ami-06ce824c157700cd2"
}
variable "v-instance-type" {
    description = "EC2 instance type"
    default = "t2.micro"
}
variable "v-instance-key" {
    description = "Instance key"
    default = "softuni"
}
variable "v-count" {
    description = "Resource count"
    default = "1"
}
data "aws_availability_zones" "main-avz" {}
variable "main-cidr" {
    type = list
    default = ["10.10.10.0/24", "10.10.11.0/24"] 
}
