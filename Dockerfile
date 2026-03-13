# Pinned to a specific version. Do not revert this to :latest.
FROM cytopia/ansible:2.11-tools

# 1. Install system and Python dependencies
# Added curl (for SOPS download) and age (for local debugging/key generation)
RUN apk add --no-cache rsync docker-compose git openssh-client wget curl age && \
    pip install --no-cache-dir passlib zensical

# 2. Install Mitogen for 60%+ faster execution
RUN wget https://github.com/mitogen-hq/mitogen/archive/refs/tags/v0.3.7.tar.gz && \
    mkdir -p /plugins/mitogen && \
    tar -xf v0.3.7.tar.gz -C /plugins/mitogen --strip-components=1 && \
    rm v0.3.7.tar.gz

# 3. Install SOPS
# Pinning to a specific, stable version.
ENV SOPS_VERSION=v3.9.0
RUN curl -LO "https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64" && \
    mv "sops-${SOPS_VERSION}.linux.amd64" /usr/local/bin/sops && \
    chmod +x /usr/local/bin/sops

# 4. Pre-install the Ansible Galaxy requirements
COPY requirements.yml /tmp/requirements.yml
RUN ansible-galaxy install -r /tmp/requirements.yml && \
    rm /tmp/requirements.yml

WORKDIR /data