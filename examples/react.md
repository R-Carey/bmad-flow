# BMAD Automation - React Configuration

Complete configuration for React web app projects.

## Configuration

Edit `bmad-config.sh`:

```bash
#!/bin/zsh

# Project paths
export BMAD_STATUS_FILE="_bmad-output/implementation-artifacts/sprint-status.yaml"
export BMAD_STORIES_DIR="_bmad-output/implementation-artifacts"

# Technology stack
export BMAD_TECH_STACK="React"

# File extensions
export BMAD_FILE_EXTENSIONS=".tsx .ts .jsx .js .css"

# CLI binaries
export BMAD_CLAUDE_BIN="claude"
export BMAD_COPILOT_BIN="copilot"

# Default models
export BMAD_CREATE_CLI="claude"
export BMAD_CREATE_MODEL="sonnet"

export BMAD_DEV_CLI="claude"
export BMAD_DEV_MODEL="claude-sonnet-4-6"

export BMAD_REVIEW_CLI="claude"
export BMAD_REVIEW_MODEL="claude-sonnet-4-6"

# Optional: Use GPT for review (different perspective)
# export BMAD_REVIEW_CLI="copilot"
# export BMAD_REVIEW_MODEL="gpt-5.3-codex"
```

## Testing Workflow

After `dev-story` completes:

```bash
# Start dev server
npm run dev
# or
yarn dev

# Open browser to localhost:3000 (or your port)
# Test the implemented feature
# Check browser console for errors
# Test responsive design
# Press Enter in terminal to continue to code-review
```

## Common React Files

The system validates these files:
- `.tsx/.ts` - TypeScript components
- `.jsx/.js` - JavaScript components
- `.css` - Stylesheets

## Example Workflow

```bash
# Check progress
./bmad.sh status 1

# Work on dashboard story
./bmad.sh cycle 1-5-user-dashboard

# What happens:
# 1. Creates story file with React requirements
# 2. Claude implements:
#    - Dashboard.tsx component
#    - Related subcomponents
#    - Styling (CSS/Tailwind)
#    - API integration
#    - State management (Redux/Zustand)
# 3. Pause - TEST in browser
#    npm run dev
#    Test UI, interactions, data fetching
# 4. Claude reviews React patterns, hooks, performance
# 5. Done ✓
```

## Tips

- Test in multiple browsers
- Check responsive design (mobile/tablet/desktop)
- Review React DevTools
- Check for console warnings
- Test loading/error states
- AI understands modern React (hooks, TypeScript, etc.)
