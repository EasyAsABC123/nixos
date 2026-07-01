# 🆕 New MacBook Setup Guide

Complete guide for setting up a new MacBook with this Nix-on-macOS configuration.

**Estimated Time:** 60-80 minutes  
**Prerequisites:** New Mac with macOS installed  
**Result:** Fully configured development environment with ~180 CLI tools and macOS defaults

---

## 📋 Pre-Setup Checklist

Before your new MacBook arrives, ensure:

- ✅ This repository is pushed to GitHub/GitLab
- ✅ You have SSH keys backed up (or can generate new ones)
- ✅ You know your preferred username (must match `config.nix`)
- ✅ You have admin access to the new Mac
- ✅ You have internet connection (WiFi or Ethernet)

---

## Phase 1: Initial macOS Setup (10 minutes)

### 1.1 Complete Apple Setup Wizard

1. **Power on** and choose language/region
2. **Connect to WiFi**
3. **Sign in with Apple ID** (optional, can skip)
4. **Create user account**
   - Username: `jschuhmann` (must match `config.nix`)
   - Full name: Your choice
   - Password: Choose strong password
5. **Enable FileVault** (disk encryption) - Recommended
6. **Skip** iCloud Drive, Screen Time, Apple Pay for now
7. **Complete setup** and reach desktop

### 1.2 System Updates

```bash
# Open Terminal (⌘+Space, type "terminal")

# Check for macOS updates
softwareupdate --list

# Install all available updates
sudo softwareupdate --install --all

# Restart if required
```

### 1.3 Install Xcode Command Line Tools

```bash
# This is REQUIRED before installing Nix
xcode-select --install
```

Click **Install** in the popup dialog. This takes ~5 minutes.

**Verify installation:**
```bash
xcode-select -p
# Should output: /Library/Developer/CommandLineTools
```

---

## Phase 2: Clone Configuration (2 minutes)

### 2.1 Set Up Git

```bash
# Configure git (temporary, will be overwritten by Nix config)
git config --global user.name "Josh Schuhmann"
git config --global user.email "jschuhmann@salesforce.com"
```

### 2.2 Clone Repository

```bash
# Create directory structure
mkdir -p ~/github

# Clone your configuration repo
cd ~/github
git clone https://github.com/YOUR-USERNAME/nixos.git

# Enter directory
cd nixos

# Verify files exist
ls -la
# Should see: config.nix, flake.nix, home.nix, etc.
```

**If you haven't pushed to GitHub yet:**

Transfer files from old Mac via one of these methods:
- **AirDrop**: Compress folder, send to new Mac
- **USB Drive**: Copy folder to drive, transfer
- **Network**: Use `rsync` or file sharing

---

## Phase 3: Customize Configuration (5 minutes)

### 3.1 Verify System Information

```bash
# Check your username
whoami
# Output: jschuhmann

# Check architecture
uname -m
# arm64 = Apple Silicon (M1/M2/M3/M4)
# x86_64 = Intel
```

### 3.2 Update config.nix (if needed)

**For same configuration (same username, same settings):**

```bash
# Just verify config.nix is correct
cat config.nix
```

Ensure:
- `username` matches output of `whoami`
- `architecture` matches your Mac:
  - `aarch64-darwin` for Apple Silicon
  - `x86_64-darwin` for Intel

**For different machine (work laptop, different name):**

```bash
# Create separate config
cp config.nix config-work.nix

# Edit new config
vim config-work.nix
```

Update values:
```nix
{
  user = {
    username = "jschuhmann";  # ← Must match whoami
    fullName = "Josh Schuhmann";
    email = "jschuhmann@salesforce.com";
    homeDirectory = "/Users/jschuhmann";
  };

  system = {
    hostname = "jschuhmann-work-macbook";  # ← Make unique
    architecture = "aarch64-darwin";  # ← Match uname -m
    stateVersion = 5;
  };

  homeManager = {
    stateVersion = "24.05";
  };
}
```

If using alternate config, update `flake.nix`:
```bash
vim flake.nix
# Change line 21:
# config = import ./config-work.nix;
```

### 3.3 Validate Configuration

```bash
# Run validation script
./validate.sh
```

**Expected output:**
```
✓ config.nix exists
✓ Username matches current user (jschuhmann)
✓ Architecture matches system (Apple Silicon)
✓ Email format is valid
...
✨ Configuration validation successful!
```

Fix any ✗ errors or ⚠ warnings before proceeding.

---

## Phase 4: Install Nix (10 minutes)

### 4.1 Choose Installer

**Option A: Determinate Systems (Recommended)**

More reliable, better APFS volume setup, easier uninstall.

```bash
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install
```

**Option B: Official Nix**

Standard installer from NixOS.org.

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

### 4.2 Installation Process

