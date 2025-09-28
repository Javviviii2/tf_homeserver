export REPO_NAME=homeserver-talos-infra

.PHONY: help
help: ## Show this help
	@echo "Usage: make ENVNAME=<environment> <command>"
	@echo ""
	@echo "Available environments: homeserver"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

ifndef ENVNAME
# Only check ENVNAME for commands that need it
NEED_ENV_COMMANDS = init validate plan plan-out apply apply-auto destroy output console taint-vms show-kubeconfig save-kubeconfig
ifneq ($(filter $(NEED_ENV_COMMANDS),$(MAKECMDGOALS)),)
$(error ENVNAME is not set. Use: make ENVNAME=homeserver <command>)
endif
endif

.PHONY: clean
clean: ## Clean terraform files
	rm -rf .terraform
	rm -f terraform.tfstate*
	rm -f tfplan*

.PHONY: init
init: ## Initialize terraform
	terraform init

.PHONY: validate
validate: ## Validate terraform configuration
	terraform validate

.PHONY: fmt
fmt: ## Format terraform files
	terraform fmt -recursive

.PHONY: plan
plan: ## Plan terraform changes
	terraform plan -var "envname=$(ENVNAME)" -var-file=envs/$(ENVNAME).tfvars

.PHONY: plan-out
plan-out: ## Plan terraform changes and save to file
	terraform plan -var "envname=$(ENVNAME)" -var-file=envs/$(ENVNAME).tfvars -out=tfplan

.PHONY: apply
apply: ## Apply terraform changes
	terraform apply -var "envname=$(ENVNAME)" -var-file=envs/$(ENVNAME).tfvars

.PHONY: apply-auto
apply-auto: ## Apply terraform changes automatically
	terraform apply -auto-approve -var "envname=$(ENVNAME)" -var-file=envs/$(ENVNAME).tfvars

.PHONY: destroy
destroy: ## Destroy terraform resources
	terraform destroy -var "envname=$(ENVNAME)" -var-file=envs/$(ENVNAME).tfvars

.PHONY: output
output: ## Show terraform outputs
	terraform output

.PHONY: console
console: ## Open terraform console
	terraform console -var "envname=$(ENVNAME)" -var-file=envs/$(ENVNAME).tfvars

.PHONY: graph
graph: ## Generate dependency graph
	terraform graph | dot -Tpng > graph.png

.PHONY: taint-vms
taint-vms: ## Taint all virtual machines for recreation
	terraform state list | grep 'libvirt_domain.talos_cluster' | xargs -r terraform taint

.PHONY: show-kubeconfig
show-kubeconfig: ## Show kubeconfig content
	terraform output -raw kube_config | jq -r '.kubeconfig_raw'

.PHONY: save-kubeconfig
save-kubeconfig: ## Save kubeconfig to ~/.kube/config
	@mkdir -p ~/.kube
	terraform output -raw kube_config | jq -r '.kubeconfig_raw' > ~/.kube/config
	@chmod 600 ~/.kube/config
	@echo "Kubeconfig saved to ~/.kube/config"