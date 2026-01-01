#!/bin/bash


# +-------------------------------------------------------------------+
# |                           draw_frame                              |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~draw_frame~ function generates and displays a rectangular    |
# | frame with customizable dimensions and borders using box-drawing  |
# | characters.                                                       |
# |                                                                   |
# | *Parameters:*                                                     |
# | 1. ~ROW~: The starting row position for the frame.                |
# | 2. ~COL~: The starting column position for the frame.             |
# | 3. ~WIDTH~: The width of the frame (including borders).           |
# | 4. ~HEIGHT~: The height of the frame (including borders).         |
# |                                                                   |
# | *Return Value:*                                                   |
# | + The function outputs the frame to the terminal.                 |
# | + It does not return any value.                                   |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function uses box-drawing characters to define the         |
# |    borders of the frame:                                          |
# |    - ~╔~ and ~╗~ for the top-left and top-right corners.          |
# |    - ~╚~ and ~╝~ for the bottom-left and bottom-right corners.    |
# |    - ~═~ for horizontal lines and ~║~ for vertical lines.         |
# | 2. The ~tput cup~ command positions the cursor at the specified   |
# |    starting row and column.                                       |
# | 3. The top border, middle rows, and bottom border are generated   |
# |    using ~printf~ and stored in an array.                         |
# | 4. The frame is printed row by row using a loop.                  |
# |                                                                   |
# | *Usage:*                                                          |
# | The ~draw_frame~ function can be used to create visual elements   |
# | in terminal-based applications, such as menus, banners, or logs.  |
# |                                                                   |
# | *Example:*                                                        |
# | draw_frame 2 4 20 10                                              |
# |                                                                   |
# | Output:                                                           |
# | A rectangular frame starting at row 2, column 4, with a width of  |
# | 20 characters and a height of 10 characters.                      |
# |                                                                   |
# | *Notes:*                                                          |
# | + Ensure that the terminal supports box-drawing characters.       |
# | + The function assumes that the terminal cursor positioning is    |
# |   managed by ~tput~.                                              |
# +-------------------------------------------------------------------+
draw_frame() {
    local ROW="$1"
    local COL="$2"
    local WIDTH="$3"
    local HEIGHT="$4"
    local TL_G="╔"  TR_G="╗"
    local BL_G="╚"  BR_G="╝"
    local HL="═"    VL="║"
    local VHL="╠"   VHR="╣"

    tput cup "$ROW" "$COL"
    tput el

    BLOCK=()

    # Top border
    BLOCK+=("$(printf "%s%s%s" "$TL_G" "$(printf "%*s" "$((WIDTH-2))" "" | sed "s/ /$HL/g")" "$TR_G")")

  ## Middle rows
    for ((i=1; i<=HEIGHT-2; i++)); do
        BLOCK+=("$(printf "%s%s%s" "$VL" "$(printf "%*s" "$((WIDTH-2))" "")" "$VL")")
    done

  ## Bottom banner border
    BLOCK[$((CONTENT_TOP-1))]="$(printf "%s%s%s" "$VHL" "$(printf "%*s" "$((WIDTH-2))" "" | sed "s/ /$HL/g")" "$VHR")"

  ## Bottom content border
    BLOCK[$((LOG_TOP-1))]="$(printf "%s%s%s" "$VHL" "$(printf "%*s" "$((WIDTH-2))" "" | sed "s/ /$HL/g")" "$VHR")"

    # Bottom border
    BLOCK+=("$(printf "%s%s%s" "$BL_G" "$(printf "%*s" "$((WIDTH-2))" "" | sed "s/ /$HL/g")" "$BR_G")")
  printf "%s\n" "${BLOCK[@]}"
}