Follow prompts:
1. Review installation plan
2. Enter password when prompted
3. Wait for installation (~5 minutes)
4. **Restart terminal** when complete

### 4.3 Verify Nix Installation

```bash
# Close and reopen Terminal, then:

# Check Nix version
nix --version
# Should output: nix (Nix) 2.x.x

# Check flakes are enabled
nix flake --help
# Should show help text (not error)

# Test basic Nix command
nix-shell -p hello --run hello
# Should output: Hello, world!
```

**Troubleshooting:**

If `nix: command not found`:
```bash
# Manually source Nix profile
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Then restart terminal
exec zsh
```

---

## Phase 5: Bootstrap nix-darwin (20-40 minutes)

### 5.1 Initial Build

```bash
cd ~/github/nixos

# Get hostname from config.nix
grep hostname config.nix
# Output: hostname = "jschuhmann-macbook";

# Bootstrap nix-darwin (use YOUR hostname)
nix run nix-darwin -- switch --flake .#jschuhmann-macbook
```

### 5.2 What Happens During Bootstrap

**This step takes 20-40 minutes.** Progress will show:

```
building the system configuration...
downloading 'https://cache.nixos.org/...'
copying path '/nix/store/...'
building '/nix/store/...'
activating the configuration...
setting up /Applications/Nix Apps...
setting up Homebrew...
```

**Components installed:**
- ✅ nixpkgs (~500MB downloaded)
- ✅ nix-darwin system
- ✅ Home Manager
- ✅ Homebrew (if not present)
- ✅ ~180 CLI packages via Nix
- ✅ ~16 GUI apps via Homebrew Casks
- ✅ macOS system defaults applied
- ✅ Dotfiles generated (~/.zshrc, ~/.gitconfig, etc.)

### 5.3 Expected Warnings (Safe to Ignore)

You may see:
```
warning: Homebrew is not installed
```
→ Normal, Homebrew will be installed automatically

```
warning: Git config being overwritten
```
→ Normal, Home Manager manages Git config

### 5.4 Build Completion

**Success looks like:**
```
setting up /Applications/Nix Apps...
setting up Homebrew...
Installing cask aerospace...
Installing cask ghostty...
...
nix-darwin activation complete
```

**If build fails:** See Troubleshooting section below

---

## Phase 6: Verify Installation (5 minutes)

### 6.1 Reload Shell

```bash
# Restart shell to load new environment
exec zsh

# You should now see Powerlevel10k prompt
# (or Starship if you chose that)
```

### 6.2 Verify Nix-Managed Tools

```bash
# Check key development tools
which git
# Should output: /nix/store/...-git-2.x.x/bin/git

which gh
# Should output: /nix/store/...-gh-2.x.x/bin/gh

which kubectl
# Should output: /nix/store/...-kubectl-1.x.x/bin/kubectl

which terraform
# Should output: /nix/store/...-terraform-1.x.x/bin/terraform

# Check versions
git --version
kubectl version --client
terraform version
```

### 6.3 Verify Homebrew Casks

```bash
# List installed GUI apps
brew list --cask

# Should show:
# 1password-cli
# aerospace
# font-hack-nerd-font
# gcloud-cli
# ghostty
# ... etc
```

### 6.4 Verify macOS Defaults

```bash
# Check Dock settings
defaults read com.apple.dock autohide
# Should output: 1

defaults read com.apple.dock autohide-delay
# Should output: 0

# Check Finder settings
defaults read NSGlobalDomain AppleShowAllExtensions
# Should output: 1

defaults read com.apple.finder FXPreferredViewStyle
# Should output: Nlsv

# Check keyboard settings
defaults read NSGlobalDomain NSAutomaticCapitalizationEnabled
# Should output: 0

defaults read NSGlobalDomain NSAutomaticSpellingCorrectionEnabled
# Should output: 0
```

### 6.5 Visual Verification

**You should see:**
- ✅ Dock auto-hides when you move mouse away
- ✅ Finder shows file extensions (e.g., "document.txt" not "document")
- ✅ Finder in list view by default
- ✅ Caps Lock acts as Control key
- ✅ No auto-correct in text fields

**Restart Dock/Finder if needed:**
```bash
killall Dock
killall Finder
```

---

## Phase 7: Post-Install Configuration (10 minutes)

### 7.1 Generate SSH Keys

```bash
# Generate new Ed25519 key
ssh-keygen -t ed25519 -C "jschuhmann@salesforce.com"

# Press Enter to accept default location (~/.ssh/id_ed25519)
# Enter passphrase (recommended) or press Enter for none

# Start ssh-agent
eval "$(ssh-agent -s)"

# Add key to agent
ssh-add ~/.ssh/id_ed25519

# Copy public key to clipboard
cat ~/.ssh/id_ed25519.pub | pbcopy

# Add to GitHub
# Visit: https://github.com/settings/keys
# Click "New SSH key"
# Paste and save
```

