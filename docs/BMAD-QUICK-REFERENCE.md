# BMAD Workflow - Quick Reference

## 📦 Adding to Another Project

**Quick Install**:
```bash
# 1. Copy files
cp bmad.sh bmad-config.sh /path/to/project/
cp BMAD-*.md /path/to/project/  # Optional docs

# 2. Configure
cd /path/to/project/
chmod +x bmad.sh
nano bmad-config.sh  # Edit for your project

# 3. Verify setup
./bmad.sh config

# 4. Start
./bmad.sh next
```

**Full Guide**: `cat BMAD-INSTALLATION.md`

**Supports**: Godot, Unity, Unreal, React, Expo, Django, Rails, and more!

---

## 📊 Visual Workflow Map

```
┌──────────────────────────────────────────────────────────────────┐
│                    BMAD GAME DEV WORKFLOW                        │
└──────────────────────────────────────────────────────────────────┘

Epic 2: Player and Combat Core (14 stories)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Check Status First:
┌─────────────────────────────────────┐
│  ./bmad.sh status 2                 │  ← Start here
└─────────────────────────────────────┘
         │
         ├─ Shows: 6/14 done (43%)
         ├─ Next: 2-7, 2-8, 2-9, etc.
         └─ Visualizes progress

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WORKFLOW OPTION 1: Manual Control (Recommended for Learning)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Story: 2-7-three-resolution-types

Step 1: Create Story
┌─────────────────────────────────────┐
│  ./bmad.sh create-story 2-7         │  Claude Sonnet
└─────────────────────────────────────┘
         │
         ├─ Creates: 2-7-three-resolution-types.md
         ├─ Status: backlog → ready-for-dev
         └─ Commits automatically
         
         ⏸️  [PAUSE] Review story file
         
Step 2: Implement
┌─────────────────────────────────────┐
│  ./bmad.sh dev-story 2-7            │  Claude Sonnet 4.6
└─────────────────────────────────────┘
         │
         ├─ Implements in Godot
         ├─ Updates story file
         ├─ Status: ready-for-dev → review
         └─ Commits automatically
         
         ⏸️  [PAUSE] TEST YOUR GAME! ← CRITICAL
         
Step 3: Code Review
┌─────────────────────────────────────┐
│  ./bmad.sh code-review 2-7          │  GPT 5.3 Codex
└─────────────────────────────────────┘
         │
         ├─ Reviews code
         ├─ Fixes issues
         ├─ Status: review → done ✓
         └─ Commits automatically

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WORKFLOW OPTION 2: Semi-Automated (Recommended for Most Stories)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌─────────────────────────────────────┐
│  ./bmad.sh cycle 2-7                │  All models
└─────────────────────────────────────┘
         │
         ├─ Auto: create-story
         ├─ Pause: Review story
         ├─ Auto: dev-story
         ├─ Pause: TEST GAME ← Still required!
         ├─ Auto: code-review
         └─ Done ✓

Time: ~10-30 min per story

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WORKFLOW OPTION 3: Batch Processing (For Multiple Stories)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌─────────────────────────────────────┐
│  ./bmad.sh epic 2                   │  Process all Epic 2
└─────────────────────────────────────┘
         │
         ├─ Shows initial status
         ├─ For each backlog story:
         │   ├─ Shows: Story 1/8
         │   ├─ Runs full cycle
         │   ├─ Pauses for testing
         │   └─ Shows: Story complete
         ├─ Shows final status
         └─ Suggests: ./bmad.sh retro 2

Time: Several hours (8 stories × 30 min = 4 hours)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

After Epic Completion:
┌─────────────────────────────────────┐
│  ./bmad.sh retro 2                  │  Generate retrospective
└─────────────────────────────────────┘
         │
         └─ Creates: epic-2-retro-2026-05-13.md
```

---

## 🎯 Command Cheat Sheet

