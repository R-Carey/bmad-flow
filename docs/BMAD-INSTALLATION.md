# BMAD Automation - Installation & Setup Guide

Complete guide to installing and configuring BMAD workflow automation in any project.

---

## 📋 Table of Contents

- [Quick Installation](#quick-installation)
- [Requirements](#requirements)
- [Step-by-Step Setup](#step-by-step-setup)
- [Project-Specific Configuration](#project-specific-configuration)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

---

## Quick Installation

### For Existing BMAD Projects

```bash
# 1. Copy files to your project root
cp bmad.sh bmad-config.sh /path/to/your-project/
cp BMAD-*.md /path/to/your-project/  # Optional: documentation

# 2. Make executable
cd /path/to/your-project/
chmod +x bmad.sh

# 3. Edit configuration
nano bmad-config.sh

# 4. Test it
./bmad.sh status 1
```

**Time**: 5 minutes

---

## Requirements

### ✅ Your Project Must Have

1. **BMAD-METHOD Structure**
   - Epic and story files
   - `sprint-status.yaml` file
   - Defined story format

2. **File Structure** (typical):
   ```
   your-project/
   ├── _bmad-output/
   │   └── implementation-artifacts/
   │       ├── sprint-status.yaml
   │       ├── 1-1-story-name.md
   │       ├── 1-2-story-name.md
   │       └── epics.md
   └── [your code]
   ```

### ✅ System Requirements

- **Claude CLI**: For AI automation
  ```bash
  which claude
  # Should show: /path/to/claude
  ```

- **Copilot CLI**: For multi-model review (optional)
  ```bash
  which copilot
  # Should show: /path/to/copilot
  ```

- **Git**: For auto-commits
  ```bash
  git --version
  ```

- **Zsh or Bash**: Shell (most systems have this)

---

## Step-by-Step Setup

### Step 1: Copy Core Files

Copy these files to your project root:

```bash
# Essential files
bmad.sh                      # Main automation script
bmad-config.sh               # Project configuration

# Documentation (recommended)
BMAD-WORKFLOWS.md            # Complete guide
BMAD-QUICK-REFERENCE.md      # Cheat sheet
BMAD-README.md               # Overview
BMAD-INSTALLATION.md         # This file
BMAD-AUTOMATION-SUMMARY.md   # Summary
```

**From this project**:
```bash
# If copying from seasonal-action-rpg
cd /path/to/seasonal-action-rpg
cp bmad.sh bmad-config.sh /path/to/new-project/
cp BMAD-*.md /path/to/new-project/
```

---

### Step 2: Make Executable

```bash
cd /path/to/new-project/
chmod +x bmad.sh
```

---

### Step 3: Configure for Your Project

Edit `bmad-config.sh` to match your project structure:

```bash
nano bmad-config.sh
```

**Key settings to change**:

```bash
# 1. File Paths (match your project)
export BMAD_STATUS_FILE="_bmad-output/implementation-artifacts/sprint-status.yaml"
export BMAD_STORIES_DIR="_bmad-output/implementation-artifacts"

# 2. Technology Stack
export BMAD_TECH_STACK="Godot"  # Change to: Unity, React, Django, etc.

# 3. File Extensions (for validation)
export BMAD_FILE_EXTENSIONS=".gd .tscn .tres"  # Godot
# Examples:
# Unity:  ".cs .prefab .unity"
# React:  ".tsx .ts .jsx .js"
# Django: ".py .html .css"

# 4. AI Models (optional - defaults are good)
export BMAD_DEV_CLI="claude"
export BMAD_DEV_MODEL="claude-sonnet-4-6"
export BMAD_REVIEW_CLI="copilot"
export BMAD_REVIEW_MODEL="gpt-5.3-codex"
```

---

### Step 4: Update Prompts (Optional)

If your project uses different technology, update prompts in `bmad.sh`:

**Find and replace "Godot" references**:

```bash
# Search for these lines in bmad.sh:
# Line ~320: "Implement all requirements in the Godot project"
# Line ~380: "Code quality and Godot best practices"

# Replace with your technology:
sed -i '' 's/Godot/Unity/g' bmad.sh        # Unity example
sed -i '' 's/Godot/React/g' bmad.sh        # React example
sed -i '' 's/Godot/Django/g' bmad.sh       # Django example
```

Or edit manually:
```bash
nano bmad.sh
# Search: Godot
# Replace: Your technology
```

---

### Step 5: Verify Installation

```bash
# Test help command
./bmad.sh help

# Test status command (use your actual epic number)
./bmad.sh status 1

# Test preflight (use an actual story)
./bmad.sh preflight 1-1
```

**Expected**: No errors, shows project status

---

## Project-Specific Configuration

### Example 1: Godot Game (Default)

```bash
# bmad-config.sh
export BMAD_STATUS_FILE="_bmad-output/implementation-artifacts/sprint-status.yaml"
export BMAD_STORIES_DIR="_bmad-output/implementation-artifacts"
export BMAD_TECH_STACK="Godot"
export BMAD_FILE_EXTENSIONS=".gd .tscn .tres"
```

### Example 2: Unity Game

```bash
# bmad-config.sh
export BMAD_STATUS_FILE="_bmad-output/implementation-artifacts/sprint-status.yaml"
export BMAD_STORIES_DIR="_bmad-output/implementation-artifacts"
export BMAD_TECH_STACK="Unity"
export BMAD_FILE_EXTENSIONS=".cs .prefab .unity .asset"
```

Then update prompts:
```bash
sed -i '' 's/Godot/Unity/g' bmad.sh
```

### Example 3: React Web App

```bash
# bmad-config.sh
export BMAD_STATUS_FILE="docs/sprint-status.yaml"
export BMAD_STORIES_DIR="docs/stories"
export BMAD_TECH_STACK="React"
export BMAD_FILE_EXTENSIONS=".tsx .ts .jsx .js .css"
```

Then update prompts:
```bash
sed -i '' 's/Godot project/React application/g' bmad.sh
sed -i '' 's/Godot best practices/React best practices/g' bmad.sh
```

### Example 4: Django Web App

```bash
# bmad-config.sh
export BMAD_STATUS_FILE="docs/sprint-status.yaml"
export BMAD_STORIES_DIR="docs/stories"
export BMAD_TECH_STACK="Django"
export BMAD_FILE_EXTENSIONS=".py .html .css .js"
```

Then update prompts:
```bash
sed -i '' 's/Godot project/Django application/g' bmad.sh
sed -i '' 's/Godot best practices/Python\/Django best practices/g' bmad.sh
```

### Example 5: Expo/React Native Mobile App

```bash
# bmad-config.sh
export BMAD_STATUS_FILE="_bmad-output/implementation-artifacts/sprint-status.yaml"
export BMAD_STORIES_DIR="_bmad-output/implementation-artifacts"
export BMAD_TECH_STACK="Expo React Native"
export BMAD_FILE_EXTENSIONS=".tsx .ts .jsx .js .json"
```

Then update prompts:
```bash
sed -i '' 's/Godot project/Expo React Native app/g' bmad.sh
sed -i '' 's/Godot best practices/React Native and Expo best practices/g' bmad.sh
```

**Testing after dev-story**:
```bash
# When automation pauses for testing:
npx expo start
# Test on iOS simulator, Android emulator, or physical device
# Verify the feature works, then press Enter
```

### Example 6: Custom Project Structure

```bash
# bmad-config.sh
export BMAD_STATUS_FILE="project/status.yaml"
export BMAD_STORIES_DIR="project/stories"
export BMAD_TECH_STACK="Custom"
export BMAD_FILE_EXTENSIONS=".custom .ext"
```

---

## Verification Checklist

After installation, verify everything works:

### ✅ 1. Help Command
```bash
./bmad.sh help
```
**Expected**: Colorful help menu with all commands

### ✅ 2. Status Command
```bash
./bmad.sh status 1  # Use your actual epic number
```
**Expected**: 
- Progress bar showing completion
- List of stories with status icons
- No errors

### ✅ 3. Preflight Check
```bash
./bmad.sh preflight 1-1  # Use an actual story
```
**Expected**:
- Git status check
- Story file validation
- Status check

### ✅ 4. Configuration Check
```bash
# Check paths exist
ls -la _bmad-output/implementation-artifacts/sprint-status.yaml

# Check Claude CLI
which claude

# Check Copilot CLI (optional)
which copilot
```

### ✅ 5. Test Run (Optional)
```bash
# Try a story cycle (will pause for confirmation)
./bmad.sh cycle 1-1
# Press Ctrl+C to abort if just testing
```

---

## Common Issues & Fixes

### Issue: "Command not found: ./bmad.sh"

**Fix**:
```bash
chmod +x bmad.sh
```

---

### Issue: "sprint-status.yaml not found"

**Fix**: Update `BMAD_STATUS_FILE` in `bmad-config.sh` to match your path:
```bash
# Find your file
find . -name "sprint-status.yaml"

# Update config
export BMAD_STATUS_FILE="path/from/find/command"
```

---

### Issue: "Story file not found"

**Fix**: Update `BMAD_STORIES_DIR` in `bmad-config.sh`:
```bash
# Find your story files
find . -name "*.md" -path "*/implementation-artifacts/*"

# Update config
export BMAD_STORIES_DIR="correct/path/to/stories"
```

---

### Issue: "Claude CLI not found"

**Fix**: Install or locate Claude CLI:
```bash
# Find it
which claude

# Update config if in different location
export BMAD_CLAUDE_BIN="/actual/path/to/claude"
```

---

### Issue: "Git dirty warning"

**Fix**: Commit or stash your changes:
```bash
git commit -am "WIP: save current work"
# Or:
git stash
```

---

### Issue: "Prompts mention wrong technology"

**Fix**: Update prompts in `bmad.sh`:
```bash
# Find and replace technology name
sed -i '' 's/Godot/YourTech/g' bmad.sh

# Or edit manually
nano bmad.sh
# Search for: Godot (or current tech)
# Replace with: Your technology
```

---

## First Run Tutorial

After installation, try this guided first run:

### 1. Check Your Progress
```bash
./bmad.sh status 1
```
**What you'll see**: Current epic status, progress bar, story list

### 2. Validate a Story
```bash
./bmad.sh preflight 1-1  # Replace 1-1 with actual story
```
**What you'll see**: Pre-flight checks, validation results

### 3. Try a Full Cycle (Recommended)
```bash
./bmad.sh cycle 1-2  # Replace with your next story
```

**What happens**:
1. Claude creates story file (if needed)
2. **Pause** - You review
3. Claude implements story
4. **Pause** - You test
5. AI reviews code
6. Story marked done

You can abort at any pause point (Ctrl+C)

---

## Directory Structure Examples

### Standard BMAD Structure (Most Common)
```
your-project/
├── bmad.sh                 ← Install here
├── bmad-config.sh          ← Install here
├── BMAD-*.md               ← Install here (optional)
├── _bmad-output/
│   └── implementation-artifacts/
│       ├── sprint-status.yaml     ← Points to this
│       ├── 1-1-story.md           ← Stories here
│       ├── 1-2-story.md
│       └── epics.md
└── [your code]
```

### Custom Structure Example
```
your-project/
├── bmad.sh                 ← Install here
├── bmad-config.sh          ← Configure for custom paths
├── docs/
│   ├── status.yaml         ← Custom status file
│   └── stories/            ← Custom story location
│       ├── 1-1-story.md
│       └── 1-2-story.md
└── src/
    └── [your code]
```

**Update `bmad-config.sh`**:
```bash
export BMAD_STATUS_FILE="docs/status.yaml"
export BMAD_STORIES_DIR="docs/stories"
```

---

## Advanced Configuration

### Custom Validation Function

Add to `bmad-config.sh`:
```bash
# Custom validation command
export BMAD_CUSTOM_VALIDATION="./scripts/validate-project.sh"
```

Create `scripts/validate-project.sh`:
```bash
#!/bin/bash
# Custom project validation
echo "Running custom validation..."
# Your validation logic here
```

### Multiple AI Providers

Configure different AIs per phase in `bmad-config.sh`:
```bash
# Use Claude for everything
export BMAD_DEV_CLI="claude"
export BMAD_REVIEW_CLI="claude"

# Or use GPT for everything
export BMAD_DEV_CLI="copilot"
export BMAD_REVIEW_CLI="copilot"

# Or mix (recommended - catches more issues)
export BMAD_DEV_CLI="claude"      # Creative implementation
export BMAD_REVIEW_CLI="copilot"  # Analytical review
```

### Custom Models

```bash
# High-reasoning for complex projects
export BMAD_DEV_MODEL="opus"
export BMAD_REVIEW_MODEL="gpt-5.5-medium"

# Fast models for simple projects
export BMAD_DEV_MODEL="sonnet"
export BMAD_REVIEW_MODEL="gpt-5.2"
```

---

## Upgrading

To upgrade to a newer version of BMAD automation:

```bash
# 1. Backup your config
cp bmad-config.sh bmad-config.sh.backup

# 2. Copy new version
cp /path/to/new/bmad.sh ./bmad.sh

# 3. Restore your config
mv bmad-config.sh.backup bmad-config.sh

# 4. Check changelog for breaking changes
cat BMAD-AUTOMATION-SUMMARY.md

# 5. Test
./bmad.sh status 1
```

---

## Uninstallation

To remove BMAD automation from a project:

```bash
# Remove files
rm bmad.sh
rm bmad-config.sh
rm BMAD-*.md

# That's it! Your project code is untouched.
```

Note: This only removes the automation scripts. Your story files, status files, and project code remain unchanged.

---

## Getting Help

- **Installation issues**: Check [Troubleshooting](#troubleshooting) section
- **Usage help**: `./bmad.sh help`
- **Command reference**: `cat BMAD-QUICK-REFERENCE.md`
- **Full guide**: `cat BMAD-WORKFLOWS.md`

---

## Success Checklist

You're ready to use BMAD automation when:

- ✅ `./bmad.sh help` shows help menu
- ✅ `./bmad.sh status 1` shows your project status
- ✅ `./bmad.sh preflight 1-1` passes validation
- ✅ Configuration matches your project structure
- ✅ Claude/Copilot CLI are accessible

---

## Next Steps

1. **Read quick reference**: `cat BMAD-QUICK-REFERENCE.md`
2. **Check progress**: `./bmad.sh status 1`
3. **Try one story**: `./bmad.sh cycle 1-1`
4. **Process your epic**: `./bmad.sh epic 1`

---

## Templates by Project Type

### Game Development

**Godot** (default in this project):
```bash
BMAD_TECH_STACK="Godot"
BMAD_FILE_EXTENSIONS=".gd .tscn .tres"
```

**Unity**:
```bash
BMAD_TECH_STACK="Unity"
BMAD_FILE_EXTENSIONS=".cs .prefab .unity .asset"
```

**Unreal**:
```bash
BMAD_TECH_STACK="Unreal"
BMAD_FILE_EXTENSIONS=".cpp .h .uasset .umap"
```

### Web Development

**React**:
```bash
BMAD_TECH_STACK="React"
BMAD_FILE_EXTENSIONS=".tsx .ts .jsx .js .css"
```

**Vue**:
```bash
BMAD_TECH_STACK="Vue"
BMAD_FILE_EXTENSIONS=".vue .ts .js .css"
```

**Angular**:
```bash
BMAD_TECH_STACK="Angular"
BMAD_FILE_EXTENSIONS=".ts .component.ts .html .css"
```

### Backend Development

**Django**:
```bash
BMAD_TECH_STACK="Django"
BMAD_FILE_EXTENSIONS=".py .html .css"
```

**Rails**:
```bash
BMAD_TECH_STACK="Rails"
BMAD_FILE_EXTENSIONS=".rb .erb .html .css"
```

**Node.js**:
```bash
BMAD_TECH_STACK="Node.js"
BMAD_FILE_EXTENSIONS=".js .ts .json"
```

### Mobile Development

**Expo/React Native**:
```bash
BMAD_TECH_STACK="Expo React Native"
BMAD_FILE_EXTENSIONS=".tsx .ts .jsx .js .json"
```

**Flutter**:
```bash
BMAD_TECH_STACK="Flutter"
BMAD_FILE_EXTENSIONS=".dart .yaml"
```

**Swift/iOS**:
```bash
BMAD_TECH_STACK="Swift iOS"
BMAD_FILE_EXTENSIONS=".swift .storyboard .xib"
```

---

**Installation complete!** You're ready to accelerate your BMAD development workflow. 🚀
