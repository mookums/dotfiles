{
  self,
  pkgs,
  stateVersion,
  zen-browser,
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
    feh
    zathura
    # GTK themes
    dconf
    papirus-icon-theme
    # Fonts
    nerd-fonts.jetbrains-mono
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
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    spotify
    vlc
    prismlauncher
    slack
    # CAD
    freecad
    kicad
    # Video
    obs-studio
    kdePackages.kdenlive
    tenacity
  ];

  selectedPackages = if minimal then essentialPackages else essentialPackages ++ additionalPackages;
in
{
  imports = [
    zen-browser.homeModules.beta
  ];

  home.stateVersion = stateVersion;

  home.packages = selectedPackages;
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
    EDITOR = "hx";
    GIT_EDITOR = "hx";
    DOTFILES = "$HOME/.dotfiles";
    BROWSER = "zen";
  };

  programs.zen-browser = {
    enable = true;

    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      DisablePocket = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
    };
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
    initContent = ''
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

  xdg.desktopEntries = {
    zathura = {
      name = "Zathura";
      exec = "zathura %f";
      mimeType = [ "application/pdf" ];
    };
    feh = {
      name = "Feh";
      exec = "feh %f";
      mimeType = [
        "image/jpeg"
        "image/png"
        "image/gif"
      ];
    };
    zen = {
      name = "Zen";
      exec = "zen %U";
      icon = "zen-browser";
      mimeType = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "application/xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
    };
  };

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = "zathura.desktop";
    "image/jpeg" = "feh.desktop";
    "image/png" = "feh.desktop";
    "text/html" = "zen.desktop";
    "text/xml" = "zen.desktop";
    "application/xhtml+xml" = "zen.desktop";
    "application/xml" = "zen.desktop";
    "x-scheme-handler/http" = "zen.desktop";
    "x-scheme-handler/https" = "zen.desktop";
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
