# base-aws-tf-template

A base template for new AWS-based Terraform plans.

## Supported Features

* S3 backend
* State locking via DynamoDB table
* Modules ready to go, out-of-the-box

## Usage

### Bootstrap the Prerequisite Resources

The plans use S3 as a backend and DynamoDB for state tracking. A standalone Terraform plan is included to generate the prerequisite infrastructure to support this:

```bash
cd ./utils/generate_backend/
terraform init && terraform apply
```

After Terraform completes its run, it should include the S3 bucket name and DynamoDB table name in the output; keep this handy as we will need it for the next step.

Example:

```bash
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

tf-ip2cr-metadata = [
  "tf-ip2cr-20240215195635031500000001",
  "tf-ip2cr",
]
```

#### Generate Backend Vars

Generate a `backend.tfvars` file in the project root and fill in the variables as appropriate.

```hcl
bucket = "<TF_S3_BUCKET_NAME>"
key    = "terraform.tfstate"

dynamodb_table = "<TF_DYNAMODB_TABLE_NAME>"
region = "<DEPLOY_REGION>"

```

Example:

```hcl
bucket = "tf-ip2cr-20240215195635031500000001"
key    = "terraform.tfstate"

dynamodb_table = "tf-ip2cr"
region = "us-east-1"

```

### Generate TF Vars

Generate a `terraform.tfvars` file and fill in the variables as approriate. The only variable required for this template is the `accounts` string map. This is used to support multi-account architectures.

Example:

```hcl
var_1 = "a"
accounts = {
  "jcarlsonpurcell-personal"            = "arn:aws:iam::509915386432:role/admin-cli",
  "jcarlsonpurcell-personal-testing"    = "arn:aws:iam::138277128026:role/admin-cli",
  "jcarlsonpurcell-personal-testing-2"  = "arn:aws:iam::685680125206:role/admin-cli"
}
```

### Plan and Apply Plans

A Make file has been included to make running these plans easier.

#### Prereqs

Set an environment variable called `TF_TGT_ACCOUNT` within your shell to the key of the account in `accounts` that you would like to deploy the plan to.

Example:

```bash
export TF_TGT_ACCOUNT="jcarlsonpurcell-personal"
```

#### Plan

```bash
make plan
```

#### Apply

```bash
make apply
```
