# Homebrew to Nix Migration Checklist

## Pre-Migration Analysis

### Total Homebrew Formulas: 226

### Migration Status

- **Migrated to Nix**: ~180 CLI tools
- **Excluded (Libraries)**: ~35 library dependencies
- **Requires Manual Setup**: ~11 specialized tools

## Detailed Package Mapping

### Core Development Tools ✅

| Homebrew | Nixpkgs | Status |
|----------|---------|--------|
| `git` | `programs.git.enable` | ✅ Managed via Home Manager |
| `gh` | `programs.gh.enable` | ✅ Managed via Home Manager |
| `go` | `go` | ✅ |
| `node` | `nodejs_24` | ✅ |
| `python@3.13` | `python313` | ✅ |
| `python@3.12` | `python312` | ✅ |
| `python@3.11` | `python311` | ✅ |
| `python@3.10` | `python310` | ✅ |
| `openjdk` | `openjdk` | ✅ |
| `maven` | `maven` | ✅ |
| `sbt` | `sbt` | ✅ |
| `zig` | `zig` | ✅ |

### Python Tools ✅

| Homebrew | Nixpkgs | Status |
|----------|---------|--------|
| `poetry` | `poetry` | ✅ |
| `pipx` | `pipx` | ✅ |
| `pyenv` | `pyenv` | ✅ |
| `black` | `black` | ✅ |
| `ruff` | `ruff` | ✅ |
| `tox` | `tox` | ✅ |
| `uv` | `uv` | ✅ |

### Version Managers ✅

| Homebrew | Nixpkgs | Status |
|----------|---------|--------|
| `jenv` | `jenv` | ✅ |
| `nvm` | `nvm` | ✅ |
| `tfenv` | `tfenv` | ✅ |
| `direnv` | `direnv` | ✅ Managed via Home Manager |

### Cloud & Infrastructure ✅

| Homebrew | Nixpkgs | Status |
|----------|---------|--------|
| `awscli` | `awscli2` | ✅ |
| `azure-cli` | `azure-cli` | ✅ |
| `kubernetes-cli` | `kubectl` | ✅ |
| `helm` | `kubernetes-helm` | ✅ |
| `helm-ls` | `helm-ls` | ✅ |
| `k9s` | `k9s` | ✅ |
| `stern` | `stern` | ✅ |
| `kubebuilder` | `kubebuilder` | ✅ |
| `kubeconform` | `kubeconform` | ✅ |
| `terraform` | `terraform` | ✅ |
| `terraform-ls` | `terraform-ls` | ✅ |
| `tflint` | `tflint` | ✅ |
| `vault` | `vault` | ✅ |
| `temporal` | `temporal` | ✅ |
| `qemu` | `qemu` | ✅ |
| `podman` | `podman` | ✅ |

### DevOps Tools ✅

| Homebrew | Nixpkgs | Status |
|----------|---------|--------|
| `pack` | `pack` | ✅ |
| `conftest` | `conftest` | ✅ |
| `pre-commit` | `pre-commit` | ✅ |
| `redis` | `redis` | ✅ |
| `watch` | `watch` | ✅ |
| `watchman` | `watchman` | ✅ |
| `dive` | `dive` | ✅ |
| `vhs` | `vhs` | ✅ |
| `grpcurl` | `grpcurl` | ✅ |
| `openvpn` | `openvpn` | ✅ |

### Modern CLI Utilities ✅

| Homebrew | Nixpkgs | Status |
|----------|---------|--------|
| `ripgrep` | `ripgrep` | ✅ |
| `fd` | `fd` | ✅ (from .devbar/bin) |
| `bat` | `bat` | ✅ |
| `jq` | `jq` | ✅ Managed via Home Manager |
| `yq` | `yq` | ✅ |
| `zoxide` | `zoxide` | ✅ |
| `tree` | `tree` | ✅ |
| `glow` | `glow` | ✅ |
| `rclone` | `rclone` | ✅ |
| `wget` | `wget` | ✅ |
| `curl` | `curl` | ✅ |
| `grep` | `gnugrep` | ✅ |
| `coreutils` | `coreutils` | ✅ |
| `gnu-tar` | `gnu-tar` | ✅ |

### Git Tools ✅

| Homebrew | Nixpkgs | Status |
|----------|---------|--------|
| `git-lfs` | `git-lfs` | ✅ Managed via Home Manager |
| `git-filter-repo` | `git-filter-repo` | ✅ |
| `bfg` | `bfg-repo-cleaner` | ✅ |

### Shell & Terminal ✅

