## Generic notes

### Pricing and Limitations

With AWS Fargate, you pay only for the amount of vCPU and memory resources that your pod needs to run. 
This includes the resources the pod requests in addition to a small amount of memory needed to run Kubernetes 
components alongside the pod. Pods running on Fargate follow the existing pricing model. vCPU and memory resources 
are calculated from the time your pod’s container images are pulled until the pod terminates, rounded up to the 
nearest second. A minimum charge for 1 minute applies. Additionally, you pay the standard cost for each EKS cluster 
you run, $0.20 per hour.

### There are currently a few limitations that you should be aware of

There is a maximum of 4 vCPU and 30Gb memory per pod.

Currently there is no support for stateful workloads that require persistent volumes or file systems.
No support for stateful workloads that need persistent volumes or file systems. 
Everything you run with Fargate is ephemeral and only lives for the time the pod lives. 
It is recommended that you use DynamoDB or S3 for pod data storage.

You cannot run Daemonsets, Privileged pods, or pods that use HostNetwork or HostPort.
The only load balancer you can use is an Application Load Balancer.
No GPU pod configurations available.

## Manual deployment steps

### EKS+Fargate

```eksctl create cluster --name demo-newsblog --region eu-west-1 --fargate
kubectl apply -f https://k8s.io/examples/application/deployment.yaml
kubectl expose deployment/nginx-deployment
kubectl port-forward nginx-deployment-CHANGE_ME 8080:80
```

### ECS + Fargate
```
aws ecs create-cluster --cluster-name fargate-cluster --region eu-west-1
aws ecs register-task-definition --cli-input-json file://task_definition.json --region eu-west-1
aws ecs create-service --region eu-west-1 --cluster fargate-cluster --service-name fargate-service --task-definition sample-fargate:1 --desired-count 2 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={assignPublicIp=ENABLED,subnets=[subnet-***],securityGroups=[sg-***]}"
```

## Automatic deployment

Requirements:
- kubectl
- helm
- terraform
- ansible-playbook
- helm

To deploy everything:
```bash
make
```

To redeploy applications:
```bash
make ansible
```

To connect to the cluster:
```bash
export AWS_PROFILE=default
export KUBECONFIG=./artifacts/ansible/kubeconfig
kubectl get ns
```
