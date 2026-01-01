#!/bin/bash

# +-------------------------------------------------------------------+
# |                           get_distro                              |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~get_distro~ function identifies the Linux distribution by    |
# | reading the ~NAME~ field from the =/etc/os-release= file and maps |
# | it to a simplified distro identifier.                             |
# |                                                                   |
# | *Parameters:*                                                     |
# | + The function does not accept any parameters.                    |
# |                                                                   |
# | *Return Value:*                                                   |
# | + On success, the function outputs a simplified distro identifier |
# |   (e.g., ~debian~, ~ubuntu~, ~arch~).                             |
# | + On failure, it outputs an error message to standard error and   |
# |   returns a non-zero exit code.                                   |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function checks if the =/etc/os-release= file exists.      |
# |    - If the file is not found, it outputs an error message and    |
# |      returns an exit code of ~1~.                                 |
# | 2. It reads the ~NAME~ field from the file using ~grep~ and       |
# |    extracts the value using ~cut~.                                |
# | 3. The ~tr~ command removes any surrounding double quotes.        |
# | 4. The ~case~ statement maps the ~NAME~ value to a simplified     |
# |    distro identifier:                                             |
# |    - ~Debian*~ maps to ~debian~                                   |
# |    - ~Ubuntu*~ maps to ~ubuntu~                                   |
# |    - ~Arch*~ maps to ~arch~                                       |
# |    - Any unsupported distro outputs an error message and returns  |
# |      an exit code of ~1~.                                         |
# |                                                                   |
# | *Usage:*                                                          |
# | The ~get_distro~ function can be used to determine the Linux      |
# | distribution in scripts that require distro-specific logic.       |
# |                                                                   |
# | *Example:*                                                        |
# | distro=$(get_distro)                                              |
# | if [[ $? -eq 0 ]]; then                                           |
# |     echo "Detected distro: $distro"                               |
# | else                                                              |
# |     echo "Failed to detect distro."                               |
# | fi                                                                |
# |                                                                   |
# | Output:                                                           |
# | For Ubuntu: ~ubuntu~                                              |
# | For Debian: ~debian~                                              |
# | For Arch: ~arch~                                                  |
# | For unsupported distros: Error message and exit code ~1~.         |
# +-------------------------------------------------------------------+
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

# +-------------------------------------------------------------------+
# |                              is_wsl                               |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~is_wsl~ function checks if the script is running in a        |
# | Windows Subsystem for Linux (WSL) environment.                    |
# |                                                                   |
# | *Parameters:*                                                     |
# | + The function does not accept any parameters.                    |
# |                                                                   |
# | *Return Value:*                                                   |
# | + Exit status ~0~ (success): The script is running in WSL.        |
# | + Exit status ≠ ~0~ (failure): The script is not running in WSL.  |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function uses the ~grep~ command to search for the strings |
# |    ~microsoft~ or ~wsl~ in the file =/proc/version=.              |
# | 2. The ~-q~ option suppresses output, and ~&>/dev/null~ ensures   |
# |    no output is displayed.                                        |
# | 3. The ~-E~ option enables extended regular expressions, and the  |
# |    ~-i~ option makes the search case-insensitive.                 |
# |                                                                   |
# | *Usage:*                                                          |
# | The ~is_wsl~ function can be used in scripts to conditionally     |
# | execute code based on whether the environment is WSL.             |
# |                                                                   |
# | *Example:*                                                        |
# | if is_wsl; then                                                   |
# |     echo "Running in WSL"                                         |
# | else                                                              |
# |     echo "Not running in WSL"                                     |
# | fi                                                                |
# +-------------------------------------------------------------------+
is_wsl() {
    grep -qEi "(microsoft|wsl)" /proc/version &>/dev/null
}

# +-------------------------------------------------------------------+
# |                              is_root                              |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~is_root~ function checks if the script is being executed     |
# | with root privileges.                                             |
# |                                                                   |
# | *Parameters:*                                                     |
# | + The function does not accept any parameters.                    |
# |                                                                   |
# | *Return Value:*                                                   |
# | + Exit status ~0~ (success): The script is running as root.       |
# | + Exit status ≠ ~0~ (failure): The script is not running as root. |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function uses the command substitution ~$(id -u)~ to       |
# |    retrieve the user ID of the current user.                      |
# | 2. It checks if the user ID is equal to ~0~, which is the user ID |
# |    for the root user.                                             |
# | 3. If the condition is true, the function returns success;        |
# |    otherwise, it returns failure.                                 |
# |                                                                   |
# | *Usage:*                                                          |
# | The ~is_root~ function can be used in scripts to ensure that      |
# | certain commands or operations are only executed with root        |
# | privileges.                                                       |
# |                                                                   |
# | *Example:*                                                        |
# | if is_root; then                                                  |
# |     echo "Running as root"                                        |
# | else                                                              |
# |     echo "Not running as root"                                    |
# | fi                                                                |
# +-------------------------------------------------------------------+
is_root() {
    [ "$(id -u)" -eq 0 ]
}

