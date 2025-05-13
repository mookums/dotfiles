{
  self,
  pkgs,
  stateVersion,
  minimal ? false,
  ...
}:
let
  essentialPackages = with pkgs; [
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
    yazi
    gdb
    lldb
    valgrind
    linuxPackages.perf
    # Apps
    zen-browser
    feh
    zathura
    # GTK themes
    dconf
    papirus-icon-theme
    # Fonts
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  additionalPackages = with pkgs; [
    # Development
    bruno
    hotspot
    heaptrack
    hyperfine
    poop
    # Apps
    google-chrome
    thunderbird
    gimp
    vesktop
    spotify
    vlc
    prismlauncher
    slack
    # CAD
    freecad
    kicad
    # Video
    obs-studio
    kdenlive
    tenacity
  ];

  selectedPackages = if minimal then essentialPackages else essentialPackages ++ additionalPackages;
in
{
  home.stateVersion = stateVersion;

  home.packages = selectedPackages;
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
    EDITOR = "hx";
    GIT_EDITOR = "hx";
    DOTFILES = "$HOME/.dotfiles";
  };

  programs.helix = {
    enable = true;

    extraPackages = with pkgs; [
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
      plugins = [ "git" ];
    };
    shellAliases = {
      nxh = "nix develop -c hx";
      nxy = "nix develop -c yazi";
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
    "alacritty".source = ./../../dots/alacritty;
    "sway".source = ./../../dots/sway;
    "helix".source = ./../../dots/helix;
    "rofi".source = ./../../dots/rofi/config;
    "tmux".source = ./../../dots/tmux;
  };

  xdg.dataFile = {
    "rofi".source = ./../../dots/rofi/share;
  };

  home.file = {
    ".wallpaper".source = ./../../dots/wallpaper;
  };
}
