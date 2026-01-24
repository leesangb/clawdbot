# Persistent Binaries for dokploy Deployment

## Environment Variable

Set `BINARIES_TO_INSTALL` to a comma-separated list of binary package names:

```bash
# In Dokploy Environment tab
BINARIES_TO_INSTALL=gh,jq,curl,wget
```

## Volumes

The following additional volumes are mounted to persist binaries and shell configuration:

| Host Path            | Container Path          | Purpose                     |
|----------------------|-------------------------|-----------------------------|
| `/data/clawdbot/binaries` | `/usr/local/bin`   | Installed binaries (gh, jq) |
| `/data/clawdbot/shell`    | `/root/.config/shell` | Shell aliases and config    |

Note: Existing named volumes (`clawdbot-config`, `clawdbot-workspace`, `clawdbot-fonts`) are preserved.

## Install Binaries

After starting the container, run:

```bash
# Install binaries from environment variable
IFS=, read -ra BINARIES <<< "$BINARIES_TO_INSTALL"
for binary in "${BINARIES[@]}"; do
  apt-get update && apt-get install -y "$binary"
done

# Or manually install specific binaries
apt-get update && apt-get install -y gh jq

# Setup shell alias (optional)
echo 'alias clawdbot="node /app/dist/entry.js"' >> ~/.bashrc
source ~/.bashrc
```

## Restart Persistence

After the first install, binaries and shell config will persist across container restarts.