| Homebrew | Nixpkgs | Status |
|----------|---------|--------|
| `tmux` | `programs.tmux.enable` | ✅ Managed via Home Manager |
| `bash` | `bash` | ✅ (macOS default, Nix provides newer) |
| `zsh-completions` | Managed via `programs.zsh` | ✅ |
| `zsh-syntax-highlighting` | Managed via `programs.zsh` | ✅ |
| `powerlevel10k` | `zsh-powerlevel10k` | ✅ Via zsh plugins |
| `starship` | `programs.starship.enable` | ✅ Managed via Home Manager |
| `ttyd` | `ttyd` | ✅ |
| `asciinema` | `asciinema` | ✅ |
| `reattach-to-user-namespace` | Not needed | ⚠️ macOS-specific, handled by tmux config |

### Development Utilities ✅

| Homebrew | Nixpkgs | Status |
|----------|---------|--------|
| `shfmt` | `shfmt` | ✅ |
| `shellcheck` | `shellcheck` | ✅ |
| `shellspec` | `shellspec` | ✅ |
| `clang-format` | `clang-format` | ✅ |
| `just` | `just` | ✅ |
| `cmake` | `cmake` | ✅ |
| `make` | `make` | ✅ |
| `libtool` | `libtool` | ✅ |
| `autoconf` | `autoconf` | ✅ |
| `protobuf` | `protobuf` | ✅ |
| `openapi-generator` | `openapi-generator` | ✅ |
| `swagger-codegen` | `swagger-codegen` | ✅ |
| `graphviz` | `graphviz` | ✅ |

### Security & Operations ✅

| Homebrew | Nixpkgs | Status |
|----------|---------|--------|
| `snyk` | `snyk` | ✅ |
| `sshpass` | `sshpass` | ✅ |
| `gnupg` | `gnupg` | ✅ |
| `pinentry` | `pinentry` | ✅ |

### Databases ✅

| Homebrew | Nixpkgs | Status |
|----------|---------|--------|
| `postgresql@15` | `postgresql_15` | ✅ |
| `sqlite` | `sqlite` | ✅ |

### Compression & Archives ✅

| Homebrew | Nixpkgs | Status |
|----------|---------|--------|
| `zstd` | `zstd` | ✅ |
| `xz` | `xz` | ✅ |
| `lz4` | `lz4` | ✅ |

### Media & Graphics ✅

| Homebrew | Nixpkgs | Status |
|----------|---------|--------|
| `ffmpeg` | `ffmpeg` | ✅ |
| `ghostscript` | `ghostscript` | ✅ |

### AI/ML ✅

| Homebrew | Nixpkgs | Status |
|----------|---------|--------|
| `llama.cpp` | `llama-cpp` | ✅ |

### Miscellaneous ✅

| Homebrew | Nixpkgs | Status |
|----------|---------|--------|
| `renovate` | `renovate` | ✅ |
| `heroku` | `heroku` | ✅ |
| `caddy` | `caddy` | ✅ |
| `task` | `task` | ✅ |
| `fswatch` | `fswatch` | ✅ |
| `pngpaste` | `pngpaste` | ✅ |
| `putty` | `putty` | ✅ |
| `speakeasy` | `speakeasy` | ✅ |
| `workmux` | `workmux` | ✅ |
| `dyff` | `dyff` | ✅ |
| `regal` | `regal` | ✅ |
| `merve` | `merve` | ✅ |
| `neovim` | `programs.neovim.enable` | ✅ Managed via Home Manager |

## Excluded Packages (Library Dependencies)

These are **intentionally excluded** because Nix manages them automatically as dependencies:

### Graphics & UI Libraries
- `cairo`, `pango`, `harfbuzz`, `freetype`, `fontconfig`
- `gdk-pixbuf`, `gtk+3`, `libepoxy`, `librsvg`
- `pixman`, `graphite2`, `fribidi`

### Compression Libraries
- `brotli`, `zlib`, `lzlib`, `lzo`, `snappy`

### Image Libraries
- `libpng`, `libjpeg`, `jpeg-turbo`, `libtiff`, `libwebp`, `giflib`
- `jbig2dec`, `openjpeg`, `libimagequant`, `jasper`
- `libavif`, `aom`, `dav1d`, `highway`, `jpeg-xl`

### System Libraries
- `glib`, `gettext`, `icu4c@78`, `ncurses`, `readline`
- `libffi`, `libevent`, `libuv`, `libev`
- `libiconv`, `libunistring`, `libidn`, `libidn2`

