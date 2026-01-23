## 📌 Architecture Overview

**High-level flow**

```
Terraform (IaC)
   │
   ├── Provision AWS Infra (EKS, RDS, IAM, ECR)
   │
   ├── Export Infra Outputs
   │
   ├── CI Pipeline
   │     ├── Build Docker Images
   │     ├── Push to Amazon ECR
   │
   └── CD Pipeline
         ├── Update Kubernetes Deployments
         └── Trigger Rolling Updates

```

## 🚀 Provision AWS Infra 

This repository provisions **AWS infrastructure using Terraform** with a **remote S3 backend** for secure and collaborative state management.

The project follows a **multi-environment IaC layout**, with **`dev`** as the active environment.

## 🗺️ Application Architecture Diagram

<img width="1536" height="800" alt="ChatGPT Image Jan 22, 2026, 08_55_49 PM" src="https://github.com/user-attachments/assets/1e33ef21-e28b-400c-9109-05f40d0e75e2" />

> 🧠 **Architecture Highlights**
>
> * Amazon **EKS** for container orchestration
> * Amazon **RDS** for managed database services
> * Modular Terraform design for reusability
> * Remote backend for state locking & versioning

## ✅ Prerequisites

Before proceeding, ensure the following tools and permissions are available:

### 🛠️ Tools

* **Terraform ≥ 1.6**
* **AWS CLI ≥ v2**
* **kubectl** (for EKS access)

### 🔐 AWS IAM Permissions

Your AWS identity (IAM user or assumed role) must be able to:

* Create & manage **S3 buckets**
* Provision **EKS, RDS, IAM, VPC**, and supporting resources
* Read/write Terraform state objects

<img width="848" height="155" alt="image" src="https://github.com/user-attachments/assets/7c58ddb9-5e8d-4660-9927-b0673e1d125d" />

## 📁 Directory Structure (Relevant)

```text
Iac/
├── env
│   └── dev
│       ├── backend.config.hcl
│       ├── data.tf
│       ├── locals.tf
│       ├── main.tf
│       ├── output.tf
│       ├── provider.tf
│       └── varible.tf
└── vars
    └── dev.terraform.tfvars
```

> 🧩 **Design Approach**
>
> * `env/dev/` → Environment-specific orchestration
> * `vars/` → Environment-specific values (kept separate for safety)

## 🪣 Step 1: Create S3 Backend Bucket (One-Time Setup)

Terraform state is stored remotely in **Amazon S3** to support:

* Team collaboration
* State versioning
* Disaster recovery

Create the bucket **once** before running Terraform:

```bash
aws s3api create-bucket \
  --bucket tfstate-dev-<unique-name> \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1
```

### 🔄 Enable Versioning (Highly Recommended)

```bash
aws s3api put-bucket-versioning \
  --bucket tfstate-dev-<unique-name> \
  --versioning-configuration Status=Enabled
```

## 🔍 Step 2: Initialize & Deploy Infrastructure via Infra Pipeline

Instead of running Terraform manually from your local machine, **infrastructure provisioning is fully automated using the GitHub Actions Infra Pipeline**.

### 📄 Backend Configuration Verification

Before triggering the pipeline, verify that the backend configuration file contains correct values:

📄 **`env/dev/backend.config.hcl`**

```hcl
bucket  = "tfstate-dev-<unique-name>"
key     = "eks/dev/terraform.tfstate"
region  = "ap-south-1"
encrypt = true
```

Ensure the S3 bucket exists and versioning is enabled.

### ⚙️ Trigger Infra Creation Workflow

Once the backend configuration is verified:

