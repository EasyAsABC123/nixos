# Nix-on-macOS Agent System

This directory contains three specialized agent personas for orchestrating a declarative macOS deployment pipeline with Nix.

## Agent Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      ORCHESTRATOR                            │
│  (Synthesizes responses from all three agents)               │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│  ARCHITECT    │  │  DOTFILES     │  │   BRIDGE      │
│    AGENT      │  │    AGENT      │  │    AGENT      │
├───────────────┤  ├───────────────┤  ├───────────────┤
│ • nix-darwin  │  │ • Home Manager│  │ • Homebrew    │
│ • /nix mount  │  │ • Shell config│  │ • Casks       │
│ • System      │  │ • CLI tools   │  │ • Mas         │
│   defaults    │  │ • Dotfiles    │  │ • API bridge  │
│ • macOS       │  │ • Git/SSH     │  │ • App catalog │
│   integration │  │ • Editors     │  │ • Migrations  │
└───────────────┘  └───────────────┘  └───────────────┘
```

## Agent Responsibilities

### 🏗️ ARCHITECT_AGENT
**Focus**: System-level Nix and macOS integration

- Manages `/nix` store and APFS volume setup
- Configures nix-darwin modules
- Sets macOS system preferences (Dock, Finder, keyboard)
- Handles security (SIP, Touch ID, Gatekeeper)
- Ensures idempotent `darwin-rebuild` operations

**Invoke when**: Questions about system setup, `/nix` mounting, macOS defaults, or nix-darwin modules.

### 🏠 DOTFILES_AGENT
**Focus**: User-space configuration and tools

- Manages Home Manager configuration
- Configures shells (zsh, fish, bash)
- Maintains dotfiles (Git, SSH, GPG)
- Curates CLI toolchain (bat, ripgrep, fzf, etc.)
- Ensures cross-platform compatibility

**Invoke when**: Questions about shell config, user packages, dotfiles, or Home Manager modules.

### 🌉 BRIDGE_AGENT
**Focus**: Homebrew and proprietary app management

- Manages `homebrew` module in nix-darwin
- Tracks GUI apps that must use Homebrew Cask
- Integrates Mac App Store via Mas
- Decides Nixpkgs vs. Homebrew for each tool
- Handles app migrations and version tracking

**Invoke when**: Questions about GUI apps, Homebrew casks, Mac App Store, or Nixpkgs vs. Homebrew decisions.

## Usage Pattern

When you ask a question or request a configuration change, the orchestrator will:

1. **Route** the query to the relevant agent(s)
2. **Synthesize** their responses
3. **Provide** a unified answer with context from all perspectives

### Example Queries

**"How do I install Slack?"**
- BRIDGE_AGENT: Use Homebrew Cask (`casks = ["slack"]`)
- ARCHITECT_AGENT: Ensure `homebrew.enable = true` in nix-darwin
- DOTFILES_AGENT: No action needed (GUI app, not CLI)

**"Configure my shell with modern Unix tools"**
- DOTFILES_AGENT: Add `bat`, `exa`, `ripgrep` to Home Manager packages
- ARCHITECT_AGENT: Ensure PATH is correct in system shell config
- BRIDGE_AGENT: No action needed (all available in Nixpkgs)

**"Set up Touch ID for sudo"**
- ARCHITECT_AGENT: Configure PAM module in nix-darwin
- DOTFILES_AGENT: No changes needed
- BRIDGE_AGENT: No changes needed

## Decision Matrix

| Concern | ARCHITECT | DOTFILES | BRIDGE |
|---------|-----------|----------|--------|
| System-wide config | ✅ Primary | ❌ | ❌ |
| User dotfiles | ❌ | ✅ Primary | ❌ |
| GUI apps | ✅ Consult | ❌ | ✅ Primary |
| CLI tools (Nixpkgs) | ❌ | ✅ Primary | ✅ Consult |
| CLI tools (Homebrew) | ❌ | ✅ Consult | ✅ Primary |
| macOS defaults | ✅ Primary | ❌ | ❌ |
| Shell config | ❌ | ✅ Primary | ❌ |
| /nix setup | ✅ Primary | ❌ | ❌ |
| Migrations | ✅ Consult | ✅ Consult | ✅ Primary |

## Configuration Layers

```
┌─────────────────────────────────────────┐
│         System Layer (root)              │ ← ARCHITECT_AGENT
│  • /nix store                            │
│  • nix-darwin modules                    │
│  • System defaults                       │
│  • LaunchDaemons                         │
└─────────────────────────────────────────┘
                  │
┌─────────────────────────────────────────┐
│       User Layer (home-manager)          │ ← DOTFILES_AGENT
│  • ~/.config/*                           │
│  • Shell config                          │
│  • CLI tools                             │
│  • Dotfiles                              │
└─────────────────────────────────────────┘
                  │
┌─────────────────────────────────────────┐
│    Application Layer (Homebrew)          │ ← BRIDGE_AGENT
│  • /Applications/*.app                   │
│  • Homebrew Casks                        │
│  • Mac App Store                         │
│  • Proprietary software                  │
└─────────────────────────────────────────┘
```

## Getting Started

Each agent document contains:
- **Specializations**: Areas of expertise
- **Core Responsibilities**: What they manage
- **Key Technical Considerations**: Important context
- **Decision Framework**: How to evaluate changes
- **Common Patterns**: Code examples
- **Troubleshooting Checklist**: Debug steps

Read the individual agent files for detailed guidance on each domain.
