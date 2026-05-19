# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.6.0] - 2026-05-18

### Added
- **`test-guide` command**: AI-generated step-by-step manual test instructions for any story
  - Reads the story file and implementation to produce device-specific, numbered test steps
  - Uses exact UI element names and button labels from the actual code
  - Flags steps that are hard to trigger (permission denial, network errors, etc.)
  - Token-efficient: pre-extracts ACs with shell tools before calling AI; uses fast Sonnet model
  - Works across all project types (React Native, Next.js, Godot, Django, Flutter, etc.)
- **Enhanced test pause (`show_story_test_hints`)**: Zero-token AC checklist shown automatically during `cycle` test pause
  - Parses Acceptance Criteria directly from the story file using shell tools (no AI call)
  - Displays tech stack context from `BMAD_TECH_STACK`
  - Strips markdown formatting for clean terminal display
  - Shows `MANUAL:` notes from the story file
  - Hints user to run `test-guide` when they need more detail

### Fixed
- **Epic auto-completion**: Epics now automatically transition to `done` when all stories are complete
  - `code-review` triggers the check after marking the last story done
  - `retro` triggers the check after the retrospective completes
- **`next` command advancement**: Properly scans past fully completed epics instead of repeatedly suggesting `retro` for already-retroed epics
- **`get_status()` multi-match bug**: Added `head -1` to prevent `epic-1` matching both `epic-1:` and `epic-1-retrospective:` lines, which caused status comparisons to silently fail
- **Unity false-positive detection**: `install.sh` now requires all three of `Assets/`, `Library/`, and `Packages/` directories to detect Unity, preventing false positives on projects with a generic `assets/` folder (common in React Native/Expo)

## [1.4.0] - 2026-05-14

### Added
- **Token usage tracking**: Shows token stats after each AI call (parsed from CLI output)
- **Session usage command**: `./bmad.sh usage` shows cumulative daily usage history
- **Usage tips**: Provides efficiency guidance after showing session stats
- **Copilot rate limit detection**: Mirrors Claude rate limit handling with switch suggestions

### Optimized
- **Prompts reduced 60-70%**: All prompts rewritten for token efficiency
  - `create-story`: 65 tokens → 28 tokens
  - `dev-story`: 130 tokens → 42 tokens (removed bmad-help skill invocation that caused 30+ min hangs)
  - `code-review`: 115 tokens → 38 tokens
  - `retro`: 120 tokens → 45 tokens
- **Important message detection**: Tighter regex, reduced false positives
- **validate_godot_artifacts**: Fixed file glob bug, removed expensive `find` command

### Fixed
- `validate_godot_artifacts` now uses glob to find story files (matches `validate_story_file`)
- `show_important_messages` now triggers on `MANUAL:` keyword (matches prompt instructions)
- Unknown command error now points to `help` command

## [1.3.0] - 2026-05-14

### BREAKING: Philosophy Change - Model-Centric Configuration
- **NEW APPROACH**: Choose best MODEL for each task, not CLI provider
- Config now recommends models with explanations of their strengths
- Examples: "use opus for complex" not "use Claude"
- Each CLI (Claude/Copilot) supports multiple models

### Fixed
- **Copilot CLI syntax**: Use `-p "prompt"` instead of `echo | --prompt -`
- **Copilot now works!**: Was completely broken, now functional
- Added `--allow-all-tools` for Copilot automation
- Context7 used to verify correct Copilot CLI usage

### Added
- Model-centric help text with use-case examples
- Model reference guide in bmad-config.sh
- Alternative model suggestions for each phase
- Clear explanations of when to use which model

### Documentation
- Help shows "for complex use opus" not "use Claude"
- Config explains model strengths (creative vs analytical)
- Recommends using different models for dev vs review
- Tip: Both providers have separate rate limits

## [1.2.0] - 2026-05-14

### Added
- Rate limit detection with clear error messages
- Alternative model suggestions when rate limits hit
- Shows reset time from API response
- "SWITCHING MODELS" section in help with concrete examples
- Shows exact command to run with Copilot when Claude hits limits

### Improved
- Rate limit message now shows EXACT command ready to copy/paste
- Clear "EASY FIX" messaging in green
- Explains separate rate limits between providers
- Help command shows how to switch models proactively

### Changed
- **MAJOR**: Simplified create-story prompt for 10x speed improvement
  - Removed bmad-help skill invocation (was causing 30+ min delays)
  - Now completes in 1-3 minutes instead of 30+
  - Direct, actionable language without numbered lists
- Capture AI output to temp file for error detection

### Fixed
- create-story taking 30+ minutes due to complex prompts
- Rate limit errors not being detected or explained

## [1.1.1] - 2026-05-13

### Added
- Periodic status updates every 60 seconds during AI operations
- Warning message at 20 minutes if process might be stuck
- Better visibility to distinguish working vs hung processes

### Changed
- Improved code-review prompt for Copilot CLI compatibility
- More actionable, direct language for GPT models

## [1.1.0] - 2026-05-13

### Added
- Progress spinner with elapsed time for AI commands
- Warning message about command duration (1-15 minutes)
- Non-interactive mode support for automation/CI/CD

### Fixed
- Config loading: properly sources `bmad-config.sh` for project-specific settings
- Story key pattern matching: handles full story names (e.g., `2-7` matches `2-7-three-resolution-types`)
- `get_status()` now uses prefix matching with glob patterns
- `update_status()` preserves full story names when updating status
- `validate_story_file()` finds files by prefix pattern instead of exact match
- Git checks now detect terminal interactivity and auto-continue in non-interactive mode
- Cycle command properly checks actual status after each phase instead of assuming success
- Nested git checks skipped in sub-commands (uses `--skip-validation` flag)
- Claude CLI permission handling with `--dangerously-skip-permissions` for automation

### Changed
- `cycle` command now validates each phase completion before proceeding
- AI commands run in background with progress indicator
- Git warnings auto-continue in non-interactive environments

## [1.0.0] - 2026-05-13

### Added
- Initial release of BMAD Flow
- Core workflow commands (create-story, dev-story, code-review)
- Automated workflows (cycle, epic)
- Visual progress tracking (status command)
- Multi-model support (Claude + GPT)
- Pre-flight validation
- Auto-commit functionality
- Batch epic processing
- Technology-agnostic configuration system
- Comprehensive documentation (8 guides)
- Installation script with auto-detection
- Examples for 10+ technologies:
  - Game Dev: Godot, Unity, Unreal
  - Web: React, Vue, Django
  - Mobile: Expo/React Native, Flutter
  - Backend: Node.js, Python, Ruby

### Features
- `status` - Visual epic progress with bars and icons
- `cycle` - Full story workflow with test pauses
- `epic` - Batch process all stories in epic
- `retro` - Generate epic retrospectives
- `preflight` - Validate story readiness
- `help` - Command reference

### Documentation
- README.md - Project overview and quick start
- INSTALLATION.md - Complete setup guide
- QUICK-REFERENCE.md - Visual command cheat sheet
- WORKFLOWS.md - Detailed workflow guide
- 10+ technology examples with complete configurations

### Configuration
- bmad-config.sh - Template configuration file
- Auto-detection of project type
- Support for custom file paths
- Configurable AI models per phase

---

## Future Releases

See [GitHub Issues](https://github.com/yourusername/bmad-flow/issues) for planned features.

---

[1.0.0]: https://github.com/yourusername/bmad-flow/releases/tag/v1.0.0
