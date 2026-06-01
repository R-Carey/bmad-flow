# BMAD Automation - Expo/React Native Configuration

Complete configuration for Expo mobile app projects.

## Configuration

Edit `bmad-config.sh`:

```bash
#!/bin/zsh

# Project paths
export BMAD_STATUS_FILE="_bmad-output/implementation-artifacts/sprint-status.yaml"
export BMAD_STORIES_DIR="_bmad-output/implementation-artifacts"

# Technology stack
export BMAD_TECH_STACK="Expo React Native"

# File extensions
export BMAD_FILE_EXTENSIONS=".tsx .ts .jsx .js .json"

# CLI binaries
export BMAD_CLAUDE_BIN="claude"
export BMAD_COPILOT_BIN="copilot"

# Default models
export BMAD_CREATE_CLI="claude"
export BMAD_CREATE_MODEL="sonnet"

export BMAD_DEV_CLI="claude"
export BMAD_DEV_MODEL="claude-sonnet-4-6"  # Great for React/TypeScript

export BMAD_REVIEW_CLI="claude"
export BMAD_REVIEW_MODEL="claude-sonnet-4-6"

# Optional: Use GPT for review (catches different issues)
# export BMAD_REVIEW_CLI="copilot"
# export BMAD_REVIEW_MODEL="gpt-5.3-codex"
```

## Testing Workflow

After `dev-story` completes:

```bash
# Start Expo dev server
npx expo start

# Test on:
# - iOS Simulator (press 'i')
# - Android Emulator (press 'a')
# - Physical device (scan QR code)
# - Web (press 'w' if enabled)

# Test the feature thoroughly
# Press Enter in terminal to continue to code-review
```

## Common Expo Files

The system validates these files:
- `.tsx/.ts` - TypeScript React components
- `.jsx/.js` - JavaScript React components
- `.json` - Configuration (app.json, eas.json, etc.)

## Example Workflow

```bash
# Check progress
./bmad.sh status 1

# Work on authentication story
./bmad.sh cycle 1-3-user-authentication

# What happens:
# 1. Creates story file with React Native requirements
# 2. Claude implements:
#    - Authentication screens (Login.tsx, Register.tsx)
#    - Navigation setup
#    - API integration
#    - State management
# 3. Pause - TEST on device
#    npx expo start
#    Test login/logout/register flows
# 4. Claude reviews React Native patterns, mobile UX
# 5. Done ✓
```

## Tips

- Test on both iOS and Android if possible
- Check different screen sizes
- Test offline behavior
- AI understands Expo SDK and React Native best practices
- Review console for warnings/errors
- Test gesture interactions
