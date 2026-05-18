#!/bin/bash

# ============================================================================
# BMAD Flow - Installation Script
# ============================================================================
# Installs BMAD workflow automation into your project
# ============================================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║       BMAD Workflow Automation - Installation          ║${NC}"
echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════╝${NC}\n"

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}\n"

# Check for git
if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ Git not found${NC}"
    echo -e "${YELLOW}  Install git first: https://git-scm.com/downloads${NC}\n"
    exit 1
fi
echo -e "${GREEN}✓ Git found${NC}"

# Check for claude CLI
if ! command -v claude &> /dev/null; then
    echo -e "${YELLOW}⚠ Claude CLI not found${NC}"
    echo -e "${YELLOW}  Install from: https://docs.anthropic.com/claude/docs/cli${NC}"
    echo -e "${YELLOW}  (Required for automation to work)${NC}\n"
else
    echo -e "${GREEN}✓ Claude CLI found${NC}"
fi

# Check for copilot CLI (optional)
if command -v copilot &> /dev/null; then
    echo -e "${GREEN}✓ Copilot CLI found (optional, for multi-model support)${NC}"
else
    echo -e "${CYAN}ℹ Copilot CLI not found (optional)${NC}"
    echo -e "${CYAN}  Install for multi-model support: https://github.com/github/copilot-cli${NC}"
fi

echo ""

# Detect if we're in a project directory
if [ ! -f "sprint-status.yaml" ] && [ ! -f "_bmad-output/implementation-artifacts/sprint-status.yaml" ]; then
    echo -e "${YELLOW}⚠ Warning: No sprint-status.yaml found in current directory${NC}"
    echo -e "${YELLOW}  Make sure you're in your BMAD project root${NC}\n"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Installation cancelled${NC}"
        exit 1
    fi
fi

# Ask where to install
echo -e "${BLUE}Where would you like to install?${NC}"
echo -e "1) Current directory ($(pwd))"
echo -e "2) Specify a path"
read -p "Choice (1 or 2): " install_choice

if [ "$install_choice" = "2" ]; then
    read -p "Enter installation path: " INSTALL_DIR
    INSTALL_DIR="${INSTALL_DIR/#\~/$HOME}"  # Expand ~
else
    INSTALL_DIR="."
fi

# Create directory if it doesn't exist
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo -e "\n${BLUE}Installing to: $(pwd)${NC}\n"

# Download or copy files
echo -e "${BLUE}Installing files...${NC}\n"

if [ -f "$(dirname "$0")/bmad.sh" ]; then
    # Installing from local directory
    echo -e "${CYAN}Installing from local files...${NC}"
    cp "$(dirname "$0")/bmad.sh" ./bmad.sh
    cp "$(dirname "$0")/bmad-config.sh" ./bmad-config.sh
    
    # Copy docs if they exist
    if [ -d "$(dirname "$0")/docs" ]; then
        mkdir -p ./docs
        cp -r "$(dirname "$0")/docs/"* ./docs/ 2>/dev/null || true
    fi
else
    # Download from GitHub
    echo -e "${CYAN}Downloading from GitHub...${NC}"
    curl -sL "https://raw.githubusercontent.com/R-Carey/bmad-flow/main/bmad.sh" -o bmad.sh
    curl -sL "https://raw.githubusercontent.com/R-Carey/bmad-flow/main/bmad-config.sh" -o bmad-config.sh
fi

# Make executable
chmod +x bmad.sh

echo -e "${GREEN}✓ Files installed${NC}\n"

# Detect project type
echo -e "${BLUE}Detecting project type...${NC}\n"

PROJECT_TYPE="Unknown"
FILE_EXTENSIONS=".example"

if [ -f "project.godot" ]; then
    PROJECT_TYPE="Godot"
    FILE_EXTENSIONS=".gd .tscn .tres"
elif [ -f "ProjectSettings/ProjectSettings.asset" ] || ([ -d "Assets" ] && [ -d "Library" ] && [ -d "Packages" ]); then
    PROJECT_TYPE="Unity"
    FILE_EXTENSIONS=".cs .prefab .unity .asset"
elif [ -f "package.json" ]; then
    if grep -q "expo" package.json; then
        PROJECT_TYPE="Expo React Native"
        FILE_EXTENSIONS=".tsx .ts .jsx .js .json"
    elif grep -q "react-native" package.json; then
        PROJECT_TYPE="React Native"
        FILE_EXTENSIONS=".tsx .ts .jsx .js .json"
    elif grep -q "react" package.json; then
        PROJECT_TYPE="React"
        FILE_EXTENSIONS=".tsx .ts .jsx .js .css"
    elif grep -q "vue" package.json; then
        PROJECT_TYPE="Vue"
        FILE_EXTENSIONS=".vue .ts .js .css"
    else
        PROJECT_TYPE="Node.js"
        FILE_EXTENSIONS=".js .ts .json"
    fi
