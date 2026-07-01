# Multi-Machine Configuration Guide

This repository supports multiple machines with different feature sets using modular configuration files.

## 🎯 Overview

You have two configurations:
- **Work Laptop** (`config.nix`) - Current machine, NO Ollama
- **Personal Laptop** (`config-personal.nix`) - M5 Max with Ollama enabled

## 📁 Configuration Files

```
config.nix              # Work laptop (this machine)
config-personal.nix     # Personal laptop (M5 Max with Ollama)
```

## 🔧 Feature Flags

Each configuration has a `features` section:

```nix
features = {
  enableOllama = true/false;   # Local AI models
  enableGaming = true/false;   # Gaming tools (future)
};
```

## 💼 Work Laptop (Current Machine)

**File:** `config.nix`

```nix
{
  user = {
    username = "jschuhmann";
    fullName = "Josh Schuhmann";
    email = "jschuhmann@salesforce.com";  # Work email
    homeDirectory = "/Users/jschuhmann";
  };

  system = {
    hostname = "jschuhmann-work";
    architecture = "aarch64-darwin";
    stateVersion = 5;
  };

  homeManager = {
    stateVersion = "24.05";
  };

  features = {
    enableOllama = false;  # NO Ollama on work laptop
    enableGaming = false;
  };
}
```

**Why Ollama is disabled:**
- ✅ Saves ~60GB disk space (models)
- ✅ Saves ~74GB RAM (no models loaded)
- ✅ No background service consuming resources
- ✅ Work laptop focuses on productivity tools only
- ✅ Security: No local AI processing work code

**What you still get:**
- All development tools (~180 packages)
- Shell configuration (Zsh, Powerlevel10k)
- Git, AWS, Kubernetes, Terraform
- Homebrew GUI apps
- macOS system defaults

## 🏠 Personal Laptop (M5 Max, 128GB RAM)

**File:** `config-personal.nix`

```nix
{
  user = {
    username = "jschuhmann";
    fullName = "Josh Schuhmann";
    email = "jschuhmann@example.com";  # Personal email
    homeDirectory = "/Users/jschuhmann";
  };

  system = {
    hostname = "jschuhmann-personal";
    architecture = "aarch64-darwin";  # M5 Max
    stateVersion = 5;
  };

  homeManager = {
    stateVersion = "24.05";
  };

  features = {
    enableOllama = true;   # Enable Ollama (128GB RAM!)
    enableGaming = false;  # Optional
  };
}
```

**Why Ollama is enabled:**
- ✅ 128GB RAM can handle multiple 70B models
- ✅ M5 Max GPU acceleration (40 cores)
- ✅ Personal projects benefit from local AI
- ✅ No corporate security concerns
- ✅ Experimenting with LLMs is encouraged

**Additional features:**
- Ollama service with 8 parallel instances
- qwen2.5-coder:32b, llama3.3:70b models
- nomic-embed-text embeddings
- VS Code/Cursor integration
- Continue.dev autocomplete

## 🚀 Building Each Configuration

### Work Laptop (This Machine)

```bash
cd ~/github/nixos

# Uses config.nix by default
darwin-rebuild switch --flake .#jschuhmann-work

# Ollama will NOT be installed
# Check: launchctl list | grep ollama
# Should return nothing
```

### Personal Laptop (M5 Max)

```bash
cd ~/github/nixos

# Tell flake to use config-personal.nix instead
# Option 1: Edit flake.nix line 21:
vim flake.nix
# Change: config = import ./config.nix;
# To:     config = import ./config-personal.nix;

# Option 2: Or add both configs to flake.nix (see below)

# Build personal config
darwin-rebuild switch --flake .#jschuhmann-personal

# Ollama WILL be installed
# Check: launchctl list | grep ollama
# Should show: com.ollama.ollama
```

## 🔀 Supporting Both Configs in One Flake

Edit `flake.nix` to support both machines:

```nix
outputs = { self, nixpkgs, darwin, home-manager, ... }:
  let
    # Work laptop config
    configWork = import ./config.nix;
    
    # Personal laptop config
    configPersonal = import ./config-personal.nix;
    
    # Helper function to create Darwin system
    mkDarwinSystem = config: darwin.lib.darwinSystem {
      system = config.system.architecture;
      modules = [
        # Conditionally load Ollama
      ] ++ (if config.features.enableOllama or false
            then [ ./modules/ollama.nix ]
            else [ ]) ++ [
        # Rest of modules...
      ];
    };
  in
  {
    # Work laptop configuration
    darwinConfigurations.jschuhmann-work = mkDarwinSystem configWork;
    
    # Personal laptop configuration
    darwinConfigurations.jschuhmann-personal = mkDarwinSystem configPersonal;
  };
```

Then build with:
```bash
# Work laptop
darwin-rebuild switch --flake .#jschuhmann-work

# Personal laptop
darwin-rebuild switch --flake .#jschuhmann-personal
```

## 📊 Feature Comparison

| Feature | Work Laptop | Personal Laptop |
|---------|-------------|-----------------|
| **Core Tools** | ✅ | ✅ |
| Shell (Zsh + P10k) | ✅ | ✅ |
| Git, SSH, GPG | ✅ | ✅ |
| Development packages | ✅ (~180) | ✅ (~180) |
| AWS/Azure/GCP CLIs | ✅ | ✅ |
| Kubernetes tools | ✅ | ✅ |
| Terraform | ✅ | ✅ |
| Homebrew GUI apps | ✅ | ✅ |
| macOS system defaults | ✅ | ✅ |
| **AI/ML** |  |  |
| Ollama service | ❌ | ✅ |
| qwen2.5-coder:32b | ❌ | ✅ |
| llama3.3:70b | ❌ | ✅ |
| nomic-embed-text | ❌ | ✅ |
| VS Code AI extensions | ❌ | ✅ |
| **Resources** |  |  |
| Disk space saved | +60GB | -60GB |
| RAM available | All | ~54GB free |
| Background services | Fewer | +Ollama |

