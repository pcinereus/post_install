#!/bin/bash

# Function to check if a package is installed
is_installed() {
  case "$distro" in
  debian | ubuntu)
    dpkg -l "$1" &>/dev/null
    ;;
  arch)
    pacman -Qi "$1" &>/dev/null
    ;;
  fedora)
    rpm -q "$1" &>/dev/null
    ;;
  *)
    echo "Unsupported Linux distribution: $distro"
    exit 1
    ;;
  esac
}

# Function to install packages if not already installed
install_packages() {
  local packages=("$@")
  local to_install=()

  for pkg in "${packages[@]}"; do
    # Parse distribution-specific package names
    if [[ "$pkg" == *:* ]]; then
      IFS=":" read -r pkg_distro pkg_name <<<"$pkg"
      if [[ "$pkg_distro" == "$distro" ]]; then
        pkg="$pkg_name"
      else
        continue
      fi
    fi

    # Check if the package is installed
    if ! is_installed "$pkg"; then
      to_install+=("$pkg")
    fi
  done

  if [ ${#to_install[@]} -ne 0 ]; then
    echo "Installing: ${to_install[*]}"
    case "$distro" in
    debian | ubuntu)
      sudo apt install -y "${to_install[@]}"
      ;;
    arch)
      sudo pacman -S --noconfirm "${to_install[@]}"
      ;;
    fedora)
      sudo dnf install -y "${to_install[@]}"
      ;;
    *)
      echo "Unsupported Linux distribution: $distro"
      exit 1
      ;;
    esac
  else
    echo "All packages are already installed."
  fi
}

## Quarto =============================================================

# Define Quarto version
QUARTO_VERSION=1.7.32

# Function to check if Quarto is installed
is_quarto_installed() {
  command -v quarto &>/dev/null
}

# Function to install Quarto on Debian-based systems
install_quarto_debian() {
  echo "Installing Quarto version ${QUARTO_VERSION}..."
  curl -o quarto-linux-amd64.deb -L https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb
  sudo apt update
  sudo apt install -y gdebi-core
  sudo gdebi --non-interactive quarto-linux-amd64.deb
  rm quarto-linux-amd64.deb
}

# Function to install Quarto on Arch-based systems
install_quarto_arch() {
  echo "Installing Quarto version ${QUARTO_VERSION}..."
  curl -o quarto-linux.tar.gz -L https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz
  tar -xzf quarto-linux.tar.gz
  sudo mv quarto-${QUARTO_VERSION} /opt/quarto
  sudo ln -s /opt/quarto/bin/quarto /usr/local/bin/quarto
  rm quarto-linux.tar.gz
}

# Detect Linux distribution
detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$ID"
  else
    echo "unknown"
  fi
}

# Main script
install_quarto() {
  if is_quarto_installed; then
    echo "Quarto is already installed."
  else
    distro=$(detect_distro)
    echo "Detected Linux distribution: $distro"
    case "$distro" in
    debian | ubuntu)
      install_quarto_debian
      ;;
    arch)
      install_quarto_arch
      ;;
    *)
      echo "Unsupported Linux distribution: $distro"
      exit 1
      ;;
    esac
  fi
}

