#!/usr/bin/env zsh

set -eo pipefail
trap 'echo "❌ Error on line $LINENO"' ERR


# 1. Install Homebrew (if not installed)
if command -v brew &> /dev/null; then
    echo "✅ Homebrew already installed."
else
    echo "🍺 Installing Homebrew..."
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 2. Setup Shell Path for Apple Silicon
echo "Ensuring Homebrew is in PATH..."
if ! grep -qs "brew shellenv" "$HOME/.zprofile"; then
    echo >> "$HOME/.zprofile"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> "$HOME/.zprofile"
    echo "✅ Added Homebrew to ~/.zprofile"
fi
eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# 3. 🍺 Brew packages 📦
source ./brew.sh

# 5. installing and configuring oh my zsh

echo "🐧 Installing Oh My Zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "🚀 Installing spaceship zsh theme..."
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt" ]; then
    echo "Installing spaceship zsh theme..."
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt" --depth=1
    ln -s "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt/spaceship.zsh-theme" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship.zsh-theme"
    echo "spaceship zsh theme installed."
else
    echo "spaceship zsh theme is already installed."
fi

echo "Setting up Zsh plugins..."

# Install zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    echo "zsh-syntax-highlighting installed."
else
    echo "zsh-syntax-highlighting is already installed."
fi

# Install zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    echo "zsh-autosuggestions installed."
else
    echo "zsh-autosuggestions is already installed."
fi

# Update .zshrc file
echo "Updating .zshrc file..."

# Backup existing .zshrc
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
    echo "✅ Backed up existing .zshrc file."
fi

if ! grep -qs "spaceship" "$HOME/.zshrc"; then
    cat > "$HOME/.zshrc" << 'EOL'
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="spaceship"

# Set plugins
plugins=(
  aws
  brew
  git
  github
  docker
  docker-compose
  helm
  kubectl
  kubectx
  terraform
  python
  pip
  macos
  zsh-syntax-highlighting
  zsh-autosuggestions
)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8
export EDITOR='nvim'

# Aliases
alias k=kubectl
alias docker=container

# Evironment variables
export TENV_AUTO_INSTALL=true
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

EOL

    cat > "$HOME/.spaceshiprc.zsh" << 'EOL'
# Display time
SPACESHIP_TIME_SHOW=true

# Display username always
SPACESHIP_USER_SHOW=always

# Do not truncate path in repos
SPACESHIP_DIR_TRUNC_REPO=false

# Change color of the git section
SPACESHIP_GIT_COLOR=magenta

# test
SPACESHIP_PROMPT_ADD_NEWLINE=true
SPACESHIP_PROMPT_SEPARATE_LINE=true

# k8s
SPACESHIP_KUBECTL_SHOW=true
SPACESHIP_KUBECTL_VERSION_SHOW=false

# Right order
spaceship remove time
SPACESHIP_RPROMPT_ORDER=(
  time
)
EOL

    echo "✅ Created new .zshrc with recommended configuration."
else
    echo "Skipping .zshrc modification because ZSH_THEME is already present."
fi


echo "✨ Setup complete!"
