---
date: 2021-06-12T03:19:40-04:00
title: "Get A List of EC2 Instances And The AMIs Used to Launch Them"
---

I was recently tasked with auditing the AMIs we are currently using for our AWS account. I could have just checked all machines but thought jq might be a better way to do it, and it actually is.<!--more-->

```bash
aws ec2 describe-instances --profile env-dev-poweruser | jq -r '.Reservations[].Instances[0] | with_entries(select([.key] | inside(["InstanceId", "ImageId"]))) | [.InstanceId, .ImageId] | join("\n")'
```

This uses the aws cli tool to pull instance information, then uses jq to filter out the field we don't need.