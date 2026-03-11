# Critical: Pin this to a specific version for stability (e.g., 2.15-tools)
FROM cytopia/ansible:latest-tools

# 1. Install system and Python dependencies
# Added git/openssh for CI operations
RUN apk add --no-cache rsync docker-compose git openssh-client wget && \
    pip install --no-cache-dir passlib zensical

# 2. Install Mitogen for 60%+ faster execution
# We extract it to /plugins/mitogen so it's globally available in the CI
RUN wget https://github.com/mitogen-hq/mitogen/archive/refs/tags/v0.3.7.tar.gz && \
    mkdir -p /plugins/mitogen && \
    tar -xf v0.3.7.tar.gz -C /plugins/mitogen --strip-components=1 && \
    rm v0.3.7.tar.gz

# 3. Pre-install the Ansible Galaxy requirements
COPY requirements.yml /tmp/requirements.yml
RUN ansible-galaxy install -r /tmp/requirements.yml && \
    rm /tmp/requirements.yml

WORKDIR /data