elif [ -f "manage.py" ] && grep -q "django" manage.py; then
    PROJECT_TYPE="Django"
    FILE_EXTENSIONS=".py .html .css"
elif [ -f "Gemfile" ] && grep -q "rails" Gemfile; then
    PROJECT_TYPE="Rails"
    FILE_EXTENSIONS=".rb .erb .html .css"
elif [ -f "pubspec.yaml" ]; then
    PROJECT_TYPE="Flutter"
    FILE_EXTENSIONS=".dart .yaml"
fi

if [ "$PROJECT_TYPE" != "Unknown" ]; then
    echo -e "${GREEN}✓ Detected: $PROJECT_TYPE${NC}\n"
    
    # Auto-configure bmad-config.sh
    echo -e "${BLUE}Configuring for $PROJECT_TYPE...${NC}\n"
    
    # Update legacy fields if present in template
    sed -i.bak "s/export BMAD_TECH_STACK=\"Your Technology\"/export BMAD_TECH_STACK=\"$PROJECT_TYPE\"/" bmad-config.sh
    sed -i.bak "s/export BMAD_FILE_EXTENSIONS=\".example .ext\"/export BMAD_FILE_EXTENSIONS=\"$FILE_EXTENSIONS\"/" bmad-config.sh
    rm -f bmad-config.sh.bak

    # Set project-type-specific config vars
    case "$PROJECT_TYPE" in
        "Godot")
            sed -i.bak 's/export BMAD_APP_NOUN="app"/export BMAD_APP_NOUN="game"/' bmad-config.sh
            sed -i.bak 's|export BMAD_TEST_CMD=""|export BMAD_TEST_CMD="./run_tests.sh"|' bmad-config.sh
            sed -i.bak 's|export BMAD_TEST_FILE_PATTERN=""|export BMAD_TEST_FILE_PATTERN='"'"'scenes/[^ "]+_test\\.tscn'"'"'|' bmad-config.sh
            sed -i.bak 's|export BMAD_TEST_RUN_INSTRUCTIONS=""|export BMAD_TEST_RUN_INSTRUCTIONS="Godot editor → FileSystem panel → double-click scene → Clear Output → F6"|' bmad-config.sh
            sed -i.bak 's|export BMAD_TEST_PASS_INDICATOR=""|export BMAD_TEST_PASS_INDICATOR="Output ends with: Results: X passed, 0 failed"|' bmad-config.sh
            sed -i.bak 's|export BMAD_TEST_FAIL_INDICATOR=""|export BMAD_TEST_FAIL_INDICATOR="Any FAIL — line in Output → fix before continuing"|' bmad-config.sh
            rm -f bmad-config.sh.bak

            # Generate run_tests.sh for headless Godot testing
            cat > run_tests.sh << 'RUNTESTS'
#!/bin/zsh
# Run a Godot test scene headlessly.
# Usage: ./run_tests.sh scenes/systems/my_test.tscn
#
# Resolves Godot binary automatically — no need for `godot` on PATH.

set -euo pipefail

SCENE="${1:-}"
if [ -z "$SCENE" ]; then
    echo "Usage: ./run_tests.sh <path/to/test.tscn>"
    exit 1
fi

G="$(command -v godot4 2>/dev/null || command -v godot 2>/dev/null || echo /Applications/Godot.app/Contents/MacOS/Godot)"

if [ ! -x "$G" ]; then
    echo "MANUAL: Godot binary not found at '$G'."
    echo "        Run the test manually: open ${SCENE} in the Godot editor → F6"
    exit 1
fi

