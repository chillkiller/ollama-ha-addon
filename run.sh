#!/usr/bin/env bashio
set -e

# ============================================================================
# Ollama Home Assistant Add-on - Startup Script
# Security-hardened version
# ============================================================================

bashio::log.info "Starting Ollama Home Assistant Add-on..."

# ============================================================================
# Signal Handler for Graceful Shutdown
# ============================================================================
cleanup() {
    bashio::log.info "Shutting down Ollama gracefully..."
    if [ -n "${OLLAMA_PID}" ] && kill -0 "${OLLAMA_PID}" 2>/dev/null; then
        kill -TERM "${OLLAMA_PID}" 2>/dev/null || true
        sleep 3
    fi
    # Secure cleanup of temporary files
    rm -f /tmp/ollama_signin.env /tmp/ollama_signin.exp /tmp/ollama_signin.sh 2>/dev/null || true
    bashio::log.info "Ollama shutdown complete"
    exit 0
}

trap cleanup SIGTERM SIGINT

# ============================================================================
# Configuration Loading
# ============================================================================

OLLAMA_CLOUD_ENABLED=$(bashio::config 'ollama_cloud.enabled')
OLLAMA_CLOUD_EMAIL=$(bashio::config 'ollama_cloud.email')
OLLAMA_CLOUD_PASSWORD=$(bashio::config 'ollama_cloud.password')
OLLAMA_CLOUD_API_KEY=$(bashio::config 'ollama_cloud.api_key')

DEFAULT_MODEL=$(bashio::config 'models.default_model')

AUTO_PULL_JSON=$(bashio::config 'models.auto_pull')
KEEP_LOADED_JSON=$(bashio::config 'models.keep_loaded')

GPU_ENABLED=$(bashio::config 'gpu.enabled')
GPU_DEVICE=$(bashio::config 'gpu.device')

NETWORK_HOST=$(bashio::config 'network.host')
NETWORK_PORT=$(bashio::config 'network.port')
OLLAMA_HOST=$(bashio::config 'network.ollama_host')

OLLAMA_NUM_PARALLEL=$(bashio::config 'advanced.ollama_num_parallel')
OLLAMA_NUM_QUEUE=$(bashio::config 'advanced.ollama_num_queue')
OLLAMA_LOAD_TIMEOUT=$(bashio::config 'advanced.ollama_load_timeout')
OLLAMA_RUN_DIR=$(bashio::config 'advanced.ollama_run_dir')
DEBUG_ENABLED=$(bashio::config 'advanced.debug')

# Validate network binding for security
if [ "${NETWORK_HOST}" != "127.0.0.1" ] && [ "${NETWORK_HOST}" != "localhost" ]; then
    bashio::log.warning "NETWORK_HOST is set to '${NETWORK_HOST}' - exposing Ollama to external networks!"
    bashio::log.warning "For maximum security, use '127.0.0.1' and access via HA ingress or local proxy."
fi

# ============================================================================
# Environment Setup
# ============================================================================

export OLLAMA_HOST="${OLLAMA_HOST}:${NETWORK_PORT}"
export OLLAMA_NUM_PARALLEL="${OLLAMA_NUM_PARALLEL}"
export OLLAMA_NUM_QUEUE="${OLLAMA_NUM_QUEUE}"
export OLLAMA_LOAD_TIMEOUT="${OLLAMA_LOAD_TIMEOUT}"

if [ -n "${OLLAMA_RUN_DIR}" ]; then
    export OLLAMA_RUN_DIR="${OLLAMA_RUN_DIR}"
    mkdir -p "${OLLAMA_RUN_DIR}"
fi

# Set API key if provided (preferred over email/password auth)
if [ -n "${OLLAMA_CLOUD_API_KEY}" ]; then
    export OLLAMA_API_KEY="${OLLAMA_CLOUD_API_KEY}"
    bashio::log.info "Ollama Cloud API key configured"
fi

# Enable debug mode if requested
if [ "${DEBUG_ENABLED}" = "true" ]; then
    set -x
    bashio::log.info "Debug mode enabled"
fi

# ============================================================================
# GPU Configuration
# ============================================================================

if [ "${GPU_ENABLED}" = "true" ]; then
    bashio::log.info "GPU acceleration enabled"
    if [ -n "${GPU_DEVICE}" ]; then
        export OLLAMA_GPU_DEVICE="${GPU_DEVICE}"
        bashio::log.info "Using GPU device: ${GPU_DEVICE}"
    else
        bashio::log.info "Using default GPU device"
    fi
else
    bashio::log.info "GPU acceleration disabled (CPU only mode)"
fi

# ============================================================================
# Ollama Cloud Authentication (Security-hardened)
# ============================================================================

