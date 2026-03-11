# Using a fixed version to prevent "latest" breakage
FROM cytopia/ansible:2.15-tools

# Install system and python dependencies once during build
RUN apk add --no-cache rsync && \
    pip install --no-cache-dir passlib

# Pre-install the galaxy requirements
# This assumes you have a requirements.yml in the same folder
COPY requirements.yml /tmp/requirements.yml
RUN ansible-galaxy install -r /tmp/requirements.yml && \
    rm /tmp/requirements.yml

WORKDIR /data