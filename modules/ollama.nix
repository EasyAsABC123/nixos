{ config, pkgs, lib, ... }:

{
  # Install Ollama package
  environment.systemPackages = with pkgs; [
    ollama  # Ollama CLI and server
  ];

  # Create LaunchDaemon for Ollama service
  launchd.daemons.ollama = {
    serviceConfig = {
      # Program to run
      ProgramArguments = [
        "${pkgs.ollama}/bin/ollama"
        "serve"
      ];

      # Keep service running
      KeepAlive = true;
      RunAtLoad = true;

      # Process type for better resource allocation
      ProcessType = "Interactive";

      # Run with elevated nice priority for responsive inference
      Nice = -10;

      # Working directory for model storage
      WorkingDirectory = "/var/lib/ollama";

      # Environment variables optimized for M5 Max with 128GB RAM
      EnvironmentVariables = {
        # Allow 8 parallel model instances to leverage 128GB RAM pool
        OLLAMA_NUM_PARALLEL = "8";

        # Keep models loaded in memory for 24 hours
        OLLAMA_KEEP_ALIVE = "24h";

        # Max GPU offloading for Apple Silicon Metal
        OLLAMA_NUM_GPU = "99";

        # Home directory for Ollama data
        OLLAMA_MODELS = "/var/lib/ollama/models";

        # Listen on localhost only (security)
        OLLAMA_HOST = "127.0.0.1:11434";
      };

      # Logging
      StandardOutPath = "/var/log/ollama/stdout.log";
      StandardErrorPath = "/var/log/ollama/stderr.log";
    };
  };

  # System activation script to setup directories and pull models
  system.activationScripts.ollama.text = ''
    echo "Setting up Ollama directories..."

    # Create log directory
    mkdir -p /var/log/ollama
    chown -R root:wheel /var/log/ollama
    chmod 755 /var/log/ollama

    # Create data directory
    mkdir -p /var/lib/ollama/models
    chmod 755 /var/lib/ollama
    chmod 755 /var/lib/ollama/models

    echo "Ollama directories created"

    # Pull models in background (non-blocking)
    # This runs after the service starts
    (
      # Wait for Ollama service to be ready
      sleep 10

      echo "Pulling Ollama models in background..."

      # Pull primary models
      ${pkgs.ollama}/bin/ollama pull qwen2.5-coder:32b &
      ${pkgs.ollama}/bin/ollama pull llama3.3:70b &
      ${pkgs.ollama}/bin/ollama pull nomic-embed-text &

      wait
      echo "Model downloads initiated (check /var/log/ollama/stdout.log for progress)"
    ) &
  '';
}
