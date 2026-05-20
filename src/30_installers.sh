install_brew() {
    JSON_METHOD="brew"
    log_info "${C_MAG}🚀 Installing Antigravity via Homebrew...${C_RESET}"
    ensure_brew
    
    if [ "$PLATFORM" = "Darwin" ]; then
        if ! run_cmd_ui "Brewing Antigravity..." brew install --cask antigravity; then
            log_error "Formula not found or installation failed."
            log_warn "Falling back to official Binary installation..."
            do_install_binary
            return
        fi
    else
        # For Linux platforms using Brew (especially Bluefin)
        run_cmd_ui "Tapping Ublue-OS experimental tap..." brew tap ublue-os/experimental-tap
        if ! run_cmd_ui "Brewing Antigravity Linux..." brew install ublue-os/experimental-tap/antigravity-linux; then
            log_error "Formula not found or installation failed."
            log_warn "Falling back to official Binary installation..."
            do_install_binary
            return
        fi
        # Workaround Homebrew Cask bug: create the missing binary symlink in $(brew --prefix)/bin/
        local brew_prefix
        brew_prefix=$(brew --prefix)
        local exec_file
        exec_file=$(find "$brew_prefix/Caskroom/antigravity-linux" -type f -name "antigravity-ide" -o -name "antigravity" 2>/dev/null | head -n 1)
        if [ -n "$exec_file" ]; then
            log_info "Creating missing binary symlink in Homebrew bin folder..."
            run_cmd ln -sf "$exec_file" "$brew_prefix/bin/antigravity"
        else
            log_warn "Could not locate the extracted executable to create the launcher symlink."
        fi
        # Refresh desktop database
        if command -v update-desktop-database &>/dev/null; then
            run_cmd update-desktop-database "$HOME/.local/share/applications" || true
        fi
    fi
    configure_chrome_path
    mkdir -p "$STATE_DIR"
    echo '{"method": "brew", "version": "'"$SCRIPT_VERSION"'"}' > "$STATE_FILE"
}

install_repo() {
    JSON_METHOD="repo"
    log_warn "This method requires sudo — you may be prompted for your password."
    sudo -v || { log_error "Sudo access required."; exit 1; }
    detect_distro
    case "$DISTRO" in
        ubuntu|debian|kali|linuxmint)
            log_info "${C_BLUE}🔑 Fetching repository keys...${C_RESET}"
            run_cmd sudo mkdir -p /etc/apt/keyrings
            curl -fSsL "https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg" | \
                sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg || { log_error "Failed to fetch keys"; exit 1; }
            
            log_info "${C_BLUE}📦 Configuring APT repository...${C_RESET}"
            echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
                sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null
            
            if ! run_cmd_ui "Updating package lists..." sudo apt update || ! run_cmd_ui "Installing Antigravity..." sudo apt install -y antigravity; then
                log_error "Installation failed! Rolling back repository changes..."
                run_cmd sudo rm -f /etc/apt/sources.list.d/antigravity.list
                exit 1
            fi
            log_info "${C_GREEN}✅ Installation complete!${C_RESET} Launch with: ${C_BOLD}antigravity${C_RESET}"
            ;;
        fedora|rhel|centos|amzn)
            log_info "${C_BLUE}📦 Setting up RPM repository...${C_RESET}"
            sudo tee /etc/yum.repos.d/antigravity.repo > /dev/null << EOL
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOL
            if ! run_cmd_ui "Updating package cache..." sudo dnf makecache || ! run_cmd_ui "Installing Antigravity..." sudo dnf install -y antigravity; then
                log_error "Installation failed! Rolling back repository changes..."
                run_cmd sudo rm -f /etc/yum.repos.d/antigravity.repo
                exit 1
            fi
            log_info "${C_GREEN}✅ Installation complete!${C_RESET} Launch with: ${C_BOLD}antigravity${C_RESET}"
            ;;
        *)
            log_error "Distribution $DISTRO not explicitly supported for repo install."
            if [ "$PLATFORM" = "Darwin" ]; then exit 1; fi
            log_warn "Falling back to official Binary installation..."
            do_install_binary
            return
            ;;
    esac
    configure_chrome_path
    mkdir -p "$STATE_DIR"
    echo '{"method": "repo", "version": "'"$SCRIPT_VERSION"'"}' > "$STATE_FILE"
}

get_ide_release_info() {
    get_product_release_info "ide" "$@"
}

