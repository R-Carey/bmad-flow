# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
