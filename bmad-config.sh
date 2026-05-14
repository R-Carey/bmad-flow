#!/bin/zsh

# ============================================================================
# BMAD Flow - Godot Game Configuration
# ============================================================================
# Configuration for Seasons of Stillness (Godot project)
# ============================================================================

# ─────────────────────────────────────────────────────────────────────────
# PROJECT PATHS
# ─────────────────────────────────────────────────────────────────────────
export BMAD_STATUS_FILE="_bmad-output/implementation-artifacts/sprint-status.yaml"
export BMAD_STORIES_DIR="_bmad-output/implementation-artifacts"

# ─────────────────────────────────────────────────────────────────────────
# TECHNOLOGY STACK
# ─────────────────────────────────────────────────────────────────────────
export BMAD_TECH_STACK="Godot"

# ─────────────────────────────────────────────────────────────────────────
# FILE EXTENSIONS
# ─────────────────────────────────────────────────────────────────────────
# Godot file types to validate during code review
export BMAD_FILE_EXTENSIONS=".gd .tscn .tres"

# ─────────────────────────────────────────────────────────────────────────
# CLI BINARIES
# ─────────────────────────────────────────────────────────────────────────
export BMAD_CLAUDE_BIN="/Users/rc-macpro-2/.local/bin/claude"
export BMAD_COPILOT_BIN="/usr/local/bin/copilot"

# ─────────────────────────────────────────────────────────────────────────
# DEFAULT AI MODELS (Model-Centric Configuration)
# ─────────────────────────────────────────────────────────────────────────
# Choose the best MODEL for each phase, not the CLI provider!
# Both Claude and Copilot support multiple models with different strengths.
#
# 🎯 RECOMMENDED MODEL STRATEGY:
#
# Phase 1 - Create Story (Documentation & Planning):
#   Best: claude-sonnet-4-6    (fast, concise, structured)
#   Alt:  gpt-5.3-codex        (good at breaking down requirements)
#
# Phase 2 - Implementation (Code Generation):
#   Best: claude-opus-4-7-high (most capable, best for complex Godot)
#   Alt:  claude-sonnet-4-6    (faster, good for simpler stories)
#   Alt:  gpt-5.5-medium       (strong at GDScript patterns)
#
# Phase 3 - Code Review (Analysis & Bug Detection):
#   Best: gpt-5.3-codex        (analytical, catches edge cases)
#   Alt:  claude-sonnet-4-6    (good second opinion)
#
# 💡 TIP: Use DIFFERENT models for dev vs review to catch more issues!
# ─────────────────────────────────────────────────────────────────────────

# Phase 1: Create Story
export BMAD_CREATE_CLI="claude"
export BMAD_CREATE_MODEL="claude-sonnet-4-6"

# Phase 2: Implementation  
export BMAD_DEV_CLI="claude"
export BMAD_DEV_MODEL="claude-sonnet-4-6"        # or: claude-opus-4-7-high, gpt-5.5-medium

# Phase 3: Code Review (different model for fresh perspective!)
export BMAD_REVIEW_CLI="copilot"
export BMAD_REVIEW_MODEL="gpt-5.3-codex"         # or: claude-sonnet-4-6

# ─────────────────────────────────────────────────────────────────────────
# MODEL REFERENCE
# ─────────────────────────────────────────────────────────────────────────
# CLAUDE MODELS (via --cli claude):
#   sonnet, claude-sonnet-4-6      - Fast, efficient, great for most tasks
#   opus, claude-opus-4-7-high     - Most capable, best for complex code
#   haiku                          - Fastest, simple tasks only
#
# GPT MODELS (via --cli copilot):
#   gpt-5.3-codex                  - Excellent for code analysis & review
#   gpt-5.5-medium                 - Strong general coding capability
#   gpt-4                          - Solid fallback option
# ─────────────────────────────────────────────────────────────────────────
