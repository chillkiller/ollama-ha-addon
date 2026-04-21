# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-04-21

### Added
- Initial release of Ollama Home Assistant Add-on
- Full integration with Ollama Cloud API
- GPU acceleration support for compatible hardware
- Multi-model management with auto-pull and keep-loaded options
- SQLite and PostgreSQL database support
- Configurable network settings and API endpoints
- Advanced options for parallel processing and queue management
- Comprehensive logging and debugging capabilities

### Features
- LLM server with cloud integration
- Support for aarch64 and amd64 architectures
- Service-based startup with auto-boot
- Configurable Ollama API port (default: 11434)
- Integration with MySQL and PostgreSQL services
- Configurable model management
- GPU device selection
- Network host and port configuration
- Advanced performance tuning options

### Configuration
- Ollama Cloud authentication (email, password, API key)
- Model management (default model, auto-pull list, keep-loaded list)
- GPU configuration (enabled/disabled, device selection)
- Network settings (host, port, Ollama host)
- Advanced settings (parallel processing, queue size, timeout, run directory, debug mode)