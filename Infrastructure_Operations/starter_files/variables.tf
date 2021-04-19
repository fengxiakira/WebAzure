variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  type = string
  default = "WebAzureProject"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  type = string
  default = "eastus"
}

variable "securityAllowVM" {
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
  default = "azure-test1"
}

variable "password"{
  type = string
  default = "azure-test1-pw"
}