echo "▶  $G --headless $SCENE"
"$G" --headless "$SCENE"
RUNTESTS
            chmod +x run_tests.sh
            echo -e "${GREEN}✓ run_tests.sh generated (headless Godot test runner)${NC}"
            ;;

        "React"|"Expo React Native"|"React Native"|"Vue"|"Node.js")
            sed -i.bak 's|export BMAD_TEST_CMD=""|export BMAD_TEST_CMD="npm test"|' bmad-config.sh
            sed -i.bak "s|export BMAD_TEST_FILE_PATTERN=\"\"|export BMAD_TEST_FILE_PATTERN='tests\?/[^ \"]+\\.(test\|spec)\\.(js\|ts)'|" bmad-config.sh
            sed -i.bak 's|export BMAD_TEST_PASS_INDICATOR=""|export BMAD_TEST_PASS_INDICATOR="All tests passed (0 failures)"|' bmad-config.sh
            sed -i.bak 's|export BMAD_TEST_FAIL_INDICATOR=""|export BMAD_TEST_FAIL_INDICATOR="FAIL or Error lines in output → fix before continuing"|' bmad-config.sh
            rm -f bmad-config.sh.bak
            ;;

        "Django")
            sed -i.bak 's|export BMAD_TEST_CMD=""|export BMAD_TEST_CMD="python manage.py test"|' bmad-config.sh
            sed -i.bak 's|export BMAD_TEST_PASS_INDICATOR=""|export BMAD_TEST_PASS_INDICATOR="OK (X tests)"|' bmad-config.sh
            sed -i.bak 's|export BMAD_TEST_FAIL_INDICATOR=""|export BMAD_TEST_FAIL_INDICATOR="FAILED (failures=X) → fix before continuing"|' bmad-config.sh
            rm -f bmad-config.sh.bak
            ;;

        "Rails")
            sed -i.bak 's|export BMAD_TEST_CMD=""|export BMAD_TEST_CMD="bundle exec rspec"|' bmad-config.sh
            sed -i.bak 's|export BMAD_TEST_PASS_INDICATOR=""|export BMAD_TEST_PASS_INDICATOR="X examples, 0 failures"|' bmad-config.sh
            sed -i.bak 's|export BMAD_TEST_FAIL_INDICATOR=""|export BMAD_TEST_FAIL_INDICATOR="X failure(s) → fix before continuing"|' bmad-config.sh
            rm -f bmad-config.sh.bak
            ;;

        "Flutter")
            sed -i.bak 's|export BMAD_TEST_CMD=""|export BMAD_TEST_CMD="flutter test"|' bmad-config.sh
            sed -i.bak 's|export BMAD_TEST_PASS_INDICATOR=""|export BMAD_TEST_PASS_INDICATOR="All tests passed!"|' bmad-config.sh
            sed -i.bak 's|export BMAD_TEST_FAIL_INDICATOR=""|export BMAD_TEST_FAIL_INDICATOR="Some tests failed → fix before continuing"|' bmad-config.sh
            rm -f bmad-config.sh.bak
            ;;
    esac

    echo -e "${GREEN}✓ Configuration updated${NC}\n"
else
    echo -e "${YELLOW}⚠ Could not auto-detect project type${NC}"
    echo -e "${YELLOW}  Please edit bmad-config.sh manually${NC}\n"
fi


# Test installation
echo -e "${BLUE}Testing installation...${NC}\n"

if ./bmad.sh help > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Installation successful!${NC}\n"
else
    echo -e "${RED}✗ Installation test failed${NC}"
    echo -e "${YELLOW}  Try running: ./bmad.sh help${NC}\n"
    exit 1
fi

# Summary
echo -e "${BOLD}${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║              Installation Complete!                     ║${NC}"
echo -e "${BOLD}${GREEN}╚════════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${BOLD}Project Type:${NC} $PROJECT_TYPE"
echo -e "${BOLD}Install Location:${NC} $(pwd)"
echo -e "${BOLD}Files Installed:${NC}"
echo -e "  • bmad.sh"
echo -e "  • bmad-config.sh"
if [ -d "./docs" ]; then
    echo -e "  • docs/ (documentation)"
fi
echo ""

echo -e "${BOLD}${CYAN}Next Steps:${NC}\n"
echo -e "1. ${YELLOW}Check your configuration:${NC}"
echo -e "   ./bmad.sh config"
echo ""
echo -e "2. ${YELLOW}Review or tweak settings:${NC}"
echo -e "   nano bmad-config.sh"
echo ""
echo -e "3. ${YELLOW}Test it:${NC}"
echo -e "   ./bmad.sh help"
echo -e "   ./bmad.sh status 1"
echo ""
echo -e "4. ${YELLOW}Use it:${NC}"
echo -e "   ./bmad.sh cycle 1-1"
echo ""

echo -e "${BOLD}${CYAN}Documentation:${NC}"
echo -e "• Quick Start: ./bmad.sh help"
if [ -f "./docs/BMAD-QUICK-REFERENCE.md" ]; then
    echo -e "• Cheat Sheet: cat docs/BMAD-QUICK-REFERENCE.md"
fi
if [ -f "./docs/BMAD-WORKFLOWS.md" ]; then
    echo -e "• Full Guide:  cat docs/BMAD-WORKFLOWS.md"
fi
if [ -f "./docs/BMAD-INSTALLATION.md" ]; then
    echo -e "• Install FAQ: cat docs/BMAD-INSTALLATION.md"
fi
echo ""

echo -e "${BOLD}${GREEN}Happy automating! 🚀${NC}\n"
