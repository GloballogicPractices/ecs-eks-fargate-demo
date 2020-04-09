ANSIBLE_TAGS  = "init,demo-eks-ec2,demo-eks-fargate,demo-fargate"
ARTIFACTS_DIR = "./artifacts"

TF_PLAN_ARGS_ADDITIONAL=
define RAND_STR
$$(head /dev/random | LC_ALL=C tr -dc a-z0-9 | head -c 10)
endef

define RAND_STR
$$(head /dev/random | LC_ALL=C tr -dc a-z0-9 | head -c 10)
endef

define ANSIBLE_TARGET
-target null_resource.ansible-run \
-var ansible_run=true \
-var ansible_trigger=${RAND_STR} \
-var ansible_arguments=\"-t ${ANSIBLE_TAGS}\"
endef

.PHONY: all
all: terraform_init terraform_plan terraform_apply ansible

.PHONY: terraform_init
terraform_init:
	terraform init && symlinks -rc .terraform

.PHONY: terraform_plan
terraform_plan:
	terraform plan -parallelism=20 -out tfplan ${TF_PLAN_ARGS} ${TF_PLAN_ARGS_ADDITIONAL}

.PHONY: terraform_apply
terraform_apply:
	terraform apply -parallelism=20 tfplan

.PHONY: ansible
ansible: TF_PLAN_ARGS=${ANSIBLE_TARGET}
ansible:
	$(MAKE) TF_PLAN_ARGS="${TF_PLAN_ARGS}" TF_PLAN_ARGS_ADDITIONAL="${TF_PLAN_ARGS_ADDITIONAL}" terraform_plan
	$(MAKE) terraform_apply
