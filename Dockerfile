# Nutze eine moderne Basis (Ansible 2.16 oder 2.17)
FROM cytopia/ansible:latest-tools

# 1. System-Abhängigkeiten
RUN apk add --no-cache rsync docker-compose git openssh-client wget curl age py3-pip

# 2. Python-Abhängigkeiten (WICHTIG: cryptography und docker-py für die Module)
RUN pip install --no-cache-dir passlib zensical docker cryptography

# 3. Mitogen (Optional - Prüfe, ob du es bei modernem Ansible noch brauchst)
# Wenn du es behältst, stelle sicher, dass die Pfade in der ansible.cfg stimmen.
RUN wget https://github.com/mitogen-hq/mitogen/archive/refs/tags/v0.3.7.tar.gz && \
    mkdir -p /plugins/mitogen && \
    tar -xf v0.3.7.tar.gz -C /plugins/mitogen --strip-components=1 && \
    rm v0.3.7.tar.gz

# 4. SOPS
ENV SOPS_VERSION=v3.9.0
RUN curl -LO "https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64" && \
    mv "sops-${SOPS_VERSION}.linux.amd64" /usr/local/bin/sops && \
    chmod +x /usr/local/bin/sops

# 5. Galaxy Requirements (Hier werden jetzt die richtigen Versionen für Ansible 2.16+ geladen)
COPY requirements.yml /tmp/requirements.yml
RUN ansible-galaxy collection install -r /tmp/requirements.yml && \
    rm /tmp/requirements.yml

WORKDIR /data