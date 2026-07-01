{
  # Personal MacBook Configuration (M5 Max, 128GB RAM)
  user = {
    username = "jschuhmann";
    fullName = "Josh Schuhmann";
    email = "jschuhmann@example.com";  # Personal email
    homeDirectory = "/Users/jschuhmann";
  };

  # System configuration
  system = {
    hostname = "jschuhmann-personal";  # Personal MacBook
    architecture = "aarch64-darwin";  # Apple Silicon (M5 Max, 128GB RAM)
    stateVersion = 5;  # nix-darwin state version
  };

  # Home Manager configuration
  homeManager = {
    stateVersion = "24.05";  # Home Manager release version
  };

  # Feature flags - Enable/disable optional features per machine
  features = {
    enableOllama = true;   # Enable local AI models (128GB RAM required)
    enableGaming = false;  # Gaming tools (optional)
  };
}
