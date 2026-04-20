# Contributing to Ollama Home Assistant Add-on

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to [GitHub Issues](https://github.com/chillkiller/ollama-ha-addon/issues).

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

- **Description:** Clear and concise description of the problem
- **Steps to Reproduce:** Detailed steps to reproduce the behavior
- **Expected Behavior:** What you expected to happen
- **Actual Behavior:** What actually happened
- **Environment:**
  - Home Assistant version
  - Add-on version
  - Host OS (HAOS, Supervised, Container)
  - Architecture (aarch64, amd64)
- **Logs:** Relevant log excerpts (redact sensitive information)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- **Description:** Clear description of the enhancement
- **Motivation:** Why this enhancement would be useful
- **Alternatives:** Any alternative solutions or features you've considered
- **Additional Context:** Screenshots, mockups, or examples

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following the coding standards below
3. **Test thoroughly** on both architectures (aarch64, amd64) if possible
4. **Update documentation** if your changes affect user-facing behavior
5. **Commit messages** should be clear and descriptive
6. **Submit a pull request** with a clear description of changes

## Coding Standards

### Shell Scripts (run.sh)

- Use `#!/usr/bin/env bashio` shebang
- Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- Use `set -e` for error handling
- Quote all variables: `"${VARIABLE}"`
- Use `bashio::log.info` for informational messages
- Use `bashio::log.warning` for warnings
- Use `bashio::log.error` for errors

### Dockerfile

- Use multi-stage builds if size optimization is needed
- Combine RUN commands with `&&` to reduce layers
- Clean up apt caches: `rm -rf /var/lib/apt/lists/*`
- Use specific version tags for base images
- Document non-obvious commands with comments

### Configuration (config.yaml)

- Follow Home Assistant Add-on conventions
- Use descriptive option names
- Provide sensible defaults
- Include schema validation
- Document all options in README.md

### Documentation

- Use clear, concise English
- Include code examples with syntax highlighting
- Update version numbers in README.md when releasing
- Keep CHANGELOG.md updated (if present)

## Testing

### Local Testing

To test changes locally:

1. Build the add-on:
   ```bash
   docker build -t ollama-ha-addon:test .
   ```

2. Run the container:
   ```bash
   docker run -p 11434:11434 ollama-ha-addon:test
   ```

3. Test the API:
   ```bash
   curl http://localhost:11434/api/tags
   ```

### Home Assistant Testing

1. Add your fork as a local add-on repository in Home Assistant
2. Install and configure the add-on
3. Check logs for errors
4. Test all configured features

## Project Structure

```
ollama-ha-addon/
├── ollama_ha_addon/      # Add-on code
│   ├── Dockerfile        # Container build definition
│   └── run.sh            # Startup script
├── config.yaml           # Add-on configuration
├── build.json            # Build configuration
├── README.md             # User documentation
├── LICENSE               # MIT License
├── SECURITY.md           # Security policy
├── CONTRIBUTING.md       # This file
└── CODE_OF_CONDUCT.md    # Community guidelines
```

## Release Process

Releases are managed by the maintainer. When preparing a release:

1. Update version in `config.yaml`
2. Update version in `README.md`
3. Update CHANGELOG.md (if present)
4. Create a Git tag: `git tag -a v1.0.0 -m "Release v1.0.0"`
5. Push the tag: `git push origin v1.0.0`

## Questions?

Feel free to open a GitHub Issue for questions that don't fit into bug reports or enhancement suggestions.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.