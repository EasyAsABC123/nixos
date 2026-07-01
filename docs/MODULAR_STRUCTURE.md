# Modular Configuration Structure

This Nix-on-macOS configuration uses a clean, modular structure to avoid repetition and make configuration management easier.

## File Structure

```
~/github/nixos/
├── flake.nix              # Main entry point (nix-darwin configuration)
├── config.nix             # Centralized configuration variables
├── home.nix               # Home Manager user configuration
├── INSTALL.md             # Installation instructions
├── COMMANDS.md            # Quick reference commands
├── AGENT_SYNTHESIS.md     # Agent analysis report
└── .claude/agents/        # Agent personas documentation
```

## Configuration Flow

```
┌─────────────────┐
│   config.nix    │  ← Edit user/system variables HERE
└────────┬────────┘
         │ imports
         ├──────────────────────┐
         ▼                      ▼
┌─────────────────┐    ┌─────────────────┐
│   flake.nix     │    │    home.nix     │
│  (nix-darwin)   │───▶│ (Home Manager)  │
│                 │    │                 │
│ • System config │    │ • Shell (zsh)   │
│ • macOS defaults│    │ • Git config    │
│ • Homebrew      │    │ • ~180 packages │
│ • Nix daemon    │    │ • Dev tools     │
└─────────────────┘    └─────────────────┘
```

## Files Explained

### 1. `config.nix` - Configuration Variables

**Purpose**: Single source of truth for user and system configuration.

```nix
{
  user = {
    username = "jschuhmann";
    fullName = "Josh Schuhmann";
    email = "jschuhmann@salesforce.com";
    homeDirectory = "/Users/jschuhmann";
  };

  system = {
    hostname = "jschuhmann-macbook";
    architecture = "aarch64-darwin";  # or "x86_64-darwin"
    stateVersion = 5;
  };

  homeManager = {
    stateVersion = "24.05";
  };
}
```

**When to edit**: Any time you need to change your username, email, or system architecture.

### 2. `flake.nix` - System Configuration

**Purpose**: Defines nix-darwin system configuration (macOS defaults, Homebrew, system packages).

**Key sections**:
- **Inputs**: nixpkgs, nix-darwin, home-manager
- **Nix daemon**: Flakes, cache, garbage collection
- **Homebrew**: GUI apps and tools requiring code signing
- **macOS defaults**: Dock, Finder, keyboard, trackpad
- **Home Manager integration**: Passes `config` to `home.nix`

**Variables used from config.nix**:
- `config.user.username` - For trusted users
- `config.system.hostname` - For darwinConfigurations name
- `config.system.architecture` - For system and hostPlatform
- `config.system.stateVersion` - For nix-darwin state version

**When to edit**: 
- Add/remove Homebrew casks
- Change macOS system defaults (Dock size, key repeat, etc.)
- Modify system-level packages

### 3. `home.nix` - User Configuration

**Purpose**: Defines Home Manager configuration (shell, CLI tools, user packages).

**Key sections**:
- **Shell**: Zsh with Powerlevel10k, aliases, completions
- **Git**: Username, email, delta diff viewer, LFS
- **Development tools**: ~180 packages (Go, Node, Python, AWS, Kubernetes, etc.)
- **Program modules**: tmux, neovim, ssh, fzf, htop
- **Environment variables**: EDITOR, GOPATH, PATH

**Variables used from config.nix**:
- `userConfig.user.username` - For home.username
- `userConfig.user.fullName` - For git.userName
- `userConfig.user.email` - For git.userEmail
- `userConfig.user.homeDirectory` - For home.homeDirectory
- `userConfig.homeManager.stateVersion` - For home.stateVersion

**When to edit**:
- Add/remove CLI packages
- Configure shell aliases
- Update Git/SSH settings
- Add program-specific configurations

## Benefits of This Structure

### 1. **No Repetition**
```nix
# Before (repetitive):
home.username = "jschuhmann";
git.userName = "Josh Schuhmann";
trusted-users = [ "jschuhmann" ];

# After (DRY):
# All these pull from config.nix automatically
```

### 2. **Easy Multi-Machine Support**

For a second machine, just create `config-work.nix`:

```nix
{
  user = {
    username = "josh";
    fullName = "Josh Schuhmann";
    email = "josh@work.com";
    homeDirectory = "/Users/josh";
  };
  
  system = {
    hostname = "josh-work-macbook";
    architecture = "x86_64-darwin";  # Intel Mac
    stateVersion = 5;
  };
  
  homeManager.stateVersion = "24.05";
}
```

Then in `flake.nix`:

```nix
let
  config = import ./config.nix;       # Personal Mac
  configWork = import ./config-work.nix;  # Work Mac
in {
  darwinConfigurations = {
    "${config.system.hostname}" = darwin.lib.darwinSystem { ... };
    "${configWork.system.hostname}" = darwin.lib.darwinSystem { ... };
  };
}
```

### 3. **Type Safety**

All variables are defined in one place, making typos impossible:

```nix
# Typo in traditional approach (silent failure):
home.username = "jschuhman";  # Oops, missing 'n'

# Modular approach (error at build time):
config.user.usernmae  # Build fails immediately
```

