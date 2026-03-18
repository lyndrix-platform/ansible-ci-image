# Using a modern base (Ansible 2.16+)
FROM cytopia/ansible:latest-tools

# 1. System Dependencies
# Added 'jq' - you'll thank me later for parsing CI results
RUN apk add --no-cache \
    rsync \
    docker-compose \
    git \
    openssh-client \
    wget \
    curl \
    age \
    py3-pip \
    jq

# 2. Python Dependencies
# CRITICAL: Added ansible-lint here
RUN pip install --no-cache-dir \
    passlib \
    zensical \
    docker \
    cryptography \
    ansible-lint

# 3. Mitogen (Status: Controversial)
# CRITICAL CRITIQUE: Mitogen is great for speed, but often breaks with 
# complex Ansible modules (like community.docker). 
# If your pipeline is fast enough without it, I recommend removing this 
# to reduce complexity. I have kept it here per your request.
RUN wget https://github.com/mitogen-hq/mitogen/archive/refs/tags/v0.3.7.tar.gz && \
    mkdir -p /plugins/mitogen && \
    tar -xf v0.3.7.tar.gz -C /plugins/mitogen --strip-components=1 && \
    rm v0.3.7.tar.gz

# 4. SOPS
ENV SOPS_VERSION=v3.9.0
RUN curl -LO "https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64" && \
    mv "sops-${SOPS_VERSION}.linux.amd64" /usr/local/bin/sops && \
    chmod +x /usr/local/bin/sops

# 5. Galaxy Requirements
# CRITICAL FIX: Your previous command ONLY installed collections. 
# We must install both Roles and Collections to avoid "Role not found" errors.
COPY requirements.yml /tmp/requirements.yml
RUN ansible-galaxy role install -r /tmp/requirements.yml -p /usr/share/ansible/roles && \
    ansible-galaxy collection install -r /tmp/requirements.yml && \
    rm /tmp/requirements.yml

WORKDIR /data