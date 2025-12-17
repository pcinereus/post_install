#!/bin/bash

# Print the logo
print_logo() {
  cat <<"EOF"
  __  __                            _
 |  \/  |                          ( )
 | \  / |_   _ _ __ _ __ __ _ _   _|/ ___
 | |\/| | | | | '__| '__/ _` | | | | / __|
 | |  | | |_| | |  | | | (_| | |_| | \__ \
 |_|  |_|\__,_|_|  |_|_ \__,_|\__, | |___/
                  / _(_)       __/ |
   ___ ___  _ __ | |_ _  __ _ |___/
  / __/ _ \| '_ \|  _| |/ _` |
 | (_| (_) | | | | | | | (_| |
  \___\___/|_| |_|_| |_|\__, |
                         __/ |
                        |___/
EOF
}

# Clear screen and show logo
clear
print_logo

# Exit on any error
set -e

# Source utility functions
source install/utils.sh

# Source the package list
if [ ! -f "install/packages.conf" ]; then
  echo "Error: packages.conf not found!"
  exit 1
fi

source install/packages.conf

echo "Starting system setup..."

# Detect the Linux distribution
distro=$(detect_distro)

# Update the system based on the detected distribution
echo "Detected Linux distribution: $distro"
case "$distro" in
debian | ubuntu)
  echo "Updating system using apt..."
  # Make sure main, contrib, and non-free repositories are enabled
  # echo "deb http://deb.debian.org/debian stable main contrib non-free" | sudo tee -a /etc/apt/sources.list
  # sudo apt update && sudo apt upgrade -y
  # sudo apt install -y software-properties-common
  # sudo add-apt-repository ppa:neovim-ppa/stable
  sudo apt update && sudo apt upgrade -y
  ;;
arch)
  echo "Updating system using pacman..."
  sudo pacman -Syu --noconfirm
  # Install yay AUR helper if not present
  if ! command -v yay &>/dev/null; then
    echo "Installing yay AUR helper..."
    sudo pacman -S --needed git base-devel --noconfirm
    cd ~
    echo $PWD
    git clone https://aur.archlinux.org/yay.git
    cd yay
    echo "building yay.... yaaaaayyyyy"
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
  else
    echo "yay is already installed"
  fi
  ;;
fedora)
  echo "Updating system using dnf..."
  sudo dnf update -y
  ;;
*)
  echo "Unsupported Linux distribution: $distro"
  exit 1
  ;;
esac

# Install packages by category
echo "Installing system utilities..."
install_packages "${SYSTEM_UTILS[@]}"

echo "Installing development tools..."
install_packages "${DEV_TOOLS[@]}"

echo "Installing modelling tools..."
install_packages "${MODEL_TOOLS[@]}"

echo "Installing package managed R packages..."
install_packages "${R_PACKAGES[@]}"

echo "Installing other R packages..."
sudo Rscript install_r_packages.R
