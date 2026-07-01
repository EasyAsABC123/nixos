{ config, pkgs, lib, ... }:

{
  # Enable Ollama service for local LLM inference
  services.ollama = {
    enable = true;

    # Use Apple Silicon-optimized acceleration
    # On macOS with Apple Silicon, Ollama uses Metal framework by default
    # No rocm package needed - Metal is the native backend
    acceleration = null;  # null = use default Metal backend on macOS

    # Automatically pull large coding models on system activation
    # These will be downloaded to /var/lib/ollama/models/
    models = [
      # Qwen 2.5 Coder 32B - Excellent for code generation and explanation
      "qwen2.5-coder:32b"

      # Llama 3.3 70B - Strong general-purpose reasoning and coding
      "llama3.3:70b"
    ];

    # Environment variables for Ollama daemon
    # These optimize performance for Apple Silicon's unified memory architecture
    environmentVariables = {
      # Allow 4 parallel model instances to leverage massive RAM pool
      # Useful for multi-file code analysis and parallel requests
      OLLAMA_NUM_PARALLEL = "4";

      # Keep models loaded in memory for 24 hours
      # Prevents expensive reload on each request (critical for 70B models)
      # With unified memory, this allows instant inference after warmup
      OLLAMA_KEEP_ALIVE = "24h";

      # Optional: Explicitly set host binding (default is 127.0.0.1:11434)
      # OLLAMA_HOST = "0.0.0.0:11434";  # Uncomment to allow network access

      # Optional: Set specific GPU layers for Metal (auto-detected by default)
      # OLLAMA_NUM_GPU = "99";  # Max GPU offloading (recommended for Apple Silicon)
    };

    # Optional: Configure Ollama listen address
    # Default: 127.0.0.1:11434 (localhost only)
    # listenAddress = "127.0.0.1:11434";

    # Optional: Configure model storage location
    # Default: /var/lib/ollama on nix-darwin
    # home = "/var/lib/ollama";
  };

  # Ensure Ollama CLI is available system-wide
  environment.systemPackages = with pkgs; [
    ollama  # CLI tool for interacting with Ollama service
  ];

  # Optional: Open firewall for Ollama API (if needed for network access)
  # networking.firewall.allowedTCPPorts = [ 11434 ];

  # LaunchDaemon configuration (nix-darwin specific)
  # Ollama runs as a system service with higher priority for performance
  launchd.daemons.ollama = {
    serviceConfig = {
      # Run with elevated nice priority for responsive inference
      Nice = -10;

      # Automatic restart on failure
      KeepAlive = true;

      # Process type for better resource allocation
      ProcessType = "Interactive";

      # Standard logging
      StandardOutPath = "/var/log/ollama/stdout.log";
      StandardErrorPath = "/var/log/ollama/stderr.log";
    };
  };

  # Create log directory for Ollama
  system.activationScripts.ollama.text = ''
    mkdir -p /var/log/ollama
    chown -R root:wheel /var/log/ollama
    chmod 755 /var/log/ollama
  '';
}
