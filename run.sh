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

# ────────────────────────────────────────────────
# Function: detect if running in WSL
# ────────────────────────────────────────────────
is_wsl() {
    grep -qEi "(microsoft|wsl)" /proc/version &>/dev/null
}
# ────────────────────────────────────────────────
# Function: detect if running as root
# ────────────────────────────────────────────────
is_root() {
    [ "$(id -u)" -eq 0 ]
}

# ────────────────────────────────────────────────
# Function: display system information
# ────────────────────────────────────────────────
generate_sys_info() {
    echo "OS: $(uname -s)"
    echo "Kernel: $(uname -r)"
    echo "Distro: $(. /etc/os-release; echo $NAME $VERSION)"
    echo "WSL: $(if is_wsl; then echo "Yes"; else echo "No"; fi)"
    echo "Run as root: $(if is_root; then echo "Yes"; else echo "No"; fi)"
    echo "User: $(whoami)"
    echo "PWD: $(pwd)"
    echo "Date: $(date)"
}


get_distro() {
    local os_name
    local distro

    # Read the NAME field from /etc/os-release
    if [[ -f /etc/os-release ]]; then
        os_name=$(grep "^NAME=" /etc/os-release | cut -d= -f2 | tr -d '"')
    else
        echo "Error: /etc/os-release not found." >&2
        return 1
    fi

    # Map the NAME to a simplified distro identifier
    case "$os_name" in
        Debian*)
            distro="debian"
            ;;
        Ubuntu*)
            distro="ubuntu"
            ;;
        Arch*)
            distro="arch"
            ;;
        *)
            echo "Error: Unsupported distro: $os_name" >&2
            return 1
            ;;
    esac

    echo "$distro"
}
distro=$(get_distro)
# ────────────────────────────────────────────────
# Function: make to top banner
# ────────────────────────────────────────────────
# top_banner () {
#     local text="$1"
#     local width="$2"
#     local vl="$3"
#     local -n _block="$4"

#     while IFS= read -r line; do
#         local centered_line
#         # Proper centering if you want it later:
#         # centered_line=$(printf "%*s" $(( (${#line} + width) / 2 )) "$line")

#         centered_line="$line"