get_stage_description() {
    #local current_stage
    #current_stage=$(cat "$CURRENT_STAGE")
    echo "$CURRENT_STAGE"
    return 0
}

create_progress_list() {
    local items=("$@")
    stage_file="install/stage.log"

    local CHECKED="\033[1;32m[✓]\033[0m"
    local UNCHECKED="\033[1;37m[ ]\033[0m"
    local FAILED="\033[1;31m[✗]\033[0m"
    local CURRENT="\033[1;33m[▶]\33[0m"

    local out=()
    # local i

    # for i in "${!items[@]}"; do
    #     if (( i % 2 == 0 )); then
    #         out+=( "$(printf "%b %s" "$CHECKED" "${items[i]}")" )
    #     else
    #         out+=( "$(printf "%b %s" "$UNCHECKED" "${items[i]}")" )
    #     fi
    # done

    [[ -f "$stage_file" ]] || return 1

    while IFS='|' read -r name status current; do
        # Skip empty or malformed lines
        [[ -z "$name" || -z "$status" ]] && continue

        case "$status" in
            1)
                out+=( "$(printf "%b %s" "$CHECKED" "$name")" )
                ;;
            0)
                out+=( "$(printf "%b %s" "$UNCHECKED" "$name")" )
                ;;
            2)
                out+=( "$(printf "%b %s" "$FAILED" "$name")" )
                ;;
            -1)
                out+=( "$(printf "%b %s" "$CURRENT" "$name")" )
                ;;
            *)
                # Unknown state → treat as unchecked
                out+=( "$(printf "%b %s" "$UNCHECKED" "$name")" )
                ;;
        esac
    done < "$stage_file"    # "return" the result
    printf "%s\n" "${out[@]}"
}

# +-------------------------------------------------------------------+
# |                           is_installed                            |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~is_installed~ function checks if a specific application,     |
# | package, or tool is installed on the system, based on its type    |
# | and the Linux distribution.                                       |
# |                                                                   |
# | *Parameters:*                                                     |
# | 1. ~type~: The type of the item to check (e.g., ~package~,         |
# |    ~r_package~, ~python_package~, etc.).                          |
# | 2. ~app~: The name of the application or package to check.         |
# | 3. ~distro~: The Linux distribution (used for package checks).    |
# |                                                                   |
# | *Return Value:*                                                   |
# | + The function returns an exit status:                            |
# |   - ~0~: The specified item is installed.                         |
# |   - Non-zero: The specified item is not installed.                |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function uses a ~case~ statement to determine the type of  |
# |    item to check.                                                 |
# | 2. Based on the ~type~, it calls the appropriate helper function: |
# |    - ~check_package_installed~: Checks if a system package is     |
# |      installed.                                                   |
# |    - ~check_R_package_installed~: Checks if an R package is       |
# |      installed.                                                   |
# |    - ~check_python_package_installed~: Checks if a Python package |
# |      is installed.                                                |
# |    - ~check_application_installed~: Checks if a general           |
# |      application is installed.                                    |
# | 3. The helper function's exit status is returned as the result.   |
# | 4. If the ~type~ is not recognized, the function does nothing.    |
# |                                                                   |
# | *Usage:*                                                          |
# | The ~is_installed~ function can be used to verify the presence of |
# | dependencies or tools in scripts.                                 |
# |                                                                   |
# | *Example:*                                                        |
# | is_installed "package" "curl" "ubuntu"                            |
# | if [[ $? -eq 0 ]]; then                                           |
# |     echo "curl is installed"                                      |
# | else                                                              |
# |     echo "curl is not installed"                                  |
# | fi                                                                |
# |                                                                   |
# | Output:                                                           |
# | The function will return ~0~ if the specified item is installed,  |
# | or a non-zero value otherwise.                                    |
# |                                                                   |
# | *Notes:*                                                          |
# | + The helper functions (e.g., ~check_package_installed~) must be  |
# |   defined and accessible for this function to work correctly.     |
# | + Ensure that the ~distro~ parameter is passed correctly for      |
# |   package checks.                                                 |
# +-------------------------------------------------------------------+
is_installed() {
    local type="$1"
    local app="$2"
    local distro="$3"

    # tput cup 70 0
    # echo "$type"

    case "$type" in
        package)
            # echo "There"
            check_package_installed "$app" "$distro"
            return $?
            ;;
        r_package)
            # echo "here"
            package="${app#*/}"
            check_R_package_installed "$package"
            # check_R_package_installed "$app"
            return $?
            ;;
        R_git_package)
            package="${app#*/}"
            check_R_package_installed "$package"
            return $?
            ;;
        INLA)
            # check_inla_installed
            check_R_package_installed "$package"
            return $?
            ;;
        python_package)
            check_python_package_installed "$app"
            return $?
            ;;
        quarto)
            check_application_installed "$app"
            return $?
            ;;
        other)
            check_application_installed "$app"
            return $?
            ;;
        *)
            ;;
    esac
}

