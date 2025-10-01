# Dockerfile for ER-PI Artifact
FROM ubuntu:20.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Set workdir to artifact root
WORKDIR /artifact

# Install essential packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo wget curl unzip git \
    build-essential g++ gcc make \
    software-properties-common \
    ca-certificates \
    redis-server \
    openjdk-11-jdk \
    golang-go \
    nodejs npm \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Node 20 and npm 10 (official setup)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# --- Install Soufflé via official PPA ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 software-properties-common wget && \
    wget -qO- https://souffle-lang.github.io/ppa/souffle-key.public | gpg --dearmor | tee /usr/share/keyrings/souffle-archive-keyring.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/souffle-archive-keyring.gpg] https://souffle-lang.github.io/ppa/ubuntu/ stable main" | tee /etc/apt/sources.list.d/souffle.list && \
    apt-get update && \
    apt-get install -y souffle && \
    rm -rf /var/lib/apt/lists/*

# Environment variables
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH=/go
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Ensure logs directory exists
RUN mkdir -p /artifact/logs

# Make run scripts executable
RUN find ./RDL-Libraries -type f -name "*_run.sh" -exec chmod +x {} \;

# Default command
CMD ["/bin/bash"]