get_product_release_info() {
    local product_name="$1"
    local version="$2"
    local platform_key="$3"
    local json_file="/tmp/versions.json"
    
    if [ ! -f "$json_file" ]; then
        if [ "$product_name" = "vibe" ] && [ "$version" = "$DEFAULT_VIBE_VERSION" ]; then
            case "$platform_key" in
                LINUX_X64) echo "$VIBE_LINUX_X64_URL|$VIBE_LINUX_X64_SHA256" ;;
                MAC_X64) echo "$VIBE_MAC_X64_URL|$VIBE_MAC_X64_SHA256" ;;
                MAC_ARM64) echo "$VIBE_MAC_ARM64_URL|$VIBE_MAC_ARM64_SHA256" ;;
                WIN_X64) echo "$VIBE_WIN_X64_URL|$VIBE_WIN_X64_SHA256" ;;
                WIN_ARM64) echo "$VIBE_WIN_ARM64_URL|$VIBE_WIN_ARM64_SHA256" ;;
            esac
            return
        elif [ "$product_name" = "ide" ] && [ "$version" = "$DEFAULT_IDE_VERSION" ]; then
            case "$platform_key" in
                LINUX_X64) echo "$IDE_LINUX_X64_URL|$IDE_LINUX_X64_SHA256" ;;
                MAC_X64) echo "$IDE_MAC_X64_URL|$IDE_MAC_X64_SHA256" ;;
                MAC_ARM64) echo "$IDE_MAC_ARM64_URL|$IDE_MAC_ARM64_SHA256" ;;
                WIN_X64) echo "$IDE_WIN_X64_URL|$IDE_WIN_X64_SHA256" ;;
                WIN_ARM64) echo "$IDE_WIN_ARM64_URL|$IDE_WIN_ARM64_SHA256" ;;
            esac
            return
        fi
        echo "|"
        return
    fi
    
    local info
    info=$(awk -v prod="$product_name" -v ver="$version" -v plat="$platform_key" '
      BEGIN { in_prod=0; in_ver=0; in_plat=0 }
      $0 ~ "\"" prod "\"" { in_prod=1; next }
      in_prod && $0 ~ "}" && $0 !~ "," && in_ver==0 { in_prod=0 }
      in_prod && $0 ~ "\"" ver "\"" { in_ver=1; next }
      in_ver && $0 ~ "}" && $0 !~ "," { if (in_plat) in_plat=0; else in_ver=0 }
      in_ver && $0 ~ "\"" plat "\"" { in_plat=1; next }
      in_plat && $0 ~ "}" { in_plat=0 }
      in_plat && $0 ~ "\"url\"" { split($0, a, "\""); url=a[4] }
      in_plat && $0 ~ "\"sha256\"" { split($0, a, "\""); sha=a[4] }
      END { if (url != "" && sha != "") print url "|" sha }
    ' "$json_file" 2>/dev/null || true)
    
    if [ -n "$info" ]; then
        echo "$info"
    else
        if [ "$product_name" = "vibe" ] && [ "$version" = "$DEFAULT_VIBE_VERSION" ]; then
            case "$platform_key" in
                LINUX_X64) echo "$VIBE_LINUX_X64_URL|$VIBE_LINUX_X64_SHA256" ;;
                MAC_X64) echo "$VIBE_MAC_X64_URL|$VIBE_MAC_X64_SHA256" ;;
                MAC_ARM64) echo "$VIBE_MAC_ARM64_URL|$VIBE_MAC_ARM64_SHA256" ;;
                WIN_X64) echo "$VIBE_WIN_X64_URL|$VIBE_WIN_X64_SHA256" ;;
                WIN_ARM64) echo "$VIBE_WIN_ARM64_URL|$VIBE_WIN_ARM64_SHA256" ;;
            esac
        elif [ "$product_name" = "ide" ] && [ "$version" = "$DEFAULT_IDE_VERSION" ]; then
            case "$platform_key" in
                LINUX_X64) echo "$IDE_LINUX_X64_URL|$IDE_LINUX_X64_SHA256" ;;
                MAC_X64) echo "$IDE_MAC_X64_URL|$IDE_MAC_X64_SHA256" ;;
                MAC_ARM64) echo "$IDE_MAC_ARM64_URL|$IDE_MAC_ARM64_SHA256" ;;
                WIN_X64) echo "$IDE_WIN_X64_URL|$IDE_WIN_X64_SHA256" ;;
                WIN_ARM64) echo "$IDE_WIN_ARM64_URL|$IDE_WIN_ARM64_SHA256" ;;
            esac
        else
            echo "|"
        fi
    fi
}

