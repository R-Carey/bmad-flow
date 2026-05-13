# Getting Started with BMAD Flow

**Accelerate your BMAD workflow in 5 minutes.**

**5-minute guide to get up and running.**

---

## Prerequisites (2 minutes)

### Required
- ✅ **BMAD-METHOD project** with standard structure
- ✅ **Claude CLI** installed
  ```bash
  # Check if installed:
  which claude
  
  # If not installed:
  # Visit: https://docs.anthropic.com/claude/docs/cli
  ```

### Optional but Recommended
- ✅ **GitHub Copilot CLI** for multi-model support
  ```bash
  # Check if installed:
  which copilot
  ```

---

## Installation (2 minutes)

### Quick Install
```bash
# Download and run installer
curl -O https://raw.githubusercontent.com/R-Carey/bmad-flow/main/install.sh
chmod +x install.sh
./install.sh
```

The installer will:
1. Check prerequisites
2. Detect your project type
3. Auto-configure for your technology
4. Test the installation

### Manual Install
```bash
# 1. Clone repository
git clone https://github.com/R-Carey/bmad-flow.git
cd bmad-flow

# 2. Copy to your project
cp bmad.sh bmad-config.sh /path/to/your-project/

# 3. Configure
cd /path/to/your-project/
chmod +x bmad.sh
nano bmad-config.sh  # Edit paths and technology

# 4. Test
./bmad.sh help
```

---

## First Run (1 minute)

### 1. Check Help
```bash
./bmad.sh help
```

**Expected**: Colorful help menu with all commands

### 2. Check Status
```bash
./bmad.sh status 1  # Replace '1' with your epic number
```

**Expected**: Progress bar, story list, status icons

### 3. Validate a Story
```bash
./bmad.sh preflight 1-1  # Replace with actual story
```

**Expected**: Pre-flight checks pass

---

## Your First Story (10-30 minutes)

### Full Cycle
```bash
./bmad.sh cycle 1-1  # Replace with your story key
```

### What Happens

```
Step 1: Create Story
  ├─ Claude reads epic file
  ├─ Creates detailed story file
  └─ Commits to git
  ⏸️  Pause: Review story file

Step 2: Implement
  ├─ Claude reads story
  ├─ Implements in your technology
  └─ Commits to git
  ⏸️  Pause: TEST YOUR APP/GAME (Critical!)

Step 3: Code Review
  ├─ GPT reviews code (fresh perspective)
  ├─ Fixes issues found
  └─ Commits to git
  ✓ Story complete!
```

---

## What to Do at Each Pause

### After Create Story
1. Open `_bmad-output/implementation-artifacts/[story-key].md`
2. Review requirements, technical approach
3. Make any adjustments if needed
4. Press Enter to continue

### After Dev Story (CRITICAL!)
1. **Run your app/game**
   - Godot: Open editor, press F5
   - Expo: `npx expo start`
   - React: `npm run dev`
   - Unity: Open editor, press Play
2. **Test the feature thoroughly**
3. **Check for errors** in console/logs
4. **Verify it works as expected**
5. Press Enter to continue to code review

### After Code Review
1. Review fixes made
2. Optionally test again
3. Story is done!

---

## Daily Workflow

### Morning Routine
```bash
# Check where you are
./bmad.sh status 2

# See what's left:
# Progress: [████████░░░░░░░░] 50% (5/10)
```

### Work on Next Story
```bash
# Semi-automated (recommended)
./bmad.sh cycle 2-6

# Or manual (full control)
./bmad.sh create-story 2-6
# [review]
./bmad.sh dev-story 2-6
# [test]
./bmad.sh code-review 2-6
```

### Batch Processing
```bash
# Process entire epic
./bmad.sh epic 2

# Runs all backlog stories
# Pauses for testing after each
# Shows progress throughout
```

---

## Common Commands

```bash
# Check progress
./bmad.sh status <epic>

# Single story (manual)
./bmad.sh create-story <story>
./bmad.sh dev-story <story>
./bmad.sh code-review <story>

# Single story (automated)
./bmad.sh cycle <story>

# Entire epic
./bmad.sh epic <epic>

# Generate retrospective
./bmad.sh retro <epic>

# Validate before starting
./bmad.sh preflight <story>

# Show help
./bmad.sh help
```

---

## Customization

### Change AI Models

Edit `bmad-config.sh`:

```bash
# Use different models
export BMAD_DEV_MODEL="opus"           # More powerful
export BMAD_REVIEW_MODEL="sonnet"     # Faster review

# Use same model for both
export BMAD_DEV_CLI="claude"
export BMAD_REVIEW_CLI="claude"
```

### Override Per Command

```bash
# Use specific model for one story
./bmad.sh dev-story 2-7 --cli claude --model opus
./bmad.sh code-review 2-7 --cli copilot --model gpt-5.3-codex
```

---

## Troubleshooting

### "Git dirty" warning
```bash
git commit -am "WIP: save work"
# or:
git stash
```

### "Story file not found"
```bash
# Run create-story first
./bmad.sh create-story 2-7
```

### "AI stopped mid-task"
```bash
# Re-run the command
./bmad.sh dev-story 2-7

# Or try different model
./bmad.sh dev-story 2-7 --cli copilot
```

### Script won't run
```bash
# Make sure it's executable
chmod +x bmad.sh
```

---

## Next Steps

1. **Read the cheat sheet**
   ```bash
   cat docs/BMAD-QUICK-REFERENCE.md
   ```

2. **Process your first epic**
   ```bash
   ./bmad.sh epic 1
   ```

3. **Learn advanced features**
   ```bash
   cat docs/BMAD-WORKFLOWS.md
   ```

4. **Explore examples for your technology**
   ```bash
   cat examples/[your-tech].md
   ```

---

## Tips for Success

✅ **Always test after dev-story** - Critical for catching bugs early

✅ **Review AI output** - AI makes mistakes, verify the code

✅ **Use status frequently** - Stay oriented on progress

✅ **Try different models** - Different perspectives catch more bugs

✅ **Start with manual cycle** - Learn the flow before automating

✅ **Use epic command for batch work** - Process multiple stories efficiently

---

## Quick Reference

| Want to... | Command |
|------------|---------|
| See progress | `./bmad.sh status 2` |
| Work on story | `./bmad.sh cycle 2-7` |
| Batch process | `./bmad.sh epic 2` |
| Get help | `./bmad.sh help` |
| Validate first | `./bmad.sh preflight 2-7` |

---

## Documentation

- [README.md](README.md) - Project overview
- [QUICK-REFERENCE.md](docs/BMAD-QUICK-REFERENCE.md) - Command cheat sheet (print this!)
- [WORKFLOWS.md](docs/BMAD-WORKFLOWS.md) - Complete guide
- [examples/](examples/) - Technology-specific configs

---

## Support

- **Issues**: [GitHub Issues](https://github.com/R-Carey/bmad-flow/issues)
- **Questions**: [GitHub Discussions](https://github.com/R-Carey/bmad-flow/discussions)
- **Examples**: [examples/](examples/)

---

**You're ready!** Start with `./bmad.sh status 1` and dive in. 🚀
