# Contributing to BMAD Flow

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Your environment (OS, shell, Claude/Copilot versions)
- Relevant logs or error messages

### Suggesting Enhancements

We welcome suggestions! Please open an issue with:
- Clear description of the enhancement
- Use case / motivation
- Example of how it would work
- Any implementation ideas

### Contributing Code

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow existing code style
   - Add comments for complex logic
   - Test your changes

4. **Commit your changes**
   ```bash
   git commit -m "feat: add your feature description"
   ```
   Use conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, etc.

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Open a Pull Request**
   - Describe your changes
   - Reference any related issues
   - Include testing steps

### Adding Technology Examples

We'd love more technology examples! To add one:

1. Create `examples/your-tech.md` with:
   - Complete `bmad-config.sh` configuration
   - Testing workflow
   - Common files
   - Example workflow
   - Tips

2. Update `examples/README.md` to list your example

3. Submit a PR

### Improving Documentation

Documentation improvements are always welcome:
- Fix typos or unclear wording
- Add missing information
- Improve examples
- Add screenshots or diagrams

## Development Guidelines

### Code Style

- **Shell scripts**: Follow existing style
  - Use `set -e` for error handling
  - Add comments for complex sections
  - Use meaningful variable names
  - Quote variables: `"$VAR"`

- **Documentation**: 
  - Use clear, concise language
  - Include code examples
  - Use proper markdown formatting
  - Add appropriate emoji for readability

### Testing

Before submitting a PR:

1. **Test the script**
   ```bash
   ./bmad.sh help
   ./bmad.sh status 1
   ```

2. **Test installation**
   ```bash
   ./install.sh
   ```

3. **Test with your technology** (if applicable)

4. **Check for errors**
   ```bash
   shellcheck bmad.sh
   ```

### Commit Messages

Use conventional commits format:

```
<type>: <description>

[optional body]

[optional footer]
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples**:
```
feat: add Flutter configuration example
fix: correct status file path in Unity config
docs: improve installation instructions
```

## Areas We Need Help With

### High Priority
- [ ] Additional technology templates (Vue, Angular, Swift, etc.)
- [ ] Windows support and testing
- [ ] Better error messages and recovery
- [ ] Automated tests

### Medium Priority
- [ ] Performance improvements
- [ ] Better progress indicators
- [ ] Customizable prompt templates
- [ ] Integration with CI/CD

### Documentation
- [ ] Video tutorials
- [ ] More examples
- [ ] Troubleshooting guide expansion
- [ ] Screenshots and GIFs

## Questions?

- Open a discussion: https://github.com/R-Carey/bmad-flow/discussions
- Or ask in an issue

## Code of Conduct

Be respectful and constructive. We're all here to improve the project together.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing! 🎉
