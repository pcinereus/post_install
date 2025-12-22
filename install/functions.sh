#!/bin/bash

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

# ────────────────────────────────────────────────
# Function: get the name of the linux distribution
# ────────────────────────────────────────────────
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

# ────────────────────────────────────────────────
# Function: make to top banner
# ────────────────────────────────────────────────
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

# ────────────────────────────────────────────────
# Function: extract unique short names from package list
# ────────────────────────────────────────────────
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

        # Add the short name to the list if it's not already included
        if [[ ! " ${short_list[*]} " =~ " $short_name " ]]; then
            short_list+=("$short_name")
        fi
    done
}

# ────────────────────────────────────────────────
# Function: determine whether a package is installed
# ────────────────────────────────────────────────
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

# ────────────────────────────────────────────────
# Function: arrange items in four column checkboxes
# ────────────────────────────────────────────────
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

# ────────────────────────────────────────────────
# Function: install missing packages
# ────────────────────────────────────────────────
install_missing_packages() {
    local -n packages=$1  # Reference to the array of packages
    local distro="$2"
    local log_file="$3"

    for package in "${packages[@]}"; do
        # Skip commented-out items
        if [[ "$package" =~ ^# ]]; then
            continue
        fi

        # Check if the package is already installed
        if ! is_installed "$package" "$distro"; then
            echo "Installing $package..." | tee -a "$log_file"
            case "$distro" in
                debian|ubuntu)
                    sudo apt-get install -y "$package" &>>"$log_file"
                    ;;
                arch)
                    # Try pacman first, fallback to yay if pacman fails
                    if ! sudo pacman -S --noconfirm "$package" &>>"$log_file"; then
                        echo "sudo pacman failed. Trying yay..." | tee -a "$log_file"
                        yay -S --noconfirm --answerclean All "$package" &>>"$log_file"
                    fi
                    # sudo pacman -S --noconfirm "$package" &>>"$log_file"
                    ;;
                *)
                    echo "Unsupported distro: $distro" | tee -a "$log_file"
                    ;;
            esac
        fi
    done
}

# ────────────────────────────────────────────────
# Function: Display the last 10 rows of the log file
# ────────────────────────────────────────────────
display_log_tail() {
    local log_file="install/install.log"
    local -n log_block=$1  # Reference to the block array

    if [[ -f "$log_file" ]]; then
        local log_tail
        log_tail=$(tail -n 10 "$log_file")
        build_block "Installation Log (Last 10 Rows):" "$log_tail" log_block "C" 1
    else
        build_block "Installation Log (Last 10 Rows):" "No log file found." log_block "C" 1
    fi
}
