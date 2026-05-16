#!/bin/bash
export PATH="/var/home/wtg/.local/bin:$PATH"
C_RED='\033[0;31m'
C_RESET='\033[0m'
header_text="${C_RED}Hello World\nLine 2\nLine 3${C_RESET}"
gum filter --header="$header_text" --height=8 "opt1" "opt2" < /dev/tty
