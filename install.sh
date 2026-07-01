#!/usr/bin/env bash
#
# Home Manager Installation Script
# Automates the setup of Nix Home Manager configuration
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect architecture
detect_arch() {
    if [[ $(uname -m) == "arm64" ]]; then
        echo "aarch64-darwin"
    else
        echo "x86_64-darwin"
    fi
}

# Main installation function
main() {
    info "Home Manager Installation Script"
    echo ""

    # Check if we're on macOS
    if [[ $(uname) != "Darwin" ]]; then
        error "This script is designed for macOS only"
        exit 1
    fi

    # Detect architecture
    ARCH=$(detect_arch)
    info "Detected architecture: $ARCH"

    # Check if Nix is installed
    if ! command_exists nix; then
        warning "Nix is not installed"
        echo ""
        echo "Would you like to install Nix now? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            info "Installing Nix using Determinate Systems installer..."
            curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

            # Source Nix profile
            if [[ -f ~/.nix-profile/etc/profile.d/nix.sh ]]; then
                source ~/.nix-profile/etc/profile.d/nix.sh
            fi

            success "Nix installed successfully"
        else
            error "Nix installation required. Please install Nix first:"
            echo "  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install"
            exit 1
        fi
    else
        success "Nix is already installed"
    fi

    # Verify Nix installation
    if ! command_exists nix; then
        error "Nix installation verification failed"
        echo "Please restart your shell and run this script again"
        exit 1
    fi

    # Check Nix version
    NIX_VERSION=$(nix --version)
    info "Nix version: $NIX_VERSION"

    # Check if flakes are enabled
    if ! nix flake --version >/dev/null 2>&1; then
        warning "Nix flakes not enabled"
        info "Enabling flakes..."

        mkdir -p ~/.config/nix
        if ! grep -q "experimental-features" ~/.config/nix/nix.conf 2>/dev/null; then
            echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
            success "Flakes enabled in ~/.config/nix/nix.conf"
        fi
    else
        success "Nix flakes are enabled"
    fi

    # Get username
    CURRENT_USER=$(whoami)
    info "Current user: $CURRENT_USER"

    # Check if flake.nix needs updating
    if grep -q "jschuhmann" flake.nix && [[ "$CURRENT_USER" != "jschuhmann" ]]; then
        warning "flake.nix contains hardcoded username 'jschuhmann'"
        echo ""
        echo "Would you like to update it to your username ($CURRENT_USER)? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            sed -i.backup "s/jschuhmann/$CURRENT_USER/g" flake.nix
            success "Updated flake.nix with username: $CURRENT_USER"
        else
            warning "Please manually update flake.nix before continuing"
            exit 1
        fi
    fi

    # Check if architecture in flake.nix matches
    if ! grep -q "$ARCH" flake.nix; then
        warning "flake.nix architecture may not match your system"
        echo "Your system: $ARCH"
        echo ""
        echo "Would you like to update flake.nix to use $ARCH? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            if [[ "$ARCH" == "aarch64-darwin" ]]; then
                sed -i.backup 's/x86_64-darwin/aarch64-darwin/g' flake.nix
            else
                sed -i.backup 's/aarch64-darwin/x86_64-darwin/g' flake.nix
            fi
            success "Updated flake.nix architecture to: $ARCH"
        fi
    fi

    # Backup existing configurations
    info "Backing up existing configurations..."
    timestamp=$(date +%Y%m%d_%H%M%S)

    if [[ -f ~/.zshrc ]]; then
        cp ~/.zshrc ~/.zshrc.backup.$timestamp
        success "Backed up ~/.zshrc"
    fi

    if [[ -f ~/.p10k.zsh ]]; then
        cp ~/.p10k.zsh ~/.p10k.zsh.backup.$timestamp
        success "Backed up ~/.p10k.zsh"
    fi

    # Ask before proceeding with installation
    echo ""
    warning "This will install Home Manager and activate the configuration"
    echo "This will modify your shell profile and install ~180 packages"
    echo ""
    echo "Continue? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        info "Installation cancelled"
        exit 0
    fi

    # Install Home Manager
    info "Installing Home Manager..."
    echo ""

    if nix run home-manager/master -- switch --flake ".#$CURRENT_USER"; then
        success "Home Manager installed and activated successfully!"
    else
        error "Home Manager installation failed"
        echo ""
        echo "Common issues:"
        echo "  1. Check that home.username matches your system username"
        echo "  2. Verify flake.nix homeConfigurations key matches your username"
        echo "  3. Ensure Nix flakes are enabled"
        exit 1
    fi

    # Post-installation steps
    echo ""
    success "Installation complete!"
    echo ""
    info "Next steps:"
    echo "  1. Restart your shell or run: source ~/.zshrc"
    echo "  2. Configure Powerlevel10k: p10k configure"
    echo "  3. Test tools: git --version, kubectl version --client, etc."
    echo "  4. Review configuration: cat ~/github/nixos/home.nix"
    echo "  5. Update packages: home-manager switch --flake ~/github/nixos#$CURRENT_USER"
    echo ""
    info "For more information, see:"
    echo "  - README.md: Overview and usage guide"
    echo "  - MIGRATION.md: Detailed migration checklist"
    echo ""
    success "Happy Nix-ing!"
}

# Run main function
main "$@"
