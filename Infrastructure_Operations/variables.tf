variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  type = string
  default = "WebAzureProject-Terraform"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  type = string
  default = "eastus"
}

variable "securityGroup" {
  description = "The name of a Network Security Group"
  type = string
  default = "AzureSecurityGroup"
}

variable "securityTag" {
  description = "The tag of a Network Security Group"
  type = string
  default = "VirtualNetwork"
}

variable "username"{
  type = string
  default = "WebAzure"
}

variable "password"{
  type = string
  default = "WebAzure-pw"
}

variable "vm_num"{
  type = number
  default = 1
}

variable "managed_disks_num"{
  type = number
  default = 1
}


