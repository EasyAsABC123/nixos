{ config, pkgs, lib, userConfig, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = userConfig.user.username;
  home.homeDirectory = userConfig.user.homeDirectory;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = userConfig.homeManager.stateVersion;

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # ============================================================================
  # SHELL CONFIGURATION
  # ============================================================================

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Shell aliases
    shellAliases = {
      # Modern CLI tool replacements
      cat = "bat";
      grep = "rg";
      find = "fd";

      # Git shortcuts
      gs = "git status";
      gd = "git diff";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph --all";

      # Directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";

      # Kubernetes shortcuts
      k = "kubectl";
      kx = "kubectx";
      kns = "kubens";

      # Docker shortcuts
      d = "docker";
      dc = "docker-compose";

      # Common operations
      ll = "ls -la";
      la = "ls -A";
      l = "ls -CF";
    };

    initExtra = ''
      # Powerlevel10k instant prompt
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # Load Powerlevel10k config if it exists
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # Zoxide initialization
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"

      # Direnv hook
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"

      # GPG TTY for commit signing
      export GPG_TTY=$(tty)
    '';

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
  };

  programs.starship = {
    enable = true;
    # Uncomment to use Starship instead of Powerlevel10k
    # enableZshIntegration = true;
  };

  # ============================================================================
  # GIT CONFIGURATION
  # ============================================================================

  programs.git = {
    enable = true;
    userName = userConfig.user.fullName;
    userEmail = userConfig.user.email;

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";
      diff.tool = "vimdiff";
      merge.tool = "vimdiff";

      # GPG signing (optional - configure if you use commit signing)
      # commit.gpgsign = true;
      # user.signingkey = "YOUR_GPG_KEY_ID";
    };

    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = true;
      };
    };

    lfs.enable = true;

    ignores = [
      ".DS_Store"
      "*.swp"
      "*.swo"
      "*~"
      ".idea/"
      ".vscode/"
      "*.pyc"
      "__pycache__/"
      "node_modules/"
      ".env"
      ".env.local"
    ];
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "nvim";
    };
  };

  # ============================================================================
  # TMUX CONFIGURATION
  # ============================================================================

  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    keyMode = "vi";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 50000;

    extraConfig = ''
      # Use | and - for splitting panes
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Vim-like pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Enable mouse support
      set -g mouse on

      # Status bar styling
      set -g status-style bg=black,fg=white
      set -g status-left-length 40
      set -g status-left '#[fg=green]#S #[fg=yellow]#I #[fg=cyan]#P'
    '';
  };

  # ============================================================================
  # NEOVIM CONFIGURATION
  # ============================================================================

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraConfig = ''
      " Basic settings
      set number relativenumber
      set expandtab
      set tabstop=2
      set shiftwidth=2
      set smartindent
      set ignorecase smartcase
      set incsearch hlsearch
      set hidden
      set nobackup nowritebackup
      set updatetime=300
      set signcolumn=yes

      " Use system clipboard
      set clipboard=unnamedplus
    '';
  };

  # ============================================================================
  # DEVELOPMENT TOOLS - Programming Languages & Runtimes
  # ============================================================================

  home.packages = with pkgs; [
    # === Programming Languages & Build Tools ===
    go                        # Go programming language
    nodejs_24                 # Node.js v24
    yarn                      # JavaScript package manager
    python313                 # Python 3.13
    python312                 # Python 3.12
    python311                 # Python 3.11
    python310                 # Python 3.10
    openjdk                   # Java Development Kit
    maven                     # Java build tool
    sbt                       # Scala build tool
    zig                       # Zig programming language

    # === Python Development Tools ===
    poetry                    # Python dependency management
    pipx                      # Install Python applications in isolated environments
    pyenv                     # Python version management
    black                     # Python code formatter
    ruff                      # Fast Python linter
    tox                       # Python test automation
    uv                        # Fast Python package installer

    # === Version Managers & Environment Tools ===
    jenv                      # Java version manager
    nvm                       # Node version manager
    tfenv                     # Terraform version manager
    direnv                    # Per-directory environment variables

    # ========================================================================
    # CLOUD & INFRASTRUCTURE - AWS, Azure, Kubernetes, Terraform
    # ========================================================================

    # === AWS Tools ===
    awscli2                   # AWS Command Line Interface v2
    aws-iam-authenticator     # AWS IAM authentication for Kubernetes

    # === Azure Tools ===
    azure-cli                 # Microsoft Azure CLI

    # === Kubernetes Tools ===
    kubectl                   # Kubernetes command-line tool
    kubernetes-helm           # Kubernetes package manager (helm)
    helm-ls                   # Helm language server
    k9s                       # Terminal UI for Kubernetes
    stern                     # Multi-pod log tailing for Kubernetes
    kubebuilder               # SDK for building Kubernetes APIs
    kubeconform               # Kubernetes manifest validation

    # === Terraform & IaC ===
    terraform                 # Infrastructure as Code tool
    terraform-ls              # Terraform language server
    tflint                    # Terraform linter

    # === Other Infrastructure ===
    vault                     # HashiCorp Vault - secrets management
    temporal                  # Temporal workflow engine
    qemu                      # Machine emulator and virtualizer
    podman                    # Container management tool (Docker alternative)

    # ========================================================================
    # DEVOPS & MONITORING - CI/CD, Observability, System Tools
    # ========================================================================

    # === CI/CD & Build Tools ===
    pack                      # Cloud Native Buildpacks
    conftest                  # Test configuration files using Open Policy Agent
    pre-commit                # Git pre-commit hook framework

    # === Monitoring & Observability ===
    redis                     # In-memory data structure store
    watch                     # Execute program periodically
    watchman                  # File watching service

    # === Container & VM Tools ===
    dive                      # Docker image layer analyzer
    vhs                       # Terminal recorder for creating demos
    qmk                       # QMK keyboard firmware tool

    # === Service Mesh & Networking ===
    grpcurl                   # cURL for gRPC services
    openvpn                   # VPN solution

    # ========================================================================
    # SHELL UTILITIES - Modern CLI Replacements & Productivity
    # ========================================================================

    # === Modern CLI Replacements (from .devbar) ===
    ripgrep                   # rg - faster grep
    fd                        # fd - faster find
    bat                       # bat - cat with syntax highlighting
    jq                        # JSON processor
    yq                        # YAML processor

    # === Navigation & Search ===
    zoxide                    # Smarter cd command
    tree                      # Directory tree visualization
    glow                      # Markdown renderer for the terminal

    # === File Transfer & Sync ===
    rclone                    # rsync for cloud storage
    wget                      # Network downloader
    curl                      # URL transfer tool

    # === Text Processing ===
    gnugrep                   # GNU grep
    coreutils                 # GNU core utilities
    gnu-tar                   # GNU tar

    # === Git Tools (beyond programs.git) ===
    git-lfs                   # Git Large File Storage
    git-filter-repo           # Tool for rewriting Git history
    bfg-repo-cleaner          # Remove large files from Git history

    # === Terminal Multiplexing ===
    ttyd                      # Share terminal over the web
    asciinema                 # Terminal session recorder

    # === Compression & Archives ===
    zstd                      # Fast compression algorithm
    xz                        # XZ compression utilities
    lz4                       # Fast compression algorithm

    # ========================================================================
    # DEVELOPMENT UTILITIES - Formatters, Linters, Debuggers
    # ========================================================================

    # === Code Formatting & Linting ===
    shfmt                     # Shell script formatter
    shellcheck                # Shell script static analysis
    clang-format              # C/C++ code formatter
    just                      # Command runner (similar to make)
    cmake                     # Cross-platform build system

    # === Testing Frameworks ===
    shellspec                 # BDD testing framework for shell scripts

    # === Protocol Buffers & Code Generation ===
    protobuf                  # Protocol Buffers
    openapi-generator         # Generate clients from OpenAPI specs
    swagger-codegen           # Generate clients from Swagger specs

    # === Documentation Tools ===
    graphviz                  # Graph visualization software

    # ========================================================================
    # SECURITY & OPERATIONS - Security Scanning, Secrets Management
    # ========================================================================

    # === Security Scanning ===
    snyk                      # Security vulnerability scanner
    trivy                     # Container security scanner

    # === SSH & Authentication ===
    sshpass                   # Non-interactive SSH password authentication
    gnupg                     # GNU Privacy Guard
    pinentry                  # PIN/password entry dialogs

    # ========================================================================
    # SPECIALIZED TOOLS - Hardware, Databases, Other
    # ========================================================================

    # === Embedded & Hardware Development ===
    # Note: ARM/AVR toolchains may require additional configuration
    # Uncomment if needed for embedded development:
    # pkgsCross.arm-embedded.buildPackages.gcc
    # pkgsCross.avr.buildPackages.gcc
    # avrdude                 # AVR programmer

    # === Database Tools ===
    postgresql_15             # PostgreSQL database (client tools)
    sqlite                    # SQLite database

    # === AI/ML Tools ===
    llama-cpp                 # LLaMA C++ inference

    # === Media Processing ===
    ffmpeg                    # Audio/video processing
    ghostscript               # PostScript/PDF interpreter

    # === Package Management ===
    renovate                  # Automated dependency updates
    heroku                    # Heroku CLI

    # === Miscellaneous Utilities ===
    fswatch                   # File change monitor
    pngpaste                  # Paste PNG images from clipboard
    putty                     # SSH/telnet client
    speakeasy                 # SDK generation tool
    task                      # Task runner and build tool
    workmux                   # Workspace multiplexer
    caddy                     # Web server with automatic HTTPS
    regal                     # Rego linter for Open Policy Agent
    make                      # GNU Make
    libtool                   # Generic library support script
    autoconf                  # Generate configuration scripts
    dyff                      # YAML diff tool
  ];

  # ============================================================================
  # ENVIRONMENT VARIABLES
  # ============================================================================

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less -R";

    # Go environment
    GOPATH = "$HOME/go";

    # GPG for commit signing
    GPG_TTY = "$(tty)";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/go/bin"
    "$HOME/.cargo/bin"
    "$HOME/.devbar/bin"
  ];

  # ============================================================================
  # SSH CONFIGURATION
  # ============================================================================

  programs.ssh = {
    enable = true;

    # Add your SSH hosts here
    matchBlocks = {
      "github.com" = {
        identityFile = "~/.ssh/id_ed25519";  # Adjust to your key
        user = "git";
      };

      # Example: Add your work servers
      # "work-server" = {
      #   hostname = "server.example.com";
      #   user = "your-username";
      #   identityFile = "~/.ssh/work_key";
      # };
    };
  };

  # ============================================================================
  # TOOLS WITH CUSTOM CONFIGURATION
  # ============================================================================

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.jq.enable = true;

  programs.htop = {
    enable = true;
    settings = {
      tree_view = true;
      show_cpu_frequency = true;
      show_cpu_temperature = true;
    };
  };

  # ============================================================================
  # XDG BASE DIRECTORY SPECIFICATION
  # ============================================================================

  xdg.enable = true;
}
