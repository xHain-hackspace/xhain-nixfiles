init:
	tofu init --upgrade

apply: 
	tofu apply --var-file=<(sops -d secrets.tfvars)
