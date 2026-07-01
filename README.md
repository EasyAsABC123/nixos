# Nix Home Manager Configuration for macOS

This repository contains a declarative Home Manager configuration that replaces Homebrew-managed CLI tools with Nix-managed equivalents.

## What's Included

### Shell Configuration
- **Zsh** with Powerlevel10k theme
- **Starship** prompt (alternative to P10k, currently disabled)
- Shell aliases for modern CLI tools
- Zoxide for smart directory jumping
- Direnv for per-directory environment variables

### Development Tools
- **Programming Languages**: Go, Node.js 24, Python (3.10-3.13), Java, Scala, Zig
- **Python Tools**: Poetry, pipx, pyenv, black, ruff, tox, uv
- **Version Managers**: jenv, nvm, tfenv, direnv

### Cloud & Infrastructure
- **AWS**: awscli2, aws-iam-authenticator
- **Azure**: azure-cli
- **Kubernetes**: kubectl, helm, k9s, stern, kubebuilder, kubeconform
- **Terraform**: terraform, terraform-ls, tflint
- **Other**: Vault, Temporal, QEMU, Podman

### DevOps & Monitoring
- Redis, pack, conftest, pre-commit
- Container tools: dive, vhs
- Networking: grpcurl, openvpn

### Modern CLI Utilities
- **Replacements**: ripgrep (grep), fd (find), bat (cat)
- **Utilities**: jq, yq, zoxide, tree, glow
- **File Transfer**: rclone, wget, curl
- **Git Tools**: git-lfs, git-filter-repo, bfg-repo-cleaner

### Development Utilities
- Formatters: shfmt, shellcheck, clang-format
- Build tools: just, cmake
- Testing: shellspec
- Code generation: protobuf, openapi-generator, swagger-codegen

### Security & Operations
- Security scanning: snyk, trivy
- SSH & Auth: sshpass, gnupg, pinentry

### Specialized Tools
- Databases: PostgreSQL 15, SQLite
- AI/ML: llama-cpp
- Media: ffmpeg, ghostscript
- Various utilities: renovate, heroku, caddy, task, and more

## Installation

### Prerequisites

1. **Install Nix** (if not already installed):
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

   Or use the official installer:
   ```bash
   sh <(curl -L https://nixos.org/nix/install)
   ```

2. **Enable Nix Flakes** (add to `~/.config/nix/nix.conf` or `/etc/nix/nix.conf`):
   ```
   experimental-features = nix-command flakes
   ```

### Setup Home Manager

