# BMAD Automation - Technology Examples

Complete configuration examples for different project types.

## Available Examples

### Game Development
- [godot.md](godot.md) - Godot game engine (GDScript)
- [unity.md](unity.md) - Unity game engine (C#)
- [unreal.md](unreal.md) - Unreal Engine (C++/Blueprints)

### Web Development
- [react.md](react.md) - React web applications
- [vue.md](vue.md) - Vue.js applications
- [django.md](django.md) - Django web framework

### Mobile Development
- [expo.md](expo.md) - Expo/React Native mobile apps
- [flutter.md](flutter.md) - Flutter mobile apps

## Using These Examples

Each example includes:
1. **Complete `bmad-config.sh` configuration**
2. **Testing workflow** for that technology
3. **Common files** the system validates
4. **Example workflow** from start to finish
5. **Technology-specific tips**

## How to Use

1. Find your technology's example file
2. Copy the configuration to your `bmad-config.sh`
3. Adjust paths if needed
4. Test with `./bmad.sh status 1`

## Not Listed?

If your technology isn't listed, use the closest example as a template:
- **Backend frameworks** → django.md
- **Frontend frameworks** → react.md
- **Mobile apps** → expo.md or flutter.md
- **Game engines** → godot.md or unity.md

Then customize:
- `BMAD_TECH_STACK` → Your technology name
- `BMAD_FILE_EXTENSIONS` → Your file types

## Contributing

Have a configuration for a new technology? Please contribute!

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.