| Command | Args | Purpose | Time |
|---------|------|---------|------|
| `next` | - | Show exactly what to do next | 1s |
| `config` | - | Show all settings + binary status | 1s |
| `status` | epic# | Show progress | 1s |
| `create-story` | story-key | Create story file | 2-5 min |
| `dev-story` | story-key | Implement story | 5-15 min |
| `code-review` | story-key | Review & fix | 3-10 min |
| `cycle` | story-key | Full story workflow | 10-30 min |
| `epic` | epic# | All stories in epic | Hours |
| `test-guide` | story-key | AI step-by-step test instructions | 1-3 min |
| `retro` | epic# | Generate retrospective | 5 min |
| `preflight` | story-key | Validate readiness | 5s |
| `usage` | - | Show today's AI usage | 1s |
| `version` | - | Show bmad-flow version | 1s |
| `help` | - | Show help | 1s |

---

## 🎨 Status Icons Legend

```
✓   Done          Story complete, merged to main
⊙   Review        In code review phase
◉   In Progress   Currently being implemented
○   Ready         Story file created, ready for dev
·   Backlog       Not started yet
```

---

## ⚙️ Config Vars Reference

Key variables in `bmad-config.sh`:

| Variable | Purpose | Example |
|----------|---------|---------|
| `BMAD_STATUS_FILE` | Path to sprint-status YAML | `_bmad-output/implementation-artifacts/sprint-status.yaml` |
| `BMAD_STORIES_DIR` | Directory containing story files | `_bmad-output/implementation-artifacts` |
| `BMAD_TECH_STACK` | Technology label | `"Godot"`, `"React"`, `"Django"` |
| `BMAD_FILE_EXTENSIONS` | Extensions to validate | `".gd .tscn .tres"` |
| `BMAD_DEV_CLI` | CLI for dev-story | `"claude"` |
| `BMAD_DEV_MODEL` | Model for dev-story | `"claude-sonnet-4-6"` |
| `BMAD_REVIEW_CLI` | CLI for code-review | `"copilot"` |
| `BMAD_REVIEW_MODEL` | Model for code-review | `"gpt-5.3-codex"` |
| `BMAD_APP_NOUN` | Noun in test-pause messages | `"game"`, `"app"`, `"service"` |
| `BMAD_GIT_COAUTHOR` | Co-authored-by trailer in auto-commits | `"Bot <bot@example.com>"` |
| `BMAD_TEST_CMD` | Command AI runs to execute tests | `"./run_tests.sh"`, `"npm test"`, `"pytest"` |
| `BMAD_TEST_FILE_PATTERN` | `grep -oE` pattern for test files in story docs | `"scenes/[a-z_]+_test\.tscn"` |
| `BMAD_TEST_RUN_INSTRUCTIONS` | Human-readable how-to-run shown at test pause | `"Press F6 in Godot..."` |
| `BMAD_TEST_PASS_INDICATOR` | What passing output looks like | `"All tests passed"` |
| `BMAD_TEST_FAIL_INDICATOR` | What failure output looks like | `"FAILED"` |

---

## 🔧 Model Strategy

```
Phase          Default CLI    Default Model       Why?
─────────────────────────────────────────────────────────────
create-story   claude         sonnet             Fast, good docs
dev-story      claude         claude-sonnet-4-6  Creative, Godot
code-review    copilot        gpt-5.3-codex      Fresh eyes, strict
```

**Override**:
```bash
./bmad.sh dev-story 2-7 --cli copilot --model gpt-5.3-codex
```

---

## ⚡ Common Workflows

### Daily Development
```bash
# Morning: See exactly what to do next
./bmad.sh next

# Or check full progress
./bmad.sh status 2

# Work on next story
./bmad.sh cycle 2-7

# End of day: Check progress
./bmad.sh status 2
```

### Sprint Planning
```bash
# See what's in the backlog
./bmad.sh status 2

# Process high-priority stories first
./bmad.sh cycle 2-7
./bmad.sh cycle 2-8
./bmad.sh cycle 2-9

# Check progress
./bmad.sh status 2
```

