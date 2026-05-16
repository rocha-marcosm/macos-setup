#!/usr/bin/env zsh

set -eo pipefail
trap 'echo "❌ Error on line $LINENO"' ERR

# 🍺 1. Update and Upgrade
brew update
brew upgrade

# 🍺 2. Install from Brewfile (if it exists)
BREWFILE_URL="https://raw.githubusercontent.com/rocha-marcosm/macos-setup/main/Brewfile"

if [ -f "Brewfile" ]; then
    echo "📦 Installing from local Brewfile..."
    brew bundle
else
    echo "🌐 No local Brewfile found. Fetching from GitHub..."
    curl -fsSL "$BREWFILE_URL" | brew bundle --file=-
fi

echo "🔧 Installing kubectl..."
if ! asdf plugin list 2>/dev/null | grep -q "^kubectl$"; then
    asdf plugin add kubectl https://github.com/asdf-community/asdf-kubectl.git
fi
asdf install kubectl latest

echo "🍺 brew setup complete!"
