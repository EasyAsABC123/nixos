# Installation Guide

This guide walks through bootstrapping nix-darwin and Home Manager on your macOS system from scratch.

## System Information

- **Architecture**: Apple Silicon (aarch64-darwin)
- **macOS Version**: 26.5.1
- **User**: jschuhmann

## Prerequisites

1. **Xcode Command Line Tools** (required for compilation)
   ```bash
   xcode-select --install
   ```

2. **Admin privileges** (required for system modifications)

## Step 1: Install Nix Package Manager

### Option A: Official Multi-User Installation (Recommended)

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

This will:
- Install Nix to `/nix`
- Set up the nix-daemon service
- Create the `nixbld` group and users
- Configure your shell profile

### Option B: Determinate Systems Installer (Alternative)

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Benefits:
- More reliable APFS volume setup
- Better error handling
- Improved uninstall support

### Verify Installation

```bash
# Check Nix version
nix --version

# Test basic command
nix-shell -p hello --run hello
```

## Step 2: Enable Flakes (if using official installer)

If you used the official Nix installer, flakes might not be enabled by default:

```bash
mkdir -p ~/.config/nix
cat > ~/.config/nix/nix.conf <<EOF
experimental-features = nix-command flakes
EOF
```

## Step 3: Bootstrap nix-darwin

```bash
# Navigate to this repository
cd ~/github/nixos

# Build the initial Darwin configuration
nix run nix-darwin -- switch --flake .#jschuhmann-macbook
```

**What this does:**
1. Downloads nix-darwin
2. Builds the system configuration from `flake.nix`
3. Activates system defaults (Dock, Finder, etc.)
4. Sets up the Homebrew integration
5. Installs Home Manager for user-space configuration

### Troubleshooting First Build

If you see errors about `/run`, create it manually:
```bash
sudo mkdir -p /run
```

If you see errors about existing `/etc/zshrc`:
```bash
# Backup existing config
sudo mv /etc/zshrc /etc/zshrc.backup
sudo mv /etc/bashrc /etc/bashrc.backup 2>/dev/null || true
```

## Step 4: Reload Your Shell

```bash
# Restart your terminal or source the new profile
exec zsh
```

## Step 5: Verify Installation

### Check nix-darwin

```bash
# Should show your configuration
darwin-rebuild --help

# Check system generation
ls -l /run/current-system
```

### Check Home Manager

```bash
# Should show your home configuration
home-manager --help

# Check home generation
ls -l ~/.local/state/nix/profiles/home-manager
```

### Check Installed Packages

```bash
# Nix-managed packages
which git gh kubectl helm terraform

# Homebrew casks (GUI apps)
brew list --cask
```

## Step 6: Initial Configuration Sync

The first activation will:

1. **Install Homebrew** (if not already present)
2. **Install Homebrew casks** from the configuration
3. **Apply macOS system defaults**
4. **Install ~180 CLI tools** via Nix
5. **Generate dotfiles** (`.zshrc`, `.gitconfig`, etc.)

This may take 10-30 minutes depending on:
- Your internet connection
- Whether binaries are available in the Nix cache
- How many packages need compilation

### Monitor Progress

```bash
# Watch Nix store activity
watch -n 1 'du -sh /nix/store'

# Check Homebrew installation progress
tail -f ~/Library/Logs/Homebrew/homebrew.log
```

## Making Changes

### Update System Configuration

```bash
# Edit flake.nix or home.nix
vim ~/github/nixos/flake.nix

# Rebuild the system
darwin-rebuild switch --flake ~/github/nixos#jschuhmann-macbook
```

### Update Packages

```bash
# Update flake inputs (nixpkgs, nix-darwin, home-manager)
cd ~/github/nixos
nix flake update

# Rebuild with updated inputs
darwin-rebuild switch --flake .#jschuhmann-macbook
```

### Rollback Changes

```bash
# List available generations
darwin-rebuild --list-generations

# Rollback to previous generation
darwin-rebuild --rollback
```

## Common Issues

### Issue: "permission denied" during build

**Solution**: Ensure you're an admin user and the nix-daemon is running
```bash
# Check daemon status
sudo launchctl list | grep nix

# Restart daemon if needed
sudo launchctl kickstart -k system/org.nixos.nix-daemon
```

### Issue: Homebrew cask install fails

**Solution**: Some casks require manual acceptance of licenses or system permissions
```bash
# Install problematic casks manually first
brew install --cask gswitch
brew install --cask aerospace

# Then run darwin-rebuild again
```

### Issue: "build of X failed" during package installation

**Solution**: Check if the package is available in nixpkgs
```bash
# Search for package
nix search nixpkgs <package-name>

# Try installing from unstable
nix-shell -p nixpkgs-unstable.<package-name>
```

### Issue: Shell configuration not loading

**Solution**: Ensure your shell is properly configured
```bash
# For zsh (default on macOS)
cat ~/.zshrc

# Should contain Home Manager initialization
# If not, add:
if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
  . ~/.nix-profile/etc/profile.d/nix.sh
fi
```

## Architecture Notes

### Apple Silicon vs Intel

This configuration is set for Apple Silicon (`aarch64-darwin`). For Intel Macs:

1. Change in `flake.nix`:
   ```nix
   system = "x86_64-darwin";
   nixpkgs.hostPlatform = "x86_64-darwin";
   ```

2. Update Home Manager package set:
   ```nix
   pkgs = nixpkgs.legacyPackages.x86_64-darwin;
   ```

## Uninstallation

If you need to remove nix-darwin:

```bash
# Remove nix-darwin activation
sudo rm -rf /run/current-system

# Remove Home Manager
home-manager uninstall

# Uninstall Nix (Determinate Systems installer)
/nix/nix-installer uninstall

# OR for official installer
# Follow: https://nixos.org/manual/nix/stable/installation/uninstall.html
```

## Next Steps

1. **Customize `home.nix`**: Update Git name/email, add more packages
2. **Review `flake.nix`**: Adjust system defaults (Dock position, key repeat, etc.)
3. **Migrate Homebrew packages**: Consider moving more CLI tools to Nix
4. **Explore nix-darwin modules**: Search for additional system configuration options

## Resources

- [nix-darwin documentation](https://github.com/LnL7/nix-darwin)
- [Home Manager manual](https://nix-community.github.io/home-manager/)
- [Nixpkgs package search](https://search.nixos.org/packages)
- [Nix language guide](https://nixos.org/guides/nix-language.html)
