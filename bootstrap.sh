#!/bin/sh
set -eu

#######################################################################
## This script bootstraps the post_install setup                      #
## Specifically, it:                                                  #
## - detects the OS                                                   #
## - ensures dependencies are installed,                              #
## - creates a non-root user if needed                                #
## - clones (or pulls) the full post-install repository               #
#######################################################################



echo "Starting bootstrap script..."

log()  { printf '[*] %s\n' "$*"; }
ok()   { printf '[✓] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*" >&2; }

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    log "Detected OS: $NAME ($ID)"
else
    echo "Cannot detect OS"
    exit 1
fi

# Determine if running in WSL
is_wsl() {
    grep -qEi "(microsoft|wsl)" /proc/version &>/dev/null
}

# Determine whether the distro is arch
is_arch() {
    [ -f /etc/os-release ] && . /etc/os-release && [ "$ID" = "arch" ]
}

# Determine whether the script is being run by root
is_root() {
    [ "$(id -u)" -eq 0 ]
}

if is_root; then
    log "Running as root user"
else
    TARGET_USER="$(awk -F: '($3 >= 1000 && $3 < 65534 && $1 != "nobody") { print $1; exit }' /etc/passwd)"
    log "Running as user: $TARGET_USER"
fi


# Determine whether there is a user defined
has_non_root_user() {
    USERS="$(awk -F: '$3 >= 1000 { print $1 }' /etc/passwd | grep -v '^nobody$')"
    if [ -n "$USERS" ]; then
        ok "Found non-root user(s): $USERS"
        return 0
    else
        warn "No non-root users found, I will prompt you to create one."
        return 1
    fi
}

# Function to create a user
create_user() {
    printf "No non-root users found.\n"
    printf "Enter username to create: "
    read USERNAME

    if [ -z "$USERNAME" ]; then
        echo "Username cannot be empty"
        exit 1
    fi

    useradd -m -s /bin/bash -G wheel "$USERNAME"
    echo "Set password for $USERNAME"
    passwd "$USERNAME"

    # Ensure sudo is installed
    pacman -Sy --noconfirm sudo

    # Enable wheel group sudo
    if ! grep -q '^%wheel' /etc/sudoers; then
        sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
    fi

    printf "User %s created and added to wheel.\n" "$USERNAME"
    printf "Please re-run this script as that user.\n"
    exit 0
}

# Ensure sudo exists (WSL edge case)
command -v sudo >/dev/null || {
    echo "sudo missing — running as root?"
}



# If the distro is arch, and there is no users, create a user
if is_arch; then
    if ! has_non_root_user; then
        if [ "$(id -u)" -ne 0 ]; then
            echo "No non-root users exist, but not running as root."
            exit 1
        fi
        create_user
    fi

    if is_root; then
        TARGET_USER="$(awk -F: '($3 >= 1000 && $3 < 65534 && $1 != "nobody") { print $1; exit }' /etc/passwd)"
        warn "Running as root on Arch Linux is not recommended."
        echo "    Please run this script as a non-root user."
        echo "    e.g. with su - $TARGET_USER"
        # if is_wsl; then
        #     # warn "Detected WSL environment. Adjusting for WSL."
        #     # # Temporarily allow passwordless sudo for the current session
        #     # echo "Defaults rootpw" | sudo tee -a /etc/sudoers.d/wsl >/dev/null
        #     # chmod 440 /etc/sudoers.d/wsl
        #     # TARGET_USER="$(awk -F: '($3 >= 1000 && $3 < 65534 && $1 != "nobody") { print $1; exit }' /etc/passwd)"
        #     # SCRIPT_PATH="$(curl -fsSL https://raw.githubusercontent.com/pcinereus/post_install/main/bootstrap.sh)"
        #     # log "[*] Re-running bootstrap as user '$TARGET_USER'"
        #     # exec su - "$TARGET_USER" -c "$SCRIPT_PATH"
        #     # # Clean up the sudoers file after execution
        #     # sudo rm -f /etc/sudoers.d/wsl
        # else
        #     # # SCRIPT_PATH="$(readlink -f "$0")"
        #     # SCRIPT_PATH="$(curl -fsSL https://raw.githubusercontent.com/pcinereus/post_install/main/bootstrap.sh)"
        #     # TARGET_USER="$(awk -F: '($3 >= 1000 && $3 < 65534 && $1 != "nobody") { print $1; exit }' /etc/passwd)"
        #     # log "****** as user '$TARGET_USER'"
        #     # exec su - "$TARGET_USER" -c "$SCRIPT_PATH"
        # fi
        exit 1
    fi
fi




# Install dependencies
install_deps() {
    case "$ID" in
        debian|ubuntu)
            sudo apt update
            sudo apt install -y git curl stow
            ;;
        arch)
            echo "*** For those about to sudu"
            sudo -S pacman -Sy --noconfirm git curl stow
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

# Swith to the user
TARGET_USER="$(awk -F: '($3 >= 1000 && $3 < 65534 && $1 != "nobody") { print $1; exit }' /etc/passwd)"
USER_HOME="$(eval echo ~$TARGET_USER)"
REPO="$USER_HOME/post_install"
log "User home: $USER_HOME"
log "User: $TARGET_USER"
log "repo: $REPO"

# Clone post_install repo
if [ "$(id -u)" -eq 0 ]; then    #if running as root (new arch install)
    log 'Running as root'
    sudo -u "$TARGET_USER" bash -c "
      if [ ! -d \"$REPO\" ]; then
        cd \"$USER_HOME\"
        git clone https://github.com/pcinereus/post_install.git \"$REPO\"
      else
        echo '[*] post_install repo already exists'
        cd \"$REPO\"
        git pull
      fi
    "
else  # if running as normal user
    echo "Running as user $(whoami)"
    if [ ! -d "$REPO" ]; then
        cd "$USER_HOME"
        git clone https://github.com/pcinereus/post_install.git "$REPO"
    else
        cd "$REPO"
        git pull
    fi
fi

cd "$REPO"

# Run OS-specific installs
#log "Distribution: $ID"
#case "$ID" in
#    debian)  sh install/debian.sh ;;
#    ubuntu) sh install/ubuntu.sh ;;
#    arch)   sh install/arch.sh ;;
#esac

# Install software
# sh install/install.sh
bash run.sh
