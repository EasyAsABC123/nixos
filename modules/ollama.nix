{ config, pkgs, lib, ... }:

{
  # Enable Ollama service for local LLM inference
  services.ollama = {
    enable = true;

    # Use Apple Silicon-optimized acceleration
    # On macOS with Apple Silicon, Ollama uses Metal framework by default
    # No rocm package needed - Metal is the native backend
    acceleration = null;  # null = use default Metal backend on macOS

    # Automatically pull models on system activation
    # With 128GB RAM, you can keep multiple large models loaded simultaneously
    # These will be downloaded to /var/lib/ollama/models/
    models = [
      # === PRIMARY MODELS ===

      # Qwen 2.5 Coder 32B - Fast autocomplete and code generation (~19GB)
      "qwen2.5-coder:32b"

      # Llama 3.3 70B - Deep reasoning, chat, and refactoring (~40GB)
      "llama3.3:70b"

      # === EMBEDDINGS MODEL ===

      # Nomic Embed Text - For semantic search and RAG (~274MB)
      # Essential for codebase context and Continue.dev embeddings
      "nomic-embed-text"

      # === OPTIONAL MODELS ===

      # Qwen 2.5 32B Instruct - Alternative chat model (~19GB)
      # Good balance of speed and quality for conversations
      # "qwen2.5:32b"

      # Qwen 2.5 7B - Lightweight for quick tasks (~4.7GB)
      # Use for simple completions when speed is critical
      # "qwen2.5:7b"

      # DeepSeek Coder V2 236B - State-of-the-art coding model (~140GB)
      # With 128GB RAM, you can actually run this beast!
      # Uncomment when you're ready for the ultimate coding assistant:
      # "deepseek-coder-v2:236b"

      # Qwen 2.5 72B - Alternative large general model (~43GB)
      # Excellent for reasoning tasks, can run alongside 32B coder
      # "qwen2.5:72b"

      # CodeLlama 70B - Specialized for code, alternative to Qwen (~40GB)
      # "codellama:70b"

      # === MULTIMODAL (Vision/Audio) ===

      # LLaVA 34B - Vision + language understanding (~19GB)
      # Can analyze screenshots, diagrams, and UI mockups
      # "llava:34b"

      # Gemma 2 27B - Multimodal reasoning (~16GB)
      # Note: Gemma4 not yet available, Gemma 2 is current version
      # "gemma2:27b"
    ];

    # Environment variables for Ollama daemon
    # Optimized for M5 Max with 128GB RAM - can handle multiple large models simultaneously
    environmentVariables = {
      # Allow 8 parallel model instances to leverage 128GB RAM pool
      # With this much memory, you can run multiple 70B models concurrently
      # Useful for multi-file code analysis, parallel requests, and mixed model workflows
      OLLAMA_NUM_PARALLEL = "8";

      # Keep models loaded in memory for 24 hours
      # With 128GB RAM, keeping multiple large models resident is no problem
      # Prevents expensive reload on each request (critical for 70B models)
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
