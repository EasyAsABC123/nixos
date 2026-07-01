{
  # User configuration - Edit these values for your system
  user = {
    username = "jschuhmann";
    fullName = "Josh Schuhmann";
    email = "jschuhmann@salesforce.com";
    homeDirectory = "/Users/jschuhmann";
  };

  # System configuration
  system = {
    hostname = "jschuhmann-macbook";
    architecture = "aarch64-darwin";  # Apple Silicon (M5 Max, 128GB RAM)
    stateVersion = 5;  # nix-darwin state version
  };

  # Home Manager configuration
  homeManager = {
    stateVersion = "24.05";  # Home Manager release version
  };
}
