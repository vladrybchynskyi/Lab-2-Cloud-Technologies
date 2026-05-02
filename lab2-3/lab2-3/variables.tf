variable "region" {
  description = "AWS Region for the lab"
  type        = string
  default     = "eu-central-1"
}
variable "namespace" {
  type    = string
  default = "student"
}
variable "environment" {
  type    = string
  default = "dev"
}
variable "name" {
  type    = string
  default = "lab1"
}
