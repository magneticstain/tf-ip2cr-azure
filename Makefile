# Makefile for Terraform

# Set the Terraform directory and backend configuration
TF_BACKEND_CONFIG = ./backend.tfvars

.PHONY: init validate plan apply auto-apply destroy auto-destroy

init:
	terraform workspace select ${TF_TGT_ACCOUNT} || terraform workspace new ${TF_TGT_ACCOUNT}
	terraform init -backend-config=$(TF_BACKEND_CONFIG)

validate:
	$(MAKE) init
	terraform validate

plan:
	$(MAKE) init
	terraform plan

apply:
	$(MAKE) init
	terraform apply

auto-apply:
	$(MAKE) init
	terraform apply -auto-approve

destroy:
	$(MAKE) init
	terraform destroy

auto-destroy:
	$(MAKE) init
	terraform destroy -auto-approve
