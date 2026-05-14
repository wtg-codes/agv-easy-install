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

    for key, info in data.items():
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

    with open(sys.argv[2], "w") as f:
        f.write(config)

    print(f"Updated {sys.argv[2]} successfully.")

if __name__ == "__main__":
    main()