## Install INLA
install_inla() {

  # Fetch the INLA versions from the website
  html_content=$(curl -s https://www.r-inla.org/download-install)

  # Extract INLA versions from the HTML content
  versions=$(echo "$html_content" | \
    grep -oP '(?<=&lt;td&gt;&lt;code&gt;)[0-9]+\.[0-9]+\.[0-9]+(?=&lt;/code&gt;)' | sort -u)

  # Convert the versions into an array
  IFS=$'\n' read -r -d '' -a version_array <<< "$versions"

  # Display the versions as a menu
  echo "Available INLA versions:"
  for i in "${!version_array[@]}"; do
    echo "$((i + 1)). ${version_array[i]}"
  done

  # Prompt the user to select a version
  read -p "Enter the number corresponding to the version you want to install: " choice

  # Validate the user's choice
  if [[ $choice -lt 1 || $choice -gt ${#version_array[@]} ]]; then
    echo "Invalid choice. Exiting."
    return 1
  fi

  # Get the selected version
  selected_version=${version_array[$((choice - 1))]}
  echo "You selected version $selected_version."

  # sudo Rscript -e "if (!requireNamespace('INLA', quietly = TRUE)) remotes::install_version('INLA', version = '25.06.13',
 # repos = c(getOption('repos'), INLA = 'https://inla.r-inla-download.org/R/testing'), dep = TRUE)"
  sudo Rscript -e "if (!requireNamespace('INLA', quietly = TRUE)) remotes::install_version('INLA', version = '$selected_version', repos = c(getOption('repos'), INLA = 'https://inla.r-inla-download.org/R/testing'), dep = TRUE)"

  # now since this was installed as root, we need to make a couple of files executable as anyone
  sudo chmod a+x /usr/local/lib/R/site-library/INLA/bin/linux/64bit/inla.mkl.run
  sudo chmod a+x /usr/local/lib/R/site-library/INLA/bin/linux/64bit/inla.mkl
}

## Install python packages
install_python_packages() {
  local packages=("$@")
  local VENV_DIR="$HOME/python-venv"
  if ! command -v pip &>/dev/null; then
    echo "pip is not installed. Please install pip first."
    exit 1
  fi

  if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment in $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
    echo "Virtual environment created successfully!"
  else
    echo "Virtual environment already exists at $VENV_DIR."
  fi

  source "$VENV_DIR/bin/activate"
  for pkg in "${packages[@]}"; do
    if ! pip show "$pkg" &>/dev/null; then
      echo "Installing Python package: $pkg"
      # pip install "$pkg" --break-system-packages
      pip install "$pkg"
    else
      echo "Python package $pkg is already installed."
    fi
  done
  deactivate
}

## Install yazi =======================================================

is_yazi_installed() {
  command -v yazi &>/dev/null
}
# Function to install Yazi on Debian/Ubuntu
install_yazi_debian() {
  echo "Installing Yazi on Debian/Ubuntu..."
  sudo apt update
  # curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  # rustup updat -y
  # sudo chmod +x /usr/local/bin/yazi
  cd ~/tmp
  # git clone https://github.com/sxyazi/yazi.git
  cd yazi
  # cargo build --release --locked
  sudo mv target/release/yazi /usr/local/bin/
  sudo mv target/release/ya /usr/local/bin/
  echo "Yazi installed successfully!"
}

# Function to install Yazi on Arch Linux
install_yazi_arch() {
  echo "Installing Yazi on Arch Linux..."
  sudo pacman -Syu --noconfirm curl
  curl -fsSL https://github.com/sxyazi/yazi/releases/latest/download/yazi-linux-x86_64 -o /usr/local/bin/yazi
  sudo chmod +x /usr/local/bin/yazi
  echo "Yazi installed successfully!"
}

# Main script
install_yazi() {
  if is_yazi_installed; then
    echo "Yazi is already installed."
  else
    distro=$(detect_distro)
    echo "Detected Linux distribution: $distro"
    case "$distro" in
    debian | ubuntu)
      install_yazi_debian
      ;;
    arch)
      install_yazi_arch
      ;;
    *)
      echo "Unsupported Linux distribution: $distro"
      exit 1
      ;;
    esac
  fi
}

##########################################
install_fonts() {
    ## Install fonts
    FONT_DIR="$HOME/.local/share/fonts"
    TMP_DIR=$(mktemp -d)
    cp ~/.dotfiles/fonts/xkcd.ttf "$FONT_DIR"
    cp ~/.dotfiles/fonts/Hannahs_Messy_Handwriting.ttf "$FONT_DIR"
    cp ~/.dotfiles/fonts/CabinSketch-Bold.ttf "$FONT_DIR"
    cp "/home/murray/.dotfiles/fonts/Complete in Him.ttf" "$FONT_DIR"
    cp ~/.dotfiles/fonts/veteran_typewriter.ttf "$FONT_DIR"
    cp "/home/murray/.dotfiles/fonts/FFF Tusj.ttf" "$FONT_DIR"

    sudo fc-cache -fv "$FONT_DIR"
}