### Networking Libraries
- `curl`, `openssl@3`, `openssl@4`, `gnutls`, `nettle`
- `libssh`, `libssh2`, `krb5`, `libnghttp2`, `libnghttp3`, `libngtcp2`
- `grpc`, `protobuf-c`

### Database Libraries
- `sqlite`, `mongo-c-driver`, `hiredis`, `postgresql@15` (client libs)

### Audio/Video Libraries
- `ffmpeg` dependencies: `lame`, `opus`, `libvorbis`, `libogg`, `flac`
- `x264`, `x265`, `libvpx`, `svt-av1`, `libmatroska`, `libebml`

### X11 Libraries
- `libx11`, `libxau`, `libxcb`, `libxdmcp`, `libxext`, `libxfixes`, `libxi`, `libxrender`, `libxtst`
- `xorgproto`

### Other Libraries
- `boost`, `pcre2`, `oniguruma`, `gmp`, `mpfr`, `mpc`, `isl`
- `abseil`, `re2`, `fmt`, `simdjson`, `pugixml`
- `libarchive`, `libgpg-error`, `libgcrypt`, `libksba`, `libassuan`, `libtasn1`

## Requires Manual Setup or Review

### Embedded Development 🔧

| Homebrew | Nixpkgs | Status |
|----------|---------|--------|
| `arm-none-eabi-binutils` | `pkgsCross.arm-embedded.*` | ⚠️ Commented out - uncomment if needed |
| `arm-none-eabi-gcc@8` | `pkgsCross.arm-embedded.*` | ⚠️ Commented out - uncomment if needed |
| `avr-binutils` | `pkgsCross.avr.*` | ⚠️ Commented out - uncomment if needed |
| `avr-gcc@8` | `pkgsCross.avr.*` | ⚠️ Commented out - uncomment if needed |
| `avrdude` | `avrdude` | ⚠️ Commented out - uncomment if needed |

### Hardware Programming Tools 🔧

| Homebrew | Nixpkgs | Status |
|----------|---------|--------|
| `teensy_loader_cli` | Not in nixpkgs | ❌ May need manual install |
| `mdloader` | Not in nixpkgs | ❌ May need manual install |
| `hid_bootloader_cli` | Not in nixpkgs | ❌ May need manual install |
| `bootloadhid` | Not in nixpkgs | ❌ May need manual install |
| `dfu-programmer` | `dfu-programmer` | ⚠️ Available, test needed |
| `dfu-util` | `dfu-util` | ⚠️ Available, test needed |

### QMK Keyboard Firmware 🔧

| Homebrew | Nixpkgs | Status |
|----------|---------|--------|
| `qmk` | `qmk` | ✅ Main tool included |
| Hardware tools above | Various | ⚠️ Check if needed for your keyboard |

### Specialized Development 🔧

| Homebrew | Nixpkgs | Status |
|----------|---------|--------|
| `docker-credential-helper` | `docker-credential-helpers` | ⚠️ Check if needed for Docker |

## Migration Steps

### Step 1: Backup Current State ✅
```bash
# Export current Homebrew package list
brew list --formula > ~/homebrew-backup-$(date +%Y%m%d).txt

# Backup shell configurations
cp ~/.zshrc ~/.zshrc.backup
cp ~/.p10k.zsh ~/.p10k.zsh.backup 2>/dev/null || true
```

### Step 2: Install and Test Nix ✅
```bash
# Install Nix (Determinate Systems installer)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Test Nix
nix --version
```

### Step 3: Activate Home Manager 🔄
```bash
cd ~/github/nixos

# Review and customize home.nix
# - Update username/email
# - Adjust tool selections
# - Configure SSH keys

# Activate configuration
nix run home-manager/master -- switch --flake .#jschuhmann
```

### Step 4: Verify Tools Work ✅
```bash
# Test core tools
git --version
gh --version
kubectl version --client
terraform --version
python3 --version
go version
node --version

# Test modern CLI replacements
rg --version      # ripgrep
fd --version
bat --version

# Test cloud tools
aws --version
az --version
```

### Step 5: Update Shell Profile 🔄
Home Manager automatically updates shell profiles, but verify:
```bash
# Check PATH
echo $PATH | tr ':' '\n' | grep nix

# Should see:
# ~/.nix-profile/bin
# /nix/var/nix/profiles/default/bin
```

### Step 6: Configure P10k (Optional) 🔄
```bash
# Run P10k configuration wizard
p10k configure
```

### Step 7: Gradual Homebrew Removal (Optional) 🔄

