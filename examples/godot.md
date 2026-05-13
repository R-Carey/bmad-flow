# BMAD Automation - Godot Configuration

Complete configuration for Godot game projects.

## Configuration

Edit `bmad-config.sh`:

```bash
#!/bin/zsh

# Project paths
export BMAD_STATUS_FILE="_bmad-output/implementation-artifacts/sprint-status.yaml"
export BMAD_STORIES_DIR="_bmad-output/implementation-artifacts"

# Technology stack
export BMAD_TECH_STACK="Godot"

# File extensions
export BMAD_FILE_EXTENSIONS=".gd .tscn .tres"

# CLI binaries
export BMAD_CLAUDE_BIN="claude"
export BMAD_COPILOT_BIN="copilot"

# Default models
export BMAD_CREATE_CLI="claude"
export BMAD_CREATE_MODEL="sonnet"

export BMAD_DEV_CLI="claude"
export BMAD_DEV_MODEL="claude-sonnet-4-6"

export BMAD_REVIEW_CLI="copilot"
export BMAD_REVIEW_MODEL="gpt-5.3-codex"
```

## Testing Workflow

After `dev-story` completes:

```bash
# 1. Open Godot Editor
# 2. Run your game (F5)
# 3. Test the implemented feature
# 4. Press Enter in terminal to continue to code-review
```

## Common Godot Files

The system validates these files are referenced in stories:
- `.gd` - GDScript source files
- `.tscn` - Scene files
- `.tres` - Resource files

## Example Workflow

```bash
# Check progress
./bmad.sh status 1

# Work on player movement story
./bmad.sh cycle 1-1-player-movement

# What happens:
# 1. Creates story file with GDScript and scene requirements
# 2. Claude implements:
#    - player.gd script
#    - Player.tscn scene
#    - Input actions
# 3. Pause - TEST in Godot
# 4. GPT reviews GDScript code, scene structure
# 5. Done ✓
```

## Tips

- Use meaningful scene and script names
- Test each feature thoroughly in Godot
- AI understands Godot 4 syntax and best practices
- Check console for errors during testing
