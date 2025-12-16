#!/bin/sh
set -eu

DOTFILES="$HOME/.dotfiles"

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Cannot detect OS"
    exit 1
fi

# Install dependencies
install_deps() {
    case "$ID" in
        debian|ubuntu)
            sudo apt update
            sudo apt install -y git curl stow
            ;;
        arch)
            sudo pacman -Sy --noconfirm git curl stow
            ;;
        *)
            echo "Unsupported distro: $ID"
            exit 1
            ;;
    esac
}

# Ensure sudo exists (WSL edge case)
command -v sudo >/dev/null || {
    echo "sudo missing — running as root?"
}

# Install deps
install_deps

# Clone dotfiles
if [ ! -d "$DOTFILES" ]; then
    git clone https://github.com/USERNAME/dotfiles.git "$DOTFILES"
fi

cd "$DOTFILES"
