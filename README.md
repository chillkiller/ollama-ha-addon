# Ollama Home Assistant Add-on

Ein professionelles Home Assistant Add-on für Ollama mit Cloud-Integration.

## Features

- **Aktuelle Ollama-Version**: v0.21.0 mit allen aktuellen Fixes und Performance-Optimierungen
- **Cloud-Integration**: Native Ollama Cloud-Authentifizierung (API-Key oder E-Mail/Passwort)
- **Modell-Management**: Automatisches Pullen und Laden von Modellen
- **Flexible Konfiguration**: Umfassende Optionen über das Home Assistant UI

## Installation

1. Füge dieses Repository zu Home Assistant hinzu:
   ```
   https://github.com/chillkiller/ollama-ha-addon
   ```
2. Installiere "Ollama" aus dem Add-on Store
3. Konfiguriere das Add-on nach deinen Anforderungen
4. Starte das Add-on

## Konfiguration

### Ollama Cloud

```yaml
ollama_cloud:
  enabled: true
  email: "your-ollama-cloud@email.com"
  password: "your-secure-password"
  api_key: "your-api-key"
```

**Empfehlung:** Verwende API-Keys statt E-Mail/Passwort für höhere Sicherheit.

### Modell-Management

```yaml
models:
  default_model: "llama3"
  auto_pull:
    - "llama3"
    - "mistral"
  keep_loaded:
    - "llama3"
```

### GPU-Unterstützung

```yaml
gpu:
  enabled: true
  device: ""
```

**Hinweis:** GPU-Unterstützung erfordert Home Assistant Supervised mit konfiguriertem NVIDIA Container Toolkit oder Intel/AMD GPU-Treibern auf dem Host.

### Netzwerk

```yaml
network:
  host: "127.0.0.1"
  port: 11434
  ollama_host: "127.0.0.1"
```

**Sicherheitshinweis:** Standardmäßig lauscht Ollama nur auf localhost. Ändere `host` nur, wenn du externen Zugriff benötigst.

### Erweiterte Optionen

```yaml
advanced:
  ollama_num_parallel: 1
  ollama_num_queue: 512
  ollama_load_timeout: 5m
  ollama_run_dir: ""
  debug: false
```

## Ports

- **11434/tcp**: Ollama API

## Sicherheit

- **Passwörter** werden verschlüsselt in der HA-Konfiguration gespeichert (password-Typ in schema)
- **API-Keys** werden als password-Felder behandelt
- **Login-Prozess** verwendet Umgebungsdateien statt Kommandozeilenparameter (verhindert /proc-Lecks)
- **Netzwerk** ist standardmäßig auf localhost beschränkt
- **Cleanup** der temporären Authentifizierungsdateien nach Gebrauch

## GPU-Unterstützung in Home Assistant

| Feature | HAOS | Supervised |
|---------|------|------------|
| NVIDIA GPU | Nicht unterstützt | Unterstützt (Host-Treiber + NVIDIA Container Toolkit) |
| Intel iGPU | Begrenzt (VA-API) | Unterstützt |
| AMD GPU (ROCm) | Nicht unterstützt | Unterstützt (Host-Treiber) |

Für GPU-Unterstützung wird **Home Assistant Supervised** auf einem Host mit den entsprechenden Treibern empfohlen.

## Lizenz

MIT License

## Support

- [Ollama Dokumentation](https://docs.ollama.com)
- [GitHub Issues](https://github.com/chillkiller/ollama-ha-addon/issues)

## Version

- **Add-on Version**: 1.0.0
- **Ollama Version**: v0.21.0
- **Base Image**: Debian Trixie