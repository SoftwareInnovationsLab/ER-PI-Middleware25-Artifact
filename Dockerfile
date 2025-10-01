# Dockerfile for ER-PI Artifact
FROM ubuntu:22.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Set workdir to artifact root
WORKDIR /artifact

# Install essential packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo wget curl unzip git gnupg2 \
    build-essential g++ gcc make cmake \
    libboost-all-dev libgmp-dev libsqlite3-dev zlib1g-dev libncurses5-dev \
    redis-server \
    openjdk-11-jdk \
    golang-go \
    nodejs npm \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# --- Install Node.js 20 ---
RUN apt-get purge -y nodejs npm libnode-dev && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

RUN npm install -g mocha

# Install Soufflé via official PPA (works with Ubuntu 22.04)
RUN wget -qO- https://souffle-lang.github.io/ppa/souffle-key.public | gpg --dearmor | tee /usr/share/keyrings/souffle-archive-keyring.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/souffle-archive-keyring.gpg] https://souffle-lang.github.io/ppa/ubuntu/ stable main" | tee /etc/apt/sources.list.d/souffle.list && \
    apt-get update && \
    apt-get install -y souffle && \
    rm -rf /var/lib/apt/lists/*

# --- Remove any previous Gradle installation ---
RUN rm -rf /opt/gradle

# --- Install Gradle 6.9.4 ---
RUN apt-get update && \
    apt-get install -y wget unzip && \
    wget https://services.gradle.org/distributions/gradle-6.9.4-bin.zip -P /tmp && \
    unzip -d /opt/gradle /tmp/gradle-6.9.4-bin.zip && \
    rm /tmp/gradle-6.9.4-bin.zip

# Set environment variables
ENV PATH="/usr/local/go/bin:/opt/gradle/gradle-6.9.4/bin:${PATH}"
ENV GOPATH=/go
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64


# Copy all artifact source code into container
COPY . /artifact

# Ensure logs directory exists
RUN mkdir -p /artifact/artifact_logs/Go_RDL/all_related_logs \
             /artifact/artifact_logs/Java_RDL/all_related_logs \
             /artifact/artifact_logs/OrbitDB_RDL/all_related_logs \
             /artifact/artifact_logs/roshi/all_related_logs && \
    chown -R 1000:1000 /artifact/artifact_logs && \
    chmod -R 775 /artifact/artifact_logs

# Make run scripts executable
RUN find ./RDL-Libraries -type f -name "*_run.sh" -exec chmod +x {} \;

# Default to bash so reviewers can run scripts
CMD ["/bin/bash"]