## 🔄 Switching Between Configs

### Current Setup (Work Laptop)

Your current machine uses `config.nix` with `enableOllama = false`.

**To verify:**
```bash
cat ~/github/nixos/config.nix | grep enableOllama
# Should show: enableOllama = false;

launchctl list | grep ollama
# Should return nothing
```

### When You Get Personal Laptop

1. **Clone repo** on new machine:
   ```bash
   git clone git@github.com:YOUR-USERNAME/nixos.git ~/github/nixos
   cd ~/github/nixos
   ```

2. **Edit flake.nix** to use personal config:
   ```bash
   vim flake.nix
   # Line 21: config = import ./config-personal.nix;
   ```

3. **Build personal config:**
   ```bash
   darwin-rebuild switch --flake .#jschuhmann-personal
   ```

4. **Wait for Ollama models** (~20-30 minutes):
   ```bash
   tail -f /var/log/ollama/stdout.log
   ```

5. **Test Ollama:**
   ```bash
   ollama run qwen2.5-coder:32b "Hello world"
   ```

## 🎨 Customizing Features

### Add New Feature Flag

Edit `config.nix` or `config-personal.nix`:

```nix
features = {
  enableOllama = false;
  enableGaming = false;
  enableDevtools = true;    # New flag
  enableMediaTools = false; # New flag
};
```

### Conditionally Load Modules

Edit `flake.nix`:

```nix
modules = [
  # Ollama (only if enabled)
] ++ (if config.features.enableOllama or false
      then [ ./modules/ollama.nix ]
      else [ ]) ++ [
  
  # Gaming tools (only if enabled)
] ++ (if config.features.enableGaming or false
      then [ ./modules/gaming.nix ]
      else [ ]) ++ [
  
  # Core modules (always loaded)
  ./modules/core.nix
];
```

### Per-Machine Packages

Edit `home.nix` to conditionally install packages:

```nix
home.packages = with pkgs; [
  # Core packages (always)
  git gh kubectl

  # Conditionally add AI tools
] ++ (if config.features.enableOllama or false
      then [ ollama ]
      else [ ]);
```

## 🐛 Troubleshooting

### Ollama Still Running on Work Laptop

**Check config:**
```bash
cat config.nix | grep enableOllama
# Should be: false
```

**Rebuild:**
```bash
darwin-rebuild switch --flake .#jschuhmann-work
```

**Verify stopped:**
```bash
launchctl list | grep ollama
# Should return nothing
```

**If still running, manually stop:**
```bash
sudo launchctl unload /Library/LaunchDaemons/com.ollama.ollama.plist
sudo rm /Library/LaunchDaemons/com.ollama.ollama.plist
```

### Wrong Hostname

**Check current hostname:**
```bash
scutil --get ComputerName
```

**Update config.nix:**
```nix
system = {
  hostname = "actual-hostname";
};
```

**Rebuild with correct name:**
```bash
darwin-rebuild switch --flake .#actual-hostname
```

## 📚 Documentation

- **[NEW_MACHINE_SETUP.md](NEW_MACHINE_SETUP.md)** - Setting up new Mac
- **[OLLAMA_SETUP.md](OLLAMA_SETUP.md)** - Ollama configuration (personal only)
- **[OLLAMA_M5_OPTIMIZATION.md](OLLAMA_M5_OPTIMIZATION.md)** - M5 Max tuning (personal only)
- **[IDE_INTEGRATION.md](IDE_INTEGRATION.md)** - VS Code/Cursor setup (personal only)

## 🔒 Security Notes

### Why Ollama is Disabled on Work Laptop

1. **Corporate Policy**: May violate policies about running AI on work devices
2. **Data Privacy**: Local AI processes code that may contain proprietary info
3. **Resource Usage**: Work laptop should focus on productivity
4. **Network Security**: AI models downloading/updating could trigger alerts
5. **Audit Trail**: Ollama requests not logged in corporate systems

### Safe to Enable Ollama When

- ✅ Personal device you own
- ✅ No corporate data processed
- ✅ No network restrictions
- ✅ Sufficient hardware (64GB+ RAM)
- ✅ You understand resource implications

## ✅ Verification Checklist

**Work Laptop:**
- [ ] `config.nix` has `enableOllama = false`
- [ ] `launchctl list | grep ollama` returns nothing
- [ ] No `/var/lib/ollama/` directory
- [ ] No Ollama models in storage
- [ ] VS Code has no Ollama extensions configured

**Personal Laptop:**
- [ ] `config-personal.nix` has `enableOllama = true`
- [ ] `launchctl list | grep ollama` shows service
- [ ] `/var/lib/ollama/models/` has models
- [ ] `ollama list` shows qwen2.5-coder:32b and llama3.3:70b
- [ ] VS Code/Cursor can access http://localhost:11434

---

**Current Machine:** Work Laptop (Ollama disabled)  
**Future Machine:** Personal M5 Max (Ollama enabled)  
**Configuration:** Feature-flag based modular system
