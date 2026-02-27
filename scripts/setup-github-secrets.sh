#!/bin/bash

# Setup GitHub Secrets for GitOps
# This script helps you configure the required secrets for the GitOps pipeline

set -e

echo "================================================"
echo "GitHub Secrets Setup for Omnitools GitOps"
echo "================================================"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ Error: GitHub CLI (gh) is not installed"
    echo ""
    echo "Install it with:"
    echo "  macOS: brew install gh"
    echo "  Linux: https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
    echo ""
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Error: Not authenticated with GitHub CLI"
    echo ""
    echo "Run: gh auth login"
    echo ""
    exit 1
fi

echo "✅ GitHub CLI is installed and authenticated"
echo ""

REPO="arnaduga/omni-tools"

echo "This script will help you set up the following secrets for $REPO:"
echo ""
echo "  1. DOCKERHUB_USERNAME - Your DockerHub username"
echo "  2. DOCKERHUB_TOKEN - DockerHub access token"
echo "  3. MANIFEST_REPO_TOKEN - GitHub PAT for updating manifests"
echo ""
echo "================================================"
echo ""

# Function to set a secret
set_secret() {
    local secret_name=$1
    local secret_description=$2
    local secret_url=$3

    echo ""
    echo "Setting up: $secret_name"
    echo "Description: $secret_description"

    if [ -n "$secret_url" ]; then
        echo "Create token at: $secret_url"
    fi

    echo ""
    read -p "Enter value for $secret_name (input hidden): " -s secret_value
    echo ""

    if [ -z "$secret_value" ]; then
        echo "⚠️  Skipping $secret_name (empty value)"
        return
    fi

    echo "$secret_value" | gh secret set "$secret_name" --repo "$REPO"

    if [ $? -eq 0 ]; then
        echo "✅ $secret_name set successfully"
    else
        echo "❌ Failed to set $secret_name"
    fi
}

# Set DockerHub Username
echo "================================================"
echo "1/3 DOCKERHUB_USERNAME"
echo "================================================"
set_secret "DOCKERHUB_USERNAME" \
    "Your DockerHub username (e.g., arnaduga)" \
    ""

# Set DockerHub Token
echo ""
echo "================================================"
echo "2/3 DOCKERHUB_TOKEN"
echo "================================================"
echo "To create a DockerHub access token:"
echo "  1. Go to: https://hub.docker.com/settings/security"
echo "  2. Click 'New Access Token'"
echo "  3. Description: 'GitHub Actions - omnitools'"
echo "  4. Permissions: Read & Write"
echo "  5. Copy the token"
echo ""
set_secret "DOCKERHUB_TOKEN" \
    "DockerHub access token with Read & Write permissions" \
    "https://hub.docker.com/settings/security"

# Set Manifest Repo Token
echo ""
echo "================================================"
echo "3/3 MANIFEST_REPO_TOKEN"
echo "================================================"
echo "To create a GitHub Personal Access Token:"
echo "  1. Go to: https://github.com/settings/tokens?type=beta"
echo "  2. Click 'Generate new token' (Fine-grained)"
echo "  3. Token name: 'omnitools-gitops-update'"
echo "  4. Repository access: Only select repositories"
echo "     → Select: arnaduga/omnitools-argo"
echo "  5. Permissions:"
echo "     → Contents: Read and Write"
echo "  6. Generate and copy the token"
echo ""
set_secret "MANIFEST_REPO_TOKEN" \
    "GitHub PAT with write access to arnaduga/omnitools-argo" \
    "https://github.com/settings/tokens?type=beta"

echo ""
echo "================================================"
echo "✅ Setup Complete!"
echo "================================================"
echo ""
echo "View your secrets at:"
echo "https://github.com/$REPO/settings/secrets/actions"
echo ""
echo "Next steps:"
echo "  1. Commit and push your changes to trigger the workflow"
echo "  2. Monitor the workflow at: https://github.com/$REPO/actions"
echo "  3. Check ArgoCD for automatic deployment"
echo ""
