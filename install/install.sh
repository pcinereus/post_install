#!/bin/bash

set -euo pipefail

init_stage_log() {
  : > "$stage_file"
  # for category in "${CATEGORIES[@]}"; do
  for category in "${DATA_ORDER[@]}"; do
    printf "%s|%d\n" "$category" "$STAGE_NOT_ATTEMPTED" >>"$stage_file"
  done
}

update_stage() {
  local category="$1"
  local status="$2"

  awk -F'|' -v cat="$category" -v st="$status" '
    BEGIN { OFS="|" }
    {
      curr = ($1 == cat ? "*" : "")
      stat = ($1 == cat ? st : $2)
      print $1, stat, curr
    }
  ' "$stage_file" >"$stage_file.tmp" && mv "$stage_file.tmp" "$stage_file"
}

run_install_type() {
  local install_type="$1"
  local -a packages="$2"
  read -ra packages <<< "${packages[@]}"

  for package in "${packages[@]}"; do
      # Skip commented-out items
      if [[ "$package" =~ ^# ]]; then
          continue
      fi
      # echo "          Installing package: $package using install type: $install_type"
      case "$install_type" in
          package)
              install_package "$package" "$distro" "$log_file"
              return $?
              ;;
          r_cran_package)
              install_R_package "$package" "$log_file"
              return $?
              ;;
          r_github_package)
              install_R_git_package "$package" "$log_file"
              return $?
              ;;
          r_inla_package)
              install_inla
              return $?
              ;;
          python_package)
              install_python_package "$package" "$log_file"
              return $?
              ;;
          *)
              echo "Unknown install type: $install_type" >&2
              return 1
              ;;
      esac
  done
}

install_package() {
    local package=$1  # Reference to the array of packages
    local distro="$2"
    local log_file="$3"

    # echo "Installing $package..." | tee -a "$log_file"
    case "$distro" in
        debian|ubuntu)
            sudo apt-get install -y "$package" &>>"$log_file"
            ;;
        arch)
            # Try pacman first, fallback to yay if pacman fails
            if ! sudo pacman -S --noconfirm "$package" &>>"$log_file"; then
                # echo "sudo pacman failed. Trying yay..." | tee -a "$log_file"
                yay -S --noconfirm --answerclean All "$package" &>>"$log_file"
            fi
            # sudo pacman -S --noconfirm "$package" &>>"$log_file"
            ;;
        *)
            echo "Unsupported distro: $distro" | tee -a "$log_file"
            ;;
    esac
}

run_category() {
    local mkey="$1"
    local name="$mkey"

    update_stage "$name" "$STAGE_CURRENT"
    local install_types="${DATA[$mkey.install_types]}"
    read -ra install_types <<< "$install_types"
    local check_types="${DATA[$mkey.check_types]}"
    for itype in "${install_types[@]}"; do
        if ! run_install_type "$itype" "${DATA[$mkey.packages.$itype]}"; then
            update_stage "$name" "$STAGE_FAILED"
            return 1
        fi
    done
    update_stage "$name" "$STAGE_SUCCESS"
}


# ─────────────────────────────────────────────────────────────────────
# Main code
# ─────────────────────────────────────────────────────────────────────

source install/functions.sh
source install/packages.conf

log_file="install/install.log"
flag_file="install/install.flag"
stage_file="install/stage.log"

# Clear the log file at the start
> "$log_file"
rm -f "$flag_file"

sudo -v

# Create the flag file to signal that the password has been supplied
touch "$flag_file"

# Keep the sudo session alive
(while true; do sudo -n true; sleep 60; done 2>/dev/null) &

# Detect the distro
distro=$(get_distro)

STAGE_NOT_ATTEMPTED=0
STAGE_CURRENT=-1
STAGE_SUCCESS=1
STAGE_FAILED=2

init_stage_log

for mkey in "${DATA_ORDER[@]}"; do
    # echo "Processing menu key: $mkey"
    run_category "$mkey"
done

#rm -f "$flag_file"
