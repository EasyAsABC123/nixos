# Documentation Index

Complete documentation for the Nix-on-macOS configuration.

## 🚀 Getting Started

**New to this setup?** Start here:

1. **[NEW_MACHINE_SETUP.md](NEW_MACHINE_SETUP.md)** ⭐
   - Complete step-by-step guide for setting up a new MacBook
   - Estimated time: 60-80 minutes
   - Covers: macOS setup → Nix install → nix-darwin bootstrap → verification

2. **[INSTALL.md](INSTALL.md)**
   - Detailed installation instructions
   - Troubleshooting common issues
   - Architecture notes (Apple Silicon vs Intel)

3. **[QUICK-START.md](QUICK-START.md)**
   - Quick reference for experienced users
   - Essential commands and workflows

## 📖 Core Documentation

### Configuration & Architecture

- **[MODULAR_STRUCTURE.md](MODULAR_STRUCTURE.md)**
  - Architecture deep dive
  - Variable passing mechanism
  - Multi-machine setup patterns
  - Benefits of modular approach

- **[MODULAR_SETUP_COMPLETE.md](MODULAR_SETUP_COMPLETE.md)**
  - Modular configuration overview
  - File structure explanation
  - Variable mapping reference
  - Common tasks and customizations

### Reference & Usage

- **[COMMANDS.md](COMMANDS.md)**
  - Daily operations (rebuild, update, rollback)
  - Package management (search, add, remove)
  - Troubleshooting commands
  - Homebrew integration
  - Useful shell aliases

- **[OLLAMA_SETUP.md](OLLAMA_SETUP.md)** 🤖
  - Local LLM inference with Ollama
  - Apple Silicon Metal acceleration
  - qwen2.5-coder:32b and llama3.3:70b models
  - API usage and integration examples
  - Performance tuning and troubleshooting

### Migration & Analysis

- **[MIGRATION.md](MIGRATION.md)**
  - Homebrew → Nix migration guide
  - Package mapping reference
  - What stays in Homebrew vs moves to Nix

- **[AGENT_SYNTHESIS.md](AGENT_SYNTHESIS.md)**
  - Agent collaboration analysis
  - ARCHITECT, DOTFILES, and BRIDGE agent outputs
  - System diagnostic analysis
  - Package categorization decisions

## 🎯 Documentation by Use Case

### I want to...

**Set up a new Mac**
→ [NEW_MACHINE_SETUP.md](NEW_MACHINE_SETUP.md)

**Understand the architecture**
→ [MODULAR_STRUCTURE.md](MODULAR_STRUCTURE.md)

**Add a new package**
→ [COMMANDS.md](COMMANDS.md#add-package-permanently)

**Change my email or username**
→ [MODULAR_SETUP_COMPLETE.md](MODULAR_SETUP_COMPLETE.md#change-your-email)

**Troubleshoot build errors**
→ [INSTALL.md](INSTALL.md#common-issues)

**Update all packages**
→ [COMMANDS.md](COMMANDS.md#update-packages)

**Rollback a broken build**
→ [COMMANDS.md](COMMANDS.md#rollback)

**Set up multiple machines**
→ [MODULAR_STRUCTURE.md](MODULAR_STRUCTURE.md#multi-machine-setup)

## 📁 File Structure

```
../                          # Repository root
├── config.nix               # ⭐ Your personal settings (edit this!)
├── flake.nix                # System configuration (nix-darwin)
├── home.nix                 # User configuration (Home Manager)
├── validate.sh              # Configuration validation script
└── docs/                    # Documentation (you are here)
    ├── README.md            # This file
    ├── NEW_MACHINE_SETUP.md # Complete setup guide
    ├── INSTALL.md           # Installation details
    ├── COMMANDS.md          # Command reference
    ├── MODULAR_STRUCTURE.md # Architecture guide
    └── ... (other docs)
```

## 🔑 Quick Reference

### Configuration Files

| File | Purpose | When to Edit |
|------|---------|--------------|
| `config.nix` | Personal settings (username, email, hostname) | Always edit this for personal info |
| `flake.nix` | System config (macOS defaults, Homebrew) | Edit for system-level changes |
| `home.nix` | User config (packages, shell, Git) | Edit to add/remove packages |

### Common Commands

```bash
# Validate configuration
./validate.sh

# Rebuild system
darwin-rebuild switch --flake .#jschuhmann-macbook

# Update packages
nix flake update && darwin-rebuild switch --flake .#jschuhmann-macbook

# Rollback changes
darwin-rebuild --rollback

# Search for packages
nix search nixpkgs <package-name>
```

## 🏗️ System Architecture

```
config.nix (variables)
    ↓
flake.nix (nix-darwin) → macOS defaults, Homebrew, system packages
    ↓
home.nix (Home Manager) → Shell, Git, ~180 CLI packages
```

## 📚 Documentation Standards

All documentation follows these principles:

- ✅ **Step-by-step**: Clear numbered steps for procedures
- ✅ **Code examples**: All commands are copy-pasteable
- ✅ **Troubleshooting**: Common issues documented inline
- ✅ **Time estimates**: Duration provided for long operations
- ✅ **Prerequisites**: Requirements listed upfront
- ✅ **Verification**: How to verify each step succeeded

## 🤖 Agent Documentation

The three specialized agents that created this configuration:

- **ARCHITECT_AGENT**: macOS & Nix Integration expert
- **DOTFILES_AGENT**: Home Manager specialist
- **BRIDGE_AGENT**: Homebrew Cask & API Integrator

Agent personas are documented in `../.claude/agents/`

## 🆘 Getting Help

1. **Check documentation**: Start with [NEW_MACHINE_SETUP.md](NEW_MACHINE_SETUP.md)
2. **Run validation**: `./validate.sh` catches common issues
3. **Check build errors**: Use `--show-trace` flag for details
4. **Search issues**: Look for similar problems in Nix/nix-darwin repos
5. **Rollback**: If stuck, `darwin-rebuild --rollback` to working state

## 📝 Contributing to Docs

When updating documentation:

1. Keep language clear and concise
2. Include code examples
3. Test all commands before documenting
4. Update this index if adding new docs
5. Use relative links between docs

## 🔗 External Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nixpkgs Search](https://search.nixos.org/packages)
- [Nix Language Guide](https://nixos.org/guides/nix-language.html)

---

**Last Updated:** 2026-07-01  
**Documentation Version:** 1.0  
**Configuration:** Modular (config.nix → flake.nix + home.nix)
