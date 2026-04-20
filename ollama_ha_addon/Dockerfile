ARG BUILD_FROM
FROM $BUILD_FROM

# Set environment variables (will be overridden by run.sh)
ENV OLLAMA_HOST=127.0.0.1:11434
ENV OLLAMA_NUM_PARALLEL=1
ENV OLLAMA_NUM_QUEUE=512
ENV OLLAMA_LOAD_TIMEOUT=5m

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    expect \
    && rm -rf /var/lib/apt/lists/*

# Download and install Ollama (specific version)
ENV OLLAMA_VERSION=0.21.0
RUN curl -fsSL https://ollama.com/install.sh | OLLAMA_VERSION=${OLLAMA_VERSION} sh

# Create directories
RUN mkdir -p /data/.ollama

# Set working directory
WORKDIR /data

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Set permissions for Ollama data directory
RUN chown -R root:root /data/.ollama

CMD ["/run.sh"]