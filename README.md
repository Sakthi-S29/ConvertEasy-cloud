Absolutely! Here is your **elaborated `README.md`** for the **ConvertEasy** project with a well-structured breakdown, a placeholder for the architecture diagram, and an explanation of the full **application workflow**.

---

# 🌩️ ConvertEasy – Cloud-Native File Conversion Platform

**ConvertEasy** is a cloud-native application that enables users to convert files (documents, images, audio, video) from one format to another via a user-friendly web interface. It is built on modern AWS cloud services using Infrastructure-as-Code (Terraform), ensuring full automation, scalability, and security.

---

## 📸 Architecture Diagram



```md
![cloud_project_architecture](https://github.com/user-attachments/assets/a1fca7fb-5f1f-491f-b176-bc28c32a978c)
```

---

## 🧭 Workflow Overview

Here's how the **ConvertEasy** system works end-to-end:

### 1. **User Interaction**
- The user accesses the static frontend hosted on an Amazon S3 bucket.
- They select a file and desired output format, then click **Convert**.

### 2. **File Upload**
- The frontend JavaScript sends a `POST` request to the `/convert` endpoint of the backend service (exposed via ALB).

### 3. **Backend Processing**
- The backend (FastAPI running in Docker on EC2) receives the file and:
  - Validates MIME type
  - Stores the raw file in the "uploaded" S3 bucket
  - Converts it using format-specific logic (LibreOffice, FFMPEG, etc.)
  - Stores the converted output in the "converted" S3 bucket
  - Generates a pre-signed URL and returns it to the frontend

### 4. **User Download**
- The user clicks the generated download link to retrieve their converted file directly from S3.

### 5. **Logging and Monitoring**
- Each conversion is asynchronously logged to DynamoDB.
- EC2 CPU is monitored using CloudWatch alarms.
- Optional: Alerts sent to SNS/email if usage spikes.

---

## 🚀 Key Features

✅ Drag-and-drop file upload interface  
✅ Real-time conversion using FastAPI backend  
✅ Multi-format support: DOCX, PDF, JPG, PNG, MP3, MP4, etc.  
✅ Secure file storage using S3  
✅ Conversion history logged to DynamoDB  
✅ Fully automated using Terraform and Docker  
✅ CI-compatible ECR image push and EC2 deployment flow  
✅ CloudWatch + SNS integration for health monitoring

---

## 🛠️ Technologies Used

| Layer             | Tech / Service                   |
|------------------|----------------------------------|
| Frontend         | HTML, CSS, JS (S3 static site)   |
| Backend          | Python FastAPI (Docker)          |
| Compute          | EC2 (private subnet, no public IP)|
| Load Balancer    | Application Load Balancer (ALB)  |
| File Storage     | Amazon S3                        |
| Database         | Amazon DynamoDB (for logging)    |
| Image Registry   | Amazon ECR                       |
| Monitoring       | Amazon CloudWatch                |
| Alerts           | Amazon SNS (optional email)      |
| Networking       | VPC, IGW, NAT Gateway, Subnets   |
| IaC              | Terraform                        |

---

## 📁 Project Structure

```
ConvertEasy/
├── backend/                   # FastAPI backend app
│   ├── converters/            # Format-specific logic
│   ├── Dockerfile
│   ├── main.py
│   └── requirements.txt
├── frontend/                  # Static website (HTML/CSS/JS)
│   ├── index.html
│   ├── style.css
│   ├── script.js
│   └── script.template.js
├── infrastructure/            # Terraform IaC
│   ├── templates/
│   │   └── docker_startup.tpl # Cloud-init to start Docker container
│   ├── ec2.tf
│   ├── ecr.tf
│   ├── vpc.tf
│   ├── s3.tf
│   ├── dynamodb.tf
│   ├── cloudwatch.tf
│   ├── nat.tf
│   ├── keypair.tf
│   └── variables.tf
└── scripts/
    └── build_and_push_to_ecr.sh  # Docker build and deploy script
```

---

## ⚙️ Setup Instructions

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-org/ConvertEasy.git
cd ConvertEasy
```

### Step 2: Ignore Sensitive Files

```bash
echo "infrastructure/converteasy-key.pem" >> .gitignore
```

### Step 3: Provision Infrastructure (Terraform)

```bash
cd infrastructure
terraform init
terraform apply -auto-approve
```

> 🛑 **Ensure all AWS services are provisioned before pushing Docker image.**

### Step 4: Build & Push Docker Image

```bash
cd scripts
bash build_and_push_to_ecr.sh
```

> 📦 This builds a `linux/amd64` image, pushes to ECR, and applies only the `aws_instance.backend` target once image is available.

---

## ✅ Post-Deployment Checklist

- Wait for EC2 to be marked as **healthy** in the **Target Group**.
- Access the app via the **S3 static site URL** or via **ALB DNS**.
- Monitor logs via **CloudWatch Logs**.
- Verify conversion logs in **DynamoDB**.
- (Optional) Check if SNS email alerts are received when CPU threshold is breached.

---

## 💰 Cost Optimization

| Feature          | Optimization |
|------------------|--------------|
| Database         | Replaced RDS with DynamoDB to reduce idle cost |
| Compute          | EC2 runs in private subnet to reduce attack surface |
| Storage          | S3 lifecycle rules (optional) for file expiry |
| Monitoring       | CloudWatch alarms used judiciously (free tier) |

---

## 🔐 Security Measures

- EC2 instances have no public IP.
- S3 buckets are private (only accessible by LabRole IAM).
- All credentials passed securely via `.env` injected at boot.
- NAT Gateway used for EC2 outbound access.

---

## 🧹 Cleanup

### Destroy the stack

```bash
terraform destroy -auto-approve
```

> ⚠️ **Note:** ECR deletion will fail if images are present. Manually delete them or enable:
```hcl
resource "aws_ecr_repository" "backend_repo" {
  force_delete = true
}
```

---

## 📌 Future Enhancements

- Add authentication using Cognito
- Replace EC2 with Fargate/Lambda
- Support queue-based conversion using SQS
- Add user dashboard with history and email reports

---

## 🏁 Final Note

This project is production-grade and built with scalability in mind. All resources are provisioned using Terraform, and the application logic is fully containerized and CI/CD ready.

---

Let me know if you'd like this as a downloadable `.md`, `PDF`, or want to integrate it into your GitHub repo with badges and deploy instructions.