1. **Clone this repository** (if you haven't already):
   ```bash
   cd ~/github/nixos
   ```

2. **Review and customize** `home.nix`:
   - Update `home.username` and `home.homeDirectory`
   - Configure Git user name and email
   - Adjust SSH configuration for your keys
   - Review and modify aliases as needed

3. **Review and customize** `flake.nix`:
   - Change the homeConfigurations username from `jschuhmann` to your username
   - Update the architecture: `aarch64-darwin` (Apple Silicon) or `x86_64-darwin` (Intel)

4. **Build and activate** the configuration:
   ```bash
   nix run home-manager/master -- switch --flake .#jschuhmann
   ```

   Replace `jschuhmann` with your username as configured in `flake.nix`.

5. **For subsequent updates**, use:
   ```bash
   home-manager switch --flake ~/github/nixos#jschuhmann
   ```

## Migration Strategy

### What's Already Covered
The Home Manager configuration includes Nix equivalents for most of your Homebrew CLI tools. These tools are now declaratively managed in `home.nix`.

### What's Excluded (Intentionally)

**Library Dependencies** - Not included because they're typically pulled in automatically:
- All `lib*` packages (libusb, libpng, libiconv, etc.)
- Build-time dependencies (cairo, gtk+3, harfbuzz, etc.)
- These are handled automatically by Nix when you install packages that need them

**Embedded Development Toolchains** - Commented out but available:
- ARM/AVR cross-compilation toolchains
- Uncomment the relevant lines in `home.nix` if you need embedded development

### Gradual Migration Approach

You don't need to uninstall Homebrew immediately. Here's a phased approach:

#### Phase 1: Test Nix Tools (Current)
1. Keep Homebrew installed
2. Activate Home Manager configuration
3. Test Nix-managed tools alongside Homebrew versions
4. Nix tools will take precedence in your PATH

#### Phase 2: Remove Homebrew Duplicates (Optional)
Once you're confident Nix is working:
```bash
# List Homebrew formulas that duplicate Nix packages
brew list

# Uninstall specific Homebrew packages
brew uninstall git gh kubectl terraform python@3.13
# ... continue with others as needed

# Or remove all formulas at once (CAUTION!)
brew list --formula | xargs brew uninstall --ignore-dependencies
```

#### Phase 3: Keep Homebrew for GUI Apps (Recommended)
Homebrew Casks are great for GUI applications. You might want to keep Homebrew just for:
- Homebrew Casks (GUI applications)
- Tools not available in nixpkgs
- Company-specific internal tools

## Managing Your Configuration

### Adding New Packages

1. Search for packages:
   ```bash
   nix search nixpkgs <package-name>
   ```

2. Add to `home.packages` in `home.nix`:
   ```nix
   home.packages = with pkgs; [
     # ... existing packages
     new-package-name
   ];
   ```

3. Apply changes:
   ```bash
   home-manager switch --flake ~/github/nixos#jschuhmann
   ```

### Updating Packages

Update all packages to latest versions:
```bash
cd ~/github/nixos
nix flake update
home-manager switch --flake .#jschuhmann
```

### Rolling Back Changes

If something breaks:
```bash
home-manager generations  # List previous generations
home-manager switch --switch-generation <number>
```

## Special Configurations

### Powerlevel10k
After first activation, configure Powerlevel10k:
```bash
p10k configure
```

The configuration will be saved to `~/.p10k.zsh` and automatically loaded.

### GPG Commit Signing
If you use GPG for commit signing:
1. Uncomment the GPG lines in the Git section of `home.nix`
2. Add your GPG key ID
3. Run `home-manager switch`

### Language Version Managers
The configuration includes version managers (pyenv, nvm, jenv, tfenv) for flexibility. However, Nix can also manage multiple versions declaratively. Consider using:
- `python310`, `python311`, `python312`, `python313` directly from Nix
- Node versions via `nodejs_20`, `nodejs_22`, `nodejs_24`

## Path Configuration

After activation, Nix tools will be available at:
- `~/.nix-profile/bin/` (Home Manager packages)
- Additional paths in `$HOME/.local/bin`, `$HOME/go/bin`, etc.

The Home Manager activation script automatically updates your shell profile.

## Troubleshooting

### Nix Command Not Found
Ensure Nix is in your PATH:
```bash
source ~/.nix-profile/etc/profile.d/nix.sh
```

Add to your shell profile if not already present.

### Home Manager Command Not Found
Use the full path initially:
```bash
nix run home-manager/master -- switch --flake .#jschuhmann
```

After first activation, `home-manager` command will be available.

### Conflicts with Homebrew
If you experience PATH conflicts:
1. Check your PATH order: `echo $PATH`
2. Nix paths should come before Homebrew paths
3. Adjust your shell profile if needed

### Package Not Found in nixpkgs
Search with variations:
```bash
nix search nixpkgs ripgrep
nix search nixpkgs rg
```

Package names in Nix sometimes differ from Homebrew names. Common mappings:
- `git-filter-repo` → `gitFilterRepo`
- `git-lfs` → `git-lfs`
- `gnu-tar` → `gnutar`

## Architecture Notes

### Homebrew → Nixpkgs Mappings

Most packages have 1:1 mappings, but some differ:

| Homebrew Formula | Nixpkgs Package | Notes |
|-----------------|----------------|-------|
| `kubernetes-cli` | `kubectl` | Different name |
| `heroku` | `heroku` | Same name |
| `gnu-tar` | `gnutar` | Hyphen → no hyphen |
| `git-filter-repo` | `gitFilterRepo` | CamelCase |
| `bfg` | `bfg-repo-cleaner` | Full name in Nix |
| `python@3.13` | `python313` | No @ symbol |

### Excluded Categories

1. **Library Dependencies**: Automatically managed by Nix
2. **Embedded Toolchains**: Commented out, uncomment if needed
3. **Hardware-Specific Tools**: Some tools like `teensy_loader_cli`, `mdloader` may require additional setup

## Next Steps

1. **Customize** the configuration to your preferences
2. **Test** that your development workflow works with Nix packages
3. **Gradually migrate** away from Homebrew formulas
4. **Keep Homebrew** for GUI apps (casks) if desired
5. **Commit** your configuration to Git for version control

## Resources

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/packages)
- [Nix Pills](https://nixos.org/guides/nix-pills/) - Learn Nix language
- [Determinate Systems](https://determinate.systems/) - Modern Nix installer

## Contributing

Feel free to customize this configuration for your needs. Consider:
- Adding program-specific configurations under `programs.*`
- Creating module files for complex setups
- Sharing your customizations with others

---

Generated from Homebrew formulas on 2026-07-01
