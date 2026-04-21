# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.0.0   | ✅        |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly:

1. **Do NOT** create a public GitHub issue
2. Send an email to GaRoN ChillKiller with details:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if known)

**Email:** security@chillkiller.dev

**Subject:** [Security] Ollama HA Add-on Vulnerability Report

## Security Features

This add-on implements several security best practices:

- **Credential Protection:** Passwords and API keys are stored as `password` type fields in Home Assistant's configuration
- **No Command-Line Exposure:** Cloud authentication uses environment files instead of command-line parameters to prevent `/proc/<pid>/cmdline` leaks
- **Secure Cleanup:** Temporary authentication files are immediately removed after use
- **Network Isolation:** Default binding to `127.0.0.1` to prevent external exposure
- **Minimal Dependencies:** Only essential packages are installed in the container

## Security Best Practices for Users

1. **Use API Keys:** Prefer API keys over email/password authentication for Ollama Cloud
2. **Network Binding:** Keep `network.host` set to `127.0.0.1` unless you specifically need external access
3. **Regular Updates:** Keep both Home Assistant and this add-on updated
4. **Review Logs:** Monitor add-on logs for unusual activity
5. **HTTPS Only:** When accessing Ollama API externally, use HTTPS/TLS

## Known Limitations

- GPU support requires Home Assistant Supervised with proper host drivers
- Cloud authentication requires network connectivity to Ollama's servers
- Model files are stored in the add-on's data directory (not encrypted at rest)

## Disclosure Policy

- Vulnerabilities will be acknowledged within 48 hours
- Patches will be released as soon as feasible
- Public disclosure will occur after a fix is available
- Credit will be given to reporters in release notes (if desired)