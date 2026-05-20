import sys
import json
import re

def main():
    if len(sys.argv) < 3:
        print("Usage: python update_config.py <versions.json> <src/00_config.sh>")
        sys.exit(1)

    with open(sys.argv[1], "r") as f:
        data = json.load(f)

    with open(sys.argv[2], "r") as f:
        config = f.read()

    # 1. Parse Antigravity releases and find the latest version
    agv_data = data.get("antigravity", {})
    if agv_data:
        latest_agv_ver = sorted(agv_data.keys(), key=lambda v: list(map(int, v.split('.'))), reverse=True)[0]
        
        # Update default AGV version variable
        agv_ver_pattern = re.compile(r'^DEFAULT_AGV_VERSION=".*"$', re.MULTILINE)
        if agv_ver_pattern.search(config):
            config = agv_ver_pattern.sub(f'DEFAULT_AGV_VERSION="{latest_agv_ver}"', config)

        # Update AGV platform variables
        for key, info in agv_data[latest_agv_ver].items():
            url = info["url"]
            sha = info["sha256"]
            
            # Replace URL
            url_pattern = re.compile(rf'^AGV_{key}_URL=".*"$', re.MULTILINE)
            if url_pattern.search(config):
                config = url_pattern.sub(f'AGV_{key}_URL="{url}"', config)
            
            # Replace SHA
            sha_pattern = re.compile(rf'^AGV_{key}_SHA256=".*"$', re.MULTILINE)
            if sha_pattern.search(config):
                config = sha_pattern.sub(f'AGV_{key}_SHA256="{sha}"', config)

    # 1b. Parse IDE releases and find the latest version
    ide_data = data.get("ide", {})
    latest_ide_ver = sorted(ide_data.keys(), key=lambda v: list(map(int, v.split('.'))), reverse=True)[0]
    
    # 2. Update default IDE version variable
    ide_ver_pattern = re.compile(r'^DEFAULT_IDE_VERSION=".*"$', re.MULTILINE)
    if ide_ver_pattern.search(config):
        config = ide_ver_pattern.sub(f'DEFAULT_IDE_VERSION="{latest_ide_ver}"', config)

    # 3. Update platform variables for the latest IDE version
    for key, info in ide_data[latest_ide_ver].items():
        url = info["url"]
        sha = info["sha256"]
        
        # Replace URL
        url_pattern = re.compile(rf'^{key}_URL=".*"$', re.MULTILINE)
        if url_pattern.search(config):
            config = url_pattern.sub(f'{key}_URL="{url}"', config)
        else:
            print(f"WARNING: {key}_URL not found in config")

        # Replace SHA
        sha_pattern = re.compile(rf'^{key}_SHA256=".*"$', re.MULTILINE)
        if sha_pattern.search(config):
            config = sha_pattern.sub(f'{key}_SHA256="{sha}"', config)
        else:
            print(f"WARNING: {key}_SHA256 not found in config")

        # Replace IDE URL
        ide_url_pattern = re.compile(rf'^IDE_{key}_URL=".*"$', re.MULTILINE)
        if ide_url_pattern.search(config):
            config = ide_url_pattern.sub(f'IDE_{key}_URL="{url}"', config)

        # Replace IDE SHA
        ide_sha_pattern = re.compile(rf'^IDE_{key}_SHA256=".*"$', re.MULTILINE)
        if ide_sha_pattern.search(config):
            config = ide_sha_pattern.sub(f'IDE_{key}_SHA256="{sha}"', config)

    # 4. Parse CLI releases and find the latest version
    cli_data = data.get("cli", {})
    if cli_data:
        latest_cli_ver = sorted(cli_data.keys(), key=lambda v: list(map(int, v.split('.'))), reverse=True)[0]
        cli_ver_pattern = re.compile(r'^DEFAULT_CLI_VERSION=".*"$', re.MULTILINE)
        if cli_ver_pattern.search(config):
            config = cli_ver_pattern.sub(f'DEFAULT_CLI_VERSION="{latest_cli_ver}"', config)

    # 5. Parse SDK releases and find the latest version
    sdk_data = data.get("sdk", {})
    if sdk_data:
        latest_sdk_ver = sdk_data.get("latest", "0.1.0")
        sdk_ver_pattern = re.compile(r'^DEFAULT_SDK_VERSION=".*"$', re.MULTILINE)
        if sdk_ver_pattern.search(config):
            config = sdk_ver_pattern.sub(f'DEFAULT_SDK_VERSION="{latest_sdk_ver}"', config)

    with open(sys.argv[2], "w") as f:
        f.write(config)

    print(f"Updated {sys.argv[2]} successfully with IDE {latest_ide_ver}.")

if __name__ == "__main__":
    main()
