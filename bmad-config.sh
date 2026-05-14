#!/bin/zsh

# ============================================================================
# BMAD Flow - Project Configuration Template
# ============================================================================
# Copy this file to your project and customize for your setup.
# See examples/ folder for framework-specific configurations.
# ============================================================================

# ─────────────────────────────────────────────────────────────────────────
# PROJECT PATHS
# ─────────────────────────────────────────────────────────────────────────
export BMAD_STATUS_FILE="_bmad-output/implementation-artifacts/sprint-status.yaml"
export BMAD_STORIES_DIR="_bmad-output/implementation-artifacts"

# ─────────────────────────────────────────────────────────────────────────
# CLI BINARIES (adjust paths for your system)
# ─────────────────────────────────────────────────────────────────────────
export BMAD_CLAUDE_BIN="claude"
export BMAD_COPILOT_BIN="copilot"

# ─────────────────────────────────────────────────────────────────────────
# DEFAULT AI MODELS (Model-Centric Configuration)
# ─────────────────────────────────────────────────────────────────────────
# Choose the best MODEL for each phase, not the CLI provider!
# Both CLIs support multiple models with different strengths.
#
# 🎯 RECOMMENDED MODEL STRATEGY:
#
# Phase 1 - Create Story (Planning, fast turnaround):
#   Best: sonnet                  (fast, concise, structured)
#   Alt:  gpt-5.3-codex           (good at decomposing requirements)
#
# Phase 2 - Implementation (Complex code generation):
#   Best: claude-sonnet-4-6       (balanced speed + quality)
#   Alt:  claude-opus-4-7-high    (most capable, complex tasks)
#   Alt:  gpt-5.5-medium          (strong general coding)
#
# Phase 3 - Code Review (Analytical, bug detection):
#   Best: gpt-5.3-codex           (analytical, catches edge cases)
#   Alt:  claude-sonnet-4-6       (good second opinion)
#
# 💡 TIP: Use DIFFERENT models for dev vs review to catch more bugs!
# ─────────────────────────────────────────────────────────────────────────

# Phase 1: Create Story
export BMAD_CREATE_CLI="claude"
export BMAD_CREATE_MODEL="sonnet"

# Phase 2: Implementation
export BMAD_DEV_CLI="claude"
export BMAD_DEV_MODEL="claude-sonnet-4-6"

# Phase 3: Code Review (different model = fresh perspective!)
export BMAD_REVIEW_CLI="copilot"
export BMAD_REVIEW_MODEL="gpt-5.3-codex"

# ─────────────────────────────────────────────────────────────────────────
# MODEL REFERENCE
# ─────────────────────────────────────────────────────────────────────────
# CLAUDE CLI (--cli claude):
#   - sonnet, claude-sonnet-4-6      Fast, efficient, great for most tasks
#   - opus, claude-opus-4-7-high     Most capable, complex implementation
#   - haiku                          Fastest, simple tasks only
#
# COPILOT CLI (--cli copilot):
#   Supports BOTH GPT and Claude models!
#   GPT:
#     - gpt-5.4 (default)            Latest GPT, balanced
#     - gpt-5.3-codex                Excellent for code review
#     - gpt-5.5-medium               Strong general coding
#   Claude (via Copilot):
#     - claude-sonnet-4.6            Fast, efficient (supports effort levels)
#     - claude-haiku-4.5             Fastest option
#
# 💡 Claude & Copilot have SEPARATE rate limits - switch if one hits limit!
# 💡 Copilot supports effort levels for Claude models (low/medium/high)
# ─────────────────────────────────────────────────────────────────────────
