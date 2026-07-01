# Quick Command Reference

Essential commands for managing your Nix-on-macOS system.

## Daily Operations

### Rebuild System

```bash
# Full system rebuild (system + user)
darwin-rebuild switch --flake ~/github/nixos#jschuhmann-macbook

# Shorthand (from within nixos directory)
cd ~/github/nixos
darwin-rebuild switch --flake .#jschuhmann-macbook

# Dry run (see what would change)
darwin-rebuild build --flake .#jschuhmann-macbook
```

### Update Packages

```bash
# Update all flake inputs (nixpkgs, nix-darwin, home-manager)
cd ~/github/nixos
nix flake update

# Update specific input only
nix flake lock --update-input nixpkgs

# Then rebuild to apply updates
darwin-rebuild switch --flake .#jschuhmann-macbook
```

### Home Manager (User Packages)

```bash
# Rebuild home configuration only
home-manager switch --flake ~/github/nixos#jschuhmann

# Check current generation
home-manager generations

# List installed packages
home-manager packages
```

## Package Management

### Search for Packages

```bash
# Search nixpkgs
nix search nixpkgs <package-name>

# Example: Search for kubectl
nix search nixpkgs kubectl

# Search with regex
nix search nixpkgs 'python.*tensorflow'
```

### Install Package Temporarily

```bash
# One-time shell with package
nix-shell -p <package-name>

# Example: Try a package before adding to config
nix-shell -p ripgrep
```

### Add Package Permanently

Edit `~/github/nixos/home.nix`:

```nix
home.packages = with pkgs; [
  # ... existing packages ...
  <new-package-name>
];
```

Then rebuild:
```bash
darwin-rebuild switch --flake ~/github/nixos#jschuhmann-macbook
```

## Homebrew Integration

### List Managed Casks

```bash
# Show all Homebrew casks
brew list --cask

# Show casks not in your config (will be removed on next rebuild)
brew list --cask | grep -v -f <(cat ~/github/nixos/flake.nix | grep '".*"' | tr -d ' "')
```

### Add New Cask

Edit `~/github/nixos/flake.nix`:

```nix
homebrew = {
  casks = [
    # ... existing casks ...
    "new-app-name"
  ];
};
```

Then rebuild (Homebrew will auto-install):
```bash
darwin-rebuild switch --flake ~/github/nixos#jschuhmann-macbook
```

## System Management

### View Generations

```bash
# List all system generations
darwin-rebuild --list-generations

# List home-manager generations
home-manager generations
```

### Rollback

```bash
# Rollback to previous generation
darwin-rebuild --rollback

# Rollback home-manager only
home-manager --rollback

# Switch to specific generation
darwin-rebuild switch --flake ~/github/nixos#jschuhmann-macbook --profile-name <generation-number>
```

### Garbage Collection

```bash
# Delete old generations (user)
nix-collect-garbage -d

# Delete old generations (system, requires sudo)
sudo nix-collect-garbage -d

# Delete generations older than 30 days
nix-collect-garbage --delete-older-than 30d

# Optimize store (deduplicate)
nix-store --optimise
```

### View Store Usage

```bash
# Total store size
du -sh /nix/store

# Number of paths in store
nix path-info --all | wc -l

# Size of specific package
nix path-info -S /nix/store/<package-hash>
```

## Troubleshooting

### Rebuild Errors

```bash
# Build without switching (test for errors)
darwin-rebuild build --flake ~/github/nixos#jschuhmann-macbook

# Show detailed error output
darwin-rebuild switch --flake ~/github/nixos#jschuhmann-macbook --show-trace

# Check Nix daemon status
sudo launchctl list | grep nix

# Restart Nix daemon
sudo launchctl kickstart -k system/org.nixos.nix-daemon
```

### Reset to Known-Good State

```bash
# Rollback to previous generation
darwin-rebuild --rollback

# Or rebuild from clean flake.lock
cd ~/github/nixos
rm flake.lock
nix flake update
darwin-rebuild switch --flake .#jschuhmann-macbook
```

### Fix Broken Symlinks

```bash
# Check for broken Home Manager symlinks
find ~ -maxdepth 3 -xtype l

# Remove and rebuild
rm ~/.zshrc ~/.gitconfig  # (example)
home-manager switch --flake ~/github/nixos#jschuhmann
```

### Clear Nix Cache

```bash
# Clear evaluation cache
rm -rf ~/.cache/nix

# Clear entire Nix cache (use with caution)
sudo rm -rf /nix/var/nix/db
sudo nix-store --init
```

## Configuration Editing

### Edit Files

```bash
# Edit system configuration
vim ~/github/nixos/flake.nix

# Edit user configuration
vim ~/github/nixos/home.nix

# Check syntax before building
nix flake check ~/github/nixos
```

### Test Configuration

```bash
# Dry-run build (no activation)
darwin-rebuild build --flake ~/github/nixos#jschuhmann-macbook

# Show what will change
darwin-rebuild switch --flake ~/github/nixos#jschuhmann-macbook --dry-run
```

## System Information

### Nix Environment

```bash
# Nix version
nix --version

# Current system
echo $NIX_PLATFORM

# Current generation link
ls -l /run/current-system
ls -l ~/.local/state/nix/profiles/home-manager
```

### Check Defaults

```bash
# Check macOS defaults applied
defaults read com.apple.dock autohide
defaults read com.apple.finder AppleShowAllExtensions
defaults read NSGlobalDomain AppleInterfaceStyle

# Check Touch ID for sudo
cat /etc/pam.d/sudo | grep pam_tid.so
```

## Advanced Operations

### Pin Package Version

In `home.nix`:

```nix
# Pin specific package version
let
  pinnedPkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/<commit-hash>.tar.gz";
    sha256 = "<sha256-hash>";
  }) {};
in {
  home.packages = [
    pinnedPkgs.somePackage
  ];
}
```

### Use Overlay

In `flake.nix`:

```nix
nixpkgs.overlays = [
  (final: prev: {
    myCustomPackage = prev.callPackage ./packages/my-package.nix {};
  })
];
```

### Cross-Compile

```bash
# Build for x86_64 on arm64
nix build --system x86_64-darwin ~/github/nixos#darwinConfigurations.jschuhmann-macbook.system
```

## Shell Aliases (Add to home.nix)

```nix
programs.zsh.shellAliases = {
  # Rebuild shortcuts
  rebuild = "darwin-rebuild switch --flake ~/github/nixos#jschuhmann-macbook";
  update = "cd ~/github/nixos && nix flake update && darwin-rebuild switch --flake .#jschuhmann-macbook";
  rollback = "darwin-rebuild --rollback";

  # Nix shortcuts
  nix-search = "nix search nixpkgs";
  nix-clean = "nix-collect-garbage -d && sudo nix-collect-garbage -d";
  nix-optimize = "nix-store --optimise";

  # List packages
  nix-list = "nix-env -qa";
  home-list = "home-manager packages";
};
```

## Git Workflow (for Configuration)

```bash
# Initialize git repo (if not already)
cd ~/github/nixos
git init
git add .
git commit -m "Initial nix-darwin configuration"

# Make changes and commit
vim flake.nix
git diff
git add flake.nix
git commit -m "Update dock settings"

# Push to remote (optional but recommended)
git remote add origin <your-repo-url>
git push -u origin main
```

## Useful Resources

- Search packages: https://search.nixos.org/packages
- Nix options: https://search.nixos.org/options
- Home Manager options: https://nix-community.github.io/home-manager/options.html
- nix-darwin options: https://daiderd.com/nix-darwin/manual/index.html