### Epic Completion
```bash
# Batch process remaining stories
./bmad.sh epic 2

# Generate retrospective
./bmad.sh retro 2

# Move to next epic
./bmad.sh status 3
```

---

## 🚨 Critical Testing Points

```
Story Lifecycle:
────────────────

backlog
  │
  ├─ create-story
  │
ready-for-dev
  │
  ├─ dev-story
  │
review  ← ⚠️ TEST YOUR GAME HERE! (Critical!)
  │
  ├─ code-review
  │
done ✓
```

**Why test before code-review?**
- AI implements features but might miss bugs
- Testing reveals issues for review phase to fix
- Saves time vs. testing after final commit

---

## 📊 Progress Tracking Examples

### Empty Epic (Start)
```
Progress:
[░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 0% (0/14)

Stories by Status:
  · 2-1-player-movement (backlog)
  · 2-2-strike-blade (backlog)
  · 2-3-strike-spear-staff (backlog)
  ...
```

### Mid-Epic (Current)
```
Progress:
[██████████████████████░░░░░░░░░░░░░░░░░░] 43% (6/14)

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

### Epic Complete
```
Progress:
[████████████████████████████████████████] 100% (14/14)

All stories complete! ✓

Generate retrospective:
  ./bmad.sh retro 2
```

---

## 🛠️ Troubleshooting Quick Fixes

| Problem | Quick Fix |
|---------|-----------|
| Not sure what's configured | `./bmad.sh config` |
| Git dirty | `git commit -am "WIP"` or `git stash` |
| Story file missing | `./bmad.sh create-story 2-7` |
| AI stopped | Re-run command or try different model |
| Wrong status | Edit `sprint-status.yaml` |
| Critical bugs found | Fix manually, re-run code-review |

---

## 📱 One-Liner Examples

```bash
# Quick status check
./bmad.sh next

# Or full status
./bmad.sh status 2

# Verify config and binary status
./bmad.sh config

# Process one story, full automation
./bmad.sh cycle 2-7

# Process entire epic
./bmad.sh epic 2

# Use specific model for complex story
./bmad.sh dev-story 2-10 --cli claude --model opus

# Pre-flight check before starting
./bmad.sh preflight 2-7

# Generate retrospective after epic
./bmad.sh retro 2
```

---

## 🎯 Decision Tree: Which Command?

```
Need to...
│
├─ See what to do next?
│  └─ ./bmad.sh next
│
├─ Check/debug config?
│  └─ ./bmad.sh config
│
├─ Check progress?
│  └─ ./bmad.sh status <epic#>
│
├─ Work on ONE story?
│  │
│  ├─ Want full control?
│  │  └─ Manual: create → dev → review
│  │
│  └─ Want automation?
│     └─ ./bmad.sh cycle <story-key>
│
├─ Work on MANY stories?
│  └─ ./bmad.sh epic <epic#>
│
├─ Need test instructions for a story?
│  ├─ Basic (zero tokens): test hints auto-shown at cycle pause
│  └─ Detailed (AI): ./bmad.sh test-guide <story-key>
│
├─ Validate before starting?
│  └─ ./bmad.sh preflight <story-key>
│
└─ Epic is done?
   └─ ./bmad.sh retro <epic#>
```

---

## 💡 Pro Tips

1. **Always run status first** - Know where you are
2. **Test after dev-story** - Catch issues early; ACs shown automatically at the cycle pause
3. **Use `test-guide` for complex stories** - AI generates device-level steps from your actual implementation
4. **Use different models for review** - Different AI = different bugs caught
5. **Run preflight when unsure** - Validates everything
6. **Generate retro after epic** - Learn and improve

---

## 📚 More Help

- **Detailed Guide**: `cat BMAD-WORKFLOWS.md`
- **Script Help**: `./bmad.sh help`
- **BMad Help**: Invoke `bmad-help` in Claude/Copilot

---

**Print this page** and keep it by your desk! 📄
