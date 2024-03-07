variable "subscription_id" {
    type = string
    description = "ID of the Azure Subscrip[tion to install the test resources in"
    default = ""
}

variable "ssh_key_file" {
    type = string
    description = "File path of the SSH public key that should be used with the test VM (Azure requires it for creation)"
    default = ""
}