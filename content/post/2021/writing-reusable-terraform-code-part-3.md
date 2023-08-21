---
date: 2021-06-02T22:50:01-04:00
title: "Writing Reusable Terraform Code, Part 3"
---

In [part 1]({{<relref "writing-reusable-terraform-code-part-1.md">}}) and [part 2]({{<relref "writing-reusable-terraform-code-part-2.md">}}) I briefly talked about modules and workspaces. This time I will take things a bit further.<!--more-->

When your infrastructure becomes more complex, you will usually have a group of people administering the dev/qa environments and only a subset who have access to apply configuration to production. Workspaces don't help here because they would still allow access to state files on S3 which is not desirable in this situation.

This is how a repository would normally look like:

```plaintext
.
├── conf1
├──── environments
├────── dev
├──────── account.tf
├──────── outputs.tf
├──────── variables.tf
├──────── vars.auto.tfvars
├────── prd
├──────── account.tf
├──────── outputs.tf
├──────── variables.tf
├──────── vars.auto.tfvars
├────── qa
├──────── account.tf
├──────── outputs.tf
├──────── variables.tf
├──────── vars.auto.tfvars
├──── modules
├────── module1
├────── module2
├────── module3
├── conf2
├──── ...
├── conf3
└──── ..
```

First, you will notice we have multiple configurations, that is because for any reasonably complex infrastructure we would need to split it into contained sets, or "configurations". I ran into a situation where I only needed to rebuild or destroy part of the infrastructure and couldn't because they were all in the same directory.

The second thing you will notice is that we have similar files in each environment. Yes we did move all of our code to modules, but we still need to feed variables to those modules and therefore we have to have those files there. Now imagine you wanted to update something in one of your modules and needed to add another variable? Or you had to add the IP address of the new branch office to your 15 security groups. You would have to go through all environments and do that. Too much trouble.

This is where [partial backend configuration](https://www.terraform.io/docs/language/settings/backends/configuration.html#partial-configuration) comes to play. When you run `terraform init` Terraform hard-codes the backend configuration inside the .terraform folder to be able to handle state updates. This is why we can't have variables inside backend blocks.

So instead of the above we would have the following:

```plaintext
.
├── conf1
├──── environments
├────── dev.conf
├────── prd.conf
├────── qa.conf
├──── modules
├────── module1
├────── module2
├────── module3
├──── account.tf
├──── common.auto.tfvars
├──── dev.tfvars
├──── outputs.tf
├──── prd.tfvars
├──── qa.tfvars
├──── variables.tf
├── conf2
├──── ...
├── conf3
└──── ..
```

account.tf would look something like:

```plaintext
provider "aws" {
  region                  = "ca-central-1"
  shared_credentials_file = "/home/USER/.aws/credentials"
}

terraform {
  backend "s3" {
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}
```

Environment files would look like:

```plaintext
dev.conf:
bucket = "dev-bucket"

prd.conf:
bucket = "prd-bucket"

qa.conf:
bucket = "qa-bucket"
```

To update an environment, we would need to reinitialize like so:

```bash
# For conf1 and dev
# Init (From inside /conf1)
# -reconfigure is used to here to skip the prompt to copy the current
# configuration to the new location, so we don't override other environments
terraform init -backend-config=environments/dev.conf -reconfigure

# Apply
terraform apply -var-file=dev.tfvars

# Destroy
terraform destroy -var-file=dev.tfvars
```

This way, all common variables are stored in common.auto.tfvars which is automatically loaded, and we choose which variable file to load containing environment-specific configurations.

We could also use YAML files like in [part 2]({{<relref "writing-reusable-terraform-code-part-2.md">}})

```plaintext
locals {
    environment_path = "./environments/${var.environment}.yaml" 
    defaults       = file("${path.module}/config.yaml")

    workspace = fileexists(local.environment_path) ? file(local.environment_path) : yamlencode({})

    settings = merge(
        yamldecode(local.defaults),
        yamldecode(local.workspace)
    )
}
```

Then

```bash
# Apply
terraform apply -var "environment=dev"
```

I have personally found YAML files are much easier to work with than .tfvars files. This has also allowed me to use a single set of variable files for all configurations reducing duplication even more. You just have to move the YAML files up the folder structure and update `environment_path` above.