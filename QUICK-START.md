# Quick Start Guide

## Installation (3 steps)

### 1. Review Configuration
```bash
cd ~/github/nixos

# Edit these files with your personal info:
# - flake.nix: Change username if not 'jschuhmann'
# - home.nix: Update Git user.name and user.email
```

### 2. Run Installation Script
```bash
./install.sh
```

Or manually:
```bash
nix run home-manager/master -- switch --flake .#jschuhmann
```

### 3. Restart Shell
```bash
exec zsh
# Or just close and reopen your terminal
```

## Daily Usage

### Update All Packages
```bash
cd ~/github/nixos
nix flake update
home-manager switch --flake .#jschuhmann
```

### Add New Package
```bash
# 1. Search for package
nix search nixpkgs <package-name>

# 2. Add to home.nix under home.packages
# 3. Apply changes
home-manager switch --flake ~/github/nixos#jschuhmann
```

### Rollback Changes
```bash
home-manager generations
home-manager switch --switch-generation <number>
```

## What You Get

### Shell Enhancements
- **Zsh** with Powerlevel10k theme
- **Modern CLI tools**: `rg` (grep), `fd` (find), `bat` (cat)
- **Smart navigation**: `zoxide` (cd on steroids)
- **Auto-completion** and syntax highlighting

### Development Tools
- Git, GitHub CLI, Neovim with full configuration
- Python 3.10-3.13, Node.js 24, Go, Java, Scala, Zig
- Poetry, pipx, black, ruff for Python
- Docker alternatives: Podman

### Cloud & Infrastructure
- **AWS**: `aws`, `aws-iam-authenticator`
- **Azure**: `az`
- **Kubernetes**: `kubectl`, `helm`, `k9s`, `stern`
- **Terraform**: `terraform`, `terraform-ls`, `tflint`
- **Others**: Vault, Temporal, QEMU

### DevOps
- CI/CD: pack, conftest, pre-commit
- Monitoring: Redis, watch, watchman
- Container analysis: dive
- Service mesh: grpcurl

## Common Commands

### Home Manager
```bash
# Apply configuration changes
home-manager switch

# List previous generations
home-manager generations

# Rollback to previous generation
home-manager switch --switch-generation <number>

# Show what will change (dry run)
home-manager build

# Clean old generations
nix-collect-garbage -d
```

### Nix Package Management
```bash
# Search for packages
nix search nixpkgs <name>

# Try a package without installing
nix shell nixpkgs#<package>

# Run a command from a package once
nix run nixpkgs#<package>

# Update flake inputs
nix flake update

# Show package information
nix eval nixpkgs#<package>.meta
```

### Git Workflow (Enhanced)
```bash
# Your Git is now configured with delta for diffs
git diff  # Beautiful syntax-highlighted diffs

# Git LFS is enabled
git lfs install

# GitHub CLI available
gh pr list
gh repo view
```

### Shell Aliases (Pre-configured)
```bash
# Modern replacements
cat → bat         # Syntax-highlighted cat
grep → rg         # Fast grep (ripgrep)
find → fd         # Fast find

# Git shortcuts
gs → git status
gd → git diff
gc → git commit
gp → git push
gl → git log --oneline --graph --all

# Kubernetes
k → kubectl
```

### Directory Navigation
```bash
# Use zoxide for smart directory jumping
z <partial-name>  # Jump to frequently used directory

# Examples:
z nixos           # cd ~/github/nixos
z config          # cd ~/.config (if frequently used)

# Regular navigation
.. → cd ..
... → cd ../..
```

## Configuration Customization

### File Structure
```
~/github/nixos/
├── flake.nix        # Nix flake configuration (entry point)
├── home.nix         # Main Home Manager configuration
├── README.md        # Full documentation
├── MIGRATION.md     # Detailed migration checklist
├── QUICK-START.md   # This file
└── install.sh       # Installation script
```

### Common Customizations

#### Add a New Package
Edit `home.nix`:
```nix
home.packages = with pkgs; [
  # ... existing packages
  your-new-package
];
```

#### Change Git Configuration
Edit `home.nix`:
```nix
programs.git = {
  userName = "Your Name";
  userEmail = "your.email@example.com";
  # ... other options
};
```

#### Add Shell Alias
Edit `home.nix`:
```nix
programs.zsh = {
  shellAliases = {
    # ... existing aliases
    myalias = "your-command";
  };
};
```

#### Enable GPG Commit Signing
Edit `home.nix`, uncomment:
```nix
programs.git = {
  extraConfig = {
    commit.gpgsign = true;
    user.signingkey = "YOUR_GPG_KEY_ID";
  };
};
```

## Troubleshooting

### Command not found
**Solution**: Restart shell or run:
```bash
source ~/.zshrc
```

### Wrong tool version
**Solution**: Check which version is being used:
```bash
which <command>
# Should show: /Users/jschuhmann/.nix-profile/bin/<command>
```

### Installation fails
**Solution**: Check these:
1. Username matches in `flake.nix` and `home.nix`
2. Architecture matches your Mac (aarch64 vs x86_64)
3. Nix flakes are enabled

### Need to rollback
**Solution**:
```bash
home-manager generations
home-manager switch --switch-generation <number>
```

## Migration from Homebrew

### Gradual Migration (Recommended)
1. Keep Homebrew installed
2. Install Home Manager (Nix tools take precedence)
3. Test your workflow
4. Optionally remove Homebrew duplicates later

### Quick Migration
```bash
# List what Homebrew has
brew list --formula

# Remove Homebrew duplicates (after verifying Nix tools work)
brew uninstall git gh kubectl terraform awscli python@3.13 go node
```

### Keep Homebrew for GUI Apps
Nix is great for CLI tools. Keep Homebrew for:
- GUI applications (Homebrew Casks)
- Tools not in nixpkgs
- Company-specific tools

## Key Differences from Homebrew

| Aspect | Homebrew | Nix/Home Manager |
|--------|----------|------------------|
| Config | Implicit (brew list) | Declarative (home.nix) |
| Rollback | ❌ No | ✅ Yes |
| Multiple versions | Complex | Easy |
| Reproducible | ❌ No | ✅ Yes |
| Updates | In-place | Atomic |
| State | Global | Per-user |

## Next Steps

1. **Customize** `home.nix` for your needs
2. **Test** your development workflow
3. **Learn** Nix language for advanced configs
4. **Share** configuration across machines (Git sync)
5. **Explore** [Home Manager options](https://nix-community.github.io/home-manager/options.html)

## Resources

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/packages)
- [Nix Language Tutorial](https://nixos.org/guides/nix-language.html)
- [Zero to Nix](https://zero-to-nix.com/) - Modern Nix guide

## Getting Help

- Search packages: `nix search nixpkgs <name>`
- Check Home Manager options: [Search options](https://home-manager-options.extranix.com/)
- NixOS Discourse: https://discourse.nixos.org/
- Nix Discord: https://discord.gg/RbvHtGa

---

**Quick Reference**: This guide covers 80% of daily usage.
For detailed information, see `README.md` and `MIGRATION.md`.
