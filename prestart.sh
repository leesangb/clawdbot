#!/bin/sh
set -e

# Prestart script for dokploy deployment
# Ensures binaries and shell configuration persist across restarts

echo "[prestart] Checking binaries to install..."

# Create shell config directory
mkdir -p /root/.config/shell

# Setup aliases if not already set
if ! grep -q "alias clawdbot=" /root/.bashrc /root/.config/shell/aliases.sh 2>/dev/null; then
  echo "[prestart] Setting up clawdbot alias..."
  echo 'alias clawdbot="node /app/dist/entry.js"' > /root/.config/shell/aliases.sh
  if [ -n "$BASH_VERSION" ]; then
    echo 'source /root/.config/shell/aliases.sh' >> /root/.bashrc
  elif [ -n "$ZSH_VERSION" ]; then
    echo 'source /root/.config/shell/aliases.sh' >> /root/.zshrc
  fi
fi

# Install binaries from BINARIES_TO_INSTALL env var if not present
if [ -n "$BINARIES_TO_INSTALL" ]; then
  echo "[prestart] Installing binaries: $BINARIES_TO_INSTALL"
  IFS=, read -ra BINARIES <<< "$BINARIES_TO_INSTALL"
  NEED_INSTALL=0

  for binary in "${BINARIES[@]}"; do
    binary=$(echo "$binary" | xargs)  # trim whitespace
    if [ -n "$binary" ] && [ ! -f "/usr/local/bin/$binary" ] && ! command -v "$binary" >/dev/null 2>&1; then
      NEED_INSTALL=1
      break
    fi
  done

  if [ "$NEED_INSTALL" -eq 1 ]; then
    echo "[prestart] Running apt-get update..."
    apt-get update -qq

    for binary in "${BINARIES[@]}"; do
      binary=$(echo "$binary" | xargs)
      if [ -n "$binary" ] && ! command -v "$binary" >/dev/null 2>&1; then
        echo "[prestart] Installing $binary..."
        apt-get install -y "$binary"
      fi
    done
  else
    echo "[prestart] All binaries already installed."
  fi
else
  echo "[prestart] No BINARIES_TO_INSTALL set, skipping binary installation."
fi

# GitHub CLI authentication
if [ -n "$GITHUB_TOKEN" ] && command -v gh >/dev/null 2>&1; then
  echo "[prestart] Checking GitHub authentication..."
  if ! gh auth status >/dev/null 2>&1; then
    echo "[prestart] Logging in to GitHub with token..."
    echo "$GITHUB_TOKEN" | gh auth login --with-token
    echo "[prestart] GitHub login successful."
  else
    echo "[prestart] Already logged in to GitHub."
  fi
fi

echo "[prestart] Complete, starting application..."
exec "$@"
