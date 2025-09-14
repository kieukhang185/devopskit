# Makefile for Devopskit Terraform IAC
# Init variables
ENV 		?= dev
AWS_REGION  ?= ap-south-1
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

# Ensure TF_STATE_BUCKET is set
_assert-bucket:
	@if [ -z "$(TF_STATE_BUCKET)" ]; then \
		echo "Error: TF_STATE_BUCKET is required (must be globally unique)"; \
		exit 1; \
	fi

# Confirm destructive action
_assert-confirm:
	@read -p "Are you sure you want to proceed? This action is destructive. Type 'yes' to confirm: " CONFIRM; \
	if [ "$$CONFIRM" != "yes" ]; then \
		echo "Error: This action is destructive. To proceed, set CONFIRM=yes"; \
		exit 1; \
	fi

# Empty and delete S3 bucket
_empty-versioned-bucket:
	@set -eou pipefail; \
	if ! aws s3api head-bucket --bucket "$(TF_STATE_BUCKET)" 2>/dev/null; then \
		echo "Bucket '$(TF_STATE_BUCKET)' does not exist, nothing to delete."; \
		exit 0; \
	fi; \

	echo "Emptying bucket 's3://$(TF_STATE_BUCKET)'..."; \
	aws s3 rm "s3://$(TF_STATE_BUCKET)" --recursive || true; \
	while : ; do \
		json=$$(aws s3api list-object-versions --bucket "$(TF_STATE_BUCKET)" --output json || true); \
		vers=$$(echo "$$json" | jq -r '.Versions // []'); \
		mark=$$(echo "$$json" | jq -r '.DeleteMarkers // []'); \
		if [ "$$vers" = "[]" ] && [ "$$mark" = "[]" ]; then \
			echo "Bucket '$(TF_STATE_BUCKET)' is now empty."; break; \
		fi; \
		del=$$(jq -nc --argjson v "$$vers" --argjson m "$$mark" '{Objects: ($$v + $$m | map({Key: .Key, VersionId: .VersionId})), Quiet: false'}); \
		echo "$$del" | aws s3api delete-objects --bucket "$(TF_STATE_BUCKET)" --delete file:///dev/stdin >/dev/null || true; \
	done; \

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

# TODO: Check if EBS encryption is already enabled and skip if so
# Enable default EBS encryption (per env)
tf-ebs-encryption:
	@echo "Enabling default EBS encryption in region '$(AWS_REGION)' for environment '$(ENV)'..."
	@[ -d "repo/iac/envs/$(ENV)/ebs-encryption" ] || (echo "Error: IAC directory 'iac/envs/$(ENV)/ebs-encryption' does not exist"; exit 1)
	cd iac/envs/$(ENV)/ebs-encryption
		terraform init ${TF_IN_AUTOMATE} -upgrade
		terraform apply ${TF_IN_AUTOMATE} \
		-auto-approve \
		-var="region=$(AWS_REGION)"

# Destroy backend (S3 + DynamoDB)
destroy-backend-s3: _assert-bucket _assert-confirm
	@echo "Destroying S3 bucket '$(TF_STATE_BUCKET)' and all its contents..."
	@[ -d "$(IAC_DIR)/bootstrap-s3" ] || (echo "Error: IAC directory '$(IAC_DIR)' does not exist"; exit 1)
	$(MAKE) _empty-versioned-bucket
	cd $(IAC_DIR)/bootstrap-s3; \
		terraform init ${TF_IN_AUTOMATE}
		terraform destroy ${TF_IN_AUTOMATE} \
			-auto-approve \
			$(TF_VAR_FLAGS) \
			-var="bucket_name=$(TF_STATE_BUCKET)" \
			-var="environment=$(ENV)"

# Destroy backend DynamoDB
destroy-backend-dynamodb: _assert-confirm
	@echo "Destroying DynamoDB table '$(TF_LOCK_TABLE)'..."
	@[ -d "$(IAC_DIR)/bootstrap-dynamodb" ] || (echo "Error: IAC directory '$(IAC_DIR)' does not exist"; exit 1)
	cd $(IAC_DIR)/bootstrap-dynamodb; \
		terraform init ${TF_IN_AUTOMATE}
		terraform destroy ${TF_IN_AUTOMATE} \
			-auto-approve \
			$(TF_VAR_FLAGS) \
			-var="table_name=$(TF_LOCK_TABLE)" \
			-var="environment=$(ENV)"

tf-backend-destroy: destroy-backend-s3 destroy-backend-dynamodb
	@echo "Backend destruction complete for environment '$(ENV)'."
	@echo "Note: This does not delete any Terraform-managed infrastructure. To destroy that, run 'make tf-destroy ENV=$(ENV)' first."

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

tf-tags:
	cd $(IAC_DIR) && terraform init  -upgrade >/dev/null ; \
	terraform output $(TF_IN_AUTOMATE) required_tags_preview || true

clean:
	@echo "Cleaning Terraform local files..."
	find iac/envs -type d -name ".terraform" -exec rm -rf {} +
	find iac/envs -type f \( -name ".terraform.lock.hcl" -o -name "terraform.tfstate*" -o -name "*.tfplan" -o -name "crash.log*" \) -delete
	@echo "Clean complete."

help:
	@echo ""
	@echo "Makefile for Devopskit Terraform IAC"
	@echo "----------------------"
	@echo "Usage: make <target> [ENV=dev|stage|prod (default: dev)] [AWS_REGION=<aws-region> (default: ap-south-1)]"
	@echo ""
	@echo "Targets:"
	@echo ""
	@echo "Bootstrap remote state:"
	@echo "  make tf-backend-bootstrap ENV=dev TF_STATE_BUCKET=devopskit-$(ENV)-tfstate-<unique>	# creates S3+DynamoDB"
	@echo "  make tf-backend-init ENV=dev								# terraform init (remote backend)"
	@echo "  make destroy-backend-s3 ENV=dev							# destroy S3 bucket and contents"
	@echo "  make destroy-backend-dynamodb ENV=dev							# destroy DynamoDB table"
	@echo "  make tf-backend-destroy ENV=dev 							# destroy all backend resources"
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
