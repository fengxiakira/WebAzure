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
  default = 2
}

variable "managed_disks_num"{
  type = number
  default = 2
}

variable "imageId"{
  type = string
  default = "/subscriptions/66f68753-1d99-469b-87b9-60a248f339a2/resourceGroups/WebAzureProject/providers/Microsoft.Compute/images/WebAzureProject-vm"
}


