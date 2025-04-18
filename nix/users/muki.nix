{
  config,
  pkgs,
  stateVersion,
  self,
  ...
}:
{
  home.packages = with pkgs; [
    # Development
    alacritty
    git
    tmux
    fzf
    twm
    ripgrep
    fastfetch
    sshfs
    picocom
    btop
    bruno
    gdb
    lldb
    valgrind
    linuxPackages.perf
    hotspot
    heaptrack
    hyperfine
    poop
    # Apps
    wineWowPackages.stable
    zen-browser
    google-chrome
    thunderbird
    gimp
    vesktop
    spotify
    vlc
    prismlauncher
    feh
    # CAD
    freecad
    kicad
    # Video
    obs-studio
    kdenlive
    tenacity
    # GTK themes
    dconf
    papirus-icon-theme
    # Fonts
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    TERM = "xterm-256color";
    TERMINAL = "alacritty";
    SHELL = "${pkgs.zsh}/bin/zsh";
    EDITOR = "nvim";
    GIT_EDITOR = "nvim";
    DOTFILES = "$HOME/.dotfiles";
  };

  programs.neovim = {
    enable = true;
    # package = pkgs.neovim;
    extraPackages = with pkgs; [
      # Lua
      luarocks
      luajitPackages.jsregexp
      # Treesitter
      gcc
      # Nil for all the flakes.
      nil
      nixfmt-rfc-style
    ];
  };

  programs.helix = {
    enable = true;

    extraPackages = with pkgs; [
      nil
    ];
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "muki";
      custom = "${self}/dots/zsh/.oh-my-zsh/themes";
      plugins = [ "git" ];
    };
    shellAliases = {
      nxv = "nix develop -c nvim";
      nxh = "nix develop -c hx";
      nxd = "nix develop";
    };
    initExtra = ''
      # Add helpers to PATH
      export PATH=$DOTFILES/helpers/:$PATH
      # Add .local/bin to PATH
      export PATH=$HOME/.local/bin/:$PATH
    '';
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };

  xdg.configFile = {
    "alacritty".source = "${self}/dots/alacritty";
    "sway".source = "${self}/dots/sway";
    "nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${self}/dots/nvim";
      recursive = true;
    };
    "helix".source = "${self}/dots/helix";
    "rofi".source = "${self}/dots/rofi/config";
    "tmux".source = "${self}/dots/tmux/";
  };

  xdg.dataFile = {
    "rofi".source = "${self}/dots/rofi/share";
  };

  home.file = {
    ".wallpaper".source = "${self}/dots/wallpaper";
  };

  home.stateVersion = stateVersion;
}
