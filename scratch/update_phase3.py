import os

with open('.github/workflows/nightly-update.yml', 'r') as f:
    content = f.read()

# 3.1 & 3.2
content = content.replace('actions/checkout@v3', 'actions/checkout@v4')
content = content.replace('actions/setup-python@v4', 'actions/setup-python@v5')
# 3.3
content = content.replace('pip install requests', 'pip install -r requirements.txt')

old_steps = """      - name: Update antigravity-manager.sh
        if: env.LATEST_URL != ''
        run: |
          sed -i "s|DOWNLOAD_URL=.*|DOWNLOAD_URL=\\"${{ env.LATEST_URL }}\\"|" antigravity-manager.sh

      - name: Commit and push changes
        if: env.LATEST_URL != ''
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add antigravity-manager.sh
          if ! git diff --cached --quiet; then
            git commit -m "chore: nightly update of Antigravity download URL"
            git push
          fi"""

new_steps = """      - name: Validate URL and Compute SHA-256
        if: env.LATEST_URL != ''
        run: |
          # 3.4 Validate URL
          curl -fSsL --head "${{ env.LATEST_URL }}"
          
          # 3.7 Download and compute SHA-256
          TMP_TAR=$(mktemp)
          curl -fSsL "${{ env.LATEST_URL }}" -o "$TMP_TAR"
          NEW_SHA=$(sha256sum "$TMP_TAR" | awk '{print $1}')
          rm -f "$TMP_TAR"
          echo "NEW_SHA=$NEW_SHA" >> $GITHUB_ENV

      - name: Update antigravity-manager.sh
        if: env.LATEST_URL != ''
        run: |
          OLD_URL=$(grep -oP '^DOWNLOAD_URL="\\K[^"]+' antigravity-manager.sh)
          echo "OLD_URL=$OLD_URL" >> $GITHUB_ENV
          # 3.5 Use # as sed delimiter
          sed -i "s#^DOWNLOAD_URL=.*#DOWNLOAD_URL=\\"${{ env.LATEST_URL }}\\"#" antigravity-manager.sh
          sed -i "s#^KNOWN_SHA256=.*#KNOWN_SHA256=\\"${{ env.NEW_SHA }}\\"#" antigravity-manager.sh

      - name: Lint script
        if: env.LATEST_URL != ''
        run: shellcheck -e SC1091,SC2162 antigravity-manager.sh

      - name: Commit and push changes
        if: env.LATEST_URL != ''
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add antigravity-manager.sh
          if ! git diff --cached --quiet; then
            # 3.8 Improve commit message
            git commit -m "chore: nightly update of Antigravity download URL
            
            From: ${{ env.OLD_URL }}
            To:   ${{ env.LATEST_URL }}"
            git push
          fi"""

content = content.replace(old_steps, new_steps)

with open('.github/workflows/nightly-update.yml', 'w') as f:
    f.write(content)

# scrape_latest.py
with open('scrape_latest.py', 'r') as f:
    scrape = f.read()

# 3.9 Docstring
if not scrape.startswith('"""'):
    scrape = '"""\nScrapes the latest Antigravity tarball URL.\n"""\n' + scrape

# 3.10 Type hints
scrape = scrape.replace('def scrape_url():', 'from typing import Optional\n\ndef scrape_url() -> Optional[str]:')

# 3.12 Print errors to stderr
scrape = scrape.replace('print(f"Error scraping: {e}")', 'print(f"Error scraping: {e}", file=sys.stderr)')

# 3.11 URL validation HEAD request
old_return = "return found.group(0)"
new_return = """url_candidate = found.group(0)
                try:
                    head_resp = requests.head(url_candidate, timeout=10, allow_redirects=True)
                    if head_resp.status_code == 200:
                        return url_candidate
                except Exception as e:
                    print(f"HEAD validation failed: {e}", file=sys.stderr)"""
scrape = scrape.replace(old_return, new_return)

with open('scrape_latest.py', 'w') as f:
    f.write(scrape)
