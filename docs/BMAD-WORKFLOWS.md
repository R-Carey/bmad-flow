# BMAD Game Dev Studio - Workflow Automation Guide

Complete guide to automating your BMAD-METHOD game development workflow.

---

## Table of Contents

- [Quick Start](#quick-start)
- [Commands Reference](#commands-reference)
- [Workflow Cycles](#workflow-cycles)
- [Multi-Model Strategy](#multi-model-strategy)
- [Progress Tracking](#progress-tracking)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

### 1. Check Your Progress

```bash
./bmad.sh status 2
```

**Output**: Visual progress bar, story breakdown, what's left to do

### 2. Start Next Story

```bash
# Option A: Run phases manually (recommended for learning)
./bmad.sh create-story 2-7

# Option B: Run full cycle (automated with test pauses)
./bmad.sh cycle 2-7
```

### 3. Process Entire Epic

```bash
./bmad.sh epic 2
```

**Output**: Processes all backlog stories in Epic 2, one at a time

---

## Commands Reference

### 📋 Individual Story Commands

These run a single phase of the BMAD workflow.

#### `create-story <story-key>`

**Purpose**: Create a story definition file from the epic specification

**When to use**: Story is in `backlog` status

**What it does**:
1. Invokes `bmad-help` for validation
2. Reads epic file to understand requirements
3. Creates `{story-key}.md` in `_bmad-output/implementation-artifacts/`
4. Updates status to `ready-for-dev`
5. Auto-commits changes

**Example**:
```bash
./bmad.sh create-story 2-7
```

**Default Model**: Claude Sonnet (fast, good at documentation)

---

#### `dev-story <story-key>`

**Purpose**: Implement the story in Godot

**When to use**: Story is in `ready-for-dev` or `in-progress` status

**What it does**:
1. Pre-flight check (git clean, story file exists)
2. Invokes `bmad-help` for validation
3. Reads story file
4. Implements in Godot project
5. Updates story file with implementation notes
6. Updates status to `review`
7. Auto-commits changes

**Example**:
```bash
./bmad.sh dev-story 2-7
# Or with specific model:
./bmad.sh dev-story 2-7 --cli claude --model claude-sonnet-4-6
```

**Default Model**: Claude Sonnet 4.6 (creative, great at implementation)

**⚠️ CRITICAL**: Test your game after this phase!

**AI-fail pause**: If the AI exits with a non-zero status, `bmad.sh` displays a prominent warning banner and prompts `y/n` before proceeding to code review — giving you the chance to investigate and fix issues rather than silently advancing.

---

#### `code-review <story-key>`

**Purpose**: Review code with fresh AI eyes and fix issues

**When to use**: Story is in `review` status and you've tested it

**What it does**:
1. Pre-flight check (git clean, story file exists)
2. Validates Godot artifacts (checks for .gd, .tscn references)
3. Invokes `bmad-help` for validation
4. Reviews all code changes
5. Checks for bugs, performance issues, edge cases
6. Fixes critical issues
7. Updates status to `done`
8. Auto-commits changes

**Example**:
```bash
./bmad.sh code-review 2-7
# Or with different model for fresh perspective:
./bmad.sh code-review 2-7 --cli copilot --model gpt-5.3-codex
```

**Default Model**: GPT 5.3 Codex (analytical, catches different issues than Claude)

---

### 🔄 Batch Commands

These automate multiple phases or stories.

#### `cycle <story-key>`

**Purpose**: Run complete workflow for one story (create → dev → review)

**When to use**: You want automation but still need test pauses

**What it does**:
1. Detects current story status
2. Runs remaining phases:
   - If `backlog` → runs all 3 phases
   - If `ready-for-dev` → runs dev + review
   - If `review` → runs review only
3. Pauses after dev-story for testing
4. Shows progress throughout

**Example**:
```bash
./bmad.sh cycle 2-7
```

**Flow**:
```
create-story 2-7
  ↓
[Pause - review story file]
  ↓
dev-story 2-7
  ↓
[Pause - TEST YOUR GAME]
  ↓
code-review 2-7
  ↓
DONE ✓
```

---

#### `epic <epic-number>`

**Purpose**: Process all remaining stories in an epic

**When to use**: You want to batch-process multiple stories

**What it does**:
1. Shows initial epic status
2. Gets all non-done stories
3. For each story:
   - Shows progress (Story X of Y)
   - Runs full cycle
   - Pauses for testing
4. Shows final epic status
5. Suggests running retrospective

**Example**:
```bash
./bmad.sh epic 2
```

**Output**:
```
╔═══════════════════════════════════════════════════════════╗
║          Processing Epic 2 - All Stories               ║
╚═══════════════════════════════════════════════════════════╝

Epic 2 Status Overview
...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Story 1/8: 2-7-three-resolution-types
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Runs full cycle for 2-7]

✓ Story 2-7 complete (1/8)

[Continues with 2-8, 2-9, etc.]
```

---

### 🛠️ Utility Commands

#### `status [epic-number]`

**Purpose**: View epic progress and story breakdown

**Example**:
```bash
./bmad.sh status 2
```

**Output**:
```
╔═══════════════════════════════════════════════════════════╗
║              Epic 2 Status Overview                     ║
╚═══════════════════════════════════════════════════════════╝

Epic Status: in-progress

✓ Done:        6 stories
⊙ Review:      0 stories
◉ In Progress: 0 stories
○ Ready:       0 stories
· Backlog:     8 stories
  Total:       14 stories

Progress:
[██████████████████████████░░░░░░░░░░░░░░] 43% (6/14)

Stories by Status:

  ✓ 2-1-player-movement (done)
  ✓ 2-2-strike-blade (done)
  ✓ 2-3-strike-spear-staff (done)
  ✓ 2-4-evade (done)
  ✓ 2-5-attune (done)
  ✓ 2-6-cleanse-restore (done)
  · 2-7-three-resolution-types (backlog)
  · 2-8-health-defeat-respawn (backlog)
  ...
```

---

#### `retro <epic-number>`

**Purpose**: Generate epic retrospective document

**When to use**: After completing an epic

**What it does**:
1. Reads all story files for the epic
2. Analyzes what worked, what didn't
3. Creates retrospective document
4. Updates status
5. Auto-commits

**Example**:
```bash
./bmad.sh retro 2
```

**Output**: `_bmad-output/implementation-artifacts/epic-2-retro-2026-05-13.md`

---

#### `preflight <story-key>`

**Purpose**: Validate story is ready for next phase

**Example**:
```bash
./bmad.sh preflight 2-7
```

**Checks**:
- ✓ Git working directory is clean
- ✓ Story file exists
- ✓ Story status is valid
- ✓ Godot artifacts are present (if applicable)

---

#### `help`

**Purpose**: Show command reference

```bash
./bmad.sh help
# Or just:
./bmad.sh
```

---

## Workflow Cycles

### Cycle 1: Single Story (Manual Control)

**Best for**: Learning the workflow, complex stories, debugging

```bash
# Phase 1: Create Story
./bmad.sh create-story 2-7
[Review story file, adjust if needed]

# Phase 2: Implement
./bmad.sh dev-story 2-7
[TEST YOUR GAME - critical!]

# Phase 3: Review
./bmad.sh code-review 2-7
[Final test, verify fixes]

# Result: Story 2-7 is DONE ✓
```

**Time**: ~5-15 min per phase (depending on story complexity)

**Pros**:
- Full control at each phase
- Can pause and edit story mid-workflow
- Easy to debug if something goes wrong

**Cons**:
- More typing
- Have to remember sequence

---

### Cycle 2: Single Story (Semi-Automated)

**Best for**: Most stories, good balance of automation and control

```bash
./bmad.sh cycle 2-7
```

**Flow**:
```
Start
  ↓
Auto: create-story
  ↓
Pause: "Review story file, press Enter..."
  ↓
Auto: dev-story
  ↓
Pause: "TEST YOUR GAME, press Enter..."
  ↓
Auto: code-review
  ↓
Done ✓
```

**Time**: ~10-30 min total (depending on story complexity)

**Pros**:
- Less typing
- Automatic status management
- Still get test pauses
- Can interrupt at any phase

**Cons**:
- Less flexibility to edit between phases

---

### Cycle 3: Entire Epic (Fully Automated)

**Best for**: Batch processing, overnight runs, similar stories

```bash
./bmad.sh epic 2
```

**Flow**:
```
Start
  ↓
Show Epic Status
  ↓
For each backlog story:
  ├─ Show progress (X/Y)
  ├─ Run create-story
  ├─ Pause for review
  ├─ Run dev-story
  ├─ Pause for testing
  └─ Run code-review
  ↓
Show Final Status
  ↓
Suggest: ./bmad.sh retro 2
```

**Time**: Several hours (depends on epic size and test time)

**Pros**:
- Processes entire epic
- Great for similar stories
- Shows progress throughout

**Cons**:
- Long process
- Less control over individual stories
- Should monitor for AI errors

---

### Cycle 4: Check Progress Anytime

```bash
./bmad.sh status 2
```

**Use this**:
- Before starting work ("What's left?")
- After epic completion ("Did we miss anything?")
- For team updates ("Where are we?")

---

## Multi-Model Strategy

### Why Use Different Models?

**The Problem**: Every AI has blind spots
- Claude might implement a feature but miss edge cases
- GPT might catch bugs Claude missed

**The Solution**: Use different models for different phases
- Claude for creative implementation
- GPT for analytical review

---

### Recommended Setup (Default in Script)

```bash
# Phase 1: Create Story
# Model: Claude Sonnet (fast)
# Why: Good at documentation, understands BMAD format

# Phase 2: Implementation  
# Model: Claude Sonnet 4.6 (creative)
# Why: Excellent at code generation, understands Godot

# Phase 3: Code Review
# Model: GPT 5.3 Codex (analytical)
# Why: Different perspective, catches different issues
```

### How to Customize

**Edit the script** (`bmad.sh` lines 17-25):

```bash
DEFAULT_CREATE_CLI="claude"
DEFAULT_CREATE_MODEL="sonnet"

DEFAULT_DEV_CLI="claude"
DEFAULT_DEV_MODEL="claude-sonnet-4-6"

DEFAULT_REVIEW_CLI="copilot"
DEFAULT_REVIEW_MODEL="gpt-5.3-codex"
```

**Or override per-command**:

```bash
# Use GPT for everything
./bmad.sh dev-story 2-7 --cli copilot --model gpt-5.3-codex

# Use high-reasoning Claude for complex story
./bmad.sh dev-story 2-7 --cli claude --model opus
```

---

### Available Models

**Claude** (via `--cli claude`):
- `sonnet` - Fast, balanced
- `claude-sonnet-4-6` - Latest Sonnet
- `opus` - Most capable (slower, expensive)

**Copilot** (via `--cli copilot`):
- `gpt-5.3-codex` - Code-specialized
- `gpt-5.2` - General GPT
- (Check `copilot --help` for full list)

---

## Progress Tracking

### Visual Progress Bar

```
Progress:
[████████████████████░░░░░░░░░░░░░░░░░░░░] 43% (6/14)
```

**Legend**:
- `█` = Completed stories
- `░` = Remaining stories
- `43%` = Completion percentage
- `(6/14)` = Done / Total

---

### Status Icons

```
✓ Done          - Story is complete
⊙ Review        - In code review
◉ In Progress   - Currently being implemented
○ Ready         - Story file created, ready for dev
· Backlog       - Not started yet
```

---

### Story Status Transitions

```
backlog
  ↓ (create-story)
ready-for-dev
  ↓ (dev-story)
in-progress
  ↓ (dev-story completes)
review
  ↓ (code-review)
done ✓
```

---

## Troubleshooting

### "Git working directory has uncommitted changes"

**Cause**: You have uncommitted work

**Fix**:
```bash
# Option 1: Commit your changes first
git add .
git commit -m "WIP: manual changes"

# Option 2: Stash changes
git stash

# Option 3: Skip validation (not recommended)
./bmad.sh dev-story 2-7 --skip-validation
```

---

### "Story file not found"

**Cause**: Story hasn't been created yet

**Fix**:
```bash
# Create the story first
./bmad.sh create-story 2-7

# Then run dev
./bmad.sh dev-story 2-7
```

---

### "AI stopped mid-implementation"

**Cause**: AI encountered an error or needed clarification

**Fix**:
1. Read the AI's last message
2. If it's asking for input, provide it manually
3. Re-run the command to continue
4. Or run with different model: `--cli copilot`

---

### "Code review found critical issues"

**Cause**: Implementation has bugs that need attention

**Fix**:
1. Read the review findings
2. Fix issues manually or with AI
3. Test thoroughly
4. Re-run code-review or mark done manually

---

### "Wrong story status"

**Cause**: Status got out of sync

**Fix**: Edit `_bmad-output/implementation-artifacts/sprint-status.yaml`

```yaml
2-7-three-resolution-types: ready-for-dev  # Change this
```

---

## Tips & Best Practices

### ✅ DO

- **Test after every dev-story phase** - Critical!
- **Review AI output before committing** - AI makes mistakes
- **Use `status` frequently** - Stay oriented
- **Use different models for review** - Catch more issues
- **Run retrospectives** - Learn and improve

### ❌ DON'T

- **Don't skip testing** - You'll regret it later
- **Don't run epic overnight unsupervised** - Monitor for AI errors
- **Don't edit files during AI execution** - Git conflicts
- **Don't trust AI blindly** - Always verify

---

## Quick Reference Card

```bash
# Check progress
./bmad.sh status 2

# Process one story manually
./bmad.sh create-story 2-7
./bmad.sh dev-story 2-7      # Test here!
./bmad.sh code-review 2-7

# Process one story automatically
./bmad.sh cycle 2-7

# Process entire epic
./bmad.sh epic 2

# Generate retrospective
./bmad.sh retro 2

# Pre-flight check
./bmad.sh preflight 2-7

# Help
./bmad.sh help
```

---

## Advanced Usage

### Custom Model per Phase

```bash
# Create with fast model
./bmad.sh create-story 2-7 --cli claude --model sonnet

# Implement with powerful model
./bmad.sh dev-story 2-7 --cli claude --model opus

# Review with different AI
./bmad.sh code-review 2-7 --cli copilot --model gpt-5.3-codex
```

### Skip Validation (Use Carefully)

```bash
./bmad.sh dev-story 2-7 --skip-validation
```

### Process Specific Stories Only

```bash
# Edit sprint-status.yaml, set unwanted stories to "done"
# Then run:
./bmad.sh epic 2  # Will skip "done" stories
```

---

## Getting Help

- **Script Help**: `./bmad.sh help`
- **BMad Help**: Invoke `bmad-help` skill in Claude/Copilot
- **This Guide**: `cat BMAD-WORKFLOWS.md`
- **BMad GDS Docs**: https://github.com/bmad-code-org/bmad-module-game-dev-studio

---

## Summary

**For Learning**: Use manual commands (`create-story`, `dev-story`, `code-review`)

**For Efficiency**: Use `cycle` for single stories

**For Batch**: Use `epic` for multiple stories

**For Monitoring**: Use `status` frequently

**Always**: Test your game after implementation!

---

*Happy game development! 🎮*
