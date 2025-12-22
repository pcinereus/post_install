#!/bin/bash

source install/functions.sh
source install/packages.conf

log_file="install/install.log"
flag_file="install/install.flag"

# Clear the log file at the start
> "$log_file"
rm -f "$flag_file"

# Prompt for sudo password at the start
sudo -v

# Create the flag file to signal that the password has been supplied
touch "$flag_file"

# Keep the sudo session alive
(while true; do sudo -n true; sleep 60; done 2>/dev/null) &

# Detect the distro
distro=$(get_distro)

# Install packages for each category
declare -a system_names
extract_short_names "$distro" SYSTEM_UTILS system_names
install_missing_packages system_names "$distro" "$log_file"

declare -a dev_short_names
extract_short_names "$distro" DEV_TOOLS dev_short_names
install_missing_packages dev_short_names "$distro"

declare -a model_short_names
extract_short_names "$distro" MODEL_TOOLS model_short_names
install_missing_packages model_short_names "$distro"

declare -a r_short_names
extract_short_names "$distro" R_PACKAGES r_short_names
install_missing_packages r_short_names "$distro"

echo "Installation complete. See $log_file for details." > "$log_file"
