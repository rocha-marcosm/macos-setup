#!/usr/bin/env zsh

set -eo pipefail

# 1. Install Xcode Command Line Tools
if xcode-select -p &> /dev/null; then
    echo "✅ Xcode command line tools already installed."
else
    echo "🔧 Installing Xcode command line tools..."
    xcode-select --install
fi

# 2. Install Homebrew (if not installed)
if command -v brew &> /dev/null; then
    echo "✅ Homebrew already installed."
else
    echo "🍺 Installing Homebrew..."
    NONINTERACTIVE=1 /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 3. Setup Shell Path for Apple Silicon
echo "Ensuring Homebrew is in PATH..."
if [[ $(uname -m) == "arm64" ]]; then
    if ! grep -qs "brew shellenv" "$HOME/.zshrc"; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zshrc"
        echo "✅ Added Homebrew to ~/.zshrc"
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 4. Update and Upgrade
brew update
brew upgrade

# 5. Install from Brewfile (if it exists)
if [ -f "Brewfile" ]; then
    echo "📦 Installing from Brewfile..."
    brew bundle
else
    echo "📄 No Brewfile found."
fi

echo "✨ Setup complete!"
