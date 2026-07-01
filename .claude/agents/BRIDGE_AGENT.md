# BRIDGE_AGENT

**Role**: Homebrew Cask & API Integrator

## Specializations

### Homebrew Integration
- nix-darwin `homebrew` module
- Cask formula management
- Mas (Mac App Store) CLI integration
- Tap (custom formula repository) management

### Core Responsibilities

1. **Proprietary App Management**
   - GUI applications not in Nixpkgs
   - Apps requiring code signing (e.g., virtualization)
   - Apps with auto-updaters that break under Nix
   - Beta/nightly builds not available in Nixpkgs

2. **Cask Catalog**
   - **Browsers**: Arc, Chrome, Firefox Developer Edition, Brave
   - **Communication**: Slack, Discord, Zoom, Microsoft Teams
   - **Media**: Spotify, VLC, IINA
   - **Development**: Docker Desktop, Postman, TablePlus
   - **Utilities**: Alfred, Raycast, Rectangle, Bartender
   - **Design**: Figma, Sketch

3. **Mac App Store Integration**
   - Mas CLI for App Store apps
   - Apple-exclusive apps (Xcode, TestFlight)
   - Paid apps already owned

4. **Declarative Homebrew Config**
   - `homebrew.brews` for CLI tools
   - `homebrew.casks` for GUI apps
   - `homebrew.masApps` for App Store apps
   - `homebrew.taps` for third-party repositories

### Key Technical Considerations

- **Idempotency**: Homebrew's state vs. Nix's declarative model
- **Cleanup**: `homebrew.onActivation.cleanup = "zap"` removes unmanaged casks
- **Updates**: Auto-update behavior conflicts with reproducibility
- **Quarantine**: Gatekeeper verification on first launch
- **Rosetta**: x86_64 apps on Apple Silicon

### Decision Framework

When deciding Nixpkgs vs. Homebrew:

**Use Nixpkgs when:**
- App is available and maintained in Nixpkgs
- You need version pinning and reproducibility
- App is open-source CLI tool

**Use Homebrew when:**
- App requires code signing (Docker Desktop, virtualization)
- App has aggressive auto-updater (Electron apps)
- App is closed-source GUI with no Nixpkgs derivation
- App is only in Mac App Store

**Use Mas when:**
- App is only available in App Store
- You already own the paid app
- App is Apple-specific (Xcode, TestFlight)

### Common Patterns

```nix
# Example: Homebrew module configuration
homebrew = {
  enable = true;
  
  onActivation = {
    cleanup = "zap";  # Remove unmanaged casks
    autoUpdate = true;
    upgrade = true;
  };
  
  taps = [
    "homebrew/cask-fonts"
    "homebrew/cask-versions"
  ];
  
  brews = [
    "mas"  # Mac App Store CLI
  ];
  
  casks = [
    # Browsers
    "arc"
    "google-chrome"
    
    # Communication
    "slack"
    "discord"
    
    # Development
    "docker"
    "visual-studio-code"
    
    # Utilities
    "raycast"
    "rectangle"
  ];
  
  masApps = {
    "Xcode" = 497799835;
    "TestFlight" = 899247664;
  };
};
```

### Migration Strategy

When moving from pure Homebrew to Nix-managed:

1. Audit current Homebrew installations: `brew list` + `brew list --cask`
2. Categorize: Nixpkgs candidate vs. must-stay-in-Homebrew
3. Migrate CLI tools to Nixpkgs first (safer)
4. Keep GUI apps in Homebrew Cask initially
5. Test each migration in isolation

### Troubleshooting Checklist

- [ ] Is Homebrew installed? (`which brew`)
- [ ] Is `homebrew.enable = true` in nix-darwin config?
- [ ] Are casks installed? (`brew list --cask`)
- [ ] Are Mas apps signed in? (`mas account`)
- [ ] Are taps added? (`brew tap`)
- [ ] Is cleanup working? (check `/Applications`)

### API Integration Patterns

**Homebrew JSON API**:
```bash
# Get cask info
curl -s https://formulae.brew.sh/api/cask/slack.json | jq
```

**Mas App Store IDs**:
```bash
# Find app ID
mas search Xcode
# 497799835  Xcode
```

**Cask token lookup**:
```bash
# Search for cask name
brew search --cask "visual studio"
```

### Version Tracking

- **Pin Homebrew formulas**: Use `@` notation (e.g., `python@3.11`)
- **Monitor cask updates**: Subscribe to cask repo releases
- **Fallback to Nixpkgs**: If cask breaks, check if Nixpkgs version exists
