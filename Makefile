SHELL := /usr/bin/env bash

tf_dir = terraform

tf_init:
	cd $(tf_dir) && tofu init --upgrade

tf_plan: 
	cd $(tf_dir) && tofu apply --var-file=<(sops -d secrets.tfvars)

tf_apply: 
	cd $(tf_dir) && tofu apply --var-file=<(sops -d secrets.tfvars)