### 4. **Clear Separation of Concerns**

- `config.nix` → **What** (your personal data)
- `flake.nix` → **System** (macOS configuration)
- `home.nix` → **User** (your tools and shell)

## Usage Examples

### Initial Setup

```bash
# 1. Edit your personal information
vim ~/github/nixos/config.nix

# 2. Build and activate
cd ~/github/nixos
darwin-rebuild switch --flake .#jschuhmann-macbook
```

### Change Your Email

```bash
# 1. Edit config.nix
vim ~/github/nixos/config.nix
# Change: email = "new-email@example.com"

# 2. Rebuild (Git config updates automatically)
darwin-rebuild switch --flake .#jschuhmann-macbook
```

### Add a New Package

```bash
# 1. Edit home.nix
vim ~/github/nixos/home.nix
# Add to home.packages: newPackage

# 2. Rebuild
darwin-rebuild switch --flake .#jschuhmann-macbook
```

### Change Hostname

```bash
# 1. Edit config.nix
vim ~/github/nixos/config.nix
# Change: hostname = "new-hostname"

# 2. Rebuild with NEW hostname
darwin-rebuild switch --flake .#new-hostname
```

## Variable Passing Mechanism

### From config.nix to flake.nix

```nix
# In flake.nix
let
  config = import ./config.nix;
in {
  darwinConfigurations.${config.system.hostname} = darwin.lib.darwinSystem {
    # config is available here
    system = config.system.architecture;
    
    modules = [
      ({ pkgs, ... }: {
        # config is available here too
        trusted-users = [ config.user.username ];
      })
    ];
  };
}
```

### From flake.nix to home.nix

```nix
# In flake.nix
home-manager = {
  extraSpecialArgs = { inherit config; };  # Pass config to home.nix
  users.${config.user.username} = import ./home.nix;
};

# In home.nix
{ config, pkgs, config: userConfig, ... }:  # Rename to avoid collision
{
  home.username = userConfig.user.username;  # Use passed config
  programs.git.userName = userConfig.user.fullName;
}
```

**Note**: We rename `config` to `userConfig` in `home.nix` to avoid collision with the built-in `config` attribute.

## Architecture-Specific Notes

### Apple Silicon (M1/M2/M3/M4)

```nix
system = {
  architecture = "aarch64-darwin";
};
```

### Intel Mac

```nix
system = {
  architecture = "x86_64-darwin";
};
```

## Troubleshooting

### "error: infinite recursion encountered"

**Cause**: Variable naming collision (e.g., `config` used twice)

**Fix**: Rename the imported config in function arguments:
```nix
{ config, pkgs, config: userConfig, ... }:
```

### "error: attribute 'user' missing"

**Cause**: `config.nix` not properly imported

**Fix**: Ensure `let config = import ./config.nix;` is at the top of `outputs` in `flake.nix`

### Build fails after changing hostname

**Cause**: Using old hostname in rebuild command

**Fix**: Use new hostname:
```bash
darwin-rebuild switch --flake .#NEW-HOSTNAME
```

## Advanced: Multiple Configurations

### Personal + Work Setup

```nix
# flake.nix
let
  mkDarwinSystem = configFile: darwin.lib.darwinSystem {
    let config = import configFile; in
    {
      system = config.system.architecture;
      modules = [ /* shared modules */ ];
    };
  };
in {
  darwinConfigurations = {
    personal = mkDarwinSystem ./config.nix;
    work = mkDarwinSystem ./config-work.nix;
  };
}
```

### Shared + Machine-Specific

```
config-shared.nix      # Common settings
config-personal.nix    # Imports shared + overrides
config-work.nix        # Imports shared + overrides
```

## Migration from Non-Modular Setup

If you have an existing non-modular configuration:

1. **Extract variables to config.nix**:
   ```bash
   grep -r "jschuhmann" *.nix  # Find all hardcoded values
   ```

2. **Update flake.nix**:
   - Add `let config = import ./config.nix;`
   - Replace hardcoded values with `config.user.username`, etc.

3. **Update home.nix**:
   - Rename function arg: `config: userConfig`
   - Replace hardcoded values with `userConfig.user.username`, etc.

4. **Test**:
   ```bash
   nix flake check
   darwin-rebuild build --flake .#YOUR-HOSTNAME
   ```

## Future Enhancements

Potential improvements to the modular structure:

1. **Separate module files**: Split `home.nix` into `shell.nix`, `git.nix`, `packages.nix`
2. **Shared configurations**: Create `shared/` directory for common settings
3. **Machine-specific overrides**: `machines/personal.nix`, `machines/work.nix`
4. **Package groups**: `packages/dev.nix`, `packages/devops.nix`, `packages/cloud.nix`
5. **Secrets management**: Add `agenix` or `sops-nix` for encrypted values

## Resources

- [Nix language basics](https://nixos.org/guides/nix-language.html)
- [nix-darwin options](https://daiderd.com/nix-darwin/manual/index.html)
- [Home Manager options](https://nix-community.github.io/home-manager/options.html)
- [Nix module system](https://nixos.wiki/wiki/NixOS_modules)