if [ "${OLLAMA_CLOUD_ENABLED}" = "true" ]; then
    bashio::log.info "Ollama Cloud authentication enabled"

    # Prefer API key over email/password (more secure, no /proc exposure)
    if [ -n "${OLLAMA_CLOUD_API_KEY}" ]; then
        bashio::log.info "Using API key for Ollama Cloud authentication"
        # API key is already exported as environment variable above
    elif [ -z "${OLLAMA_CLOUD_EMAIL}" ] || [ -z "${OLLAMA_CLOUD_PASSWORD}" ]; then
        bashio::log.warning "Ollama Cloud credentials incomplete. Provide email + password or API key."
    else
        bashio::log.info "Attempting to sign in to Ollama Cloud..."

        if command -v expect &> /dev/null; then
            # SECURITY: Use environment file instead of command-line parameters
            # This prevents password exposure via /proc/<pid>/cmdline
            OLLAMA_ENV_FILE="/tmp/ollama_signin.env"
            printf 'OLLAMA_CLOUD_EMAIL=%s\nOLLAMA_CLOUD_PASSWORD=%s\n' \
                "${OLLAMA_CLOUD_EMAIL}" "${OLLAMA_CLOUD_PASSWORD}" \
                > "${OLLAMA_ENV_FILE}"
            chmod 600 "${OLLAMA_ENV_FILE}"

            cat > /tmp/ollama_signin.exp << 'EXPEOF'
#!/usr/bin/expect
set timeout 30
set env_file [lindex $argv 0]

# Read credentials from env file (not command line)
set fd [open $env_file r]
set email ""
set password ""
while {[gets $fd line] >= 0} {
    if {[string match "OLLAMA_CLOUD_EMAIL=*" $line]} {
        set email [string range $line 22 end]
    }
    if {[string match "OLLAMA_CLOUD_PASSWORD=*" $line]} {
        set password [string range $line 24 end]
    }
}
close $fd

spawn ollama signin $email
expect {
    "Password:" {
        send "$password\r"
        expect {
            "Success" { exit 0 }
            timeout { exit 1 }
        }
    }
    timeout { exit 1 }
}
EXPEOF

            chmod +x /tmp/ollama_signin.exp

            if /tmp/ollama_signin.exp "${OLLAMA_ENV_FILE}"; then
                bashio::log.info "Successfully signed in to Ollama Cloud"
            else
                bashio::log.warning "Failed to sign in to Ollama Cloud, continuing without cloud access"
            fi

            # Secure cleanup: remove env file immediately after use
            rm -f "${OLLAMA_ENV_FILE}" /tmp/ollama_signin.exp 2>/dev/null || true
        else
            bashio::log.warning "expect not available, cannot perform interactive login. Use API key instead."
        fi
    fi
else
    bashio::log.info "Ollama Cloud authentication disabled"
fi

# ============================================================================
# Model Management
# ============================================================================

parse_json_array() {
    local json="$1"
    echo "$json" | sed 's/^\[//;s/\]$//;s/"//g;s/,/\n/g' | grep -v '^$'
}

if [ -n "${AUTO_PULL_JSON}" ] && [ "${AUTO_PULL_JSON}" != "[]" ]; then
    bashio::log.info "Auto-pulling models..."
    while IFS= read -r model; do
        if [ -n "${model}" ]; then
            bashio::log.info "Pulling model: ${model}"
            if ollama pull "${model}"; then
                bashio::log.info "Successfully pulled model: ${model}"
            else
                bashio::log.warning "Failed to pull model: ${model}"
            fi
        fi
    done < <(parse_json_array "${AUTO_PULL_JSON}")
fi

if [ -n "${KEEP_LOADED_JSON}" ] && [ "${KEEP_LOADED_JSON}" != "[]" ]; then
    bashio::log.info "Keeping models loaded..."
    while IFS= read -r model; do
        if [ -n "${model}" ]; then
            bashio::log.info "Loading model: ${model}"
            if ollama pull "${model}"; then
                bashio::log.info "Successfully loaded model: ${model}"
            else
                bashio::log.warning "Failed to load model: ${model}"
            fi
        fi
    done < <(parse_json_array "${KEEP_LOADED_JSON}")
fi

# ============================================================================
# Start Ollama Server
# ============================================================================

bashio::log.info "Starting Ollama server on ${NETWORK_HOST}:${NETWORK_PORT}..."

ollama serve --host "${NETWORK_HOST}" --port "${NETWORK_PORT}" &
OLLAMA_PID=$!

bashio::log.info "Waiting for Ollama server to be ready..."
MAX_RETRIES=30
RETRY_COUNT=0

while [ ${RETRY_COUNT} -lt ${MAX_RETRIES} ]; do
    if curl -s "http://${OLLAMA_HOST}/api/tags" > /dev/null 2>&1; then
        bashio::log.info "Ollama server is ready!"
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    bashio::log.debug "Waiting for Ollama server... (${RETRY_COUNT}/${MAX_RETRIES})"
    sleep 2
done

if [ ${RETRY_COUNT} -eq ${MAX_RETRIES} ]; then
    bashio::log.error "Ollama server failed to start within expected time"
    exit 1
fi

# ============================================================================
# Health Monitoring
# ============================================================================

bashio::log.info "Ollama Home Assistant Add-on started successfully"
bashio::log.info "API endpoint: http://${NETWORK_HOST}:${NETWORK_PORT}"

while true; do
    if ! kill -0 "${OLLAMA_PID}" 2>/dev/null; then
        bashio::log.error "Ollama server process died, exiting..."
        exit 1
    fi

    if ! curl -s "http://${OLLAMA_HOST}/api/tags" > /dev/null 2>&1; then
        bashio::log.warning "Ollama server health check failed"
    fi

    sleep 60
done