do_install_binary() {
    local product_name="${1:-vibe}"
    local target_version="$2"
    if [ -z "$target_version" ]; then
        if [ "$product_name" = "ide" ]; then
            target_version="$DEFAULT_IDE_VERSION"
        else
            target_version="$DEFAULT_VIBE_VERSION"
        fi
    fi

    JSON_METHOD="binary"
    local target_url=""
    local target_sha=""
    local install_type=""
    local file_ext=""
    local platform_key=""

    # Set up correct directories and symlinks depending on the product
    local app_dir_var="$APP_DIR"
    local bin_name="antigravity"
    local desktop_file_sys_var="$DESKTOP_FILE_SYS"
    local desktop_file_user_var="$DESKTOP_FILE_USER"
    local icon_path_var="$ICON_PATH"
    local app_title="Google Antigravity Vibe"
    local state_file_var="$STATE_FILE"

    if [ "$product_name" = "ide" ]; then
        app_dir_var="${APP_DIR}-ide"
        bin_name="antigravity-ide"
        desktop_file_sys_var="$HOME/.local/share/applications/google-antigravity-ide.desktop"
        if command -v xdg-user-dir &> /dev/null; then DESKTOP_DIR=$(xdg-user-dir DESKTOP); else DESKTOP_DIR="$HOME/Desktop"; fi
        desktop_file_user_var="$DESKTOP_DIR/google-antigravity-ide.desktop"
        icon_path_var="${app_dir_var}/resources/icon.png"
        app_title="Google Antigravity IDE"
        state_file_var="${STATE_DIR}/install-ide.json"
    fi

    # Determine target based on platform and architecture
    if [ "$PLATFORM" = "Darwin" ]; then
        install_type="dmg"
        file_ext="dmg"
        if [ "$ARCH" = "arm64" ]; then
            platform_key="MAC_ARM64"
        else
            platform_key="MAC_X64"
        fi
    elif [ "$WSL_DISTRO_NAME" != "" ] || [ "$OSTYPE" = "msys" ] || [ "$OSTYPE" = "cygwin" ]; then
        install_type="exe"
        file_ext="exe"
        if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
            platform_key="WIN_ARM64"
        else
            platform_key="WIN_X64"
        fi
    elif [ "$PLATFORM" = "Linux" ]; then
        platform_key="LINUX_X64"
        install_type="tarball"
        file_ext="tar.gz"
    else
        log_error "Unsupported platform for binary installation."
        exit 1
    fi

    # Fetch release details dynamically
    fetch_versions_json || true
    local info
    info=$(get_product_release_info "$product_name" "$target_version" "$platform_key")
    target_url=$(echo "$info" | cut -d'|' -f1)
    target_sha=$(echo "$info" | cut -d'|' -f2)

    if [ -z "$target_url" ] || [ -z "$target_sha" ]; then
        log_error "Could not find package details for $app_title version $target_version ($platform_key)."
        exit 1
    fi

    local sha_cmd=""
    if command -v sha256sum >/dev/null 2>&1; then
        sha_cmd="sha256sum"
    elif command -v shasum >/dev/null 2>&1; then
        sha_cmd="shasum -a 256"
    else
        log_error "sha256sum or shasum is required but was not found."
        exit 1
    fi

    log_info "${C_MAG}🚀 Starting $app_title Official Binary Installation ($target_version)...${C_RESET}"
    
    TMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TMP_DIR"; if [ "$PLATFORM" = "Darwin" ] && [ -d "/Volumes/Antigravity" ]; then hdiutil detach /Volumes/Antigravity -force -quiet 2>/dev/null || true; fi; exit_handler' EXIT INT TERM
    local dl_target="$TMP_DIR/Antigravity.$file_ext"

    if [ "$JSON_OUT" -eq 1 ] || [ "$QUIET" -eq 1 ]; then
        run_cmd curl -fSL "$target_url" -o "$dl_target"
    else
        log_info "${C_BLUE}⬇️  Downloading $app_title...${C_RESET}"
        curl -fSL --progress-bar "$target_url" -o "$dl_target"
    fi

    log_info "${C_BLUE}🔐 Verifying checksum...${C_RESET}"
    if ! echo "$target_sha  $dl_target" | $sha_cmd -c - >/dev/null 2>&1; then
        log_error "Checksum verification failed!"
        exit 1
    fi

    if [ "$install_type" = "tarball" ]; then
        log_info "${C_CYAN}📁 Preparing directories...${C_RESET}"
        mkdir -p "$BIN_DIR" "$app_dir_var" "$WORKSPACE_DIR" "$DESKTOP_DIR" "$(dirname "$desktop_file_sys_var")"

        if command -v gum >/dev/null 2>&1; then
            gum spin --spinner dot --title "Extracting archive..." -- tar -xzf "$dl_target" -C "$app_dir_var" --strip-components=1
        else
            tar -xzf "$dl_target" -C "$app_dir_var" --strip-components=1
        fi

        log_info "${C_BLUE}🔗 Creating symlink...${C_RESET}"
        ln -sf "$app_dir_var/antigravity" "$BIN_DIR/$bin_name"

        # Extract/Copy application icon
        log_info "${C_CYAN}🎨 Extracting application icon...${C_RESET}"
        local extracted_icon=0
        
        # 1. Try copying unpacked icon from 1.x IDE location
        local old_icon_location="${app_dir_var}/resources/app/out/vs/workbench/contrib/antigravityCustomAppIcon/browser/media/antigravity/antigravity.png"
        if [ -f "$old_icon_location" ]; then
            mkdir -p "$(dirname "$icon_path_var")"
            cp "$old_icon_location" "$icon_path_var"
            extracted_icon=1
        fi

        # 2. Try extracting from app.asar (for 2.x Vibe UI)
        if [ "$extracted_icon" -eq 0 ] && command -v python3 >/dev/null 2>&1; then
            if python3 -c "
import struct, json
try:
    with open('${app_dir_var}/resources/app.asar', 'rb') as f:
        header = f.read(16)
        if len(header) == 16:
            _, _, _, json_size = struct.unpack('<IIII', header)
            header_json = json.loads(f.read(json_size).decode('utf-8'))
            info = header_json.get('files', {}).get('icon.png')
            if info:
                f.seek(16 + json_size + int(info['offset']))
                import os
                os.makedirs(os.path.dirname('${icon_path_var}'), exist_ok=True)
                with open('${icon_path_var}', 'wb') as out:
                    out.write(f.read(info['size']))
                print('OK')
except Exception as e:
    pass
" 2>/dev/null | grep -q "OK"; then
                extracted_icon=1
            fi
        fi

        if [ "$extracted_icon" -eq 0 ] && command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
            if (
                cd "$TMP_DIR" || exit 1
                if npx --yes @electron/asar extract-file "${app_dir_var}/resources/app.asar" icon.png 2>/dev/null; then
                    mkdir -p "$(dirname "$icon_path_var")"
                    mv icon.png "$icon_path_var"
                elif npx --yes asar extract-file "${app_dir_var}/resources/app.asar" icon.png 2>/dev/null; then
                    mkdir -p "$(dirname "$icon_path_var")"
                    mv icon.png "$icon_path_var"
                else
                    exit 1
                fi
            ); then
                extracted_icon=1
            fi
        fi

        if [ "$extracted_icon" -eq 0 ]; then
            log_warn "Could not extract application icon. Desktop shortcut will use a default icon."
        fi

        cat << EOF > "$desktop_file_sys_var"
[Desktop Entry]
Version=1.0
Name=$app_title
Comment=Secure Agentic Development IDE
Exec=$BIN_DIR/$bin_name %F
Icon=$icon_path_var
Terminal=false
Type=Application
Categories=Development;IDE;
EOF

        if ! grep -qi "microsoft" /proc/version 2>/dev/null; then
            log_info "${C_CYAN}🖥️  Adding shortcut to Desktop...${C_RESET}"
            cp "$desktop_file_sys_var" "$desktop_file_user_var"
            chmod +x "$desktop_file_user_var"
            if command -v gio &> /dev/null; then run_cmd gio set "$desktop_file_user_var" metadata::trusted true || true; fi
            if command -v update-desktop-database &> /dev/null; then run_cmd update-desktop-database "$HOME/.local/share/applications" || true; fi
        fi

        echo ""
        if command -v gum >/dev/null 2>&1; then
            gum style --border double --border-foreground 46 --padding "1 2" "🎉 Installation Complete!
Launch: $bin_name
Workspace: $WORKSPACE_DIR"
        else
            log_info "${C_GREEN}${C_BOLD}🎉 Installation Complete!${C_RESET}"
            log_info "  ${C_CYAN}▸${C_RESET} Launch:    ${C_BOLD}$bin_name${C_RESET}"
            log_info "  ${C_CYAN}▸${C_RESET} Workspace: ${C_BOLD}$WORKSPACE_DIR${C_RESET}"
        fi

    elif [ "$install_type" = "dmg" ]; then
        log_info "${C_CYAN}💿 Mounting DMG...${C_RESET}"
        run_cmd hdiutil attach "$dl_target" -mountpoint /Volumes/Antigravity -nobrowse -quiet
        log_info "${C_BLUE}📦 Copying to /Applications...${C_RESET}"
        
        # Dynamically find the .app bundle inside the DMG safely
        APP_NAME=""
        for app_dir in /Volumes/Antigravity/*.app; do
            if [ -d "$app_dir" ]; then
                APP_NAME="$(basename "$app_dir")"
                break
            fi
        done
        
        if [ -z "$APP_NAME" ]; then
            log_error "Could not find any .app bundle inside the mounted DMG!"
            log_info "Contents of /Volumes/Antigravity:"
            ls -la /Volumes/Antigravity >> "$LOG_FILE" 2>&1 || true
            run_cmd hdiutil detach /Volumes/Antigravity -quiet
            exit 1
        fi
        
        log_info "  ${C_DIM}Found app bundle: $APP_NAME${C_RESET}"
        
        if [ -d "/Applications/$APP_NAME" ]; then
            run_cmd rm -rf "/Applications/$APP_NAME"
        fi
        
        if ! cp -R "/Volumes/Antigravity/$APP_NAME" /Applications/ >> "$LOG_FILE" 2>&1; then
            log_error "Failed to copy $APP_NAME to /Applications. Check /tmp/antigravity-install.log for details."
            run_cmd hdiutil detach /Volumes/Antigravity -quiet
            exit 1
        fi
        
        run_cmd hdiutil detach /Volumes/Antigravity -quiet

        echo ""
        log_warn "macOS Gatekeeper may block the standalone binary from running."
        log_info "If you see 'cannot be opened because the developer cannot be verified',"
        log_info "run this command to clear the quarantine flag:"
        log_info "  ${C_BOLD}xattr -rd com.apple.quarantine '/Applications/$APP_NAME'${C_RESET}"

        # Create CLI shim for terminal launch
        mkdir -p "$BIN_DIR"
        local mac_bin_path
        mac_bin_path=$(find "/Applications/$APP_NAME/Contents/MacOS" -type f -executable | head -n 1 || true)
        
        if [ -n "$mac_bin_path" ] && [ -f "$mac_bin_path" ]; then
            run_cmd ln -sf "$mac_bin_path" "$BIN_DIR/$bin_name"
        else
            log_warn "Could not create terminal shortcut (executable not found inside $APP_NAME)."
        fi

        log_info "${C_GREEN}${C_BOLD}🎉 Installation Complete!${C_RESET} Launch from Applications folder or type '$bin_name' in terminal."

    elif [ "$install_type" = "exe" ]; then
        log_info "${C_CYAN}🚀 Launching Windows Installer...${C_RESET}"
        if command -v cmd.exe >/dev/null 2>&1; then
            # Convert WSL path to Windows path for cmd.exe
            win_path=$(wslpath -w "$dl_target")
            cmd.exe /c start "" "$win_path"
        else
            log_error "Could not find cmd.exe to launch installer."
            exit 1
        fi
        log_info "${C_GREEN}${C_BOLD}🎉 Please complete the installation in the Windows UI!${C_RESET}"
    fi

    configure_chrome_path
    mkdir -p "$STATE_DIR"
    echo "{\"method\": \"binary\", \"version\": \"$target_version\"}" > "$state_file_var"
}

do_remove() {
    JSON_METHOD="remove"
    if [ "$AUTO" -ne 1 ] && [ "$JSON_OUT" -ne 1 ]; then
        echo -ne "${C_RED}⚠ Are you sure you want to uninstall Antigravity? [y/N]: ${C_RESET}"
        read confirm < /dev/tty
        case "$confirm" in
            [yY]|[yY][eE][sS]) ;;
            *) log_warn "Cancelled."; return ;;
        esac
    fi
    log_info "${C_RED}🧹 Removing Google Antigravity...${C_RESET}"
    
    # Remove CLI and other shared files
    rm -f "$BIN_DIR/agy" "$BIN_DIR/jules"
    if command -v npm >/dev/null 2>&1; then
        npm uninstall -g @google/jules >/dev/null 2>&1 || sudo npm uninstall -g @google/jules >/dev/null 2>&1 || true
    fi

    # Remove Vibe (Binary/Tarball)
    rm -rf "$APP_DIR" "$BIN_DIR/antigravity" "$DESKTOP_FILE_SYS" "$DESKTOP_FILE_USER"
    if [ "$PLATFORM" = "Darwin" ]; then
        rm -rf "/Applications/Google Antigravity.app"
        rm -rf "/Applications/Antigravity.app"
    fi

    # Remove IDE (Binary/Tarball)
    rm -rf "${APP_DIR}-ide" "$BIN_DIR/antigravity-ide" "$HOME/.local/share/applications/google-antigravity-ide.desktop"
    if command -v xdg-user-dir &> /dev/null; then DESKTOP_DIR=$(xdg-user-dir DESKTOP); else DESKTOP_DIR="$HOME/Desktop"; fi
    rm -f "$DESKTOP_DIR/google-antigravity-ide.desktop"

    if command -v update-desktop-database &> /dev/null; then run_cmd update-desktop-database "$HOME/.local/share/applications" || true; fi

    # Also check other install methods (brew, repo)
    if [ -f "$STATE_FILE" ]; then
        local method
        method=$(grep -o '"method": "[^"]*' "$STATE_FILE" | grep -o '[^\"]*$')
        log_info "Found installation state. Method used: $method"
        
        case "$method" in
            "brew")
                if [ "$PLATFORM" = "Darwin" ]; then 
                    run_cmd brew uninstall --cask antigravity || true
                else 
                    local brew_prefix
                    brew_prefix=$(brew --prefix 2>/dev/null || echo "/home/linuxbrew/.linuxbrew")
                    run_cmd rm -f "$brew_prefix/bin/antigravity" || true
                    run_cmd brew uninstall ublue-os/experimental-tap/antigravity-linux || run_cmd brew uninstall antigravity || true
                    if command -v update-desktop-database &>/dev/null; then
                        run_cmd update-desktop-database "$HOME/.local/share/applications" || true
                    fi
                fi ;;
            "repo")
                detect_distro
                if command -v apt &> /dev/null && [ -f /etc/apt/sources.list.d/antigravity.list ]; then
                    run_cmd sudo apt remove -y antigravity || true
                    sudo rm -f /etc/apt/sources.list.d/antigravity.list
                elif command -v dnf &> /dev/null && [ -f /etc/yum.repos.d/antigravity.repo ]; then
                    run_cmd sudo dnf remove -y antigravity || true
                    sudo rm -f /etc/yum.repos.d/antigravity.repo
                fi ;;
        esac
        rm -f "$STATE_FILE"
    fi

    # Also check IDE state file
    if [ -f "${STATE_DIR}/install-ide.json" ]; then
        rm -f "${STATE_DIR}/install-ide.json"
    fi

    log_info "${C_GREEN}✅ Uninstalled successfully.${C_RESET} (Note: Your code in $WORKSPACE_DIR was kept safe)."
}

get_cli_release_info() {
    local version="$1"
    local platform_key="$2"
    local json_file="/tmp/versions.json"
    
    if [ ! -f "$json_file" ]; then
        echo "|"
        return
    fi
    
    local info
    info=$(awk -v ver="$version" -v plat="$platform_key" '
      BEGIN { in_cli=0; in_ver=0; in_plat=0 }
      $0 ~ "\"cli\"" { in_cli=1; next }
      in_cli && $0 ~ "}" && $0 !~ "," && in_ver==0 { in_cli=0 }
      in_cli && $0 ~ "\"" ver "\"" { in_ver=1; next }
      in_ver && $0 ~ "}" && $0 !~ "," { if (in_plat) in_plat=0; else in_ver=0 }
      in_ver && $0 ~ "\"" plat "\"" { in_plat=1; next }
      in_plat && $0 ~ "}" { in_plat=0 }
      in_plat && $0 ~ "\"url\"" { split($0, a, "\""); url=a[4] }
      in_plat && $0 ~ "\"sha512\"" { split($0, a, "\""); sha=a[4] }
      END { if (url != "" && sha != "") print url "|" sha }
    ' "$json_file" 2>/dev/null || true)
    
    echo "$info"
}

install_cli() {
    local target_version="${1:-$DEFAULT_CLI_VERSION}"
    JSON_METHOD="cli"
    log_info "${C_MAG}🚀 Installing Antigravity CLI version $target_version...${C_RESET}"
    
    fetch_versions_json || true
    
    local cli_os=""
    case "$PLATFORM" in
        Darwin) cli_os="darwin" ;;
        Linux) cli_os="linux" ;;
        *) cli_os="linux" ;;
    esac
    
    local cli_arch=""
    case "$ARCH" in
        x86_64|amd64) cli_arch="amd64" ;;
        arm64|aarch64) cli_arch="arm64" ;;
        *) cli_arch="amd64" ;;
    esac
    
    local platform_key="${cli_os}_${cli_arch}"
    
    local info
    info=$(get_cli_release_info "$target_version" "$platform_key")
    local target_url
    target_url=$(echo "$info" | cut -d'|' -f1)
    local target_sha
    target_sha=$(echo "$info" | cut -d'|' -f2)
    
    if [ -z "$target_url" ] || [ -z "$target_sha" ]; then
        if [ "$target_version" = "$DEFAULT_CLI_VERSION" ]; then
            log_warn "Release details not found in versions.json. Falling back to official bootstrap installer..."
            TMP_DIR=$(mktemp -d)
            trap 'rm -rf "$TMP_DIR"; exit_handler' EXIT INT TERM
            local install_script="$TMP_DIR/install.sh"
            
            if [ "$JSON_OUT" -eq 1 ] || [ "$QUIET" -eq 1 ]; then
                if run_cmd curl -fSsL "$CLI_INSTALL_URL" -o "$install_script" && run_cmd bash "$install_script" --dir "$BIN_DIR"; then
                    :
                else
                    log_error "Antigravity CLI installation failed."
                    rm -rf "$TMP_DIR"
                    trap exit_handler EXIT INT TERM
                    exit 1
                fi
            else
                log_info "${C_BLUE}⬇️  Downloading CLI installer...${C_RESET}"
                if ! curl -fSsL "$CLI_INSTALL_URL" -o "$install_script"; then
                    log_error "Failed to download CLI installer."
                    rm -rf "$TMP_DIR"
                    trap exit_handler EXIT INT TERM
                    exit 1
                fi
                log_info "${C_BLUE}📦 Executing CLI installer...${C_RESET}"
                if ! bash "$install_script" --dir "$BIN_DIR"; then
                    log_error "CLI installer execution failed."
                    rm -rf "$TMP_DIR"
                    trap exit_handler EXIT INT TERM
                    exit 1
                fi
            fi
            
            rm -rf "$TMP_DIR"
            trap exit_handler EXIT INT TERM
            log_info "${C_GREEN}✅ Antigravity CLI installation complete!${C_RESET}"
            return
        else
            log_error "Could not find package details for Antigravity CLI version $target_version ($platform_key)."
            exit 1
        fi
    fi
    
    TMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TMP_DIR"; exit_handler' EXIT INT TERM
    
    local is_tar_gz=false
    local file_ext="bin"
    case "$target_url" in
        *.tar.gz*) is_tar_gz=true; file_ext="tar.gz" ;;
    esac
    
    local dl_target="$TMP_DIR/cli.$file_ext"
    
    if [ "$JSON_OUT" -eq 1 ] || [ "$QUIET" -eq 1 ]; then
        run_cmd curl -fSL "$target_url" -o "$dl_target"
    else
        log_info "${C_BLUE}⬇️  Downloading CLI package...${C_RESET}"
        curl -fSL --progress-bar "$target_url" -o "$dl_target"
    fi
    
    log_info "${C_BLUE}🔐 Verifying checksum (SHA-512)...${C_RESET}"
    local sha_cmd=""
    if command -v sha512sum >/dev/null 2>&1; then
        sha_cmd="sha512sum"
    elif command -v shasum >/dev/null 2>&1; then
        sha_cmd="shasum -a 512"
    else
        log_error "sha512sum or shasum is required but was not found."
        exit 1
    fi
    
    if ! echo "$target_sha  $dl_target" | $sha_cmd -c - >/dev/null 2>&1; then
        log_error "Checksum verification failed!"
        exit 1
    fi
    
    mkdir -p "$BIN_DIR"
    local binary_dest="$BIN_DIR/agy"
    
    if [ "$is_tar_gz" = "true" ]; then
        log_info "${C_BLUE}📦 Extracting CLI...${C_RESET}"
        tar -xzf "$dl_target" -C "$TMP_DIR" antigravity
        cp "$TMP_DIR/antigravity" "$binary_dest"
    else
        cp "$dl_target" "$binary_dest"
    fi
    
    chmod +x "$binary_dest"
    if [ "$PLATFORM" = "Darwin" ]; then
        xattr -d com.apple.quarantine "$binary_dest" 2>/dev/null || true
    fi
    
    log_info "${C_BLUE}⚙️  Configuring environment...${C_RESET}"
    "$binary_dest" install || true
    
    rm -rf "$TMP_DIR"
    trap exit_handler EXIT INT TERM
    log_info "${C_GREEN}✅ Antigravity CLI installation complete!${C_RESET}"
}

install_sdk() {
    local target_version="${1:-$DEFAULT_SDK_VERSION}"
    JSON_METHOD="sdk"
    log_info "${C_MAG}🚀 Installing Antigravity Python SDK...${C_RESET}"
    
    if ! command -v python3 >/dev/null 2>&1; then
        log_error "python3 is required but was not found on your system."
        exit 1
    fi
    
    if ! python3 -m pip --version >/dev/null 2>&1; then
        log_error "pip is required but was not found. Please install pip for python3 first."
        exit 1
    fi
    
    local pkg="google-antigravity"
    if [ -n "$target_version" ] && [ "$target_version" != "latest" ]; then
        pkg="google-antigravity==$target_version"
    fi
    
    log_info "${C_BLUE}📦 Installing package '$pkg' via pip...${C_RESET}"
    if [ "$JSON_OUT" -eq 1 ] || [ "$QUIET" -eq 1 ]; then
        run_cmd python3 -m pip install --upgrade "$pkg"
    else
        if ! python3 -m pip install --upgrade "$pkg"; then
            log_error "Failed to install Google Antigravity SDK."
            exit 1
        fi
    fi
    
    log_info "${C_GREEN}✅ Antigravity SDK installation complete!${C_RESET}"
}

ensure_brew() {
    if check_brew; then
        return 0
    fi
    
    log_warn "Homebrew is required but not installed."
    local install_now=true
    if [ "$AUTO" -eq 0 ] && command -v gum >/dev/null 2>&1; then
        if ! gum confirm "Would you like the installer to set up Homebrew now?"; then
            install_now=false
        fi
    elif [ "$AUTO" -eq 0 ]; then
        read -r -p "Would you like the installer to set up Homebrew now? [Y/n]: " choice < /dev/tty
        case "$choice" in
            [nN]*) install_now=false ;;
        esac
    fi
    
    if [ "$install_now" = false ]; then
        log_error "Homebrew installation declined. Cannot proceed with Homebrew installation."
        exit 1
    fi
    
    log_info "${C_BLUE}⬇️  Installing Homebrew...${C_RESET}"
    if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        log_error "Homebrew installation failed."
        exit 1
    fi
    
    # Try to load brew into current session
    local brew_path=""
    if [ -f "/opt/homebrew/bin/brew" ]; then
        brew_path="/opt/homebrew/bin/brew"
    elif [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
        brew_path="/home/linuxbrew/.linuxbrew/bin/brew"
    elif [ -f "/usr/local/bin/brew" ]; then
        brew_path="/usr/local/bin/brew"
    fi
    
    if [ -n "$brew_path" ]; then
        eval "$("$brew_path" shellenv)"
        
        # Also write to profile
        local profile_file=""
        if [ "$PLATFORM" = "Darwin" ]; then
            profile_file="$HOME/.zprofile"
        else
            profile_file="$HOME/.bashrc"
        fi
        
        if [ -f "$profile_file" ] && ! grep -q "shellenv" "$profile_file"; then
            log_info "Adding Homebrew configuration to $profile_file..."
            echo "eval \"\$($brew_path shellenv)\"" >> "$profile_file"
        fi
    fi
    
    if ! check_brew; then
        log_error "Homebrew was installed but is still not found in PATH."
        exit 1
    fi
    
    log_info "${C_GREEN}✅ Homebrew installed and configured successfully!${C_RESET}"
}

ensure_node() {
    if command -v npm >/dev/null 2>&1; then
        return 0
    fi
    
    log_warn "Node.js & NPM are required to install Jules CLI."
    local install_now=true
    if [ "$AUTO" -eq 0 ] && command -v gum >/dev/null 2>&1; then
        if ! gum confirm "Would you like the installer to set up Node.js and NPM now?"; then
            install_now=false
        fi
    elif [ "$AUTO" -eq 0 ]; then
        read -r -p "Would you like the installer to set up Node.js and NPM now? [Y/n]: " choice < /dev/tty
        case "$choice" in
            [nN]*) install_now=false ;;
        esac
    fi
    
    if [ "$install_now" = false ]; then
        log_error "Node.js installation declined. Cannot proceed with Jules CLI installation."
        exit 1
    fi
    
    # Try using brew if available
    if check_brew; then
        log_info "${C_BLUE}📦 Installing Node.js via Homebrew...${C_RESET}"
        if [ "$JSON_OUT" -eq 1 ] || [ "$QUIET" -eq 1 ]; then
            run_cmd brew install node
        else
            brew install node
        fi
        if command -v npm >/dev/null 2>&1; then
            log_info "${C_GREEN}✅ Node.js and NPM installed successfully via Homebrew!${C_RESET}"
            return 0
        fi
    fi
    
    # Standalone binary fallback install
    log_info "${C_BLUE}⬇️  Setting up standalone Node.js and NPM in user space...${C_RESET}"
    
    local node_url=""
    local node_dir_name=""
    
    case "$PLATFORM" in
        Darwin)
            if [ "$ARCH" = "arm64" ]; then
                node_url="https://nodejs.org/dist/v20.11.1/node-v20.11.1-darwin-arm64.tar.gz"
                node_dir_name="node-v20.11.1-darwin-arm64"
            else
                node_url="https://nodejs.org/dist/v20.11.1/node-v20.11.1-darwin-x64.tar.gz"
                node_dir_name="node-v20.11.1-darwin-x64"
            fi
            ;;
        Linux)
            if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
                node_url="https://nodejs.org/dist/v20.11.1/node-v20.11.1-linux-arm64.tar.xz"
                node_dir_name="node-v20.11.1-linux-arm64"
            else
                node_url="https://nodejs.org/dist/v20.11.1/node-v20.11.1-linux-x64.tar.xz"
                node_dir_name="node-v20.11.1-linux-x64"
            fi
            ;;
        *)
            log_error "Unsupported platform for standalone Node.js installation."
            exit 1
            ;;
    esac
    
    local node_lib_dir="$HOME/.local/lib/node"
    mkdir -p "$node_lib_dir" "$BIN_DIR"
    
    local dl_temp
    dl_temp=$(mktemp -d)
    local archive_ext="tar.gz"
    case "$node_url" in
        *.tar.xz) archive_ext="tar.xz" ;;
    esac
    
    local dl_target="$dl_temp/node.$archive_ext"
    
    if [ "$JSON_OUT" -eq 1 ] || [ "$QUIET" -eq 1 ]; then
        run_cmd curl -fSL "$node_url" -o "$dl_target"
    else
        curl -fSL --progress-bar "$node_url" -o "$dl_target"
    fi
    
    log_info "${C_CYAN}📁 Extracting Node.js...${C_RESET}"
    tar -xf "$dl_target" -C "$dl_temp"
    
    # Copy files to permanent location
    rm -rf "$node_lib_dir"
    mv "$dl_temp/$node_dir_name" "$node_lib_dir"
    rm -rf "$dl_temp"
    
    # Symlink binaries to $BIN_DIR
    ln -sf "$node_lib_dir/bin/node" "$BIN_DIR/node"
    ln -sf "$node_lib_dir/bin/npm" "$BIN_DIR/npm"
    ln -sf "$node_lib_dir/bin/npx" "$BIN_DIR/npx"
    
    # Ensure BIN_DIR is in PATH for current execution
    export PATH="$BIN_DIR:$PATH"
    
    # Force profile config reload for the user
    # Add to shell configuration profile
    local profile_file=""
    if [ "$PLATFORM" = "Darwin" ]; then
        profile_file="$HOME/.zprofile"
    else
        profile_file="$HOME/.bashrc"
    fi
    
    if [ -f "$profile_file" ] && ! grep -q "$BIN_DIR" "$profile_file"; then
        log_info "Adding $BIN_DIR to PATH in $profile_file..."
        echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$profile_file"
    fi
    
    if ! command -v npm >/dev/null 2>&1; then
        log_error "Node.js was installed but npm is still not found in PATH."
        exit 1
    fi
    
    log_info "${C_GREEN}✅ Standalone Node.js and NPM setup complete!${C_RESET}"
}

install_jules() {
    local target_version="${1:-$DEFAULT_JULES_VERSION}"
    JSON_METHOD="jules"
    log_info "${C_MAG}🚀 Installing Google Jules CLI...${C_RESET}"
    
    ensure_node
    
    local pkg="@google/jules"
    if [ -n "$target_version" ] && [ "$target_version" != "latest" ]; then
        pkg="@google/jules@$target_version"
    fi
    
    log_info "${C_BLUE}📦 Installing package '$pkg' via npm...${C_RESET}"
    
    local install_ok=false
    if [ "$JSON_OUT" -eq 1 ] || [ "$QUIET" -eq 1 ]; then
        if run_cmd npm install -g "$pkg" 2>/dev/null; then
            install_ok=true
        elif command -v sudo >/dev/null 2>&1 && run_cmd sudo npm install -g "$pkg"; then
            install_ok=true
        fi
    else
        if npm install -g "$pkg"; then
            install_ok=true
        elif command -v sudo >/dev/null 2>&1; then
            log_warn "Permission denied. Retrying with sudo..."
            if sudo npm install -g "$pkg"; then
                install_ok=true
            fi
        fi
    fi
    
    if [ "$install_ok" = false ]; then
        log_error "Failed to install Google Jules CLI package."
        exit 1
    fi
    
    # If we installed to a local or custom path, link it to BIN_DIR
    local npm_prefix
    npm_prefix=$(npm config get prefix 2>/dev/null || echo "")
    if [ -n "$npm_prefix" ] && [ -f "$npm_prefix/bin/jules" ]; then
        ln -sf "$npm_prefix/bin/jules" "$BIN_DIR/jules"
    fi
    
    log_info "${C_GREEN}✅ Google Jules CLI installation complete!${C_RESET}"
}

