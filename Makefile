
# Init variables
ENV 		?= dev
AWS_REGION  ?= us-east-1
IAC_DIR 	?= iac/envs/$(ENV)

# Variables for boostrap backend per environment
TF_STATE_BUCKET ?=  devopskit-$(ENV)-tfstate-123abc
TF_LOCK_TABLE   ?=  devopskit-$(ENV)-tflock

# Terraform options
TF_IN_AUTOMATE 	?= -input=false -no-color
TF_VAR_FLAGS 	?= -var="aws_region=$(AWS_REGION)"

# Utility
SHELL := /usr/bin/bash
.ONESHELL:
.SILENT: help

# Backend boostrap target
tf-backend-bootstrap: _assert-bucket
	@echo "S3 bucket for Terraform state"
	cd $(IAC_DIR)/bootstrap-s3
	terraform init ${TF_IN_AUTOMATE}
	terraform apply ${TF_IN_AUTOMATE} \
		-auto-approve \
		$(TF_VAR_FLAGS) \
		-var="bucket_name=$(TF_STATE_BUCKET)" \
		-var="environment=$(ENV)"

	@echo "DynamoDB table for Terraform state locking"
	cd ../bootstrap-dynamodb
	terraform init ${TF_IN_AUTOMATE}
	terraform apply ${TF_IN_AUTOMATE} \
		-auto-approve \
		$(TF_VAR_FLAGS) \
		-var="table_name=$(TF_LOCK_TABLE)" \
		-var="environment=$(ENV)"

	@echo "Backend bootstrap complete for environment '$(ENV)'. Now you can run 'make tf-backend-init ENV=$(ENV)' to initialize Terraform with the remote backend."

# Initialize Terraform with remote backend required backend.tf
tf-backend-init:
	[[ -d $(IAC_DIR) ]] || (echo "Error: IAC directory '$(IAC_DIR)' does not exist"; exit 1)
	cd $(IAC_DIR) && terraform init ${TF_IN_AUTOMATE} -migrate-state

tf-fmt:
	cd $(IAC_DIR) && terraform fmt -recursive

tf-validate: tf-fmt
	cd $(IAC_DIR) && terraform validate

tf-plan: tf-validate
	cd $(IAC_DIR) && terraform plan $(TF_IN_AUTOMATE) $(TF_VAR_FLAGS)

tf-apply:
	cd $(IAC_DIR) && terraform apply $(TF_IN_AUTOMATE) -auto-approve $(TF_VAR_FLAGS)

tf-up: tf-plan
	cd $(IAC_DIR) && terraform apply $(TF_IN_AUTOMATE) -auto-approve $(TF_VAR_FLAGS)

tf-destroy:
	cd $(IAC_DIR) && terraform destroy $(TF_IN_AUTOMATE) -auto-approve $(TF_VAR_FLAGS)

tf-output:
	cd $(IAC_DIR) && terraform output $(TF_IN_AUTOMATE) -json | jq .

clean:
	@echo "Cleaning Terraform local files..."
	find iac/envs -type d -name ".terraform" -exec rm -rf {} +
	find iac/envs -type f \( -name ".terraform.lock.hcl" -o -name "terraform.tfstate*" -o -name "*.tfplan" -o -name "crash.log*" \) -delete
	@echo "Clean complete."

_assert-bucket:
	@if [ -z "$(TF_STATE_BUCKET)" ]; then \
		echo "Error: TF_STATE_BUCKET is required (must be globally unique)"; \
		exit 1; \
	fi

help:
	@echo ""
	@echo "Makefile for Devopskit Terraform IAC"
	@echo "----------------------"
	@echo "Usage: make <target> [ENV=dev|stage|prod (default: dev)] [AWS_REGION=<aws-region> (default: us-east-1)]"
	@echo ""
	@echo "Targets:"
	@echo ""
	@echo "Bootstrap remote state:"
	@echo "  make tf-backend-bootstrap ENV=dev TF_STATE_BUCKET=devopskit-$(ENV)-tfstate-<unique>  # creates S3+DynamoDB"
	@echo "  make tf-backend-init ENV=dev                                 						  # terraform init (remote backend)"
	@echo ""
	@echo "Provision infra (per env):"
	@echo "  make tf-fmt ENV=dev                Format Terraform files"
	@echo "  make tf-validate ENV=dev           Validate Terraform configuration"
	@echo "  make tf-plan ENV=dev               Generate and show Terraform plan"
	@echo "  make tf-destroy ENV=dev            Destroy Terraform-managed infrastructure"
	@echo "  make tf-output ENV=dev             Show Terraform output values"
	@echo ""
	@echo "Convenience (do it all):"
	@echo "  make tf-up ENV=dev   # plan + apply"
	@echo ""
	@echo "Other:"
	@echo "  make clean           # clean local Terraform files (does not touch remote state)"
	@echo ""
