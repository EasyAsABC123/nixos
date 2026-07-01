{
  # Work MacBook Configuration (Current Machine)
  user = {
    username = "jschuhmann";
    fullName = "Josh Schuhmann";
    email = "jschuhmann@salesforce.com";  # Work email
    homeDirectory = "/Users/jschuhmann";
  };

  # System configuration
  system = {
    hostname = "jschuhmann-work";  # Work MacBook
    architecture = "aarch64-darwin";  # Apple Silicon
    stateVersion = 5;  # nix-darwin state version
  };

  # Home Manager configuration
  homeManager = {
    stateVersion = "24.05";  # Home Manager release version
  };

  # Feature flags - Disable resource-intensive features on work laptop
  features = {
    enableOllama = false;  # NO local AI on work laptop (security/performance)
    enableGaming = false;  # NO gaming tools on work laptop
  };
}
