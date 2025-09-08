
# Init variables
ENV 		?= dev
AWS_REGION  ?= us-east-1
IAC_DIR 	?= iac/envs/$(ENV)

# Variables for boostrap backend per environment
TF_STATE_BUCKET ?=  devopskit-$(ENV)-tfstate-123abc
TF_LOCK_TABLE  ?=  devopskit-$(ENV)-tflock

# Terraform options
TF_IN_AUTOMATE 	?= -input=false -no-color
TF_VAR_FLAGS 	?= -var=region=$(AWS_REGION)

# Utility
SHELL := /usr/bin/bash
.ONESHELL:
.SILENT: help

# Backend boostrap target
tf-backend-boostrap: _assert-bucket
	# S3 bucket for Terraform state
	cd $(IAC_DIR)/boostrap-s3
	terraform ${TF_IN_AUTOMATE} init
	terraform ${TF_IN_AUTOMATE} apply \
		-auto-approve \
		$(TF_VAR_FLAGS) \
		-var=bucket_name=$(TF_STATE_BUCKET) \
		-var=environment=$(ENV)"

	# DynamoDB table for Terraform state locking
	cd ../boostrap-dynamodb
	terraform ${TF_IN_AUTOMATE} init
	terraform ${TF_IN_AUTOMATE} apply \
		-auto-approve \
		$(TF_VAR_FLAGS) \
		-var=table_name=$(TF_LOCK_TABLE) \
		-var=environment=$(ENV)

	@echo "Backend bootstrap complete for environment '$(ENV)'. Now you can run 'make tf-backend-init ENV=$(ENV)'' to initialize Terraform with the remote backend."

# Initialize Terraform with remote backend required backend.tf
tf-backend-init:
	[[ -d $(IAC_DIR) ]] || (echo "Error: IAC directory '$(IAC_DIR)' does not exist"; exit 1)
	cd $(IAC_DIR) && terraform ${TF_IN_AUTOMATE} init -migrate-state

tf-fmt:
	cd $(IAC_DIR) && terraform fmt -recursive

tf-validate: tf-fmt
	cd $(IAC_DIR) && terraform $(TF_IN_AUTOMATE) validate

tf-plan: tf-validate
	cd $(IAC_DIR) && terraform $(TF_IN_AUTOMATE) plan $(TF_VAR_FLAGS)

tf-apply:
	cd $(IAC_DIR) && terraform $(TF_IN_AUTOMATE) apply -auto-approve $(TF_VAR_FLAGS)

tf-up: tf-plan
	cd $(IAC_DIR) && terraform $(TF_IN_AUTOMATE) apply -auto-approve $(TF_VAR_FLAGS)

tf-destroy:
	cd $(IAC_DIR) && terraform $(TF_IN_AUTOMATE) destroy -auto-approve $(TF_VAR_FLAGS)

tf-output:
	cd $(IAC_DIR) && terraform $(TF_IN_AUTOMATE) output -json | jq .

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