#         _block+=("$(printf "%s %-*s %s" "$vl" "$width" "$centered_line" "$vl")")
#     done <<< "$text"
# }
top_banner () {
    local text="$1"       # ASCII art or multiline text for the left column
    # local sys_info="$2"   # System information for the right column
    local width="$2"      # Total width of the banner
    local vl="$3"         # Vertical line character
    local -n _block="$4"  # Reference to the block array

    local sys_info="$(generate_sys_info)"  # Generate system information

    local left_width=$((width / 2))  # Width of the left column
    local right_width=$((width - left_width - 1))  # Width of the right column

    # Read both the left (ASCII art) and right (system info) inputs line by line
    local IFS=$'\n'
    local left_lines=($(echo "$text"))
    local right_lines=($(echo "$sys_info"))

    # Determine the maximum number of lines to process
    local max_lines=$(( ${#left_lines[@]} > ${#right_lines[@]} ? ${#left_lines[@]} : ${#right_lines[@]} ))

    for ((i = 0; i < max_lines; i++)); do
        local left_line="${left_lines[i]:-}"  # Default to an empty string if no more lines
        local right_line="${right_lines[i]:-}"  # Default to an empty string if no more lines

        # Format the left and right columns
        _block+=("$(printf "%s %-*s %-*s %s" "$vl" "$left_width" "$left_line" "$right_width" "$right_line" "$vl")")
    done
}
# ────────────────────────────────────────────────
# Function: build a block into an array
# ────────────────────────────────────────────────
build_block () {

    local title="$1"
    local list_input="$2"
    local -n BLOCK=$3   # reference to array name passed in
    local type="$4"
    local COLS="$5"
    local C_WIDTH=$(( ((WIDTH-2) / COLS) - 2 ))             # Width of a half window minus borders

    local TL_G="╔"  TR_G="╗"
    local BL_G="╚"  BR_G="╝"
    local HL="═"    VL="║"
    local VHL="╠"   VHR="╣"

    declare -A CORNER_TOP_LEFT=(
        [HEAD]="$TL_G"
        [C]="$VHL"
        [TL]="$VHL"
        [TR]="$TL_G"
        [BL]="$VHL"
        [BR]="$VHL"
    )
    declare -A CORNER_TOP_RIGHT=(
        [HEAD]="$TR_G"
        [C]="$VHR"
        [TL]="$TR_G"
        [TR]="$VHR"
        [BL]="$VHR"
        [BR]="$VHR"
    )
    declare -A CORNER_BOTTOM_LEFT=(
        [HEAD]="$VHL"
        [C]="$VHL"
        [TL]="$VHL"
        [TR]="$TL_G"
        [BL]="$BL_G"
        [BR]="$BL_G"
    )
    declare -A CORNER_BOTTOM_RIGHT=(
        [HEAD]="$VHL"
        [C]="$TL_G"
        [TL]="$VHL"
        [TR]="$TL_G"
        [BL]="$BL_G"
        [BR]="$BL_G"
    )

    BLOCK=()

    # Top border
    BLOCK+=("$(printf "%s%s%s" "${CORNER_TOP_LEFT[$type]}" "$(printf "%*s" "$((C_WIDTH+2))" "" | sed "s/ /$HL/g")" "${CORNER_TOP_RIGHT[$type]}")")

    # Title
    if [[ "$type" == "HEAD" ]]; then
    top_banner "$title" "$C_WIDTH" "$VL" BLOCK
        # top_banner "$title" BLOCK "$C_WIDTH" "$VL"
        # while IFS= read -r line; do
        #     local centered_line
        #     # centered_line=$(printf "%*s" $(( (${#line} + C_WIDTH) / 2 )) "$line")
        #     centered_line=$(printf "%*s" "" "$line")
        #     BLOCK+=("$(printf "%s %-*s %s" "$VL" "$C_WIDTH" "$centered_line" "$VL")")
        # done <<< "$title"
    else
        # Left-align the title for other types
        BLOCK+=("$(printf "%s %-*s %s" "$VL" "$C_WIDTH" "$title" "$VL")")
    fi
    # BLOCK+=("$(printf "%s %-*s %s" "$VL" "$C_WIDTH" "$title" "$VL")")

    # Spacer line
    # BLOCK+=("$(printf "%s %-*s %s" "$VL" "$HALF_WIDTH" "" "$VL")")

    # Listing lines
    while IFS= read -r line; do
        BLOCK+=("$(printf "%s %-*s %s" "$VL" "$C_WIDTH" "$line" "$VL")")
    done <<< "$list_input"

    # Bottom border
    # BLOCK+=("$(printf "%s%s%s" "${CORNER_BOTTOM_LEFT[$type]}" "$(printf "%*s" "$((HALF_WIDTH+2))" "" | sed "s/ /$HL/g")" "${CORNER_BOTTOM_RIGHT[$type]}")")
}

# create_checkbox_block() {
#     local -n items=$1  # Reference to the array passed as the first argument
#     local block_name=$2
#     local wrap_after=7 #$3  # Number of items per group

#     echo "*** $block_name"
#     local count=0
#     for item in "${items[@]}"; do
#         # Skip commented-out items
#         if [[ "$item" =~ ^# ]]; then
#             continue
#         fi
#         # echo "- [ ] $item"
#         # Start a new sublist after every `wrap_after` items
#         if (( count % wrap_after == 0 )); then
#             echo ""
#         fi

#         echo "- [ ] $item"
#         ((count++))
#     done
# }
# create_two_column_checkbox_block() {
#     local -n items=$1  # Reference to the array passed as the first argument
#     local block_name=$2

#     echo "*** $block_name"
#     local count=0
#     local left_column=""
#     local right_column=""

#     for item in "${items[@]}"; do
#         # Skip commented-out items
#         if [[ "$item" =~ ^# ]]; then
#             continue
#         fi

#         # Add to the left or right column based on the count
#         if (( count % 2 == 0 )); then
#             left_column="- [ ] $item"
#         else
#             right_column="- [ ] $item"
#             # Print the two columns side by side
#             printf "%-30s %s\n" "$left_column" "$right_column"
#         fi
#         ((count++))
#     done

#     # If there's an unpaired item in the left column, print it
#     if (( count % 2 != 0 )); then
#         printf "%-30s\n" "$left_column"
#     fi
# }

# Function to extract unique short names from the package list
extract_short_names() {
    local distro="$1"
    local -n full_list=$2  # Reference to the full package list
    local -n short_list=$3 # Reference to the output short name list

    for item in "${full_list[@]}"; do
        # Skip commented-out items
        if [[ "$item" =~ ^# ]]; then
            continue
        fi

        # If the item contains a colon, check if it matches the distro
        if [[ "$item" == *:* ]]; then
            if [[ "$item" != "$distro:"* ]]; then
                continue  # Exclude items that do not match the distro
            fi
        fi

        # Extract the name after the colon (or use the full name if no colon exists)
        short_name="${item#*:}"
        # # Extract the short name (everything before the colon, or the full name if no colon exists)
        # short_name="${item%%:*}"

        # Add the short name to the list if it's not already included
        if [[ ! " ${short_list[*]} " =~ " $short_name " ]]; then
            short_list+=("$short_name")
        fi
    done
}

is_installed() {
    local app="$1"
    local distro="$2"

    case "$distro" in
        debian|ubuntu)
            dpkg -l "$app" &>/dev/null
            return $?  # Return 0 if installed, non-zero otherwise
            ;;
        arch)
            pacman -Q "$app" &>/dev/null
            return $?  # Return 0 if installed, non-zero otherwise
            ;;
        *)
            echo "Unsupported distro: $distro" >&2
            return 1
            ;;
    esac
}

create_four_column_checkbox_block() {
    local -n items=$1  # Reference to the array passed as the first argument
    local block_name=$2
    local distro="$3"

    # echo "*** $block_name"
    local count=0
    local columns=()

    for item in "${items[@]}"; do
        # Skip commented-out items
        if [[ "$item" =~ ^# ]]; then
            continue
        fi

        # Add the item to the current row
        # Check if the application is installed
        if is_installed "$item" "$distro"; then
        columns+=("- [X] $item")
        else
        columns+=("- [ ] $item")
        fi
        # columns+=("- [ ] $item")

        # Print the row when it has 4 items
        if (( ${#columns[@]} == 4 )); then
            printf "%-25s %-25s %-25s %-25s\n" "${columns[@]}"
            columns=()  # Reset the columns array
        fi
    done

    # Print any remaining items in the last row
    if (( ${#columns[@]} > 0 )); then
        printf "%-25s %-25s %-25s %-25s\n" "${columns[@]}" "" "" ""
    fi
}

source install/packages.conf


while true; do
    clear

    # TITLE="Refresh every ${REFRESH}s "
    TITLE=" "
    # build_block "Model listing:" "$TITLE" HEAD_BLOCK "HEAD" 1
    ascii_logo=$(print_logo)
    build_block "$ascii_logo" "$TITLE" HEAD_BLOCK "HEAD" 1
    printf "%s\n" "${HEAD_BLOCK[@]}"


# create_checkbox_block SYSTEM_UTILS "System Utilities"

    # LEFT_INPUT=$(ls -lat)
    # build_block "Model listing:" "$LEFT_INPUT" LEFT_BLOCK "TR" 2
    # LEFT_INPUT=$(create_checkbox_block SYSTEM_UTILS "System Utilities")

    declare -a short_names
    extract_short_names "$distro" SYSTEM_UTILS short_names
    # LEFT_INPUT=$(create_four_column_checkbox_block SYSTEM_UTILS "System Utilities")
    LEFT_INPUT=$(create_four_column_checkbox_block short_names "System Utilities" "$distro")
    build_block "System utilities:" "$LEFT_INPUT" LEFT_BLOCK "C" 1
    printf "%s\n" "${LEFT_BLOCK[@]}"

    declare -a more_short_names
    extract_short_names "$distro" DEV_TOOLS more_short_names
    LEFT_INPUT=$(create_four_column_checkbox_block more_short_names "Development Tools" "$distro")
    build_block "Development tools:" "$LEFT_INPUT" LEFT_BLOCK "C" 1
    printf "%s\n" "${LEFT_BLOCK[@]}"

    declare -a more_short_names
    extract_short_names "$distro" MODEL_TOOLS model_short_names
    LEFT_INPUT=$(create_four_column_checkbox_block model_short_names "Model Tools" "$distro")
    build_block "Modelling tools:" "$LEFT_INPUT" LEFT_BLOCK "C" 1
    printf "%s\n" "${LEFT_BLOCK[@]}"

    declare -a r_short_names
    extract_short_names "$distro" R_PACKAGES r_short_names
    LEFT_INPUT=$(create_four_column_checkbox_block r_short_names "R packages" "$distro")
    build_block "R packages:" "$LEFT_INPUT" LEFT_BLOCK "C" 1
    printf "%s\n" "${LEFT_BLOCK[@]}"

    # build_block "System utilities:" "$LEFT_INPUT" LEFT_BLOCK "TR" 2
    # RIGHT_INPUT=$(ls -lat)
    # build_block "Model listing:" "$RIGHT_INPUT" RIGHT_BLOCK "TR" 2
    # max_lines=$(( ${#LEFT_BLOCK[@]} > ${#RIGHT_BLOCK[@]} ? ${#LEFT_BLOCK[@]} : ${#RIGHT_BLOCK[@]} ))
    # for ((i=0; i<max_lines; i++)); do
    # printf "%-*s%s%s\n" \
    # "$((HALF_WIDTH + 0))" \
    # "${LEFT_BLOCK[i]}" \
    # "$SPACER" \
    # "${RIGHT_BLOCK[i]}"
    # done

    # # Draw top border
    # printf "%s%s%s\n" "$TL" "$(printf "%*s" "$WIDTH" "" | sed "s/ /$HL/g")" "$TR"
    # printf "%s%*s%s%*s%s\n" "$VL" "$PAD" "" "$TITLE" "$((WIDTH - PAD - ${#TITLE}))" "" "$VL"
    # printf "%s%s%s\n" "$VHL" "$(printf "%*s" "$WIDTH" "" | sed "s/ /$HL/g")" "$VHR"


    sleep "$REFRESH"
done