# +-------------------------------------------------------------------+
# |                           print_logo                              |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~print_logo~ function displays an ASCII art logo to the       |
# | terminal. It is typically used to add a visual element to a       |
# | script's output, such as branding or decoration.                  |
# |                                                                   |
# | *Parameters:*                                                     |
# | + The function does not accept any parameters.                    |
# |                                                                   |
# | *Return Value:*                                                   |
# | + The function outputs the ASCII art logo to the standard output. |
# | + It does not return any value.                                   |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function uses the ~cat~ command with a here-document to    |
# |    print the ASCII art enclosed between the ~EOF~ markers.        |
# | 2. The ~<<"EOF"~ syntax ensures that the content is treated as    |
# |    literal text and is printed exactly as written.                |
# |                                                                   |
# | *Usage:*                                                          |
# | The ~print_logo~ function can be used to display a logo at the    |
# | start of a script or program to enhance its presentation.         |
# |                                                                   |
# | *Example:*                                                        |
# | print_logo                                                        |
# |                                                                   |
# | Output:                                                           |
# | The function will print the ASCII art logo to the terminal.       |
# |                                                                   |
# | *Notes:*                                                          |
# | + Ensure that the terminal supports ASCII art rendering properly. |
# | + The logo can be customized by modifying the content inside the  |
# |   ~EOF~ markers.                                                  |
# +-------------------------------------------------------------------+
print_logo() {
  cat <<"EOF"
   .--.
  | o_o|  Murray's
  | \_:|   Post-install
 / /   \\   Script
( |     |)
/`\_   _/'\
\___)=(___/

EOF
}


# +-------------------------------------------------------------------+
# |                            draw_logo                              |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~draw_logo~ function displays an ASCII logo in the terminal   |
# | at a specified starting row and column, with optional color       |
# | formatting.                                                       |
# |                                                                   |
# | *Parameters:*                                                     |
# | + The function does not accept any parameters.                    |
# |                                                                   |
# | *Return Value:*                                                   |
# | + The function does not return a value but directly modifies the  |
# |   terminal display to show the logo.                              |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function hides the cursor using ~tput civis~ to improve    |
# |    the visual presentation.                                       |
# | 2. It sets the starting row and column for the logo display.      |
# | 3. The ~print_logo~ function is called to generate the ASCII logo.|
# | 4. The function iterates over each line of the logo:              |
# |    - It positions the cursor at the appropriate row and column    |
# |      using ~tput cup~.                                            |
# |    - It prints the line with yellow color formatting using ANSI   |
# |      escape codes.                                                |
# | 5. After displaying the logo, the cursor is restored using ~tput  |
# |    cnorm~.                                                        |
# |                                                                   |
# | *Usage:*                                                          |
# | The ~draw_logo~ function is used to display a visually appealing  |
# | logo in terminal-based applications.                              |
# |                                                                   |
# | *Example:*                                                        |
# | draw_logo                                                         |
# |                                                                   |
# | Output:                                                           |
# | The ASCII logo is displayed in yellow at the specified position   |
# | in the terminal.                                                  |
# |                                                                   |
# | *Notes:*                                                          |
# | + Ensure that the ~print_logo~ function is defined and accessible |
# |   before calling this function.                                   |
# | + The function assumes that the terminal supports ANSI escape     |
# |   codes for color formatting and cursor manipulation.             |
# +-------------------------------------------------------------------+
draw_logo() {
    tput civis
    YELLOW="\033[1;33m"   # bright yellow
    RESET="\033[0m"       # reset color
    local start_row="1"
    local start_col="2"
    local line
    local row="$start_row"

    ascii_logo=$(print_logo)
    while IFS= read -r line; do
        tput cup "$row" "$start_col"
        printf "%b%s%b" "${YELLOW}" "$line" "${RESET}"
        ((row++))
    done <<< "$ascii_logo"
    tput cnorm
}

# +-------------------------------------------------------------------+
# |                        generate_sys_info                          |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~generate_sys_info~ function collects and displays system     |
# | information, including OS details, kernel version, distribution,  |
# | WSL status, user privileges, and other relevant data.             |
# |                                                                   |
# | *Parameters:*                                                     |
# | + The function does not accept any parameters.                    |
# |                                                                   |
# | *Return Value:*                                                   |
# | + The function outputs system information to the standard output. |
# | + It does not return any value.                                   |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function uses various commands to gather system details:   |
# |    - ~uname -s~: Retrieves the operating system name.             |
# |    - ~uname -r~: Retrieves the kernel version.                    |
# |    - ~. /etc/os-release~: Sources the OS release file to extract  |
# |      distribution name and version.                               |
# |    - ~is_wsl~: Checks if the environment is WSL.                  |
# |    - ~is_root~: Checks if the script is running with root         |
# |      privileges.                                                  |
# |    - ~whoami~: Retrieves the current username.                    |
# |    - ~pwd~: Retrieves the current working directory.              |
# |    - ~date~: Retrieves the current date and time.                 |
# | 2. The function formats and prints the collected information.     |
# |                                                                   |
# | *Usage:*                                                          |
# | The ~generate_sys_info~ function can be used to display system    |
# | information for debugging, logging, or reporting purposes.        |
# |                                                                   |
# | *Example:*                                                        |
# | generate_sys_info                                                 |
# |                                                                   |
# | Output:                                                           |
# | OS: Linux                                                         |
# | Kernel: 5.15.90.1-microsoft-standard-WSL2                         |
# | Distro: Ubuntu 22.04.3 LTS                                        |
# | WSL: Yes                                                          |
# | Run as root: No                                                   |
# | User: user                                                        |
# | PWD: /home/user                                                   |
# | Date: Mon Oct 2 12:34:56 UTC 2023                                 |
# +-------------------------------------------------------------------+
generate_sys_info() {
    echo "OS: $(uname -s)"
    echo "Kernel: $(uname -r)"
    # echo "Distro: $(. /etc/os-release; echo $NAME $VERSION)"
    echo "Distro: $(. /etc/os-release; echo "$PRETTY_NAME")"
    echo "WSL: $(if is_wsl; then echo "Yes"; else echo "No"; fi)"
    echo "Run as root: $(if is_root; then echo "Yes"; else echo "No"; fi)"
    echo "User: $(whoami)"
    echo "PWD: $(pwd)"
    echo "Date: $(date)"
    # echo " "
    # echo " "
    echo "Current stage: $(get_stage_description "install/stage.log" || echo "N/A")"
    # echo " "
    # echo "User choice: $user_choice"
}

# +-------------------------------------------------------------------+
# |                           clear_info                              |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~clear_info~ function clears a specific section of the        |
# | terminal, typically used to reset or remove information displayed |
# | in the banner area.                                               |
# |                                                                   |
# | *Parameters:*                                                     |
# | + The function does not accept any parameters.                    |
# |                                                                   |
# | *Return Value:*                                                   |
# | + The function does not return any value. It directly modifies    |
# |   the terminal display to clear the specified area.               |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function iterates over the rows of the banner area using a |
# |    loop.                                                          |
# | 2. For each row:                                                  |
# |    - It positions the cursor at the appropriate row and column    |
# |      using ~tput cup~.                                            |
# |    - It prints blank spaces to overwrite the content, ensuring    |
# |      the width matches ~BANNER_INFO_WIDTH~.                       |
# | 3. The number of rows cleared is determined by ~BANNER_HEIGHT - 2~|
# |    to exclude the top and bottom borders of the banner.           |
# |                                                                   |
# | *Usage:*                                                          |
# | The ~clear_info~ function is used to reset the information area   |
# | of a banner before updating it with new content.                  |
# |                                                                   |
# | *Example:*                                                        |
# | clear_info                                                        |
# |                                                                   |
# | Output:                                                           |
# | The specified section of the terminal is cleared, leaving it      |
# | blank.                                                            |
# |                                                                   |
# | *Notes:*                                                          |
# | + Ensure that the global variables ~BANNER_HEIGHT~, ~BANNER_TOP~, |
# |   ~BANNER_INFO_LEFT~, and ~BANNER_INFO_WIDTH~ are properly        |
# |   initialized before calling this function.                       |
# | + The function assumes that the terminal supports cursor          |
# |   positioning with ~tput cup~.                                    |
# +-------------------------------------------------------------------+
clear_info() {
  for ((i=0; i<(BANNER_HEIGHT - 2); i++)); do
    tput cup $((BANNER_TOP + i)) $BANNER_INFO_LEFT
    printf "%s%s%s" "" "$(printf "%*s" "$((BANNER_INFO_WIDTH))" "" )" ""
  done
}

# +-------------------------------------------------------------------+
# |                            draw_info                              |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~draw_info~ function displays system information in a         |
# | designated section of the terminal, typically within a banner.    |
# |                                                                   |
# | *Parameters:*                                                     |
# | + The function does not accept any parameters.                    |
# |                                                                   |
# | *Return Value:*                                                   |
# | + The function does not return any value. It directly modifies    |
# |   the terminal display to show the system information.            |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function hides the cursor using ~tput civis~ to improve    |
# |    the visual presentation.                                       |
# | 2. It initializes the starting row and column for displaying the  |
# |    system information. The column is determined by the global     |
# |    variable ~BANNER_INFO_LEFT~.                                   |
# | 3. The ~generate_sys_info~ function is called to retrieve the     |
# |    system information as a multiline string.                      |
# | 4. The ~clear_info~ function is called to clear the designated    |
# |    area before displaying new content.                            |
# | 5. The function iterates over each line of the system information:|
# |    - It positions the cursor at the appropriate row and column    |
# |      using ~tput cup~.                                            |
# |    - It prints the line to the terminal.                          |
# | 6. After displaying the information, the cursor is restored using |
# |    ~tput cnorm~.                                                  |
# |                                                                   |
# | *Usage:*                                                          |
# | The ~draw_info~ function is used to display dynamic system        |
# | information in terminal-based applications.                       |
# |                                                                   |
# | *Example:*                                                        |
# | draw_info                                                         |
# |                                                                   |
# | Output:                                                           |
# | The terminal displays system information such as OS, kernel,      |
# | distribution, WSL status, user privileges, and more.              |
# |                                                                   |
# | *Notes:*                                                          |
# | + Ensure that the ~generate_sys_info~ and ~clear_info~ functions  |
# |   are defined and accessible before calling this function.        |
# | + The function assumes that the terminal supports cursor          |
# |   positioning with ~tput cup~.                                    |
# | + The global variable ~BANNER_INFO_LEFT~ must be properly         |
# |   initialized to define the starting column for the information.  |
# +-------------------------------------------------------------------+
draw_info() {
    tput civis
    local start_row="1"
    local start_col="$BANNER_INFO_LEFT"
    local row="$start_row"
    local line
    local sys_info="$(generate_sys_info)"

    clear_info

    while IFS= read -r line; do
        tput cup "$row" "$start_col"
        printf "%s" "$line"
        ((row++))
    done <<< "$sys_info"
    tput cnorm
}

clear_progress() {
  for ((i=0; i<(BANNER_HEIGHT - 2); i++)); do
    tput cup $((BANNER_TOP + i)) $BANNER_PROGRESS_LEFT
    printf "%s%s%s" "" "$(printf "%*s" "$((BANNER_PROGRESS_WIDTH))" "" )" ""
  done
}

update_progress() {
    local -a progress_list
    mapfile -t progress_list < <(create_progress_list "${MENU_ORDER[@]}")
    clear_progress

    for ((i=0; i<${#progress_list[@]}; i++)); do
        tput cup "$((BANNER_TOP + i))" "$BANNER_PROGRESS_LEFT"
        printf "%s" "${progress_list[i]}"
    done
}

# +-------------------------------------------------------------------+
# |                           draw_banner                             |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~draw_banner~ function is a high-level function that combines |
# | multiple sub-functions to display a banner in the terminal. The   |
# | banner typically includes an ASCII logo and additional            |
# | information.                                                      |
# |                                                                   |
# | *Parameters:*                                                     |
# | + The function does not accept any parameters.                    |
# |                                                                   |
# | *Return Value:*                                                   |
# | + The function does not return a value but directly modifies the  |
# |   terminal display to show the banner.                            |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function calls the ~draw_logo~ function to display an      |
# |    ASCII logo at the top of the terminal.                         |
# | 2. It then calls the ~draw_info~ function to display additional   |
# |    information below the logo.                                    |
# | 3. The function is designed to be modular, allowing for easy      |
# |    extension by adding more sub-functions as needed.              |
# |                                                                   |
# | *Usage:*                                                          |
# | The ~draw_banner~ function is used to create a visually appealing |
# | banner for terminal-based applications.                           |
# |                                                                   |
# | *Example:*                                                        |
# | draw_banner                                                       |
# |                                                                   |
# | Output:                                                           |
# | The terminal displays a banner with an ASCII logo and additional  |
# | information.                                                      |
# |                                                                   |
# | *Notes:*                                                          |
# | + Ensure that the ~draw_logo~ and ~draw_info~ functions are       |
# |   defined and accessible before calling this function.            |
# | + The function assumes that the terminal supports ANSI escape     |
# |   codes for cursor manipulation and color formatting.             |
# +-------------------------------------------------------------------+
draw_banner() {
    draw_logo
    draw_info
    update_progress
}

# +-------------------------------------------------------------------+
# |                           draw_tabs                               |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~draw_tabs~ function renders a row of tabs in the terminal,   |
# | highlighting the active tab and displaying all available tabs.    |
# |                                                                   |
# | *Parameters:*                                                     |
# | + The function does not accept any parameters directly but relies |
# |   on the following global variables:                              |
# |   - ~TAB_ROW~: The row in the terminal where the tabs will be     |
# |     drawn.                                                        |
# |   - ~TABS~: An array containing the names of the tabs.            |
# |   - ~ACTIVE_TAB~: The index of the currently active tab.          |
# |   - ~WIDTH~: The total width of the terminal.                     |
# |                                                                   |
# | *Return Value:*                                                   |
# | + The function outputs the tabs directly to the terminal.         |
# | + It does not return any value.                                   |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function positions the cursor at the specified ~TAB_ROW~   |
# |    using ~tput cup~.                                              |
# | 2. It iterates over the ~TABS~ array to generate the tab layout:  |
# |    - The active tab is highlighted using ANSI color codes.        |
# |    - Inactive tabs are displayed with normal formatting.          |
# | 3. A horizontal line is drawn below the tabs to visually separate |
# |    them from the content below.                                   |
# | 4. The horizontal line is created using the ~sed~ command to      |
# |    repeat the specified character (~HL~).                         |
# |                                                                   |
# | *Usage:*                                                          |
# | The ~draw_tabs~ function can be used to create a tabbed interface |
# | in terminal-based applications.                                   |
# |                                                                   |
# | *Example:*                                                        |
# | TABS=("Home" "Settings" "About")                                  |
# | ACTIVE_TAB=1                                                      |
# | TAB_ROW=2                                                         |
# | WIDTH=80                                                          |
# | draw_tabs                                                         |
# |                                                                   |
# | Output:                                                           |
# | The function will display tabs in the terminal, with the active   |
# | tab highlighted.                                                  |
# |                                                                   |
# | *Notes:*                                                          |
# | + Ensure that the global variables ~TABS~, ~ACTIVE_TAB~, ~TAB_ROW~,|
# |   and ~WIDTH~ are properly initialized before calling the function.|
# | + The function assumes that the terminal supports ANSI escape     |
# |   codes for color formatting.                                     |
# +-------------------------------------------------------------------+
draw_tabs() {
    tput cup "$TAB_ROW" 1
    local tab_list=""
    local tab_width=12
    local HL="═"
    local HL="-"
    local VHL="╠"   VHR="╣"

    for i in "${!TABS[@]}"; do
        if [[ $i -eq $ACTIVE_TAB ]]; then
            printf "[ ${YELLOW}%-12s${RESET} ] |" "${TABS[$i]}"
        else
            printf "  %-12s  | " "${TABS[$i]}"
        fi
    done
    tput cup "$((TAB_ROW + 1))" 1
    printf "%s%s%s" "" "$(printf "%*s" "$((WIDTH-2))" "" | sed "s/ /$HL/g")" ""
}

# +-------------------------------------------------------------------+
# |                          clear_content                            |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~clear_content~ function clears the content area of the       |
# | terminal by overwriting it with blank spaces.                     |
# |                                                                   |
# | *Parameters:*                                                     |
# | + The function does not accept any parameters directly but relies |
# |   on the following global variables:                              |
# |   - ~CONTENT_HEIGHT~: The height of the content area to clear.    |
# |   - ~CONTENT_TOP~: The starting row of the content area.          |
# |   - ~WIDTH~: The total width of the terminal.                     |
# |                                                                   |
# | *Return Value:*                                                   |
# | + The function does not return any value. It directly modifies    |
# |   the terminal display.                                           |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function iterates over the rows of the content area using  |
# |    a loop.                                                        |
# | 2. For each row:                                                  |
# |    - It positions the cursor at the appropriate row and column    |
# |      using ~tput cup~.                                            |
# |    - It prints blank spaces to overwrite the content, ensuring    |
# |      the width matches ~WIDTH-2~.                                 |
# |                                                                   |
# | *Usage:*                                                          |
# | The ~clear_content~ function is used to reset the content area of |
# | the terminal before displaying new content.                       |
# |                                                                   |
# | *Example:*                                                        |
# | clear_content                                                     |
# |                                                                   |
# | Output:                                                           |
# | The content area of the terminal is cleared, leaving it blank.    |
# |                                                                   |
# | *Notes:*                                                          |
# | + Ensure that the global variables ~CONTENT_HEIGHT~, ~CONTENT_TOP~,|
# |   and ~WIDTH~ are properly initialized before calling this        |
# |   function.                                                       |
# | + The function assumes that the terminal supports cursor          |
# |   positioning with ~tput cup~.                                    |
# +-------------------------------------------------------------------+
clear_content() {
  for ((i=0; i<(CONTENT_HEIGHT - 2); i++)); do
    tput cup $((CONTENT_TOP + 2 + i)) 1
    printf "%s%s%s" "" "$(printf "%*s" "$((WIDTH-2))" "" )" ""
  done
}

# +-------------------------------------------------------------------+
# |                              ui_safe                              |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~ui_safe~ function executes a command or script in a "safe"   |
# | mode by temporarily disabling the shell's error handling (~set -e~). |
# | This ensures that the script does not terminate if the command    |
# | being executed fails.                                             |
# |                                                                   |
# | *Parameters:*                                                     |
# | + The function accepts any command and its arguments as input.    |
# |                                                                   |
# | *Return Value:*                                                   |
# | + The function returns the exit status of the executed command.   |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function disables the shell's error handling using ~set +e~. |
# |    - This allows commands to fail without causing the script to   |
# |      terminate.                                                   |
# | 2. It executes the provided command and its arguments using ~"$@"~. |
# | 3. After the command is executed, the shell's error handling is   |
# |    re-enabled using ~set -e~.                                     |
# |                                                                   |
# | *Usage:*                                                          |
# | The ~ui_safe~ function is useful for running commands that may    |
# | fail without interrupting the execution of the script.            |
# |                                                                   |
# | *Example:*                                                        |
# | ui_safe ls nonexistent_file                                       |
# | echo "This message will still be printed even if the command fails." |
# |                                                                   |
# | Output:                                                           |
# | The function will execute the ~ls nonexistent_file~ command. If   |
# | the command fails, the script will continue execution without     |
# | terminating.                                                      |
# |                                                                   |
# | *Notes:*                                                          |
# | + Use this function cautiously, as it suppresses error handling   |
# |   for the duration of the command execution.                      |
# | + Ensure that error handling is re-enabled after the command is   |
# |   executed.                                                       |
# +-------------------------------------------------------------------+
ui_safe() {
    set +e
    "$@"
    set -e
}

# +-------------------------------------------------------------------+
# |                     collect_menu_packages                         |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~collect_menu_packages~ function collects information about   |
# | packages associated with a specific menu key and determines their |
# | installation status for a given Linux distribution.               |
# |                                                                   |
# | *Parameters:*                                                     |
# | 1. ~mkey~: The menu key used to identify the relevant menu items. |
# | 2. ~distro~: The Linux distribution (e.g., ~ubuntu~, ~debian~).   |
# | 3. ~out_rows~: A reference to an array where the collected        |
# |    package information will be stored.                            |
# |                                                                   |
# | *Return Value:*                                                   |
# | + The function appends formatted package information to the       |
# |   referenced array ~out_rows~.                                    |
# | + It does not return any value.                                   |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function initializes the ~out_rows~ array to store the     |
# |    results.                                                       |
# | 2. It iterates over the installation types specified in the       |
# |    ~DATA~ associative array for the given ~mkey~.                 |
# | 3. For each installation type:                                    |
# |    - It retrieves the check type (e.g., ~package~, ~r_package~)   |
# |      and the list of packages.                                    |
# |    - It checks the installation status of each package using the  |
# |      ~is_installed~ function.                                     |
# |    - It appends the package information to ~out_rows~ in the      |
# |      format: ~install_type|check_type|status| package_name~.      |
# |      - ~status~ is ~1~ if the package is installed, ~0~ otherwise.|
# |                                                                   |
# | *Usage:*                                                          |
# | The ~collect_menu_packages~ function is used to gather and format |
# | package information for display in terminal-based applications.   |
# |                                                                   |
# | *Example:*                                                        |
# | local packages=()                                                 |
# | collect_menu_packages "menu_key" "ubuntu" packages                |
# | printf "%s\n" "${packages[@]}"                                    |
# |                                                                   |
# | Output:                                                           |
# | The function populates the ~packages~ array with formatted        |
# | package information, such as:                                     |
# | ~install_type|check_type|status| package_name~.                   |
# |                                                                   |
# | *Notes:*                                                          |
# | + Ensure that the ~DATA~ associative array is properly initialized|
# |   before calling this function.                                   |
# | + The ~is_installed~ function must be defined and accessible.     |
# | + The ~out_rows~ parameter must be passed as a reference to an    |
# |   array.                                                          |
# +-------------------------------------------------------------------+
collect_packages() {
    local mkey="$1"
    local distro="$2"
    local -n out_rows="$3"   # OUTPUT

    out_rows=()

    for install_type in ${DATA[$mkey.install_types]}; do
        local check_type="${DATA[$mkey.install_to_check.$install_type]}"
        local pkgs="${DATA[$mkey.packages.$install_type]}"

        for pkg in $pkgs; do
            if is_installed "$check_type" "$pkg" "$distro"; then
                out_rows+=( "$install_type|$check_type|1| $pkg" )
            else
                out_rows+=( "$install_type|$check_type|0| $pkg" )
            fi
        done
    done
}

# +-------------------------------------------------------------------+
# |                         draw_packages                             |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~draw_packages~ function formats and displays a list of       |
# | packages in a tabular layout, grouped by installation type, with  |
# | their installation status indicated.                              |
# |                                                                   |
# | *Parameters:*                                                     |
# | 1. ~rows~: A reference to an array containing package information |
# |    in the format ~install_type|check_type|status|package_name~.   |
# |                                                                   |
# | *Return Value:*                                                   |
# | + The function does not return a value but directly outputs the   |
# |   formatted package list to the terminal.                         |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function initializes variables for layout, including the   |
# |    number of columns (~cols~) and column width (~col_width~).     |
# | 2. It defines a helper function ~flush_row~ to print a row of     |
# |    packages and reset the row buffer.                             |
# | 3. The function iterates over the ~rows~ array:                   |
# |    - It splits each row into its components (~install_type~,      |
# |      ~check_type~, ~status~, ~pkg~) using ~IFS="|"~.              |
# |    - When a new ~install_type~ is encountered, it starts a new    |
# |      section, flushing any leftover rows.                         |
# |    - It adds each package to the current row buffer, marking it   |
# |      as installed (~[X]~) or not installed (~[ ]~) based on the   |
# |      ~status~.                                                    |
# |    - When the row buffer reaches the column limit, it flushes the |
# |      row.                                                         |
# | 4. After processing all rows, it flushes any remaining packages   |
# |    in the buffer.                                                 |
# |                                                                   |
# | *Usage:*                                                          |
# | The ~draw_packages~ function is used to display a formatted       |
# | list of packages in terminal-based applications.                  |
# |                                                                   |
# | *Example:*                                                        |
# | local packages=(                                                  |
# |     "system|package|1|curl"                                       |
# |     "system|package|0|wget"                                       |
# |     "r|r_package|1|ggplot2"                                       |
# | )                                                                 |
# | draw_packages packages                                            |
# |                                                                   |
# | Output:                                                           |
# | == system ==                                                      |
# | - [X] curl                                                        |
# | - [ ] wget                                                        |
# |                                                                   |
# | == r ==                                                           |
# | - [X] ggplot2                                                     |
# |                                                                   |
# | *Notes:*                                                          |
# | + Ensure that the ~rows~ array is properly formatted before       |
# |   calling this function.                                          |
# | + The function assumes that the terminal supports ANSI escape     |
# |   codes for cursor positioning (~tput cup~).                      |
# +-------------------------------------------------------------------+
draw_packages() {
    local -n rows="$1"

  # local row="$((CONTENT_TOP + 2))"
  # local col=2

    local cols=4
    local col_width=26

    local current_install=""
    local line_items=()

    local current_row="$((CONTENT_TOP + 1))"
    local current_col=2

    flush_row() {
        tput cup "$current_row" "$current_col"
        printf "%-${col_width}s %-${col_width}s %-${col_width}s %-${col_width}s\n" \
            "${line_items[0]:-}" "${line_items[1]:-}" \
            "${line_items[2]:-}" "${line_items[3]:-}"
        line_items=()
        ((current_row++))
    }

    for row in "${rows[@]}"; do
        IFS="|" read -r install_type check_type status pkg <<< "$row"

        # New section
        if [[ "$install_type" != "$current_install" ]]; then
            # Flush leftovers
            (( ${#line_items[@]} )) && flush_row
            echo
            ((current_row++))
            tput cup "$current_row" "$current_col"
            echo "== $install_type =="
            current_install="$install_type"
            ((current_row++))
        fi
        # if [[ "${status:-0}" -eq 1 ]]; then
        if [[ "$status" -eq 1 ]]; then
            line_items+=( "- [X] $pkg" )
        else
            line_items+=( "- [ ] $pkg" )
        fi

        (( ${#line_items[@]} == cols )) && flush_row
    done

    # Flush trailing row
    (( ${#line_items[@]} )) && flush_row
}

# +-------------------------------------------------------------------+
# |                    draw_active_tab_panel                          |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~draw_active_tab~ function updates the terminal interface to  |
# | display the content associated with the currently active tab.     |
# |                                                                   |
# | *Parameters:*                                                     |
# | 1. ~ACTIVE_TAB~: The index of the currently active tab.           |
# |                                                                   |
# | *Return Value:*                                                   |
# | + The function does not return a value but updates the terminal   |
# |   interface to display the content of the active tab.             |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function sets the global variable ~ACTIVE_TAB~ to the      |
# |    provided index.                                                |
# | 2. It calls the ~clear_content~ function to clear the current     |
# |    content area of the terminal.                                  |
# | 3. The ~DATA_ORDER~ array is used to retrieve the key associated  |
# |    with the active tab.                                           |
# | 4. The ~collect_menu_packages~ function is called to gather the   |
# |    packages associated with the active tab, based on the menu key |
# |    and the current distribution (~distro~).                      |
# | 5. The ~ui_safe print_menu_packages~ function is used to safely   |
# |    display the collected packages in the terminal.                |
# |                                                                   |
# | *Usage:*                                                          |
# | The ~draw_active_tab~ function is used in terminal-based          |
# | applications to dynamically update the content displayed when a   |
# | user switches tabs.                                               |
# |                                                                   |
# | *Example:*                                                        |
# | draw_active_tab 2                                                 |
# |                                                                   |
# | Output:                                                           |
# | The terminal interface is updated to display the content          |
# | associated with the tab at index ~2~.                             |
# |                                                                   |
# | *Notes:*                                                          |
# | + Ensure that the global variables ~DATA_ORDER~ and ~distro~ are  |
# |   properly initialized before calling this function.              |
# | + The ~clear_content~, ~collect_menu_packages~, and ~ui_safe      |
# |   print_menu_packages~ functions must be defined and accessible.  |
# +-------------------------------------------------------------------+
draw_active_tab_panel() {
    ACTIVE_TAB="$1"
    clear_content

    local mkey="${DATA_ORDER[$ACTIVE_TAB]}"
    local packages=()
    collect_packages "$mkey" "$distro" packages
    ui_safe draw_packages packages
}

get_current_stage() {
    stage_file="install/stage.log"
    if [[ -f $stage_file ]]; then
        awk -F'|' '$3=="*" { print $1; exit }' "$stage_file"
    fi
}

update_info(){
    tput civis
    local start_row="1"
    local start_col="$BANNER_INFO_LEFT"

    tput cup 8 "$start_col"
    printf "Date: %s" "$(date)"
    tput cup 9 "$start_col"
    # printf "Current stage: %s" "$(get_stage_description "install/stage.log" || echo "N/A")"
    # printf "Current stage: %s" "$CURRENT_STAGE"
    local current_stage
    current_stage="$(get_current_stage)"
    if [[ -n "$current_stage" ]]; then
        printf "%-*.*s" "$BANNER_INFO_WIDTH" "$BANNER_INFO_WIDTH" "Current stage: $current_stage"
    fi
    tput cnorm
}

update_banner() {
    # draw_logo
    update_info
    update_progress
}

clear_tail() {
  for ((i=0; i<(LOG_HEIGHT - 2); i++)); do
    tput cup $((LOG_TOP + 2 + i)) 1
    printf "%s%s%s" "" "$(printf "%*s" "$((WIDTH-2))" "" )" ""
  done
}

# +-------------------------------------------------------------------+
# |                       display_log_tail                            |
# +-------------------------------------------------------------------+
# | *Purpose:*                                                        |
# | The ~display_log_tail~ function reads the last 10 lines of a log  |
# | file and formats them into a block for display. If the log file   |
# | does not exist, it displays a message indicating that no log file |
# | was found.                                                        |
# |                                                                   |
# | *Parameters:*                                                     |
# | 1. ~log_block~: A reference to an array where the formatted log   |
# |    content will be stored.                                        |
# |                                                                   |
# | *Return Value:*                                                   |
# | + The function appends the formatted log content to the referenced|
# |   array ~log_block~.                                              |
# | + It does not return any value.                                   |
# |                                                                   |
# | *How It Works:*                                                   |
# | 1. The function checks if the log file (~install/install.log~)    |
# |    exists:                                                        |
# |    - If the file exists, it reads the last 10 lines using ~tail~. |
# |    - If the file does not exist, it sets a message indicating     |
# |      that no log file was found.                                  |
# | 2. It calls the ~build_block~ function to format the log content  |
# |    or the error message into a displayable block.                 |
# | 3. The formatted block is appended to the ~log_block~ array.      |
# |                                                                   |
# | *Usage:*                                                          |
# | The ~display_log_tail~ function can be used to display the latest |
# | entries from a log file in terminal-based applications.           |
# |                                                                   |
# | *Example:*                                                        |
# | local log_display=()                                              |
# | display_log_tail log_display                                      |
# | printf "%s\n" "${log_display[@]}"                                 |
# |                                                                   |
# | Output:                                                           |
# | If the log file exists, the last 10 lines are displayed. If not,  |
# | a message indicating the absence of the log file is shown.        |
# |                                                                   |
# | *Notes:*                                                          |
# | + The ~build_block~ function must be defined and accessible for   |
# |   this function to work correctly.                                |
# | + Ensure that the log file path (~install/install.log~) is valid. |
# +-------------------------------------------------------------------+
display_log_tail() {
    local log_file="install/install.log"
    local -n log_block=$1  # Reference to the block array

    clear_tail

    tput cup "$((LOG_TOP + 0))" 2
    if [[ -f "$log_file" ]]; then
        local -a log_tail
        mapfile -t log_tail < <(tail -n 10 "$log_file")
        len=${#log_tail[@]}
        if (( len < 10 )); then
            minn=$len
        else
            minn=10
        fi
        for ((i=0; i<"$minn"; i++)); do
            tput cup "$((LOG_TOP + 0 + i))" 2
            printf "%s" "${log_tail[i]}"
        done
    else
        tput cup "$LOG_TOP" 2
        echo "Installation log (last 10 rows): No log file found."
    fi
}

# ─────────────────────────────────────────────────────────────────────
# Main code
# ─────────────────────────────────────────────────────────────────────
clear
draw_frame 0 0 "$WIDTH" "$((LOG_TOP + LOG_HEIGHT + 2))"
tput sc
draw_banner
draw_tabs

draw_active_tab_panel "$ACTIVE_TAB"

DIRTY_TABS=false
DIRTY_CONTENT=false
