# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, Packer is used to build an image and Terraform is used to deploy infrastructure as code on Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
1. Log in your Azure account
 ```bash
az login
 ```
2. Deploy azure policy 
 - Create a policy definition
```bash
az policy definition create --name tagging-policy --rules azurepolicy.rules.json --params azurePolicy.parm.json
```
- Create a policy assignment
```bash
az policy assignment create --name tagging-policy --policy tagging-policy --params "{ \"tagName\": 
    { \"value\": \"YourTag\"  } }"
```
- Check whether your policy assignment is successful
```bash
az policy assignment list
```
3.  Run Packer
```bash
packer build
```
4. Customize 
  You can customize several things in variables.tf 
  Customize default and description as you like.
  <br />
  e.g.
  ```json
variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  type = string
  default = "WebAzureProject-Terraform"
}
```

4. Run Terraform
```bash
terraform init
```
```bash
terraform apply "solution"
```

### Output
Please check the following docs:
- Sample Successful Azure Policy assignment is **azPolicyOutput1.jpg** and **azPolicyOutput2.jpg**
- Sample successful **terraform apply** is **terraform apply output**

