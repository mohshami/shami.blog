---
date: 2021-05-20T22:28:45-04:00
title: "Writing Reusable Terraform Code, Part 1"
---

I'm fairly new to Terraform, yes I have been using it for the past 2 or 3 years, but my use-case was quite simple; Create a few servers in [DigitalOcean](https://www.digitalocean.com/) or [Hetzner](https://www.hetzner.com/), install a web stack, and use the outputs to update the load balancer and the firewall.<!--more-->

Last year I moved to Ottawa and started working at [The Canadian Internet Registration Authority](https://www.cira.ca) where I was exposed to AWS. The AWS more advanced features got me working with more advanced Terraform configurations and I wanted to share my findings here.

All my previous configurations consisted of a single folder with a few .tf files containing the account information, resource definitions and some variables. That won't work when you have multiple environments, here is were I got introduced to [modules](https://www.terraform.io/docs/language/modules/develop/index.html). I will not go into details here because that information can be easily found on Google.

Lets take a look at a sample directory structure:

```none
.
|-- environments
|   |-- dev
|   |   |-- cloudinit.conf
|   |   |-- main.tf
|   |   |-- terraform.tfvars
|   |   `-- variables.tf
|   `-- prd
|   |   |-- cloudinit.conf
|   |   |-- main.tf
|   |   |-- terraform.tfvars
|   |   `-- variables.tf
|-- modules
    `-- web
        |-- main.tf
        `-- variables.tf
```

In the above configuration, all your resource definitions are stored under `/modules/web` and you store your variables in `/environments/dev` and `/environments/prd`.

Pros:
* Eliminated duplicate resource definitions.
* Different credentials can be used for dev and prd, allowing developers or junior system administrators to build and test the dev environment, but only the people in charge can touch production.

Cons:
* If you have a larger environment, most variables will be identical between dev and prd, with only a smaller subset being different.
* Some environments can't be built out of a single configuration like the above, so we would have even more duplicate variables.
* This will get complicated even more quickly if you have more environments.

Those cons will be addressed in [part 2]({{<relref "writing-reusable-terraform-code-part-2.md">}}).