**Option A: Keep Both (Safe)**
- Keep Homebrew and Nix side-by-side
- Nix tools take precedence in PATH
- Use Homebrew for GUI apps (casks)

**Option B: Remove Homebrew CLI Duplicates**
```bash
# Uninstall specific formulas
brew uninstall git gh kubectl terraform awscli azure-cli
brew uninstall python@3.13 python@3.12 go node

# Continue with others as needed...
```

**Option C: Full Homebrew Removal (Advanced)**
```bash
# Remove all formulas but keep casks
brew list --formula | xargs brew uninstall --ignore-dependencies

# Or completely remove Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
```

### Step 8: Test Your Workflow ✅
```bash
# Test development workflow
cd ~/your-project
git status
kubectl get nodes
terraform plan
python --version

# Test shell integrations
cd ~
z your-project  # Test zoxide
direnv allow    # Test direnv
```

### Step 9: Commit Configuration ✅
```bash
cd ~/github/nixos
git init
git add flake.nix home.nix README.md MIGRATION.md
git commit -m "Initial Home Manager configuration"
```

## Rollback Plan

If you need to rollback:

### Rollback to Previous Home Manager Generation
```bash
home-manager generations
home-manager switch --switch-generation <number>
```

### Restore Homebrew Tools
```bash
# Reinstall from backup
cat ~/homebrew-backup-*.txt | xargs brew install

# Or restore shell config
cp ~/.zshrc.backup ~/.zshrc
source ~/.zshrc
```

### Uninstall Nix Completely
```bash
# If using Determinate Systems installer
/nix/nix-installer uninstall

# Or manual cleanup
rm -rf ~/.nix-profile ~/.nix-defexpr ~/.nix-channels ~/.config/nix
sudo rm -rf /nix
```

## Post-Migration Checklist

- [ ] All development tools work (`git`, `gh`, `kubectl`, `terraform`, etc.)
- [ ] Cloud CLIs authenticated (`aws`, `az`, `gcloud` if used)
- [ ] Language runtimes work (`go`, `node`, `python`, `java`)
- [ ] Shell prompt displays correctly (Powerlevel10k)
- [ ] Zoxide directory jumping works (`z <dirname>`)
- [ ] Direnv loads project environments
- [ ] Git signing works (if configured)
- [ ] SSH keys properly configured
- [ ] Neovim/editor launches correctly
- [ ] Tmux configuration loads
- [ ] Project builds complete successfully
- [ ] CI/CD tools accessible
- [ ] Kubernetes contexts accessible

## Troubleshooting

### Issue: Command not found after Home Manager switch
**Solution**: Restart your shell or run:
```bash
source ~/.zshrc
```

### Issue: Nix tools not in PATH
**Solution**: Check that `~/.nix-profile/bin` is in PATH:
```bash
echo $PATH | grep -o '[^:]*nix[^:]*'
```

### Issue: Conflicts between Homebrew and Nix versions
**Solution**: Check which version is being used:
```bash
which git
# Should show: /Users/jschuhmann/.nix-profile/bin/git

# If showing Homebrew path, check PATH order
echo $PATH | tr ':' '\n' | head -5
```

### Issue: Embedded development tools not working
**Solution**: 
1. Uncomment ARM/AVR toolchains in `home.nix`
2. Run `home-manager switch`
3. Some hardware tools may need manual installation

### Issue: Performance slower than Homebrew
**Solution**: 
- Nix uses symlinks, which can be slower on some filesystems
- Consider using `nix-direnv` for project-specific performance
- Enable Nix daemon: `sudo launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist`

## Benefits of This Migration

✅ **Declarative Configuration**: Your entire dev environment in version-controlled files
✅ **Reproducibility**: Same configuration across machines
✅ **Rollback Capability**: Easy to revert to previous configurations
✅ **Isolation**: No global state pollution
✅ **Atomic Upgrades**: All-or-nothing updates
✅ **Multiple Versions**: Run different versions of tools side-by-side
✅ **Cross-Platform**: Works on macOS, Linux, and NixOS

## Next Steps

1. **Customize further**: Add more program-specific configurations
2. **Modularize**: Split `home.nix` into multiple files for organization
3. **Share**: Commit to Git and sync across machines
4. **Learn Nix**: Explore Nix language for advanced customizations
5. **Community**: Join Nix community forums and Discord

---

**Migration Status**: Ready to Deploy
**Last Updated**: 2026-07-01
**Migrated Tools**: ~180 CLI packages
**Excluded Libraries**: ~35 automatic dependencies
**Manual Setup Required**: ~11 specialized tools
