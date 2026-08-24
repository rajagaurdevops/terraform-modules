# Terraform Modules

Terraform modules are reusable collections of Terraform configuration. Instead of
copying the same resources into every environment, a module lets you define an
infrastructure pattern once and use it with different values.

## Why use a module?

Using a module helps you:

- Reuse the same infrastructure design in development, staging, and production.
- Keep infrastructure configuration consistent across environments.
- Pass environment-specific values without changing the module itself.
- Reduce duplicated Terraform code and make future changes easier.
- Expose useful resource values to other Terraform resources.

## How to use a module

Create a Terraform configuration in a separate directory and reference the
module with its local path or a remote source:

```hcl
terraform {
	required_providers {
		provider_name = {
			source  = "organization/provider_name"
			version = "~> 1.0"
		}
	}
}

module "example" {
	source = "../path/to/module"

	name        = "example"
	environment = "development"
	value       = "custom-value"
}

output "resource_id" {
	value = module.example.resource_id
}
```

Replace the input names and values with the variables defined by the module.
The `source` can point to a local directory, a Git repository, or a registry.

## Use the module from another repository with Terragrunt

Terragrunt can download and use this module from a separate repository. Create a
`terragrunt.hcl` file in the repository that will use the module:

```hcl
terraform {
	source = "git::https://github.com/organization/terraform-modules.git//module-directory?ref=v1.0.0"
}

inputs = {
	name        = "example"
	environment = "development"
	value       = "custom-value"
}
```

Update the URL with the module repository, module directory, and Git tag or
commit you want to use. Pinning a version makes deployments repeatable.

Run Terragrunt from the directory containing `terragrunt.hcl`:

```bash
terragrunt init
terragrunt plan
terragrunt apply
```

Terragrunt passes the values in `inputs` to the module's input variables. The
module's outputs can then be used by other Terraform resources or exposed from
the Terragrunt configuration. For multiple related directories, a parent
Terragrunt configuration can manage them together with `terragrunt run --all`.

## Module inputs

Inputs are variables declared inside the module. They allow the caller to
customize the module for a particular environment.

Common input categories include:

- Names and tags.
- Environment or workspace identifiers.
- Locations and regions.
- Sizes, counts, and feature flags.
- Network ranges or other configuration values.

Every required input should be supplied by the calling configuration. Optional
inputs use the default value declared by the module.

## Module outputs

Outputs expose values from a module so the calling configuration can use them
elsewhere:

- Resource IDs.
- Resource names or addresses.
- Configuration values calculated by the module.
- Information needed by another module.

Use an output with `module.<module_name>.<output_name>`:

```hcl
module "example" {
  source = "../path/to/module"
}

resource "provider_resource" "example" {
  related_id = module.example.resource_id
}
```

The exact input and output names depend on the module.

## Module structure

A typical module contains:

| File | Purpose |
| --- | --- |
| `main.tf` | Resources and primary module logic |
| `variables.tf` | Input variables accepted by the module |
| `outputs.tf` | Values exposed to the calling configuration |
| `versions.tf` | Terraform and provider requirements |

## Terraform workflow

From the directory containing the calling configuration, run:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Review the plan before applying it. `terraform destroy` removes resources
managed by the calling configuration, so use it only when that is intended.