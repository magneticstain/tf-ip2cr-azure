# tf-ip2cr-azure

Terraform plans for generating ephemeral test resources for testing ip2cr in GCP.

## Summary

Currently, this set of terraform plans:

1. Creates a Virtual Machine with a public IP address
1. Starts a new Load Balancer that fronts the created VM
1. Generates a Front Door CDN profile with the VM as the origin

This should provide several vectors for testing IP2CR.

## Usage

### Login via Azure CLI

If needed, authenticate Azure CLI to the target subscription:

Example:

```bash
az login
```

[Terraform Docs Reference](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli)

### Bootstrap the Prerequisite Resources

The plans use Azure Storage as a backend. A standalone Terraform plan is included to generate the prerequisite infrastructure to support this:

```bash
cd ./utils/generate_backend/
terraform init && terraform apply
```

After Terraform completes its run, it should include the several pieces of information in the output, including the:

* Resource Group Name
* Storage Account Name
* Storage Container Name

Keep this handy as we will need it for the next step.

Example:

```bash
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

tf-backend-metadata = [
  "tf-backend-ip-2-cloudresource",
  "tfbackendip2cr6n2f0",
  "tf-backend-ip-2-cloudresource",
]

```

#### Generate Backend Vars

Generate a `backend.tfvars` file in the project root and fill in the variables as appropriate.

```hcl
resource_group_name  = "<RESOURCE_GRP_NAME>"
storage_account_name = "<STORAGE_ACCT_NAME>"
container_name       = "<STORAGE_CONTAINER_NAME>"
key                  = "terraform.tfstate"
```

Example:

```hcl
resource_group_name  = "tf-backend-ip-2-cloudresource"
storage_account_name = "tfbackendip2cr6n2f0"
container_name       = "tf-backend-ip-2-cloudresource"
key                  = "terraform.tfstate"
```

### Set TF Vars

Generate a `terraform.tfvars` file and fill in the variables as appropriate.

```hcl
subscription_id = "<AZURE_SUBSCRIPTION_ID>"
```

Example:

```hcl
subscription_id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
```

### Plan and Apply Plans

A Make file has been included to make running these plans easier. There is no need to initialize the environment, or any other prerequesite work, prior to running these commands.

#### Plan

```bash
make plan
```

#### Apply

```bash
make apply
```
