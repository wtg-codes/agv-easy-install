#!/bin/bash
export PATH="/var/home/wtg/.local/bin:$PATH"
C_RED='\033[0;31m'
C_RESET='\033[0m'
header_text="${C_RED}Hello World${C_RESET}"
echo -e "$header_text" | cat -v
