{
  description = "jschuhmann's macOS system configuration via nix-darwin and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, darwin, home-manager, ... }:
    let
      # Import both configurations
      configWork = import ./config.nix;
      configPersonal = import ./config-personal.nix;

      # Helper function to create Darwin system
      mkDarwinSystem = userConfig: darwin.lib.darwinSystem {
        system = userConfig.system.architecture;

        modules = [
          # Conditionally load Ollama module (only on personal laptop)
          # Controlled by userConfig.features.enableOllama flag
        ] ++ (if userConfig.features.enableOllama or false
              then [ ./modules/ollama.nix ]
              else [ ]) ++ [

          # Core nix-darwin configuration
          ({ pkgs, ... }: {
            # Nix daemon configuration
            nix = {
              package = pkgs.nix;

              settings = {
                # Enable experimental features
                experimental-features = [ "nix-command" "flakes" ];

                # Optimize store automatically
                auto-optimise-store = true;

                # Trusted users for daemon
                trusted-users = [ "@admin" userConfig.user.username ];

              # Substituters and cache
              substituters = [
                "https://cache.nixos.org"
              ];

              trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              ];
            };

            # Garbage collection
            gc = {
              automatic = true;
              interval = { Weekday = 0; Hour = 3; Minute = 0; };
              options = "--delete-older-than 30d";
            };
          };

          # System packages (system-level tools)
          environment.systemPackages = with pkgs; [
            vim
            git
            curl
            wget
          ];

          # Homebrew integration for GUI apps and tools requiring code signing
          homebrew = {
            enable = true;

            # Remove packages not managed by this configuration
            onActivation.cleanup = "zap";

            # Required for nerd fonts
            taps = [
              "homebrew/cask-fonts"
            ];

            casks = [
              # GUI Applications requiring code signing or proprietary packaging
              "aerospace"              # Tiling window manager - requires accessibility permissions & code signing
              "gswitch"                # GPU switcher - requires system extension loading & code signing
              "smcfancontrol"          # SMC tool - requires kernel-level access & code signing
              "ghostty"                # Terminal emulator - GUI app
              "rectangle"              # Window management - requires accessibility permissions
              "secretive"              # Secure Enclave key management - requires macOS keychain integration
              "sublime-text"           # Proprietary editor with auto-updater
              "mysqlworkbench"         # GUI database tool
              "quarto"                 # Publishing system
              "warp"                   # Terminal with proprietary features

              # Java distributions
              "temurin@17"             # Eclipse Temurin OpenJDK 17

              # Nerd Font
              "font-hack-nerd-font"    # Patched font

              # CLI tools via Homebrew (consider migrating to nixpkgs)
              "1password-cli"
              "gcloud-cli"
              "ngrok"
            ];
          };

          # macOS system defaults
          system = {
            # Set system state version
            stateVersion = userConfig.system.stateVersion;

            defaults = {
              # Dock settings
              dock = {
                autohide = true;
                autohide-delay = 0.0;
                autohide-time-modifier = 0.2;
                expose-animation-duration = 0.1;
                launchanim = false;
                mineffect = "scale";
                minimize-to-application = true;
                mru-spaces = false;
                orientation = "bottom";
                show-recents = false;
                showhidden = true;
                static-only = true;
                tilesize = 48;
              };

              # Finder settings
              finder = {
                AppleShowAllExtensions = true;
                AppleShowAllFiles = true;
                CreateDesktop = false;
                FXDefaultSearchScope = "SCcf";
                FXEnableExtensionChangeWarning = false;
                FXPreferredViewStyle = "Nlsv";
                QuitMenuItem = true;
                ShowPathbar = true;
                ShowStatusBar = true;
                _FXShowPosixPathInTitle = true;
              };

              # Trackpad settings
              trackpad = {
                Clicking = true;
                TrackpadRightClick = true;
                TrackpadThreeFingerDrag = false;
              };

              # NSGlobalDomain (system-wide) settings
              NSGlobalDomain = {
                # Keyboard settings
                AppleKeyboardUIMode = 3;
                ApplePressAndHoldEnabled = false;
                InitialKeyRepeat = 15;
                KeyRepeat = 2;

                # Interface settings
                AppleInterfaceStyle = "Dark";
                AppleShowAllExtensions = true;
                AppleShowScrollBars = "WhenScrolling";

                # Save dialog settings
                NSAutomaticCapitalizationEnabled = false;
                NSAutomaticDashSubstitutionEnabled = false;
                NSAutomaticPeriodSubstitutionEnabled = false;
                NSAutomaticQuoteSubstitutionEnabled = false;
                NSAutomaticSpellingCorrectionEnabled = false;
                NSDocumentSaveNewDocumentsToCloud = false;
                NSNavPanelExpandedStateForSaveMode = true;
                NSNavPanelExpandedStateForSaveMode2 = true;

                # Misc settings
                PMPrintingExpandedStateForPrint = true;
                PMPrintingExpandedStateForPrint2 = true;

                # Menu bar
                _HIHideMenuBar = false;
              };

              # Screen capture settings
              screencapture = {
                location = "~/Pictures/Screenshots";
                type = "png";
              };

              # Activity Monitor settings
              ActivityMonitor = {
                IconType = 5;
                ShowCategory = 100;
              };

              # Custom user preferences
              CustomUserPreferences = {
                "com.apple.terminal" = {
                  StringEncodings = [ 4 ];
                };

                "com.apple.TimeMachine" = {
                  DoNotOfferNewDisksForBackup = true;
                };

                "com.apple.ImageCapture" = {
                  disableHotPlug = true;
                };
              };
            };

            # Keyboard settings
            keyboard = {
              enableKeyMapping = true;
              remapCapsLockToControl = true;
            };

            # Activation scripts
            activationScripts.postActivation.text = ''
              # Reload Dock to apply settings
              killall Dock || true

              # Reload Finder to apply settings
              killall Finder || true

              # Create screenshots directory if it doesn't exist
              mkdir -p ~/Pictures/Screenshots

              echo "nix-darwin activation complete"
            '';
          };

          # Enable touch ID for sudo
          security.pam.enableSudoTouchIdAuth = true;

          # Auto upgrade nix package and the daemon service
          services.nix-daemon.enable = true;

          # Used for backwards compatibility
          system.configurationRevision = null;

          # The platform the configuration will be used on
          nixpkgs.hostPlatform = userConfig.system.architecture;

          # Allow unfree packages
          nixpkgs.config.allowUnfree = true;
        })

        # Home Manager integration
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            # Pass configuration variables to home.nix
            extraSpecialArgs = { inherit userConfig; };

            users.${userConfig.user.username} = import ./home.nix;
          };
        }
      ];
      };
    in
    {
      # Work laptop configuration
      darwinConfigurations.jschuhmann-work = mkDarwinSystem configWork;

      # Personal laptop configuration (M5 Max with Ollama)
      darwinConfigurations.jschuhmann-personal = mkDarwinSystem configPersonal;
    };
}
