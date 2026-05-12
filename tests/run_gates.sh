#!/usr/bin/env bash
# =============================================================================
# tests/run_gates.sh — Phase gate test runner for agv-easy-install
# =============================================================================
# Usage:
#   bash tests/run_gates.sh --phase 0       # Run one phase gate
#   bash tests/run_gates.sh --phase all     # Run all phase gates sequentially
#
# Exit code 0 = all gates passed, non-zero = failure on first failing check.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_DIR"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0

check() {
    local label="$1"
    shift
    if eval "$@" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✅ $label${RESET}"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo -e "  ${RED}❌ $label${RESET}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

# =============================================================================
# Phase 0 — Documentation Bootstrap
# =============================================================================
gate_0() {
    echo -e "\n${CYAN}${BOLD}=== Phase 0 Gate: Documentation Bootstrap ===${RESET}"
    check "0.G1 critique.md exists"            'test -s docs/architecture/critique.md'
    check "0.G2 retort.md exists"              'test -s docs/architecture/retort.md'
    check "0.G3 implementation_plan.md exists"  'test -s docs/architecture/implementation_plan.md'
    check "0.G4 run_gates.sh exists"           'test -f tests/run_gates.sh'
    check "0.G5 AGENTS.md exists"              'test -s AGENTS.md'
}

# =============================================================================
# Phase 1 — Project Scaffolding & Hygiene
# =============================================================================
gate_1() {
    echo -e "\n${CYAN}${BOLD}=== Phase 1 Gate: Scaffolding & Hygiene ===${RESET}"
    check "1.G1 LICENSE is MIT"                'head -1 LICENSE | grep -qi "MIT"'
    check "1.G2 .gitignore has __pycache__"    'grep -q "__pycache__" .gitignore'
    check "1.G3 .gitignore has .DS_Store"      'grep -q ".DS_Store" .gitignore'
    check "1.G4 requirements.txt has requests" 'grep -q "requests" requirements.txt'
    check "1.G5 CONTRIBUTING.md exists"        'test -s CONTRIBUTING.md'
    check "1.G6 PR template exists"            'test -s .github/PULL_REQUEST_TEMPLATE.md'
    check "1.G7 docs/index.html exists"        'test -f docs/index.html'
    check "1.G8 root index.html removed"       '! test -f index.html'
    check "1.G9 Pages scoped to docs/"         'grep -q "path:.*docs" .github/workflows/deploy-pages.yml'
}

# =============================================================================
# Phase 2 — Shell Script Hardening + Homebrew
# =============================================================================
gate_2() {
    echo -e "\n${CYAN}${BOLD}=== Phase 2 Gate: Shell Hardening + Homebrew ===${RESET}"

    local SCRIPT="antigravity-manager.sh"

    # Syntax & lint
    check "2.G1  Bash syntax valid"            "bash -n $SCRIPT"
    check "2.G2  Shellcheck clean"             "shellcheck -e SC1091,SC2162 $SCRIPT"

    # UX flags
    check "2.G3  --version works"              "bash $SCRIPT --version 2>&1 | grep -qE '[0-9]+\.[0-9]+\.[0-9]+'"
    check "2.G4  --help lists --version"       "bash $SCRIPT --help 2>&1 | grep -q '\-\-version'"
    check "2.G5  --help lists --remove"        "bash $SCRIPT --help 2>&1 | grep -q '\-\-remove'"

    # Functions exist
    check "2.G6  detect_platform() exists"     "grep -q 'detect_platform' $SCRIPT"
    check "2.G7  install_brew() exists"        "grep -q 'install_brew' $SCRIPT"
    check "2.G8  check_brew() exists"          "grep -q 'check_brew' $SCRIPT"

    # Safety features
    check "2.G9  trap cleanup exists"          "grep -q 'trap.*EXIT' $SCRIPT"
    check "2.G10 SHA-256 verification"         "grep -q 'sha256sum' $SCRIPT"
    check "2.G11 KNOWN_SHA256 constant"        "grep -q 'KNOWN_SHA256' $SCRIPT"

    # Old patterns removed
    check "2.G12 Old \$0 bash detection gone"  "! grep -q '\"bash\"' $SCRIPT"

    # Menu
    check "2.G13 Menu has 7 options"           "grep -q '\[1-7\]' $SCRIPT"
    check "2.G14 Auto-detect suggestion"       "grep -qiE 'Detected|Recommended|recommend' $SCRIPT"
}

# =============================================================================
# Phase 3 — Nightly Pipeline Fixes
# =============================================================================
gate_3() {
    echo -e "\n${CYAN}${BOLD}=== Phase 3 Gate: Pipeline Fixes ===${RESET}"

    local NIGHTLY=".github/workflows/nightly-update.yml"

    # Action versions
    check "3.G1  checkout@v4"                  "grep -q 'actions/checkout@v4' $NIGHTLY"
    check "3.G2  setup-python@v5"              "grep -q 'actions/setup-python@v5' $NIGHTLY"

    # Pipeline features
    check "3.G3  requirements.txt used"        "grep -q 'requirements.txt' $NIGHTLY"
    check "3.G4  URL validation step"          "grep -qE 'curl.*(--head|-I)' $NIGHTLY"
    check "3.G5  shellcheck lint step"         "grep -q 'shellcheck' $NIGHTLY"
    check "3.G6  sed safe delimiter"           "grep 'sed' $NIGHTLY | grep -q '#'"
    check "3.G7  SHA-256 sync step"            "grep -q 'KNOWN_SHA256' $NIGHTLY"

    # Scraper
    check "3.G8  scraper compiles"             "python3 -m py_compile scrape_latest.py"
    check "3.G9  scraper has docstring"        "python3 -c \"import ast; m=ast.parse(open('scrape_latest.py').read()); assert ast.get_docstring(m)\""
    check "3.G10 scraper has type hints"       "grep -q 'def scrape_url.*->.*:' scrape_latest.py"
    check "3.G11 errors to stderr"             "grep -q 'stderr' scrape_latest.py"
}

# =============================================================================
# Phase 4 — Landing Page, README, & Roadmap
# =============================================================================
gate_4() {
    echo -e "\n${CYAN}${BOLD}=== Phase 4 Gate: Docs & Polish ===${RESET}"

    local PAGE="docs/index.html"

    # Landing page
    check "4.G1  Lucide pinned"                "! grep -q 'lucide@latest' $PAGE"
    check "4.G2  Meta description"             "grep -q 'meta name=\"description\"' $PAGE"
    check "4.G3  OG tags"                      "grep -q 'og:title' $PAGE"
    check "4.G4  Favicon"                      "grep -q 'rel=\"icon\"' $PAGE"
    check "4.G5  Aria labels (>=2)"            "[ \$(grep -c 'aria-label' $PAGE) -ge 2 ]"
    check "4.G6  Homebrew in landing page"     "grep -qi 'brew' $PAGE"
    check "4.G7  aria-expanded toggle"         "grep -q 'aria-expanded' $PAGE"

    # README
    check "4.G8  Architecture section"         "grep -qi 'architecture' README.md"
    check "4.G9  Homebrew documented"          "grep -qi 'brew' README.md"
    check "4.G10 Troubleshooting"              "grep -qi 'troubleshooting' README.md"
    check "4.G11 Roadmap"                      "grep -qi 'roadmap' README.md"
    check "4.G12 Scope claim fixed"            "! grep -qi 'exclusively on Ubuntu' README.md"
    check "4.G13 Changelog"                    "grep -qi 'changelog' README.md"
}

# =============================================================================
# Runner
# =============================================================================
print_summary() {
    echo ""
    echo -e "${BOLD}────────────────────────────────${RESET}"
    echo -e "  ${GREEN}Passed: $PASS_COUNT${RESET}  ${RED}Failed: $FAIL_COUNT${RESET}"
    echo -e "${BOLD}────────────────────────────────${RESET}"
    if [ "$FAIL_COUNT" -gt 0 ]; then
        echo -e "\n${RED}${BOLD}❌ GATE FAILED${RESET}"
        exit 1
    else
        echo -e "\n${GREEN}${BOLD}🎉 ALL GATES PASSED${RESET}"
    fi
}

usage() {
    echo "Usage: $0 --phase <0|1|2|3|4|all>"
    echo ""
    echo "Runs phase gate tests for the agv-easy-install fix-up."
    echo ""
    echo "Options:"
    echo "  --phase 0     Run Phase 0 gate (Documentation Bootstrap)"
    echo "  --phase 1     Run Phase 1 gate (Scaffolding & Hygiene)"
    echo "  --phase 2     Run Phase 2 gate (Shell Hardening + Homebrew)"
    echo "  --phase 3     Run Phase 3 gate (Pipeline Fixes)"
    echo "  --phase 4     Run Phase 4 gate (Docs & Polish)"
    echo "  --phase all   Run all gates sequentially"
    exit 1
}

# Parse args
PHASE=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --phase) PHASE="$2"; shift 2 ;;
        --help|-h) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

if [ -z "$PHASE" ]; then
    usage
fi

echo -e "${BOLD}agv-easy-install — Phase Gate Runner${RESET}"
echo -e "Working directory: ${REPO_DIR}"

if [ "$PHASE" = "all" ]; then
    for p in 0 1 2 3 4; do
        gate_"$p"
    done
else
    gate_"$PHASE"
fi

print_summary
