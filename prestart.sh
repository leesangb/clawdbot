#!/bin/sh

echo "[prestart] Starting prestart script..."

install_binaries() {
  if [ -z "$BINARIES_TO_INSTALL" ]; then
    echo "[prestart] No BINARIES_TO_INSTALL set, skipping."
    return 0
  fi

  echo "[prestart] Binaries to install: $BINARIES_TO_INSTALL"
  
  NEED_INSTALL=0
  OLD_IFS="$IFS"
  IFS=','
  for binary in $BINARIES_TO_INSTALL; do
    binary=$(echo "$binary" | tr -d ' ')
    if [ -n "$binary" ] && ! command -v "$binary" >/dev/null 2>&1; then
      echo "[prestart] $binary not found, will install"
      NEED_INSTALL=1
    else
      echo "[prestart] $binary already available"
    fi
  done
  IFS="$OLD_IFS"

  if [ "$NEED_INSTALL" -eq 1 ]; then
    echo "[prestart] Running apt-get update..."
    apt-get update -qq || { echo "[prestart] apt-get update failed"; return 1; }

    OLD_IFS="$IFS"
    IFS=','
    for binary in $BINARIES_TO_INSTALL; do
      binary=$(echo "$binary" | tr -d ' ')
      if [ -n "$binary" ] && ! command -v "$binary" >/dev/null 2>&1; then
        echo "[prestart] Installing $binary..."
        apt-get install -y "$binary" || echo "[prestart] Failed to install $binary"
      fi
    done
    IFS="$OLD_IFS"
  else
    echo "[prestart] All binaries already installed."
  fi
}

setup_github_auth() {
  if [ -n "$GITHUB_TOKEN" ] && command -v gh >/dev/null 2>&1; then
    echo "[prestart] Setting up GitHub authentication..."
    if ! gh auth status >/dev/null 2>&1; then
      echo "$GITHUB_TOKEN" | gh auth login --with-token && echo "[prestart] GitHub login successful."
    else
      echo "[prestart] Already logged in to GitHub."
    fi
  fi
}

install_binaries
setup_github_auth

echo "[prestart] Complete."
exec "$@"
