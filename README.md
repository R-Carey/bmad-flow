# BMAD Flow

**Accelerate your BMAD-METHOD development workflow with AI-powered automation.**

Drop-in automation system for any BMAD project - works with Godot, Unity, React, Expo, Django, and more!

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Zsh%2FBash-green.svg)](https://www.gnu.org/software/bash/)

---

## ⚡ Quick Start

```bash
# 1. Download
curl -O https://raw.githubusercontent.com/R-Carey/bmad-flow/main/install.sh
chmod +x install.sh

# 2. Install (auto-detects your project type)
./install.sh

# 3. Verify setup
./bmad.sh config

# 4. Use it!
./bmad.sh next
./bmad.sh cycle 1-1
```

**Time to productivity**: 5 minutes

---

## 🎯 What It Does

Automates the tedious parts of BMAD development:

- ✅ **Visual Progress Tracking** - See epic status with progress bars
- ✅ **Automated Workflows** - Run full story cycles with one command
- ✅ **Multi-Model Support** - Use different AI models per phase (optional, catches more bugs!)
- ✅ **Smart Validation** - Pre-flight checks and artifact verification before executing
- ✅ **Active Config Display** - `./bmad.sh config` shows all settings + binary status at a glance
- ✅ **Auto-Commits** - Git commits after each phase
- ✅ **Batch Processing** - Process entire epics at once
- ✅ **Rate Limit Recovery** - Detects limits and suggests switching CLI automatically

**Result**: ~60% time savings on workflow overhead + higher code quality

---

## 🚀 Features

### Individual Phase Commands
```bash
./bmad.sh create-story 2-7    # Create story from epic
./bmad.sh dev-story 2-7        # Implement the story
./bmad.sh code-review 2-7      # Review and fix code
```

### Automated Workflows
```bash
./bmad.sh cycle 2-7            # Full workflow with test pauses
./bmad.sh epic 2               # Process all stories in epic
```

### Progress Tracking
```bash
./bmad.sh status 2             # Visual progress with bars
```

**Output**:
```
╔═══════════════════════════════════════════════════════════╗
║              Epic 2 Status Overview                     ║
╚═══════════════════════════════════════════════════════════╝

✓ Done:        6 stories
· Backlog:     8 stories

Progress:
[█████████████████░░░░░░░░░░░░░░░░░░░░░░░] 42% (6/14)

Stories by Status:
  ✓ 2-1-player-movement (done)
  · 2-7-three-resolution-types (backlog)
```

### Utilities
```bash
./bmad.sh next                 # Show exactly what to do next (recommended!)
./bmad.sh config               # Show all active settings + binary status
./bmad.sh status 2             # Visual progress with progress bars
./bmad.sh usage                # Show today's AI token/request usage
./bmad.sh retro 2              # Generate retrospective
./bmad.sh preflight 2-7        # Validate before starting
./bmad.sh version              # Show bmad-flow version
./bmad.sh help                 # Show all commands
```

---

## 📦 Installation

### Prerequisites

- **BMAD-METHOD project** with standard structure
- **Claude CLI** installed ([Install guide](https://docs.anthropic.com/claude/docs/cli))
- **Git** for auto-commits
- **Optional**: Copilot CLI for multi-model support

### Method 1: Automated Install (Recommended)

```bash
curl -O https://raw.githubusercontent.com/R-Carey/bmad-flow/main/install.sh
chmod +x install.sh
./install.sh

# Verify setup immediately after:
./bmad.sh config
```

### Method 2: Manual Install

```bash
# 1. Download files
git clone https://github.com/R-Carey/bmad-flow.git
cd bmad-flow

# 2. Copy to your project
cp bmad.sh bmad-config.sh /path/to/your-project/
cp docs/*.md /path/to/your-project/  # Optional

# 3. Configure
cd /path/to/your-project/
chmod +x bmad.sh
nano bmad-config.sh  # Edit for your project

# 4. Test
./bmad.sh help
./bmad.sh status 1
```

---

## ⚙️ Configuration

Edit `bmad-config.sh` to match your project:

```bash
# File paths (adjust to your structure)
export BMAD_STATUS_FILE="_bmad-output/implementation-artifacts/sprint-status.yaml"
export BMAD_STORIES_DIR="_bmad-output/implementation-artifacts"

# AI models (defaults use Claude for all phases)
export BMAD_DEV_CLI="claude"
export BMAD_DEV_MODEL="claude-sonnet-4-6"
export BMAD_REVIEW_CLI="claude"
export BMAD_REVIEW_MODEL="claude-sonnet-4-6"

# Optional: Use different models per phase for diverse perspectives
# export BMAD_REVIEW_CLI="copilot"
# export BMAD_REVIEW_MODEL="gpt-5.3-codex"

# General
export BMAD_APP_NOUN="app"            # Noun used in test-pause messages: "game", "app", "service"
export BMAD_GIT_COAUTHOR=""           # If set, added as Co-authored-by trailer in auto-commits

# Test runner integration (used by dev-story to give the AI test hints)
export BMAD_TEST_CMD=""               # Command the AI runs to execute tests, e.g. "./run_tests.sh"
export BMAD_TEST_FILE_PATTERN=""      # grep -oE pattern to extract test file paths from story docs
export BMAD_TEST_RUN_INSTRUCTIONS=""  # Human-readable instructions shown at the test pause
export BMAD_TEST_PASS_INDICATOR=""    # What passing output looks like, e.g. "All tests passed"
export BMAD_TEST_FAIL_INDICATOR=""    # What failure output looks like, e.g. "FAILED"
```

> **`--skip-validation` flag**: Pass `--skip-validation` to any command to bypass the git-clean pre-flight check. This flag is fully functional (previously was silently ignored).

See [examples/](examples/) for configurations for specific technologies.

---

## 🎮 Supported Technologies

### Game Development
- **Godot** - GDScript, scenes, resources
- **Unity** - C#, prefabs, scenes
- **Unreal** - C++, Blueprints, assets

### Web Development
- **React** - TypeScript, JSX, components
- **Vue** - SFC, TypeScript, Composition API
- **Angular** - TypeScript, components, modules
- **Django** - Python, templates, models
- **Rails** - Ruby, ERB, Active Record
- **Node.js** - JavaScript, TypeScript, Express

### Mobile Development
- **Expo/React Native** - TypeScript, components, navigation
- **Flutter** - Dart, widgets
- **Swift** - iOS native development

### Backend Development
- **Python** - Django, Flask, FastAPI
- **Ruby** - Rails, Sinatra
- **Go** - Standard library, frameworks
- **Node.js** - Express, NestJS

**And more!** Works with any BMAD-METHOD project.

---

## 📚 Documentation

| Document | Purpose | Read When |
|----------|---------|-----------|
| [README.md](README.md) | This file | Starting out |
| [BMAD-QUICK-REFERENCE.md](docs/BMAD-QUICK-REFERENCE.md) | Command cheat sheet | Daily use |
| [BMAD-INSTALLATION.md](docs/BMAD-INSTALLATION.md) | Complete setup guide | Setting up |
| [BMAD-WORKFLOWS.md](docs/BMAD-WORKFLOWS.md) | Detailed guide | Learning deeply |
| [examples/](examples/) | Tech-specific configs | Your technology |

---

## 🎯 Usage Examples

### Daily Development Workflow

```bash
# Morning: Check what to do next
./bmad.sh next

# Or see full epic progress
./bmad.sh status 2

# Work on next story
./bmad.sh cycle 2-7
# Creates story → Implements → Reviews → Commits
# Pauses for you to test between phases

# Check progress
./bmad.sh status 2
```

### Batch Processing

```bash
# Process entire epic at once
./bmad.sh epic 2

# Processes all backlog stories
# Pauses for testing after each implementation
# Shows progress: "Story 3/8 complete"
```

### Multi-Model Strategy (Optional)

```bash
# Use defaults (Claude for all phases)
./bmad.sh cycle 2-7

# Override for specific story - use different model for fresh perspective
./bmad.sh dev-story 2-7 --cli claude --model opus
./bmad.sh code-review 2-7 --cli copilot --model gpt-5.3-codex
```

**Tip**: Using different models for dev vs review can catch more bugs (different AI = different blind spots).

---

## 🔄 Workflow Cycles

### Cycle 1: Manual Control (Full Control)
```bash
./bmad.sh create-story 2-7    # Create
# [Review story file]
./bmad.sh dev-story 2-7        # Implement
# [TEST YOUR APP/GAME]
./bmad.sh code-review 2-7      # Review
# [Done ✓]
```

### Cycle 2: Semi-Automated (Balanced)
```bash
./bmad.sh cycle 2-7
# Runs all phases with test pauses
# Best for most stories
```

### Cycle 3: Batch Processing (Efficient)
```bash
./bmad.sh epic 2
# Processes all stories in epic
# Great for similar stories
```

---

## 📊 Status Visualization

### Progress Bars
```
[█████████████████░░░░░░░░░░░░░░░░░░░░░░░] 42% (6/14)
```

### Status Icons
```
✓ Done          Story complete
⊙ Review        In code review
◉ In Progress   Being implemented
○ Ready         File created, ready for dev
· Backlog       Not started
```

### Story Lifecycle
```
· backlog
  ↓ create-story
○ ready-for-dev
  ↓ dev-story
◉ in-progress
  ↓ completes
⊙ review  ← TEST HERE!
  ↓ code-review
✓ done
```

---

## 🤖 Multi-Model Strategy (Optional)

### Default: Claude for All Phases

By default, BMAD uses Claude for all phases. This works well and keeps things simple.

```bash
# In bmad-config.sh (default)
export BMAD_DEV_CLI="claude"
export BMAD_DEV_MODEL="claude-sonnet-4-6"

export BMAD_REVIEW_CLI="claude"
export BMAD_REVIEW_MODEL="claude-sonnet-4-6"
```

### Why Use Different Models?

Every AI has blind spots. Using different models for different phases can catch more issues:

- **Claude** (Dev) - Creative, great at implementation
- **GPT** (Review) - Analytical, catches different bugs

**Result**: Higher quality code with diverse AI perspectives

### Multi-Model Configuration (Optional)

```bash
# In bmad-config.sh - use GPT for review
export BMAD_DEV_CLI="claude"
export BMAD_DEV_MODEL="claude-sonnet-4-6"

export BMAD_REVIEW_CLI="copilot"          # Different AI for review
export BMAD_REVIEW_MODEL="gpt-5.3-codex"
```

### Override Per Command

```bash
# Use different model for complex story
./bmad.sh dev-story 2-10 --cli claude --model opus

# Use GPT for review on specific story
./bmad.sh code-review 2-7 --cli copilot --model gpt-5.3-codex
```

---

## 🛠️ Commands Reference

### Core Commands

| Command | Args | Description |
|---------|------|-------------|
| `status` | epic# | Show progress and story breakdown |
| `next` | - | Show exactly what to do next |
| `config` | - | Show all active settings and binary status |
| `create-story` | story-key | Create story file from epic |
| `dev-story` | story-key | Implement the story |
| `code-review` | story-key | Review and fix code |
| `cycle` | story-key | Full workflow with pauses |
| `epic` | epic# | Process all stories in epic |
| `usage` | - | Show today's AI token/request usage |
| `retro` | epic# | Generate retrospective |
| `preflight` | story-key | Validate readiness |
| `version` | - | Show bmad-flow version |
| `help` | - | Show help menu |

### Options

```bash
--cli <claude|copilot>     # Choose AI provider
--model <model-name>       # Choose specific model
--skip-validation          # Skip pre-flight checks
```

---

## 📖 Examples by Technology

See [examples/](examples/) for complete configurations:

- [examples/godot.md](examples/godot.md) - Godot game development
- [examples/unity.md](examples/unity.md) - Unity game development
- [examples/react.md](examples/react.md) - React web apps
- [examples/expo.md](examples/expo.md) - Expo/React Native mobile
- [examples/django.md](examples/django.md) - Django web apps
- [examples/flutter.md](examples/flutter.md) - Flutter mobile apps

Each includes:
- Complete configuration
- Technology-specific setup
- Testing workflow
- Common issues

---

## ⚠️ Important Notes

### Always Test After Implementation

```
Story Lifecycle:
────────────────
dev-story completes
  ↓
⚠️ TEST YOUR APP/GAME HERE ⚠️
  ↓
code-review (fixes bugs you found)
  ↓
done ✓
```

The automation **pauses** for testing. This is intentional and critical!

### Git Must Be Clean

Before running commands:
```bash
git status
# If dirty, commit or stash:
git commit -am "WIP"
# or:
git stash
```

### Monitor AI Output

- AI can make mistakes
- Review generated code
- Test thoroughly
- Don't trust blindly

---

## 🎓 Learning Path

### Day 1: Installation & Basics (30 min)
1. Install with `install.sh`
2. Read [QUICK-REFERENCE.md](docs/QUICK-REFERENCE.md)
3. Try: `./bmad.sh status 1`
4. Try: `./bmad.sh cycle 1-1`

### Week 1: Process Your Epic (ongoing)
1. Run: `./bmad.sh epic 1`
2. Monitor progress with `status`
3. Complete epic

### Week 2+: Mastery
1. Read [WORKFLOWS.md](docs/WORKFLOWS.md)
2. Customize models
3. Optimize workflow
4. Apply to more projects

---

## 🤝 Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Areas we'd love help with:
- Additional technology templates
- Improved validation logic
- Bug reports and fixes
- Documentation improvements
- Test coverage

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

- Built for [BMAD-METHOD](https://bmadcode.com) projects
- Inspired by developer productivity needs
- Powered by Claude and GitHub Copilot

---

## 💬 Support

- **Issues**: [GitHub Issues](https://github.com/R-Carey/bmad-flow/issues)
- **Discussions**: [GitHub Discussions](https://github.com/R-Carey/bmad-flow/discussions)
- **Documentation**: [docs/](docs/)

---

## 🚀 Quick Links

- [Installation Guide](docs/BMAD-INSTALLATION.md)
- [Quick Reference](docs/BMAD-QUICK-REFERENCE.md)
- [Complete Guide](docs/BMAD-WORKFLOWS.md)
- [Examples](examples/)
- [Contributing](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)

---

## 🌊 Go with the Flow

**Ready to accelerate your BMAD workflow?**

```bash
curl -O https://raw.githubusercontent.com/R-Carey/bmad-flow/main/install.sh
chmod +x install.sh && ./install.sh
```

---

*Built with ❤️ for the BMAD community | Let your development flow* 🌊
