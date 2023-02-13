---
date: 2021-05-20T23:01:27-04:00
title: "Writing Reusable Terraform Code, Part 2"
---

In [part 1]({{<relref "writing-reusable-terraform-code-part-1.md">}}), I talked about modules and how they are the first step into reducing duplicate resources. Here I will talk about [workspaces](https://www.terraform.io/docs/language/state/workspaces.html).<!--more-->

From the workspaces documentation page:

Each Terraform configuration has an associated backend that defines how operations are executed and where persistent data such as the Terraform state are stored.

The persistent data stored in the backend belongs to a workspace. Initially the backend has only one workspace, called "default", and thus there is only one Terraform state associated with that configuration.

Certain backends support multiple named workspaces, allowing multiple states to be associated with a single configuration. The configuration still has only one backend, but multiple distinct instances of that configuration to be deployed without configuring a new backend or changing authentication credentials.

Let's take a look at my first attempt to use workspaces (This doesn't include the modules folder):

```none
.
├── account.tf
├── cloudinit.sh
├── common.tfvars
├── dev.tfvars
├── db.tf
├── ec2.tf
├── outputs.tf
├── prd.tfvars
├── redis.tf
└── vpc.tf
```

```none
terraform {
  backend "s3" {
    bucket = "my-terraform-backend"
    key    = "state"
    region = "eu-west-3"
    workspace_key_prefix = "workspaces"
  }
}
```

The state information will be saved to the `my-terraform-backend` bucket under `/workspaces/dev` and `/workspaces/prd`. Workspace commands include

```bash
# Create the dev workspace
terraform workspace new dev

# Create the prd workspace
terraform workspace new prd

# Switch to the dev workspace
terraform workspace select dev

# Switch to the prd workspace
terraform workspace select prd

# Show the active workspace
terraform workspace show
```

To apply your configuration, run the following command
```bash
terraform apply -var-file="common.tfvars" -var-file="dev.tfvars"
```

Pros:
* Eliminated duplicate resource definitions.
* Eliminated duplicate variables
* Reduces complexity because we would have one workspace per environment (product1-prd, product2-dev)

Cons, taken from the workspaces page:

> When Terraform is used to manage larger systems, teams should use multiple separate Terraform configurations that correspond with suitable architectural boundaries within the system so that different components can be managed separately and, if appropriate, by distinct teams. Workspaces alone are not a suitable tool for system decomposition, because each subsystem should have its own separate configuration and backend, and will thus have its own distinct set of workspaces. This does not apply if all users have access to all environments, but this is not usually the case.

One other minor drawback is the longer command, `common.tfvars` can be renamed to `common.auto.tfvars` and then you will have a single -var-file argument, but still. I'm super lazy when it comes to things like this, so I looked for an alternative. I stumbled across [this](https://medium.com/@smburrows/terraform-workspace-variables-497535bf645e) and this is what I got

```none
├── config.yaml
├── main.tf
└── workspaces
    ├── dev.yaml
    └── prd.yaml
```
&nbsp;

```hcl
locals {
    workspace_path = "./workspaces/${terraform.workspace}.yaml" 
    defaults       = file("${path.module}/config.yaml")

    workspace = fileexists(local.workspace_path) ? file(local.workspace_path) : yamlencode({})

    settings = merge(
        yamldecode(local.defaults),
        yamldecode(local.workspace)
    )
}
```

What this does is it takes two YAML files; common.yml and dev/prd.yml, combines them into a single variable and passes it as local.settings. Not only does this fix the issue with the command line, but it also provides much more flexibility when it comes to defining resources. I will discuss using YAML and handling the multiple configurations in [part 3]({{<relref "writing-reusable-terraform-code-part-3.md">}}).