**Test SSH to GitHub:**
```bash
ssh -T git@github.com
# Should output: Hi YOUR-USERNAME! You've successfully authenticated...
```

### 7.2 Configure GPG (Optional - for commit signing)

```bash
# Generate GPG key
gpg --full-generate-key

# Choose:
# - Kind: (1) RSA and RSA
# - Key size: 4096
# - Expiration: 0 (does not expire) or your preference
# - Name: Josh Schuhmann
# - Email: jschuhmann@salesforce.com

# List keys
gpg --list-secret-keys --keyid-format=long

# Output will show:
# sec   rsa4096/ABCDEF1234567890 2024-01-01 [SC]
#                ^^^^^^^^^^^^^^^^ ← This is your key ID

# Export public key
gpg --armor --export ABCDEF1234567890

# Copy output and add to GitHub:
# https://github.com/settings/keys → New GPG key

# Enable commit signing
vim ~/github/nixos/home.nix
```

Uncomment these lines in `home.nix`:
```nix
extraConfig = {
  # ...
  commit.gpgsign = true;
  user.signingkey = "ABCDEF1234567890";  # ← Your key ID
};
```

Rebuild:
```bash
darwin-rebuild switch --flake ~/github/nixos#jschuhmann-macbook
```

### 7.3 Configure Cloud CLIs

**AWS:**
```bash
aws configure
# Enter: Access Key ID, Secret Access Key, Region, Output format
```

**Azure:**
```bash
az login
# Follow browser prompts
```

**Google Cloud:**
```bash
gcloud init
# Follow prompts to authenticate and select project
```

### 7.4 Grant Accessibility Permissions

Some apps require accessibility permissions:

1. **Aerospace** (window tiling)
   - Open Aerospace
   - System Settings → Privacy & Security → Accessibility
   - Enable Aerospace

2. **Rectangle** (window management)
   - Open Rectangle
   - Grant accessibility permissions when prompted

3. **gSwitch** (GPU switching)
   - May require restart after granting permissions

---

## Phase 8: Data Migration (Optional, Varies)

### Option A: Time Machine Restore

```bash
# Connect Time Machine backup drive

# Open Migration Assistant
# Applications → Utilities → Migration Assistant

# Choose "From a Mac, Time Machine backup, or startup disk"
# Select specific files/folders to migrate
```

### Option B: Manual File Transfer

**Via USB Drive:**
```bash
# On old Mac: Copy files to USB
cp -R ~/Documents ~/Projects /Volumes/USB_DRIVE/

# On new Mac: Copy from USB
cp -R /Volumes/USB_DRIVE/Documents ~/
cp -R /Volumes/USB_DRIVE/Projects ~/
```

**Via rsync (network):**
```bash
# On new Mac: Get IP address
ifconfig | grep "inet " | grep -v 127.0.0.1

# On old Mac: Sync files
rsync -avz --progress \
  ~/Documents/ ~/Projects/ ~/Pictures/ \
  jschuhmann@NEW-MAC-IP:~/
```

### Option C: Cloud Sync

```bash
# Clone repositories
cd ~/Projects
git clone git@github.com:you/repo1.git
git clone git@github.com:you/repo2.git

# Restore from cloud backup (Dropbox, Google Drive, etc.)
# Download files from cloud service
```

### Files to Migrate

**Essential:**
- `~/Documents/`
- `~/Projects/` or `~/code/`
- `~/.ssh/` (if not generating new keys)
- `~/.gnupg/` (GPG keys)
- `~/.aws/` (AWS credentials)
- `~/.kube/` (Kubernetes configs)

**Optional:**
- `~/Pictures/`
- `~/Downloads/`
- `~/Desktop/`
- Application-specific data

---

## 🚨 Troubleshooting

### Issue: Nix command not found after install

**Solution:**
```bash
# Manually source Nix
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Restart terminal
exec zsh

# If still not working, check installation
ls -la /nix/
```

### Issue: darwin-rebuild fails with "permission denied"

**Solution:**
```bash
# Ensure you're an admin user
groups | grep admin

# If not in admin group:
# System Settings → Users & Groups → Unlock → Your User → Check "Allow user to administer this computer"
```

### Issue: Homebrew cask fails to install

**Example:** `gswitch` or `aerospace` fail

**Solution:**
```bash
# Install problematic cask manually
brew install --cask gswitch

# Grant permissions when prompted
# Then retry darwin-rebuild
darwin-rebuild switch --flake ~/github/nixos#jschuhmann-macbook
```

### Issue: Architecture mismatch error

**Error:** `system 'aarch64-darwin' required by ... but I am 'x86_64-darwin'`

