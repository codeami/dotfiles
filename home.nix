{ config, lib, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    # Lands in ~/.zshenv, where the previous one had it.
    envExtra = ''
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
    '';
    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        # herdr is a manual install outside Nix, so generate its completion from
        # the installed binary and refresh it whenever that binary changes.
        # Order 550 puts this before compinit, which is where fpath must be set.
        if [[ -x /usr/local/bin/herdr ]]; then
          _herdr_completions="''${XDG_CACHE_HOME:-$HOME/.cache}/herdr/zsh"
          if [[ ! -f "$_herdr_completions/_herdr" || /usr/local/bin/herdr -nt "$_herdr_completions/_herdr" ]]; then
            mkdir -p "$_herdr_completions"
            /usr/local/bin/herdr completion zsh > "$_herdr_completions/_herdr" 2>/dev/null
          fi
          fpath=("$_herdr_completions" $fpath)
          unset _herdr_completions
        fi
      '')
      (lib.mkOrder 1000 ''
        bindkey '^f' autosuggest-accept

        # Carried over from this Mac's previous ~/.zshrc, kept at
        # ~/.zshrc.before-nix-darwin. nvm, Rust, Antigravity and OpenClaw all
        # install themselves outside Nix, so they stay wired up here.
        export PATH="$HOME/.local/bin:$PATH"

        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

        export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

        [ -f "$HOME/.openclaw/completions/openclaw.zsh" ] && source "$HOME/.openclaw/completions/openclaw.zsh"
      '')
    ];
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # herdr is installed by hand (see README), so nothing starts its server for
  # us the way `brew services` would for a formula. This agent does that on
  # login and restarts it if it dies, mirroring the formula's service block.
  launchd.agents.herdr = {
    enable = true;
    config = {
      ProgramArguments = [ "/usr/local/bin/herdr" "server" ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/herdr.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/herdr.log";
      EnvironmentVariables.PATH = "/usr/local/bin:/etc/profiles/per-user/${user}/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";
    };
  };

  # Home Manager only loads the agent above; in this environment launchd leaves
  # the first spawn pending, so kick it once the agent is installed. Without
  # this, herdr server would come up at login but not after a rebuild.
  home.activation.startHerdr =
    lib.hm.dag.entryAfter [ "setupLaunchAgents" ] ''
      uid=$(/usr/bin/id -u ${user})
      # No -k: start it when it is not running, but never kill a live server
      # (its panes and agents survive a rebuild).
      run /bin/launchctl kickstart "gui/$uid/org.nix-community.home.herdr" || true
      # So a config.toml edit in this repo reaches the running server on the
      # next switch. No-op if nothing changed or the server is down.
      run /usr/bin/sudo -u ${user} -H /usr/local/bin/herdr server reload-config || true
    '';

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  # Keep Pi's credential and runtime state local by linking only authored files and directories.
  home.file.".pi/agent/themes".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/themes";
  home.file.".pi/agent/extensions".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/extensions";
  home.file.".pi/agent/models.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/models.json";
  home.file.".pi/agent/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/settings.json";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}
