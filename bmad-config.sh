#!/bin/zsh

# ============================================================================
# BMAD Automation - Project Configuration Template
# ============================================================================
# Edit this file to match your project structure and technology stack
# ============================================================================

# ─────────────────────────────────────────────────────────────────────────
# PROJECT PATHS
# ─────────────────────────────────────────────────────────────────────────
# Adjust these to match your BMAD project structure

export BMAD_STATUS_FILE="_bmad-output/implementation-artifacts/sprint-status.yaml"
export BMAD_STORIES_DIR="_bmad-output/implementation-artifacts"

# ─────────────────────────────────────────────────────────────────────────
# TECHNOLOGY STACK
# ─────────────────────────────────────────────────────────────────────────
# Set to your project's technology (used in AI prompts)
# Examples: "Godot", "Unity", "React", "Expo React Native", "Django", etc.

export BMAD_TECH_STACK="Your Technology"

# ─────────────────────────────────────────────────────────────────────────
# FILE EXTENSIONS
# ─────────────────────────────────────────────────────────────────────────
# File extensions to validate during code review (space-separated)
# 
# Game Dev Examples:
#   Godot:  ".gd .tscn .tres"
#   Unity:  ".cs .prefab .unity .asset"
#   Unreal: ".cpp .h .uasset .umap"
#
# Web Dev Examples:
#   React:   ".tsx .ts .jsx .js .css"
#   Vue:     ".vue .ts .js .css"
#   Angular: ".ts .component.ts .html .css"
#   Django:  ".py .html .css"
#
# Mobile Dev Examples:
#   Expo/React Native: ".tsx .ts .jsx .js .json"
#   Flutter:           ".dart .yaml"
#   Swift:             ".swift .storyboard .xib"

export BMAD_FILE_EXTENSIONS=".example .ext"

# ─────────────────────────────────────────────────────────────────────────
# CLI BINARIES
# ─────────────────────────────────────────────────────────────────────────
# Paths to your AI CLI tools (usually don't need to change)

export BMAD_CLAUDE_BIN="claude"    # or full path: "/path/to/claude"
export BMAD_COPILOT_BIN="copilot"  # or full path: "/path/to/copilot"

# ─────────────────────────────────────────────────────────────────────────
# DEFAULT AI MODELS
# ─────────────────────────────────────────────────────────────────────────
# Configure which AI models to use for each phase

# Phase 1: Create Story (fast, good at documentation)
export BMAD_CREATE_CLI="claude"
export BMAD_CREATE_MODEL="sonnet"

# Phase 2: Implementation (creative, great at code generation)
export BMAD_DEV_CLI="claude"
export BMAD_DEV_MODEL="claude-sonnet-4-6"

# Phase 3: Code Review (analytical, catches different issues)
# Recommendation: Use different model than dev for fresh perspective
export BMAD_REVIEW_CLI="copilot"  # or "claude" if you don't have copilot
export BMAD_REVIEW_MODEL="gpt-5.3-codex"  # or "claude-sonnet-4-6"

# ─────────────────────────────────────────────────────────────────────────
# ADVANCED OPTIONS (Optional)
# ─────────────────────────────────────────────────────────────────────────

# Custom validation script (uncomment to use)
# export BMAD_CUSTOM_VALIDATION="./scripts/validate-project.sh"

# ─────────────────────────────────────────────────────────────────────────
# NOTES
# ─────────────────────────────────────────────────────────────────────────
# 
# Multi-Model Strategy:
# - Using different models for dev vs review catches more bugs
# - Claude: Creative, great at implementation
# - GPT: Analytical, catches different edge cases
# 
# See examples/ directory for complete configurations for specific technologies
#
# ─────────────────────────────────────────────────────────────────────────