**Solution:**
```bash
# Check actual architecture
uname -m

# Update config.nix to match
vim ~/github/nixos/config.nix

# Change architecture to:
# "aarch64-darwin"  # for arm64 (Apple Silicon)
# "x86_64-darwin"   # for x86_64 (Intel)
```

### Issue: Build takes extremely long

**Expected:** 20-40 minutes first build

**If stuck > 1 hour:**
```bash
# Cancel (Ctrl+C) and check logs
darwin-rebuild switch --flake ~/github/nixos#jschuhmann-macbook --show-trace

# Check internet connection
ping cache.nixos.org

# Try building without Homebrew first
# Comment out homebrew section in flake.nix temporarily
```

### Issue: macOS defaults not applying

**Solution:**
```bash
# Manually reload Dock and Finder
killall Dock
killall Finder

# Or reboot the Mac
sudo reboot

# After reboot, verify again
defaults read com.apple.dock autohide
```

### Issue: Git commit signing fails

**Error:** `gpg: signing failed: No secret key`

**Solution:**
```bash
# List GPG keys
gpg --list-secret-keys --keyid-format=long

# Ensure key ID in home.nix matches
vim ~/github/nixos/home.nix

# Set GPG_TTY
export GPG_TTY=$(tty)

# Test signing
echo "test" | gpg --clearsign
```

---

## 📊 Setup Timeline Summary

| Phase | Task | Duration | Skippable? |
|-------|------|----------|------------|
| 1 | macOS Setup & Updates | 10 min | No |
| 2 | Clone Repository | 2 min | No |
| 3 | Customize Config | 5 min | No |
| 4 | Install Nix | 10 min | No |
| 5 | Bootstrap nix-darwin | 20-40 min | No |
| 6 | Verify Installation | 5 min | No |
| 7 | Post-Install (SSH, GPG, Cloud) | 10 min | Partial |
| 8 | Data Migration | Varies | Yes |
| **Total** | **~60-80 min** | **(+ migration time)** |

---

## ✅ Setup Complete Checklist

Your setup is complete when:

- ✅ `nix --version` shows version number
- ✅ `which git` points to `/nix/store/...`
- ✅ `brew list --cask` shows GUI apps
- ✅ Dock auto-hides with no delay
- ✅ Finder shows file extensions in list view
- ✅ No auto-correct in text fields
- ✅ Caps Lock acts as Control
- ✅ SSH to GitHub works: `ssh -T git@github.com`
- ✅ Git commits show your name/email from config
- ✅ Cloud CLIs authenticated (AWS, Azure, GCP)

---

## 🎯 Quick Reference Card

**Save this for setup day:**

```bash
# 1. Install Xcode CLI Tools
xcode-select --install

# 2. Clone repo
mkdir -p ~/github && cd ~/github
git clone git@github.com:YOUR-USERNAME/nixos.git
cd nixos

# 3. Validate
./validate.sh

# 4. Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install

# 5. Restart terminal, then bootstrap
exec zsh
nix run nix-darwin -- switch --flake .#jschuhmann-macbook

# 6. Reload shell
exec zsh

# 7. Verify
which git gh kubectl
brew list --cask
```

---

## 🔄 After Setup: Daily Operations

### Update Packages
```bash
cd ~/github/nixos
nix flake update
darwin-rebuild switch --flake .#jschuhmann-macbook
```

### Add New Package
```bash
vim ~/github/nixos/home.nix
# Add to home.packages: newPackage

darwin-rebuild switch --flake .#jschuhmann-macbook
```

### Change System Settings
```bash
vim ~/github/nixos/flake.nix
# Modify system.defaults.*

darwin-rebuild switch --flake .#jschuhmann-macbook
```

### Rollback Changes
```bash
darwin-rebuild --rollback
```

### View System Generations
```bash
darwin-rebuild --list-generations
```

---

## 📚 Additional Resources

- **INSTALL.md** - Detailed installation guide
- **COMMANDS.md** - Command reference
- **MODULAR_STRUCTURE.md** - Architecture documentation
- **config.nix** - Your personal settings (edit this!)
- **flake.nix** - System configuration (macOS defaults)
- **home.nix** - User configuration (packages, shell)

---

## 💾 Backup Your Configuration

After successful setup, commit any changes:

```bash
cd ~/github/nixos

# Stage all files
git add .

# Commit with setup date
git commit -m "Setup complete on new MacBook - $(date +%Y-%m-%d)"

# Push to GitHub
git push origin main
```

Now you can clone this configuration on any future Mac! 🎉

---

**Last Updated:** 2026-07-01  
**Tested On:** macOS 26.5.1 (Apple Silicon)  
**Estimated Total Time:** 60-80 minutes + data migration
