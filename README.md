# EKS/ECS EC2 & Fargate demo module

A demo module to showcase four docker deployment scenarios on AWS:

* EKS on EC2 nodes
* EKS on Fargate
* ECS on EC2 nodes
* ECS on Fargate

It uses terraform for provisioning underlying infrastructure as well as running example Ansible pipelines for demo application build and deployment.

## Fargate overview

### Pricing

With AWS Fargate, you pay only for the amount of vCPU and memory resources that your pod needs to run. 
This includes the resources the pod requests in addition to a small amount of memory needed to run Kubernetes 
components alongside the pod. Pods running on Fargate follow the existing pricing model. vCPU and memory resources 
are calculated from the time your pod’s container images are pulled until the pod terminates, rounded up to the 
nearest second. A minimum charge for 1 minute applies. Additionally, you pay the standard cost for each EKS cluster 
you run, $0.10 per hour.

### Limitations

There is a maximum of 4 vCPU and 30Gb memory per pod.

Currently there is no support for stateful workloads that require persistent volumes or file systems.
No support for stateful workloads that need persistent volumes or file systems. 
Everything you run with Fargate is ephemeral and only lives for the time the pod lives. 
It is recommended that you use DynamoDB or S3 for pod data storage.

On EKS you cannot run Daemonsets, Privileged pods, or pods that use HostNetwork or HostPort.
The only load balancer you can use is an Application Load Balancer.
No GPU pod configurations available.

## Deployment

Prerequisites:

* Active AWS account with billing enabled
* [awscli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) installed
* Locally configured AWS profile with existing credentials. See Manual/Automated parts for required IAM permissions

We also expect two environment variables to be set (for both manual and automated deployment):

```bash
export AWS_PROFILE=default # Replace with your AWS profile name
export CLUSTER_NAME=demo
```

Please note, that we use eu-west-1 region by default. Tweak configuration if you need to change it.

### Manual

#### EKS+Fargate

Requirements:

* [eksctl](https://eksctl.io/introduction/installation/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

Steps:

```
eksctl create cluster --name ${CLUSTER_NAME} --region eu-west-1 --fargate
kubectl apply -f https://k8s.io/examples/application/deployment.yaml
kubectl expose deployment/nginx-deployment
kubectl port-forward nginx-deployment-CHANGE_ME 8080:80
```

See official [eksctl page](https://eksctl.io/) for more info.

#### ECS + Fargate

Steps:

```
aws ecs create-cluster --cluster-name ${CLUSTER_NAME} --region eu-west-1
aws ecs register-task-definition --cli-input-json file://examples/task_definition.json --region eu-west-1
aws ecs create-service --region eu-west-1 --cluster ${CLUSTER_NAME} --service-name fargate-service --task-definition sample-fargate:1 --desired-count 2 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={assignPublicIp=ENABLED,subnets=[subnet-***],securityGroups=[sg-***]}"
```

Notes:

* You need to specify your real Security Group Id and Public or Private Subnet.

### Automatic

Requirements:

* [make](https://en.wikipedia.org/wiki/Make_\(software\))
* [Terraform 0.12.x](https://www.terraform.io/downloads.html)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [Helm 2](https://v2.helm.sh/docs/using_helm/#install-helm)
* [Docker](https://docs.docker.com/get-docker/)
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

We use several community Terraform modules to provision resources:

* [VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc)
* [EKS](https://github.com/terraform-aws-modules/terraform-aws-eks)
* [ASG](terraform-aws-modules/autoscaling/aws) for ECS ec2
* [DynamoDB](https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table) for async demo

To deploy everything:
```bash
make
```

To deploy applications:
```bash
make ansible
```

To connect to the EKS EC2 cluster:
```bash
export KUBECONFIG=./.artifacts/${CLUSTER_NAME}-eks-ec2/kubeconfig
kubectl get ns
```

To connect to the EKS Fargate cluster:
```bash
export KUBECONFIG=./.artifacts/${CLUSTER_NAME}-eks-fargate/kubeconfig
kubectl get ns
```

Tips:

* If you see an admission webhook error while running ansible try again
* Destroy probably wouldn't work, you need to firstly manually delete kubernetes-created ALBs and ECS services
* "make ansible" doesn't rebuild ansible scripts. If you need to make changes to roles or playbooks run "make"
* Ingress has issues on EKS on Fargate due to [SG](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html) [limitations](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html). See [relevant ticket](https://github.com/kubernetes/ingress-nginx/issues/4888)
