---
title: "Templating SSH Client Configuration"
date: 2024-08-17T09:47:06-04:00
---

**Note**: When I first got the idea for this I used [gomplate](https://gomplate.ca/), then I realized my dotfile manager of choice, [chezmoi](https://www.chezmoi.io/) is better suited for my usecase. I have dumped the files I created in this [gist](https://gist.github.com/mohshami/ea88c2ba63d13ac928501208fe9da3a5) just in case someone finds them useful.<!--more-->

In my [my previous post]({{<relref "dynamic_proxyjump.md">}}), I explained how I use `Match` in my ssh_config to dynamically select my jump host. At first I had a few files in a git repository that I symlink to `~/.ssh/conf.d` and have them `include`ed in `~/.ssh/config`. But the more hosts I added the more unmanageable the soultion becoame. Recently I started using [devpod](https://devpod.sh/) for development and it started modifying `~/.ssh/config` which started breaking in all sorts of ways, so I decided to redo my configuration and thought templating it would be a good idea. I ended up liking the end result and wanted to share.

`~/.local/share/chezmoi/.chezmoitemplates/ssh_host`:
```
{{- $host := . -}}
{{- range (default (list (list "always" "none")) (index . "proxy")) }}
Match host {{ $host.name }},{{ $host.ips|join "," }}{{ if ne (index . 0) "none" }} exec "~/.ssh/network_detect/{{ index . 0 }}"{{ end }} {{- if not (contains "*" (index $host.ips 0)) }}
HostName {{ index $host.ips 0 }}{{ end }}
  User {{ index $host "user" | default "root" }}
{{- if index $host "key" }}
  IdentitiesOnly yes
{{- if eq (printf "%T" $host.key) "string" }}
  IdentityFile ~/.ssh/{{ $host.key }}
{{- else -}}
{{ range $host.key }}
  IdentityFile ~/.ssh/{{ . }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- range $env, $env_val := default nil (index $host "env") }}
  SetEnv {{ $env }}={{ $env_val }}
{{- end }}
{{- range $option, $option_val := default nil (index $host "options") }}
  {{ $option }} {{ $option_val }}
{{- end }}
  ProxyJump {{ index . 1 }}
{{ end -}}
```

`~/.local/share/chezmoi/private_dot_ssh/config.inc.tmpl`:
```
AddKeysToAgent yes
{{- range values .ssh_servers -}}
{{ range . }}
{{ template "ssh_host" . }}
{{- end -}}
{{- end -}}
{{- "" }}
{{- $hosts := list }}
{{- range (values .ssh_servers) }}
{{- range . }}
{{- $hosts = append $hosts .name }}
{{- end }}
{{- end }}
# Allow auto completions for shells that support it
{{- range ($hosts | uniq) }}
Host {{ . -}}
{{ end }}

Host *
  ForwardAgent no
  ServerAliveInterval 30
  ServerAliveCountMax 2
  SetEnv TERM=xterm-256color
```

This allows storing server information as follows

`~/.local/share/chezmoi/.chezmoidata/office.yml`:
```yaml
ssh_servers:
  office:
    -
      name: office-web1
      ips:
        - 10.1.0.1
      key: ed25519
      env:
        TERM: xterm-ghostty
      proxy:
        -
          - office
          - none
        -
          - home
          - home-bastion
        -
          - wireguard
          - wg-bastion
```

`~/.local/share/chezmoi/.chezmoidata/client1.yml`:
```yaml
ssh_servers:
  client1:
    -
      name: client1-infra
      ips:
        - 172.16.0.*
      key:
        - client1-web.pub
        - client1-db.pub
      proxy:
        -
          - office
          - office-bastion
        -
          - wireguard
          - wg-bastion
```

And you can even store per-machine configuration as follows
`.config/chezmoi/chezmoi.json`:
```json
{
  "git": {
    "autoCommit": true,
    "autoPush": true
  },
  "data": {
    "ssh_servers": {
      "this_host_only":
        [
          {
            "name": "host1",
            "ips": [ "172.17.1.1" ]
          }
        ]
    }
  }
}
```

The sub-keys under ssh_servers allows chezmoi to combine the data from mutiple files, making the configuration that little bit more maintainable.
