#!/usr/bin/bash

# Usage:
# ./scripts/tf.sh dev plan
# ./scripts/tf.sh stage apply
# ./scripts/tf.sh prod destroy

set -euo pipefail

ENV="${1:-dev}"
CMD="${2:-plan}"
AWS_REGION="${3:-us-east-1}"

IAC_DIR="iac/envs/${ENV}"

if [[ ! -d "${IAC_DIR}" ]]; then
  echo "Error: Environment directory '${IAC_DIR}' does not exist."
  exit 1
fi

pushd "${IAC_DIR}" > /dev/null

export TF_IN_AUTOMATION=1
TF_FLAGS=(-input=false -no-color -var="aws_region=${AWS_REGION}")

case "${CMD}" in
  init)
    terraform "${TF_FLAGS[@]}" init -migrate-state
    ;;
  fmt)
    terraform fmt -recursive -check
    ;;
  validate)
    terraform -input=false validate
    ;;
  plan)
    terraform "${TF_FLAGS[@]}" plan
    ;;
  apply)
    terraform "${TF_FLAGS[@]}" apply -auto-approve
    ;;
  destroy)
    terraform "${TF_FLAGS[@]}" destroy -auto-approve
    ;;
  outputs)
    terraform -input=false output -json | jq .
    ;;
  *)
    cho "Unknown command: ${CMD}"
    echo "Usage: $0 {dev|stage|prod} {plan|apply|destroy} [aws-region]"
    exit 1
    ;;
esac

popd >/dev/null
