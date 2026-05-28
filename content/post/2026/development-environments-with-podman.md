---
title: "Development Environments With Podman"
date: 2026-05-28T09:56:28+03:00
categories:
  - Technical
---
A while back I switched to NixOS. Then when I started playing with Rust, I found out Rust does not play nicely with Nix. So I went on the journy of finding an alternative.<!--more-->

I started experimenting with a few solutions: [distrobox](https://distrobox.it/), [Devbox](https://www.jetify.com/devbox), [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers). They all had their pros and cons, e.g. distrobox would pollute my home directory and the last version I used kept freezing.

The solution I ended up with is a custom development container with [podman](https://podman.io/) and [mise-en-place](https://mise.jdx.dev/). The benefits of the setup are:
* Allows simulating production environments more closely. Like mounting an Ansible configuration to `/ansible`, similar to the [Semaphore UI](https://semaphoreui.com/) server.
* Extremely flexible, can simulate almost any environment. I use Debian slim, you can use whatever suits your needs.
* Shared UID/GID between the host and container, user can edit their files from either.
* Perfect for use with [Neovim](https://neovim.io), my favorite IDE/text editor, with custom configurations/LSPs per container.
* Allows usage over SSH, even from a phone or tablet.
* Isolates changes from the host.
* Gives least amount of access to the tools running inside the container. Useful when using tools like [pi](https://pi.dev).
* Unlike Docker, podman doesn't mess with iptables.


To achieve this I used 2 wrapper scripts and a small configuration file

Now for the scripts:

```bash {filename="devenv-buildimage"}
#!/bin/bash

# devenv-buildimage
# Builds the development container image

set -euo pipefail

# Default configuration file
CONFIG_FILE="./.devenv"

# Check if a custom config file is provided
if [ $# -ge 1 ]; then
    CONFIG_FILE="$1"
fi

# Check if the config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file '$CONFIG_FILE' not found." >&2
    exit 1
fi

# Read the image name from the config file
IMAGE_NAME=""
while IFS='=' read -r key value; do
    # Skip comments and empty lines
    [[ "$key" =~ ^[[:space:]]*#.*$ || -z "$key" ]] && continue

    # Trim whitespace
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)

    case "$key" in
        Image|image)
            IMAGE_NAME="$value"
            ;;
    esac
done < "$CONFIG_FILE"

# Validate required field
if [ -z "$IMAGE_NAME" ]; then
    echo "Error: 'image' is required in the config file." >&2
    exit 1
fi

BASE_IMAGE="docker.io/debian:trixie-slim"

# Use the same UID and GID as current user
MyUID=$(id -u)
MyGID=$(id -g)

echo "==> Creating working container from $BASE_IMAGE..."
CONTAINER=$(buildah from "$BASE_IMAGE")
echo "    Container: $CONTAINER"

cleanup() {
    echo "==> Removing working container..."
    buildah rm "$CONTAINER" 2>/dev/null || true
}
trap cleanup EXIT

echo "==> Running setup commands..."
buildah run \
    --env MyUID="$MyUID" \
    --env MyGID="$MyGID" \
    "$CONTAINER" -- bash -c '
set -e
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install --no-install-recommends -y curl fish build-essential ripgrep unzip fd-find luarocks locales tree-sitter-cli sudo git ca-certificates
update-ca-certificates

luarocks --lua-version 5.1 install jsregexp

locale-gen en_US.UTF-8
echo "en_US.UTF-8 UTF-8" | tee /etc/locale.gen
locale-gen
dpkg-reconfigure locales
update-locale LANG=en_US.UTF-8

curl https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh

rm -rf /var/lib/apt/lists/*

useradd -m -u $MyUID -g $MyGID devuser

# Passwordless sudo for devuser
echo "devuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/devuser
chmod 0440 /etc/sudoers.d/devuser

mkdir -p /home/devuser/.config /home/devuser/.local/share/mise/installs
chown -R devuser:users /home/devuser
'

echo "==> Configuring image defaults (user, workdir, env)..."
buildah config \
    --user devuser \
    --workingdir /home/devuser \
    --env HOME=/home/devuser \
    --env LANG=en_US.UTF-8 \
    "$CONTAINER"

echo "==> Committing image as $IMAGE_NAME..."
buildah commit "$CONTAINER" "$IMAGE_NAME"

echo "==> Done. Image built: $IMAGE_NAME"
```


```bash {filename="devenv-createcontainer"}
#!/bin/bash

# devenv-createcontainer
# Creates a container using the image, volumes and ports defined

# Default configuration file
CONFIG_FILE="./.devenv"

# Check if a custom config file is provided
if [ $# -ge 1 ]; then
    CONFIG_FILE="$1"
fi

# Check if the config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file '$CONFIG_FILE' not found." >&2
    exit 1
fi

# Initialize variables
VOLUMES=()
PORTS=()
ENTRYPOINT=""
IMAGE=""
COMMAND=""
NAME=""

# Read the config file line by line
while IFS='=' read -r key value; do
    # Skip comments and empty lines
    [[ "$key" =~ ^[[:space:]]*#.*$ || -z "$key" ]] && continue

    # Trim whitespace
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)

    case "$key" in
        Volume|volume|volumes)
            VOLUMES+=("$value")
            ;;
        Port|port|ports)
            PORTS+=("$value")
            ;;
        Entrypoint|entrypoint)
            ENTRYPOINT="$value"
            ;;
        Image|image)
            IMAGE="$value"
            ;;
        Command|command)
            COMMAND="$value"
            ;;
        Name|name)
            NAME="$value"
            ;;
        *)
            echo "Warning: Unknown key '$key' in config file." >&2
            ;;
    esac
done < "$CONFIG_FILE"

# Validate required fields
if [ -z "$IMAGE" ]; then
    echo "Error: 'image' is required in the config file." >&2
    exit 1
fi

# Build the podman run command
PODMAN_CMD="podman run -d --stop-signal SIGKILL --userns=keep-id:uid=$(id -u),gid=$(id -g)"

# Add container name if specified
if [ -n "$NAME" ]; then
    PODMAN_CMD+=" --name $NAME"
fi

# Add volumes
for vol in "${VOLUMES[@]}"; do
    PODMAN_CMD+=" -v $vol"
done

# Add ports
for port in "${PORTS[@]}"; do
    PODMAN_CMD+=" -p $port"
done

# Add entrypoint
if [ -n "$ENTRYPOINT" ]; then
    PODMAN_CMD+=" --entrypoint $ENTRYPOINT"
fi

# Add image
PODMAN_CMD+=" $IMAGE"

# Add command
if [ -n "$COMMAND" ]; then
    PODMAN_CMD+=" $COMMAND"
fi

# Print the command for debugging (optional)
echo "Executing: $PODMAN_CMD"

# Execute the command
eval "$PODMAN_CMD"
```

Last but not least, the configuration file
```ini
# Example file, just save as .devenv in the root of your project
name=nix
image=devcontainer

# The root of the project goes to /workspace
volume=./:/workspace

# Share .ssh configuration in read-only mode
volume=~/.ssh:/home/devuser/.ssh:ro

# Neovim and fish doesn't really play nicely with read only, so create them as
# an overlay share, container can modify but changes are not mirrored to the host
volume=~/.config/fish:/home/devuser/.config/fish:O
volume=~/.config/nvim:/home/devuser/.config/nvim:O

# If you have multiple containers running mise, share the downloads umong them
# be nice :)
volume=~/.local/share/mise/installs:/home/devuser/.local/share/mise/installs

# The git user information is likely shaared with the host
volume=~/.gitconfig:/home/devuser/.gitconfig:ro

# If you also want to share the SSH agent socket with the host
volume=$SSH_AUTH_SOCK:/tmp/ssh-agent

# Expose ports to the host
port=1313:1313
port=8080:80

# This makes the container run indefinitely
entrypoint=sleep
command=infinity
```

Now all you need to do is:
* Place `.devenv` in the root of your project.
* Run `devenv-buildimage` to create/update the dev environment.
* Run `devenv-createcontainer` to create the final development environment.
* Run `podman exec -it CONTAINER_NAME fish` to enter the development shell.
* Run `mise use -g neovim lazygit` to install neovim and lazygit globally in the container. Other tools can also be used
* Run `mise trust .` in `/workspace` to trust any mise settings inside that workspace (This is only needed once per container per path)
