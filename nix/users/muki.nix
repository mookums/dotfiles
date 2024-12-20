{
  config,
  pkgs,
  stateVersion,
  self,
  ...
}: {
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
    bottom
    gdb
    valgrind
    # Profiling
    linuxPackages.perf
    hotspot
    heaptrack
    # Apps
    firefox
    flameshot
    gimp
    discord
    slack
    spotify
    vlc
    prismlauncher
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
    (nerdfonts.override {fonts = ["JetBrainsMono"];})
  ];
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
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
      alejandra
    ];
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "muki";
      custom = "${self}/dots/zsh/.oh-my-zsh/themes";
      plugins = ["git"];
    };
    shellAliases = {
      nxv = "nix develop -c nvim";
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
    "i3".source = "${self}/dots/i3";
    "nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${self}/dots/nvim";
      recursive = true;
    };
    "rofi".source = "${self}/dots/rofi/config";
    "tmux".source = "${self}/dots/tmux/";
  };

  xdg.dataFile = {"rofi".source = "${self}/dots/rofi/share";};

  home.file = {
    ".fehbg".source = "${self}/dots/feh/.fehbg";
    ".wallpaper".source = "${self}/dots/wallpaper";
  };

  home.stateVersion = stateVersion;
}