# +-------------------------------------------------------------------+
# |                     check_package_installed                       |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~check_package_installed~ function checks if a specific       |
# | system package is installed on the system, based on the Linux     |
# | distribution.                                                     |
# |                                                                   |
# | *Parameters:*                                                     |
# | 1. ~app~: The name of the package to check.                       |
# | 2. ~distro~: The Linux distribution (e.g., ~debian~, ~ubuntu~,    |
# |    ~arch~).                                                       |
# |                                                                   |
# | *Return Value:*                                                   |
# | + The function returns an exit status:                            |
# |   - ~0~: The package is installed.                                |
# |   - Non-zero: The package is not installed or the distribution is |
# |     unsupported.                                                  |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function uses a ~case~ statement to determine the package  |
# |    manager based on the ~distro~ parameter.                       |
# | 2. For ~debian~ or ~ubuntu~, it uses the ~dpkg -l~ command to     |
# |    check if the package is installed.                             |
# | 3. For ~arch~, it uses the ~pacman -Q~ command to check if the    |
# |    package is installed.                                          |
# | 4. If the ~distro~ is unsupported, it outputs an error message to |
# |    standard error and returns an exit code of ~1~.                |
# |                                                                   |
# | *Usage:*                                                          |
# | The ~check_package_installed~ function can be used to verify the  |
# | presence of system packages in scripts that depend on specific    |
# | software.                                                         |
# |                                                                   |
# | *Example:*                                                        |
# | check_package_installed "curl" "ubuntu"                           |
# | if [[ $? -eq 0 ]]; then                                           |
# |     echo "curl is installed"                                      |
# | else                                                              |
# |     echo "curl is not installed"                                  |
# | fi                                                                |
# |                                                                   |
# | Output:                                                           |
# | The function will return ~0~ if the package is installed, or a    |
# | non-zero value otherwise.                                         |
# |                                                                   |
# | *Notes:*                                                          |
# | + Ensure that the ~distro~ parameter matches the system's package |
# |   manager.                                                        |
# | + The function assumes that the appropriate package manager       |
# |   commands are available on the system.                           |
# +-------------------------------------------------------------------+
check_package_installed() {
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

# +-------------------------------------------------------------------+
# |                   check_R_package_installed                       |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~check_R_package_installed~ function checks if a specific R   |
# | package is installed on the system.                               |
# |                                                                   |
# | *Parameters:*                                                     |
# | 1. ~R_package~: The name of the R package to check.               |
# |                                                                   |
# | *Return Value:*                                                   |
# | + The function returns an exit status:                            |
# |   - ~0~: The R package is installed.                              |
# |   - ~1~: The R package is not installed.                          |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function checks if the file ~install/installed_R_packages.txt~ |
# |    exists:                                                        |
# |    - If the file does not exist, it runs an R script to generate  |
# |      a list of installed R packages and writes it to the file.    |
# | 2. The function uses ~grep~ to search for the specified R package |
# |    in the generated file.                                         |
# | 3. If the package is found, the function returns ~0~ (success).   |
# |    Otherwise, it returns ~1~ (failure).                           |
# |                                                                   |
# | *Usage:*                                                          |
# | The ~check_R_package_installed~ function can be used to verify    |
# | the presence of R packages in scripts that depend on specific R   |
# | libraries.                                                        |
# |                                                                   |
# | *Example:*                                                        |
# | check_R_package_installed "ggplot2"                               |
# | if [[ $? -eq 0 ]]; then                                           |
# |     echo "ggplot2 is installed"                                   |
# | else                                                              |
# |     echo "ggplot2 is not installed"                               |
# | fi                                                                |
# |                                                                   |
# | Output:                                                           |
# | The function will return ~0~ if the package is installed, or ~1~  |
# | if it is not installed.                                           |
# |                                                                   |
# | *Notes:*                                                          |
# | + The function assumes that R is installed and accessible via the |
# |   ~Rscript~ command.                                              |
# | + The file ~install/installed_R_packages.txt~ is used as a cache  |
# |   to avoid repeatedly querying R for installed packages.          |
# | + If the cache file becomes outdated, it may need to be manually  |
# |   deleted to force regeneration.                                  |
# +-------------------------------------------------------------------+
check_R_package_installed() {
    local R_package "$1"

    ## Check if installed_R_packages.txt exists and if it does not
    ## then run Rscript writeLines to create it
    ## if it does, then grep it to see if the package is listed
    if [[ ! -f install/installed_R_packages.txt ]]; then
        Rscript -e "writeLines(installed.packages()[, 'Package'], 'install/installed_R_packages.txt')"
#         Rscript -e "installed_packages <- installed.packages()[, 'Package']; writeLines
# (installed_packages, 'installed_R_packages.txt')"
    fi
    grep -q "^$1$" install/installed_R_packages.txt
    if [[ $? -eq 0 ]]; then  # is installed
        return 0
    else
        return 1             # not installed
    fi



    # Rscript -e "if (!suppressWarnings(requireNamespace('$1', quietly = TRUE))) { quit(status = 1) }"
    # if [[ $? -eq 0 ]]; then  # is installed
    #     return 0
    # else
    #     return 1             # not installed
    # fi
}

check_python_package_installed() {
    local package="$1"

    local VENV_DIR="$HOME/python-venv"

    # Ensure the virtual environment exists
    if [ ! -d "$VENV_DIR" ]; then
        echo "Virtual environment not found at $VENV_DIR. Please create it first."
        return 1
    fi

    # Activate the virtual environment
    source "$VENV_DIR/bin/activate"

    # Check if the package is installed
    pip show "$package" &>/dev/null
    local status=$?

    # Deactivate the virtual environment
    deactivate

    return $status
}

install_R_package() {
    local R_package="$1"
    local log_file="$2"

    Rscript -e "install.packages('$R_package', repos='https://cloud.r-project.org/')" >> "$log_file" 2>&1
}

install_R_git_package() {
    local R_package="$1"
    local log_file="$2"

    if ! is_installed "R_package" "pak" "$log_file" ; then
        Rscript -e "install.packages('pak', repos='https://cloud.r-project.org/')" >> "$log_file" 2>&1
    fi

    Rscript -e "pak::pkg_install('$R_package')" >> "$log_file" 2>&1
}

install_inla() {

  # Fetch the INLA versions from the website
  html_content=$(curl -s https://www.r-inla.org/download-install)

  # Extract INLA versions from the HTML content
  versions=$(echo "$html_content" | \
    grep -oP '(?<=&lt;td&gt;&lt;code&gt;)[0-9]+\.[0-9]+\.[0-9]+(?=&lt;/code&gt;)' | sort -u)

  # Convert the versions into an array
  version_array=()
  while IFS= read -r line; do
      version_array+=("$line")
  done <<< "$versions"

  # # Display the versions as a menu
  # echo "Available INLA versions:"
  # for i in "${!version_array[@]}"; do
  #   echo "$((i + 1)). ${version_array[i]}"
  # done

  # # Prompt the user to select a version
  # read -p "Enter the number corresponding to the version you want to install: " choice

  # # Validate the user's choice
  # if [[ $choice -lt 1 || $choice -gt ${#version_array[@]} ]]; then
  #   echo "Invalid choice. Exiting."
  #   return 1
  # fi

  # Get the selected version
  # selected_version=${version_array[$((choice - 1))]}
  # echo "You selected version $selected_version."

  # Select the latest version
  selected_version=$(printf "%s\n" "${version_array[@]}" | sort -V | tail -n 1)

  # sudo Rscript -e "if (!requireNamespace('INLA', quietly = TRUE)) remotes::install_version('INLA', version = '25.06.13',
 # repos = c(getOption('repos'), INLA = 'https://inla.r-inla-download.org/R/testing'), dep = TRUE)"
  sudo Rscript -e "if (!requireNamespace('INLA', quietly = TRUE)) remotes::install_version('INLA', version = '$selected_version', repos = c(getOption('repos'), INLA = 'https://inla.r-inla-download.org/R/testing'), dep = TRUE)"

  # now since this was installed as root, we need to make a couple of files executable as anyone
  sudo chmod a+x /usr/local/lib/R/site-library/INLA/bin/linux/64bit/inla.mkl.run
  sudo chmod a+x /usr/local/lib/R/site-library/INLA/bin/linux/64bit/inla.mkl
}

install_python_package() {
  local package="$1"
  local VENV_DIR="$HOME/python-venv"
  if ! command -v pip &>/dev/null; then
    echo "pip is not installed. Please install pip first."
    exit 1
  fi

  if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
  fi

  source "$VENV_DIR/bin/activate"
  pip install "$package"
  deactivate
}
