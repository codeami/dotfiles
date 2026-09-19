{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew = {
    enable = true;
    inherit user;
    # This Mac already had Homebrew from the official installer, and
    # nix-homebrew aborts activation over an unmanaged installation unless it
    # is allowed to migrate it. Migration swaps the Homebrew checkout under
    # /usr/local/Homebrew for the pinned one and keeps installed packages
    # (Cellar, Caskroom). No-op on a Mac that never had Homebrew.
    autoMigrate = true;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    # Everything below was already installed on this Mac. `zap` above removes
    # any brew package missing from these lists, so anything worth keeping has
    # to be declared here.
    taps = [
      "antoniorodr/memo"
      "krishkrosh/apps"
      "steipete/tap"
    ];
    # herdr is not here on purpose: the formula has no Intel macOS bottle, so
    # declaring it makes brew bundle fail on every switch. See README.
    brews = [
      "colima"
      "docker"
      "docker-compose"
      "ffmpeg"
      "gemini-cli"
      "gh"
      "go"
      "himalaya"
      "jq"
      "ollama"
      "ripgrep"
      "uv"
      "x11vnc"
    ];
    casks = [
      "wezterm"
      "claude-code"
      "1password-cli"
      "ngrok"
      # Fully qualified so it resolves through krishkrosh/apps above: a
      # fully-qualified name is what lets nix-darwin mark the cask trusted,
      # which Homebrew 6 requires for casks from non-official taps.
      "krishkrosh/apps/trackweight"
    ];
  };
}
