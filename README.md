# 🚀 Reusable Terraform Modules

> **Production-ready, modular, and reusable Infrastructure as Code (IaC) modules built according to HashiCorp best practices for multi-environment cloud architectures.**

![Terraform Version](https://img.shields.io/badge/Terraform-%3E%3D1.0.0-623CE4?logo=terraform)
![AWS Provider](https://img.shields.io/badge/AWS%20Provider-%3E%3D4.0.0-FF9900?logo=amazon-aws)
![Terragrunt Compatible](https://img.shields.io/badge/Terragrunt-Compatible-2B7A78)
![IaC Architecture](https://img.shields.io/badge/Architecture-Modular%20%26%20DRY-success)
![License](https://img.shields.io/badge/License-MIT-blue)

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Repository Structure](#-repository-structure)
- [Module Catalog](#-module-catalog)
- [What is a Terraform Module?](#-what-is-a-terraform-module)
- [Why Use Terraform Modules?](#-why-use-terraform-modules)
- [How to Consume Modules](#-how-to-consume-modules)
  - [1. Local Path Reference](#1-local-path-reference-monorepo)
  - [2. Remote Git Reference with Semantic Versioning](#2-remote-git-reference-with-version-tagging)
  - [3. Terragrunt Integration](#3-terragrunt-integration)
- [Multi-Environment Architecture Pattern](#-multi-environment-architecture-pattern)
- [Standard Module Anatomy](#-standard-module-anatomy)
- [Module Best Practices](#-module-best-practices)
- [Module Reference: AWS VPC](#-module-reference-aws-vpc)
  - [Usage Example](#usage-example)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
- [Terraform CLI Workflow & Cheatsheet](#-terraform-cli-workflow--cheatsheet)
- [CI/CD Validation Pipeline](#-cicd-validation-pipeline)
- [Contributing & Support](#-contributing--support)

---

## 📖 Overview

This repository contains a curated suite of battle-tested, modular Terraform configurations. Instead of duplicating cloud resource declarations across every environment, these modules encapsulate architecture patterns into reusable building blocks that can be parameterized for **Development**, **Staging**, and **Production**.

---

## 📂 Repository Structure

```text
terraform-modules/
│
├── README.md                      # Global repository documentation
│
└── VPC/                           # AWS Virtual Private Cloud Module
    ├── main.tf                    # Core VPC, Subnets, IGW, and Route Tables
    ├── variables.tf               # Input variable declarations with types & descriptions
    ├── output.tf                  # Exported outputs (VPC ID, Subnet IDs, etc.)
    └── versions.tf                # Required Terraform & Provider versions
```

---

## 📦 Module Catalog

| Module | Cloud | Description | Status |
| :--- | :--- | :--- | :--- |
| **[VPC](./VPC)** | AWS | Virtual Private Cloud with Public/Private Subnets, Internet Gateway, and Route Tables | `Active` |

---

## 🧠 What is a Terraform Module?

A **Terraform Module** is a container for multiple resources that are used together. 

* **Root Module:** The default working directory containing the configuration files where you run `terraform apply`.
* **Child Module:** A reusable module called from within another configuration using a `module` block.
* **Published / Remote Module:** A module distributed via Git, S3, or the Terraform Registry and consumed across different projects and teams.

```
                    ┌────────────────────────────────────────┐
                    │       Calling Configuration            │
                    │           (Root Module)                │
                    └───────────────────┬────────────────────┘
                                        │
                         Passes Inputs  │  Returns Outputs
                         (Variables)    │  (IDs, ARNs, CIDRs)
                                        ▼
                    ┌────────────────────────────────────────┐
                    │            Child Module                │
                    │               (e.g., VPC)              │
                    ├────────────────────────────────────────┤
                    │  • aws_vpc                             │
                    │  • aws_subnet (public/private)         │
                    │  • aws_internet_gateway                │
                    │  • aws_route_table                     │
                    └────────────────────────────────────────┘
```

---

## 🎯 Why Use Terraform Modules?

1. **DRY (Don't Repeat Yourself):** Define infrastructure architecture patterns once; instantiate them across 10+ environments.
2. **Consistency & Standardization:** Guarantees that staging and production networks share identical security configurations, tagging conventions, and topology.
3. **Encapsulation & Reduced Blast Radius:** Complex infrastructure logic is hidden behind simple input parameters. Callers only configure what they need.
4. **Version Control & Repeatability:** Pin infrastructure to specific Git release tags (`v1.0.0`, `v1.2.0`), allowing safe, auditable upgrades.

---

## 💻 How to Consume Modules

### 1. Local Path Reference (Monorepo)

When calling a module located within the same repository:

```hcl
# main.tf (Root Module)
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./VPC" # Or relative path: "../modules/VPC"

  vpc_cidr            = "10.0.0.0/16"
  vpc_name            = "dev-vpc"
  public_subnet_cidr  = "10.0.1.0/24"
  public_subnet_name  = "dev-public-subnet"
  private_subnet_cidr = "10.0.2.0/24"
  private_subnet_name = "dev-private-subnet"
  igw_name            = "dev-igw"
  route_table_name    = "dev-public-rt"
}

output "vpc_id" {
  description = "The ID of the provisioned VPC"
  value       = module.vpc.vpc_id
}
```

---

### 2. Remote Git Reference with Version Tagging

When sharing modules across separate repositories, reference the Git repository URL and pin it to a Git tag:

```hcl
module "production_vpc" {
  # Format: git::https://<HOST>/<ORG>/<REPO>.git//<MODULE_DIR>?ref=<TAG>
  source = "git::https://github.com/organization/terraform-modules.git//VPC?ref=v1.0.0"

  vpc_cidr            = "172.16.0.0/16"
  vpc_name            = "prod-vpc"
  public_subnet_cidr  = "172.16.1.0/24"
  public_subnet_name  = "prod-public-subnet"
  private_subnet_cidr = "172.16.2.0/24"
  private_subnet_name = "prod-private-subnet"
  igw_name            = "prod-igw"
  route_table_name    = "prod-public-rt"
}
```

> 💡 **Best Practice:** Always pin to a specific release tag (e.g., `?ref=v1.0.0`) or commit SHA. Avoid pinning to branches like `?ref=main` in production to prevent unintended breaking changes.

---

### 3. Terragrunt Integration

[Terragrunt](https://terragrunt.gruntwork.io/) is a thin wrapper for Terraform that provides extra tools for keeping configurations DRY, managing remote state, and working with multiple modules.

Create a `terragrunt.hcl` file in your environment repository:

```hcl
# environments/production/vpc/terragrunt.hcl

terraform {
  source = "git::https://github.com/organization/terraform-modules.git//VPC?ref=v1.0.0"
}

# Automatically configure remote S3 backend and DynamoDB locking from parent
include "root" {
  path = find_in_parent_folders()
}

inputs = {
  vpc_cidr            = "10.100.0.0/16"
  vpc_name            = "production-vpc"
  public_subnet_cidr  = "10.100.1.0/24"
  public_subnet_name  = "production-public-subnet-1"
  private_subnet_cidr = "10.100.2.0/24"
  private_subnet_name = "production-private-subnet-1"
  igw_name            = "production-igw"
  route_table_name    = "production-public-rt"
}
```

Deploy using Terragrunt:
```bash
terragrunt init
terragrunt plan
terragrunt apply
```

---

## 🏗️ Multi-Environment Architecture Pattern

The recommended enterprise directory structure separates the **reusable module definitions** from the **environment live configurations**:

```text
infrastructure-live/                # Separate repo or directory for live environments
│
├── terragrunt.hcl                  # Root Terragrunt config (Remote state & provider)
│
├── dev/                            # Development Environment
│   ├── vpc/
│   │   └── terragrunt.hcl          # Invokes VPC module with dev inputs
│   └── app/
│       └── terragrunt.hcl          # Invokes App module referencing dev VPC outputs
│
├── stage/                          # Staging Environment
│   └── vpc/
│       └── terragrunt.hcl
│
└── prod/                           # Production Environment
    └── vpc/
        └── terragrunt.hcl          # Invokes VPC module with prod inputs
```

---

## 🏛️ Standard Module Anatomy

Every module in this repository strictly adheres to standard HashiCorp structure:

| File | Purpose | Rule / Best Practice |
| :--- | :--- | :--- |
| `main.tf` | Resource definitions & core orchestration logic | Keep resource blocks clean, well-commented, and parameterized. |
| `variables.tf` | Declaration of all configurable inputs | Every variable **must** include a `type` and `description`. |
| `output.tf` / `outputs.tf` | Return values to the calling configuration | Expose resource IDs, ARNs, and connection strings. |
| `versions.tf` | Required Terraform and Provider constraints | Use `required_providers` with semantic constraints (`>=` or `~>`). |

---

## 🛡️ Module Best Practices

1. **No Provider Blocks in Child Modules:**  
   Child modules must **never** declare a `provider "aws" { ... }` block. Providers must be configured exclusively in the root calling module. Modules only declare provider requirements in `versions.tf`.
2. **Explicit Variable Types & Descriptions:**  
   Avoid untyped variables. Use explicit types (`string`, `number`, `list(string)`, `map(string)`).
3. **Sensible Defaults for Optional Variables:**  
   If a parameter is not strictly required, provide a sensible default value or use `default = null`.
4. **Comprehensive Outputs:**  
   Output every primary resource attribute (ID, ARN, DNS name) so downstream modules can consume them without needing data source lookups.
5. **Standardized Resource Tagging:**  
   Ensure all taggable cloud resources include standard tags (`Name`, `Environment`, `ManagedBy = "Terraform"`).

---

## 🌐 Module Reference: AWS VPC

The **[VPC](./VPC)** module provisions a foundational AWS network with segregated public and private subnets.

### Architecture Diagram

```
                              AWS REGION (VPC)
  ┌────────────────────────────────────────────────────────────────────────┐
  │  VPC CIDR (e.g. 10.0.0.0/16)                                           │
  │                                                                        │
  │  ┌───────────────────────────────┐   ┌──────────────────────────────┐  │
  │  │ Public Subnet (10.0.1.0/24)   │   │ Private Subnet (10.0.2.0/24) │  │
  │  │ • Auto-assign Public IP: Yes  │   │ • Auto-assign Public IP: No  │  │
  │  │ • Route: 0.0.0.0/0 -> IGW     │   │ • Isolated from Internet     │  │
  │  └───────────────┬───────────────┘   └──────────────────────────────┘  │
  │                  │                                                     │
  │                  ▼                                                     │
  │         [ Internet Gateway ] ───► Public Internet (0.0.0.0/0)          │
  └────────────────────────────────────────────────────────────────────────┘
```

### Usage Example

```hcl
module "network" {
  source = "./VPC"

  vpc_cidr            = "10.0.0.0/16"
  vpc_name            = "production-vpc"
  public_subnet_cidr  = "10.0.1.0/24"
  public_subnet_name  = "production-public-subnet"
  private_subnet_cidr = "10.0.2.0/24"
  private_subnet_name = "production-private-subnet"
  igw_name            = "production-igw"
  route_table_name    = "production-public-rt"
}
```

### Inputs

| Name | Type | Description | Required |
| :--- | :--- | :--- | :---: |
| `vpc_cidr` | `string` | The CIDR block for the VPC (e.g., `10.0.0.0/16`) | **Yes** |
| `vpc_name` | `string` | Name tag for the VPC resource | **Yes** |
| `public_subnet_cidr` | `string` | The CIDR block for the public subnet | **Yes** |
| `public_subnet_name` | `string` | Name tag for the public subnet | **Yes** |
| `private_subnet_cidr` | `string` | The CIDR block for the private subnet | **Yes** |
| `private_subnet_name` | `string` | Name tag for the private subnet | **Yes** |
| `igw_name` | `string` | Name tag for the Internet Gateway | **Yes** |
| `route_table_name` | `string` | Name tag for the public route table | **Yes** |

### Outputs

| Name | Type | Description |
| :--- | :--- | :--- |
| `vpc_id` | `string` | The unique ID of the provisioned VPC |
| `vpc_cidr` | `string` | The CIDR block of the VPC |
| `public_subnet_id` | `string` | The ID of the public subnet |
| `private_subnet_id` | `string` | The ID of the private subnet |
| `internet_gateway_id` | `string` | The ID of the Internet Gateway |
| `public_route_table_id` | `string` | The ID of the public route table |

---

## ⚡ Terraform CLI Workflow & Cheatsheet

Run these commands from the directory containing your **calling configuration (root module)**:

```bash
# 1. Initialize working directory, download providers and modules
terraform init

# 2. Check and enforce standard HCL formatting
terraform fmt -check -recursive

# 3. Validate syntax and argument references
terraform validate

# 4. Generate and inspect an execution plan
terraform plan -out=tfplan

# 5. Apply the approved execution plan
terraform apply tfplan

# 6. Inspect current state resources
terraform state list

# 7. Destroy managed infrastructure (Use with caution!)
terraform destroy
```

---

## 🔄 CI/CD Validation Pipeline

To ensure high code quality across all modules, integrate this automated GitHub Actions workflow (`.github/workflows/terraform-lint.yml`):

```yaml
name: "Terraform Lint & Validate"

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  validate:
    name: "Lint & Validate"
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.7.0"

      - name: Check Formatting
        run: terraform fmt -check -recursive

      - name: Initialize & Validate VPC Module
        run: |
          cd VPC
          terraform init -backend=false
          terraform validate
```

---

## 🤝 Contributing & Support

1. Fork this repository.
2. Create a feature branch: `git checkout -b feature/new-module`.
3. Ensure all code passes `terraform fmt -check` and `terraform validate`.
4. Submit a Pull Request.

---

**Happy Terraforming! 🚀**