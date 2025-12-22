#!/bin/bash
set -eu

# Print the logo
print_logo() {
  cat <<"EOF"
  __  __                            _
 |  \/  |                          ( )
 | \  / |_   _ _ __ _ __ __ _ _   _|/ ___
 | |\/| | | | | '__| '__/ _` | | | | / __|
 | |  | | |_| | |  | | | (_| | |_| | \__ \
 |_|  |_|\__,_|_|  |_|  \__,_|\__, | |___/
                  _          _ __/ |     _        _ _
                 | |        (_)___/     | |      | | |
  _ __   ___  ___| |_ ______ _ _ __  ___| |_ __ _| | |
 | '_ \ / _ \/ __| __|______| | '_ \/ __| __/ _` | | |
 | |_) | (_) \__ \ |_       | | | | \__ \ || (_| | | |
 | .__/ \___/|___/\__|  _   |_|_| |_|___/\__\__,_|_|_|
 | |           (_)     | |
 |_|_  ___ _ __ _ _ __ | |_
 / __|/ __| '__| | '_ \| __|
 \__ \ (__| |  | | |_) | |_
 |___/\___|_|  |_| .__/ \__|
                 | |
                 |_|
EOF
}


# ────────────────────────────────────────────────
# Parameters
# ────────────────────────────────────────────────
REFRESH=10                                        # seconds
WIDTH=120                                         # total width of the display
HALF_WIDTH=$(( ((WIDTH-2) / 2) - 2 ))             # Width of a half window minus borders
SPACER=""                                         # space between columns

source install/functions.sh
source install/packages.conf

distro=$(get_distro)

# ────────────────────────────────────────────────
# Get the short names of applications
# ────────────────────────────────────────────────
## System Utilities
declare -a system_names
extract_short_names "$distro" SYSTEM_UTILS system_names
## Development Tools
declare -a dev_names
extract_short_names "$distro" DEV_TOOLS dev_names
## Model Tools
declare -a model_names
extract_short_names "$distro" MODEL_TOOLS model_names
## R Packages
declare -a r_names
extract_short_names "$distro" R_PACKAGES r_names

# Start the installation script in the background
./install/install.sh &

flag_file="install/install.flag"

# Wait for the flag file to be created
while [[ ! -f "$flag_file" ]]; do
    # echo "Waiting for the installation script to be ready..."
    sleep 1
done

BL_G="╚"
BR_G="╝"
# ────────────────────────────────────────────────
# Main Display Loop
# ────────────────────────────────────────────────
while true; do
    clear

    TITLE=" "
    ascii_logo=$(print_logo)
    build_block "$ascii_logo" "$TITLE" HEAD_BLOCK "HEAD" 1
    printf "%s\n" "${HEAD_BLOCK[@]}"

    LEFT_INPUT=$(create_four_column_checkbox_block system_names "System Utilities" "$distro")
    build_block "System utilities:" "$LEFT_INPUT" LEFT_BLOCK "C" 1
    printf "%s\n" "${LEFT_BLOCK[@]}"

    LEFT_INPUT=$(create_four_column_checkbox_block dev_names "Development Tools" "$distro")
    build_block "Development tools:" "$LEFT_INPUT" LEFT_BLOCK "C" 1
    printf "%s\n" "${LEFT_BLOCK[@]}"

    LEFT_INPUT=$(create_four_column_checkbox_block model_names "Model Tools" "$distro")
    build_block "Modelling tools:" "$LEFT_INPUT" LEFT_BLOCK "C" 1
    printf "%s\n" "${LEFT_BLOCK[@]}"

    LEFT_INPUT=$(create_four_column_checkbox_block r_names "R packages" "$distro")
    build_block "R packages:" "$LEFT_INPUT" LEFT_BLOCK "C" 1
    printf "%s\n" "${LEFT_BLOCK[@]}"


    # # Draw top border
    # printf "%s%s%s\n" "$TL" "$(printf "%*s" "$WIDTH" "" | sed "s/ /$HL/g")" "$TR"
    # printf "%s%*s%s%*s%s\n" "$VL" "$PAD" "" "$TITLE" "$((WIDTH - PAD - ${#TITLE}))" "" "$VL"
    # printf "%s%s%s\n" "$VHL" "$(printf "%*s" "$WIDTH" "" | sed "s/ /$HL/g")" "$VHR"

    # Display the last 10 rows of the installation log
    display_log_tail LOG_BLOCK
    printf "%s\n" "${LOG_BLOCK[@]}"

    printf "%s%s%s\n" "$BL_G" "$(printf "%*s" "$WIDTH" "" | sed "s/ /$BR_G/g")" "$BR_G"
    sleep "$REFRESH"
done
