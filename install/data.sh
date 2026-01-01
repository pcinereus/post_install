#!/bin/bash


menu_key() {
    local name="$1"
    name="${name,,}"               # lowercase
    name="${name// /_}"            # spaces -> underscores
    echo "$name"
}

packages_to_array() {
    local raw="$1"
    local -n out=$2

    out=()

    while IFS= read -r line; do
        # Trim leading/trailing whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"

        # Skip empty or commented lines
        [[ -z "$line" || "$line" == \#* ]] && continue

        out+=( "$line" )
    done <<< "$raw"
}

extract_short_names() {
    local distro="$1"
    local -n full_list=$2
    local -n short_list=$3

    short_list=()
    for item in "${full_list[@]}"; do
        # Skip comments
        [[ "$item" == \#* ]] && continue

        if [[ "$item" == *:* ]]; then
            local prefix="${item%%:*}"
            local name="${item#*:}"
            # Keep only matching distro
            [[ "$prefix" != "$distro" ]] && continue
            short_list+=( "$name" )
        else
            # No distro prefix → always include
            short_list+=( "$item" )
        fi
    done
}


debug_menu() {
    local -n DATA_REF="$1"
    local -n ORDER_REF="$2"

    echo "========== DATA DEBUG =========="
    echo

    for mkey in "${ORDER_REF[@]}"; do
        echo "DATA KEY: $mkey"
        echo "  Name     : ${DATA_REF[$mkey.menu_name]}"
        echo "  Shortcut : ${DATA_REF[$mkey.shortcut]}"
        echo "  CheckTypes: ${DATA_REF[$mkey.check_types]}"
        # echo "  Packages: ${DATA_REF[$mkey.packages]}"
        echo

        for ct in ${DATA_REF[$mkey.check_types]}; do
            echo "    [$ct]"
            local pkgs="${DATA_REF[$mkey.packages.$ct]:-}"
            if [[ -z "$pkgs" ]]; then
                echo "      (no packages)"
            else
                for pkg in $pkgs; do
                    echo "      - $pkg"
                done
            fi
            echo
        done

        echo "  InstallTypes: ${DATA_REF[$mkey.install_types]}"
        for ct in ${DATA_REF[$mkey.install_types]}; do
            echo "    [$ct]"
            local pkgs="${DATA_REF[$mkey.packages.$ct]:-}"
            if [[ -z "$pkgs" ]]; then
                echo "      (no packages)"
            else
                for pkg in $pkgs; do
                    echo "      - $pkg"
                done
            fi
            echo
        done
        ## Check the install → check map
        for it in ${DATA[$mkey.install_types]}; do
            echo "$mkey: $it → ${DATA[$mkey.install_to_check.$it]}"
        done
        # echo "  Install to check map: ${DATA_REF[$mkey.install_to_check]}"
        echo "--------------------------------"
    done

    echo "========== END DEBUG =========="
}



# ─────────────────────────────────────────────────────────────────────
# Main code
# ─────────────────────────────────────────────────────────────────────
source install/packages.conf
declare -A DATA              # data metadata
declare -a DATA_ORDER=()     # ordered list of data keys

for category in "${CATEGORIES[@]}"; do
    declare -n cat="$category"

    install_type="${cat[install_type]}"
    check_type="${cat[check_type]:-$install_type}"

    # Stable menu key
    mkey="$(menu_key "${cat[menu_name]}")"

    # Register menu once
    if [[ -z "${DATA[$mkey.menu_name]:-}" ]]; then
        DATA_ORDER+=( "$mkey" )
        DATA["$mkey.menu_name"]="${cat[menu_name]}"
        DATA["$mkey.shortcut"]="${cat[shortcut]}"
        DATA["$mkey.install_types"]=""
        DATA["$mkey.check_types"]=""
    fi

    # Register check_type once per menu
    if [[ ! " ${DATA[$mkey.check_types]} " =~ " $check_type " ]]; then
        DATA["$mkey.check_types"]+="$check_type "
    fi
    if [[ ! " ${DATA[$mkey.install_types]} " =~ " $install_type " ]]; then
        DATA["$mkey.install_types"]+="$install_type "
    fi

    # Parse packages
    _pkg_array=()
    packages_to_array "${cat[packages]}" _pkg_array

    _short_pkgs=()
    extract_short_names "$distro" _pkg_array _short_pkgs

    # Append packages per check_type
    DATA["$mkey.packages.$install_type"]+="${_short_pkgs[*]} "

    # Map install → check
    DATA["$mkey.install_to_check.$install_type"]="$check_type"
done

# debug_menu DATA DATA_ORDER
# sleep 100

TABS=()
for mkey in "${DATA_ORDER[@]}"; do
  TABS+=( "${DATA[$mkey.menu_name]} (${DATA[$mkey.shortcut]})" )
done
ACTIVE_TAB=0
