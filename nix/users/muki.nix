{
  config,
  pkgs,
  stateVersion,
  self,
  ...
}: {
  home.packages = with pkgs; [
    # Development
    ghostty
    git
    tmux
    fzf
    twm
    ripgrep
    fastfetch
    sshfs
    picocom
    btop
    # Debugging/Profiling 
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
    gimp
    discord
    slack
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
    (nerdfonts.override {fonts = ["JetBrainsMono"];})
  ];
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    TERM = "xterm-256color";
    TERMINAL = "ghostty";
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
    "ghostty".source = "${self}/dots/ghostty";
    "i3".source = "${self}/dots/i3";
    "hypr".source = "${self}/dots/hypr";
    "waybar".source = "${self}/dots/waybar";
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