* Update the **Infra Pipeline IAM Role ARN** in the workflow file
* Commit the changes to the repository
* Trigger the [**Infrastructure Creation Workflow**](https://github.com/HARNESHA/tohands-assignment/actions/workflows/infra-pipeline.yaml)

### 🔐 Required Role Update Before Running Pipeline

Before executing the workflow, ensure the **Terraform Infra Pipeline Role** ARN is updated in the workflow file:

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::<ACCOUNT_ID>:role/GitHubAction-Terraform-InfraRole
    aws-region: ap-south-1
```

Replace `<ACCOUNT_ID>` with your AWS Account ID.

The Infra Pipeline will automatically:

* 🔐 Configure the remote S3 backend
* 📦 Download Terraform providers
* 🧱 Initialize Terraform modules
* 🏗️ Provision AWS infrastructure
* ✅ Validate and apply Terraform configuration

### 📤 Terraform Outputs

After successful workflow execution, Terraform outputs (EKS Cluster Name, RDS Endpoint, VPC details, etc.) are printed in pipeline logs and stored in remote state.

Terraform will:

* Provision AWS infrastructure
* Persist state securely in S3
* Output important values (EKS cluster name, endpoints, etc.)

> 📝 **Note**
> Save the Terraform outputs — they are required for:
>
> * Kubernetes access
> * CI/CD pipelines
> * Application deployment

## ☸️ Step 3: Access EKS | Configure ALB Ingress

Update kubeconfig:

```bash
aws eks update-kubeconfig \
  --name <your-eks-cluster-name> \
  --region ap-south-1
kubectl cluster-info
```
<img width="1848" height="130" alt="image" src="https://github.com/user-attachments/assets/624147b5-bc63-41ff-a3c6-59779325a842" />

Deploy an [ALB Ingress Controller](https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html).

## 🚀 CI/CD & Application Workflow (Automated)

After infrastructure deployment, take a notes of **Terraform outputs** to configure env in workflows.

### ⚙️ GitHub Actions – Configuration

* The following environment variables needs to be configured in both relative ci-cd workflow & rollback workflow to make automated deployment.
* The pipeline iam role should be mapped to the EKS cluster authentication layer.

```
env:
  AWS_REGION: ap-south-1
  ECR_REGISTRY: xxx.dkr.ecr.ap-south-1.amazonaws.com
  ECR_BACKEND_REPO: assignment-backend
  ECR_FRONTEND_REPO: assignment-frontend
  EKS_CLUSTER_NAME: assignment-cluster
  VITE_API_URL: http://assignment-api.jay.cloud-ip
  IMAGE_TAG: ${{ github.sha }}
```
```
  - name: Configure AWS credentials
    uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::xxx:role/GitHubAction-AssumeRoleWithAction
      aws-region: ${{ env.AWS_REGION }}
```

### CI-CD Pipeline (Automated)

* Once the all env & workflow configuration is done click on the below links to trigger the workflows.
* Manual trigger (workflow dispatch)
* [CI-Pipeline workflow](https://github.com/HARNESHA/tohands-assignment/actions/workflows/ci-pipeline.yaml)
* [CD-Pipeline workflow](https://github.com/HARNESHA/tohands-assignment/actions/workflows/cd-pipeline.yaml) 

### 🧪 CI Phase – Image Lifecycle

During CI execution:

* Backend and frontend Docker images are built
* Images are versioned using:

  * Git commit SHA
  * `latest` tag
* Images are pushed to **Amazon ECR**

### ☸️ CD Phase – Application Deployment

After image build:

* Kubernetes deployments are updated automatically
* Rolling updates are triggered in EKS
* Previous versions are retained as revisions

## Step 3: backend application secret with below commads.

```bash
kubectl create secret generic backend-secret \
    --from-literal=DOMAIN=localhost \
    --from-literal=ENVIRONMENT=local \
    --from-literal=PROJECT_NAME="Full Stack FastAPI Project" \
    --from-literal=STACK_NAME=full-stack-fastapi-project \
    --from-literal=BACKEND_CORS_ORIGINS="http://localhost,http://localhost:5173,http://assignment.jay.cloud-ip" \
    --from-literal=SECRET_KEY=harnesha2244 \
    --from-literal=FIRST_SUPERUSER=harnesha22@gmail.com \
    --from-literal=FIRST_SUPERUSER_PASSWORD=harnesha22 \
    --from-literal=USERS_OPEN_REGISTRATION=True \
    --from-literal=SMTP_HOST= \
    --from-literal=SMTP_USER= \
    --from-literal=SMTP_PASSWORD= \
    --from-literal=EMAILS_FROM_EMAIL=info@example.com \
    --from-literal=SMTP_TLS=True \
    --from-literal=SMTP_SSL=False \
    --from-literal=SMTP_PORT=587 \
    --from-literal=POSTGRES_SERVER=database-1.xxx.ap-south-1.rds.amazonaws.com \
    --from-literal=POSTGRES_PORT=5432 \
    --from-literal=POSTGRES_DB=assignmentdevdb \
    --from-literal=POSTGRES_USER=postgres \
    --from-literal=POSTGRES_PASSWORD= \
 --dry-run=client -o yaml > secret.yaml
 kubectl apply -f secret.yaml
```
## Step 4: Access the Application

Once the Ingress is applied by application helm.

* AWS automatically provisions an **Application Load Balancer**
* ALB DNS name becomes available
* Custom domain (optional) can be mapped via Route53
<img width="1487" height="493" alt="image" src="https://github.com/user-attachments/assets/9f235506-3ec5-49a5-9cc4-a04bf840aed0" />

## Step 5: Add cluster Autoscaler
Now we only need to deploy **Cluster Autoscaler** to scale the cluster.

Since we already have:

* EKS cluster running
* Memory HPA working
* Node group tagged

```
"k8s.io/cluster-autoscaler/assignment-cluster" = "owned"
"k8s.io/cluster-autoscaler/enabled"            = "true"
```

The remaining steps are:

### 1) Create IRSA Service Account

(if not done already)

```bash
eksctl utils associate-iam-oidc-provider \
 --cluster assignment-cluster \
 --approve
```

```bash
eksctl create iamserviceaccount \
  --cluster assignment-cluster \
  --namespace kube-system \
  --name cluster-autoscaler \
  --attach-policy-arn arn:aws:iam::<ACCOUNT_ID>:policy/EKSClusterAutoscalerPolicy \
  --approve
```

### 2) Install Cluster Autoscaler via Helm

```bash
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo update

helm upgrade --install cluster-autoscaler autoscaler/cluster-autoscaler \
  --namespace kube-system \
  --set autoDiscovery.clusterName=assignment-cluster \
  --set awsRegion=<your-region> \
  --set rbac.serviceAccount.create=false \
  --set rbac.serviceAccount.name=cluster-autoscaler \
  --set extraArgs.balance-similar-node-groups=true \
  --set extraArgs.scale-down-delay-after-add=10m \
  --set extraArgs.scale-down-unneeded-time=10m
```

## ✅ Final Verification

```bash
kubectl -n kube-system logs -f deployment/cluster-autoscaler
```

Look for:

```
Discovered node group: assignment-eks-node-group
Scale-up successful
```

## Step 5: Findout Resource cost
Run the [following](https://github.com/HARNESHA/tohands-assignment/blob/dev/cost/cost_script.py) python script to review & analysis the cost assocated with individual resource.


