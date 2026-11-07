FROM mcr.microsoft.com/devcontainers/javascript-node:1-22-bookworm

RUN apt-get update \
    && apt-get install -y apt-transport-https ca-certificates gnupg curl \
    && curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list \
    && apt-get update \
    # Google's apt repo only retains recent releases, so pinning a version
    # eventually breaks the build; install the latest available instead.
    && apt-get install -y google-cloud-cli \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Firebase CLI, required by the devcontainer postCreateCommand and deploys.
RUN npm install -g firebase-tools

WORKDIR /workspaces/fli-further-website
