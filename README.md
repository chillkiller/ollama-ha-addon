# Ollama Home Assistant Add-on

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Home Assistant](https://img.shields.io/badge/Home%20Assistant-Add--on-blue.svg)](https://www.home-assistant.io)
[![Ollama](https://img.shields.io/badge/Ollama-v0.21.0-orange.svg)](https://ollama.com)
[![Architecture](https://img.shields.io/badge/Arch-aarch64%20%7C%20amd64-green.svg)](https://github.com/chillkiller/ollama-ha-addon)

A professional Home Assistant add-on for running [Ollama](https://ollama.com) with native cloud integration and advanced configuration options.

## ✨ Features

- 🚀 **Latest Ollama Version** - v0.21.0 with all current fixes and performance optimizations
- ☁️ **Cloud Integration** - Native Ollama Cloud authentication (API key or email/password)
- 🤖 **Model Management** - Automatic pulling and loading of models
- ⚙️ **Flexible Configuration** - Comprehensive options via Home Assistant UI
- 🔒 **Security Hardened** - Credential protection, no command-line exposure, secure cleanup
- 🎮 **GPU Support** - NVIDIA, Intel, and AMD GPU acceleration (Supervised only)
- 🌐 **Network Isolation** - Default localhost binding for maximum security

## 📦 Installation

### Add Repository

1. Open Home Assistant
2. Go to **Settings** → **Add-ons** → **Add-on Store**
3. Click the three dots menu (⋮) → **Add-ons**
4. Select **Add repository**
5. Enter: `https://github.com/chillkiller/ollama-ha-addon`
6. Click **Add**

### Install Add-on

1. Find "Ollama" in the add-on store
2. Click **Install**
3. Configure the add-on (see Configuration below)
4. Click **Start**

## ⚙️ Configuration

### Ollama Cloud

```yaml
ollama_cloud:
  enabled: true
  email: "your-ollama-cloud@email.com"
  password: "your-secure-password"
  api_key: "your-api-key"
```

**Recommendation:** Use API keys instead of email/password for better security.

### Model Management

```yaml
models:
  default_model: "llama3"
  auto_pull:
    - "llama3"
    - "mistral"
  keep_loaded:
    - "llama3"
```

### GPU Support

```yaml
gpu:
  enabled: true
  device: ""
```

**Note:** GPU support requires Home Assistant Supervised with configured NVIDIA Container Toolkit or Intel/AMD GPU drivers on the host.

### Network

```yaml
network:
  host: "127.0.0.1"
  port: 11434
  ollama_host: "127.0.0.1"
```

**Security Note:** By default, Ollama only listens on localhost. Only change `host` if you need external access.

### Advanced Options

```yaml
advanced:
  ollama_num_parallel: 1
  ollama_num_queue: 512
  ollama_load_timeout: 5m
  ollama_run_dir: ""
  debug: false
```

## 🔌 Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 11434 | TCP | Ollama API |

## 🔒 Security

This add-on implements several security best practices:

- **Credential Protection:** Passwords and API keys are stored as `password` type fields in Home Assistant's configuration
- **No Command-Line Exposure:** Cloud authentication uses environment files instead of command-line parameters to prevent `/proc/<pid>/cmdline` leaks
- **Secure Cleanup:** Temporary authentication files are immediately removed after use
- **Network Isolation:** Default binding to `127.0.0.1` to prevent external exposure
- **Minimal Dependencies:** Only essential packages are installed in the container

## 🎮 GPU Support

| Feature | HAOS | Supervised |
|---------|------|------------|
| NVIDIA GPU | Not supported | Supported (Host drivers + NVIDIA Container Toolkit) |
| Intel iGPU | Limited (VA-API) | Supported |
| AMD GPU (ROCm) | Not supported | Supported (Host drivers) |

For GPU support, **Home Assistant Supervised** on a host with the appropriate drivers is recommended.

## 📚 Usage Examples

### Basic Model Query

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3",
  "prompt": "Why is the sky blue?"
}'
```

### List Available Models

```bash
curl http://localhost:11434/api/tags
```

### Pull a New Model

```bash
curl http://localhost:11434/api/pull -d '{
  "name": "mistral"
}'
```

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [Ollama Documentation](https://docs.ollama.com)
- [Home Assistant Add-ons](https://www.home-assistant.io/add-ons/)
- [GitHub Issues](https://github.com/chillkiller/ollama-ha-addon/issues)
- [Security Policy](SECURITY.md)

## 📊 Version Information

- **Add-on Version:** 1.0.0
- **Ollama Version:** v0.21.0
- **Base Image:** Debian Trixie

## 🙏 Acknowledgments

- [Ollama](https://ollama.com) - The amazing LLM runtime
- [Home Assistant](https://www.home-assistant.io) - The open-source home automation platform
- All contributors and users who provide feedback and suggestions

---

Made with ❤️ by [GaRoN ChillKiller](https://github.com/chillkiller)