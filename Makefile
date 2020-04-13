AWS_PROFILE   = "gl"
ANSIBLE_TAGS  = "init,apps"
TF_VAR_FILE   = "demo.tfvars"

TF_PLAN_ARGS_ADDITIONAL=
define RAND_STR
$$(head /dev/random | LC_ALL=C tr -dc a-z0-9 | head -c 10)
endef

define RAND_STR
$$(head /dev/random | LC_ALL=C tr -dc a-z0-9 | head -c 10)
endef

define ANSIBLE_TARGET
-target module.cluster-ecs-ec2.null_resource.ansible-run \
-target module.cluster-ecs-fargate.null_resource.ansible-run \
-target module.cluster-eks-ec2.null_resource.ansible-run \
-target module.cluster-eks-fargate.null_resource.ansible-run \
-target aws_route53_record.apps \
-var ansible_run=true \
-var ansible_trigger=${RAND_STR} \
-var ansible_arguments=\"-t ${ANSIBLE_TAGS}\"
endef

.PHONY: all
all: terraform_init terraform_plan terraform_apply ansible

.PHONY: terraform_init
terraform_init:
	TF_VAR_aws_profile=${AWS_PROFILE} \
	  terraform init && symlinks -rc .terraform

.PHONY: terraform_plan
terraform_plan:
	TF_VAR_aws_profile=${AWS_PROFILE} \
	  terraform plan -parallelism=20 -out tfplan \
	  -var-file=${TF_VAR_FILE} \
	  ${TF_PLAN_ARGS} ${TF_PLAN_ARGS_ADDITIONAL}

.PHONY: terraform_apply
terraform_apply:
	TF_VAR_aws_profile=${AWS_PROFILE} \
	  terraform apply -parallelism=20 tfplan

.PHONY: ansible
ansible: TF_PLAN_ARGS=${ANSIBLE_TARGET}
ansible:
	$(MAKE) TF_PLAN_ARGS="${TF_PLAN_ARGS}" TF_PLAN_ARGS_ADDITIONAL="${TF_PLAN_ARGS_ADDITIONAL}" terraform_plan
	$(MAKE) terraform_apply
	$(MAKE) outputs

.PHONY: outputs
outputs:
	TF_VAR_aws_profile=${AWS_PROFILE} \
	  terraform refresh -parallelism=20 \
	  -var-file=${TF_VAR_FILE}
	terraform output
