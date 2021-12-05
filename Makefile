red := $(shell tput setaf 1)
green := $(shell tput setaf 2)
reset := $(shell tput sgr0)
tfversion = $(shell terraform version | awk 'NR==1{gsub("v0.",""); print $$2}')
tfrequired = 13.1
ARM_CHECK := $(shell uname -m)
ifneq (${ARM_CHECK},arm64)
	VAGRANT_ISO_ARM = false
else
	VAGRANT_ISO_ARM = true
endif
TFERR := $(shell echo "${tfversion} < ${tfrequired}" | bc -l)
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
VAGRANT_CWD = "${ROOT_DIR}/vagrant"
TF_DIR = "${ROOT_DIR}/terraform"
EXEC_LIST = vagrant terraform awk
CHECKS := $(foreach exec,$(EXEC_LIST),\
        $(if $(shell command -v $(exec) 2> /dev/null),binary exists,$(error $(red)"$(exec) binary could not be found"$(reset))))
VAG_HDIR := $(wildcard $(VAGRANT_CWD)/.vagrant)
TF_HDIR := $(wildcard $(TF_DIR)/.terraform)
define NOTF_BODY
 Done!

 For services UI:

=> Vault:    http://localhost:8200, pwd: root
=> Consul:   http://localhost:8500
=> Nomad:    http://localhost:4646
endef

define BODY
 Done!

 Add "127.0.0.1 faasd-gateway" to your "/etc/hosts\" file to reach Openfaasd (same for Prometheus and Grafana).

 For services UI:

=> Vault:               http://localhost:8200, pwd: root
=> Consul:              http://localhost:8500
=> Nomad:               http://localhost:4646
=> Minimal services:    http://localhost:8080
=> OpenFaas:            http://faasd-gateway:8080, user/pwd: admin/password
=> Prometheus:          http://prometheus:8080
=> Grafana:             http://grafana:8080, user/pwd: admin/admin
endef

export NOTF_BODY BODY

## $ make => or "$ make all" runs some checks and deploys the lab (if TERRAFORM_LABS env var is not set to false, it will apply Terraform code too)
all: binaries_check validation vagrant terraform

## $ make binaries_check => performs Terraform version check
binaries_check:
    
	@: $(info $(green)Checking Terraform binary version..$(reset))
ifeq ($(TFERR), 1)
	$(error $(red)Terraform version required  >= v0.${tfrequired}$(reset))
endif

## $ make validation => performs Vagrant and Terraform code validation
validation:

	$(info $(green)Performing Vagrant and Terraform code validation..$(reset))
	@cd $(VAGRANT_CWD) && vagrant validate
ifneq ($(TERRAFORM_LABS),false)
  ifeq ("$(TF_HDIR))", "")
	@cd $(TF_DIR) && echo "Now Terraform code validation.." && terraform validate
  endif
endif

## $ make vagrant => simply "vagrant up" (avoiding Terraforming too)
vagrant:

ifeq ($(VAGRANT_VMWARE), true)
	@cd $(VAGRANT_CWD) && ARM_CHECK=$(ARM_CHECK) vagrant up --provider vmware_fusion
else
	@cd $(VAGRANT_CWD) && vagrant up
endif
ifneq ($(TERRAFORM_LABS),false)
	@echo "$(green)$$NOTF_BODY$(reset)"
endif

## $ make provision => simply "vagrant provision"
provision: v-prechecks

	@cd $(VAGRANT_CWD) && vagrant provision 
ifneq ($(TERRAFORM_LABS),false)
	@echo "$(green)$$NOTF_BODY$(reset)"
endif

## $ make terraform => simply "terraform apply"
terraform:
	
	cd $(TF_DIR) && terraform init && terraform plan && terraform apply -var="faasd_arm=$(VAGRANT_ISO_ARM)" -auto-approve
	@echo "$(green)$$BODY$(reset)"

## $ make tests => if VM has been provisioned correctly, runs some test to Hashicorp endpoints
tests: v-prechecks
	
	@cd $(VAGRANT_CWD) && TAGS_ONLY="tests" vagrant provision

## $ make dockerlogin => if DOCKER_USER and DOCKER_PASS environment variables are set, it let OpenFAAS login to docker hub registry
dockerlogin: v-prechecks

	@cd $(VAGRANT_CWD) && vagrant ssh -c "echo $(DOCKER_PASS) | docker login -u $(DOCKER_USER) --password-stdin && mkdir -p /var/lib/faasd/.docker && cp .docker/config.json /var/lib/faasd/.docker/config.json"

## $ make clean => destroys and cleans up everything (vagrant and terraform files and directories)
clean:
	
	@echo "$(green)Vagrant destroy..$(reset)"
	@-cd $(VAGRANT_CWD) && vagrant destroy -f && rm -r .vagrant
	@echo "$(green)Terraform files cleaning..$(reset)"
	@-cd $(TF_DIR) && rm -f terraform.tfstate && rm -f terraform.tfstate.backup && rm -rf .terraform
	@echo "$(green)Done.$(reset)"

## $ make ssh => ssh into the created VM
ssh: v-prechecks

	@cd $(VAGRANT_CWD) && vagrant ssh

v-prechecks:
    
ifeq ("$(VAG_HDIR))", "")
	@: $(error $(red)No .vagrant folder found$(reset))
endif

t-prechecks:

ifeq ("$(TF_HDIR))", "")
	@: $(error $(red)No .terraform folder found$(reset))
endif


.PHONY: help vagrant terraform test ssh
help: Makefile
	@echo
	@echo " 	usage: make <command> <args>"
	@echo " "
	@echo " commands available:"
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ \n\t/'
	@echo
