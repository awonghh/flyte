# Connection

Inject your AWS credentials to Flyte pod so it can access S3.
```
./refresh_aws_credential_flyte.sh
```

Set up connect to the kubernetes cluster
```
kubectl port-forward -n flyte deployment/flyte-backend-flyte-binary 8088:8088 8089:8089
```

## Submit
```
./submit.sh simple.py data_workflow
```
## Docker
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 491085430233.dkr.ecr.us-east-1.amazonaws.com


# Installation
On an EC2, set up Kube Config
```
aws eks update-kubeconfig --region us-east-1 --name unique-grunge-unicorn
```

## VPC
List VPC of EKS cluster
```
aws eks describe-cluster --name unique-grunge-unicorn --region us-east-1 --query "cluster.resourcesVpcConfig.vpcId" --output text
```
vpc-01f245f89c5541f8d

List EC2's 
```
TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`; MAC=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/mac`; curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC/vpc-id
```
vpc-01f245f89c5541f8d

The EKS and EC2 are on the same VPC.

## Network
EC2's private IP address: 10.9.100.127

## Credentials
For convenience of demo testing, use same user that creates the EKS cluster. 

On EC2, login with
```
aws sso login
```

Check with
```
aws sts get-caller-identity
```

Should see:
```
{
    "UserId": "AROAXEVXY7XM22CIZBHMF:awong@harbinger-health.com",
    "Account": "491085430233",
    "Arn": "arn:aws:sts::491085430233:assumed-role/AWSReservedSSO_RnDPowerUserAccess_d2b69c04809c3f0c/awong@harbinger-health.com"
}
```

This is not good:
```
{
    "UserId": "AROAXEVXY7XM376MV7CFG:i-0b311957371c0f797",
    "Account": "491085430233",
    "Arn": "arn:aws:sts::491085430233:assumed-role/Research_EC2_Instance_Role/i-0b311957371c0f797"
}
```
```
kubectl get nodes
NAME                  STATUS   ROLES    AGE    VERSION
i-03aa986ae977c17f5   Ready    <none>   6d6h   v1.34.3-eks-3c60543
i-06210331a42b522da   Ready    <none>   6d6h   v1.34.3-eks-3c60543
```

## Install helm
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```
Stick with Helm 3 because Helm 4 is new (Nov 2025. Major architecture update)

## Add Flyte Helm
```
helm repo add flyteorg https://flyteorg.github.io/flyte
helm repo update
```
Install Flyte dependencies. 
```
 helm install flyte-backend flyteorg/flyte-binary --namespace flyte
```

Check if the pod has spinned up.
```
kubectl get pods -n flyte -w
```

Install Flyte
```
helm install flyte-backend flyteorg/flyte-binary -n flyte -f sandbox-values.yaml
```
Update config file:
```
helm upgrade flyte-backend flyteorg/flyte-binary -n flyte -f sandbox-values.yaml
```