{
  pkgs,
  config,
  stateVersion,
  minimal ? false,
  ...
}:
let
  cliPackages = with pkgs; [
    # Shell / Navigation
    fzf
    tmux
    twm
    ripgrep
    yazi
    btop
    fastfetch
    # System / Network
    sshfs
    picocom
    miniserve
    # Debug / Trace
    gdb
    lldb
    valgrind
    perf
    gf
    # VCS
    git
    # Cache
    sccache

    claude-code
    opencode
  ];

  guiPackages = with pkgs; [
    ghostty
    feh
    zathura
    sqlitebrowser
  ];

  themePackages = with pkgs; [
    dconf
    papirus-icon-theme
    nerd-fonts.jetbrains-mono
  ];

  profilingPackages = with pkgs; [
    hotspot
    heaptrack
    hyperfine
    poop
  ];

  cadPackages = with pkgs; [
    (pkgs.symlinkJoin {
      name = "freecad-wrapped";
      paths = [ freecad ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram "$out/bin/freecad" --set QT_QPA_PLATFORM xcb
      '';
    })
    (pkgs.symlinkJoin {
      name = "kicad-wrapped";
      paths = [ kicad ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram "$out/bin/kicad" --set GDK_BACKEND x11
      '';
    })
    orca-slicer
  ];

  miscPackages = with pkgs; [
    gimp
    darktable
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    spotify
    vlc
    prismlauncher
    slack
    libreoffice
    obs-studio
    kdePackages.kdenlive
    tenacity

  ];

  selectedPackages =
    if minimal then
      cliPackages ++ themePackages
    else
      cliPackages ++ guiPackages ++ themePackages ++ profilingPackages ++ cadPackages ++ miscPackages;

  dotfilesPath = "${config.home.homeDirectory}/.dotfiles";

  sharedAliases = {
    # Generic Aliases
    nxh = "nix develop -c hx";
    nxd = "nix develop";
  };

  sharedSessionVariables = {
    SHELL = "${pkgs.bash}/bin/bash";
    EDITOR = "hx";
    GIT_EDITOR = "hx";
    DOTFILES = dotfilesPath;
    BROWSER = "chromium";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    RUSTC_WRAPPER = "sccache";
  };
in
{
  home.stateVersion = stateVersion;

  home.packages = selectedPackages;
  fonts.fontconfig.enable = true;

  home.shellAliases = sharedAliases;
  home.sessionVariables = sharedSessionVariables;

  programs = {
    chromium = {
      enable = true;
    };

    helix = {
      enable = true;
      extraPackages = with pkgs; [
        nil
        nixfmt
        prettier
      ];
    };

    bash = {
      enable = true;
      sessionVariables = sharedSessionVariables;
      enableCompletion = true;
      historyControl = [
        "ignoredups"
        "ignorespace"
      ];
    };

    carapace = {
      enable = true;
      enableBashIntegration = true;
    };

    starship = {
      enable = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };

  xdg = {
    enable = true;

    desktopEntries = {
      feh = {
        name = "Feh";
        exec = "feh %f";
        mimeType = [
          "image/jpeg"
          "image/png"
          "image/gif"
        ];
      };
    };

    mime.enable = true;

    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "zathura.desktop";

        "image/jpeg" = "feh.desktop";
        "image/png" = "feh.desktop";
        # chromium as Browser
        "default-web-browser" = "chromium.desktop";
        "text/html" = "chromium.desktop";
        "x-scheme-handler/http" = "chromium.desktop";
        "x-scheme-handler/https" = "chromium.desktop";
        "x-scheme-handler/about" = "chromium.desktop";
        "x-scheme-handler/unknown" = "chromium.desktop";
      };

    };

    configFile = {
      "ghostty".source = ./../../dots/ghostty;
      "sway".source = ./../../dots/sway;
      "i3".source = ./../../dots/i3;
      "helix".source = ./../../dots/helix;
      "rofi".source = ./../../dots/rofi/config;
      "tmux".source = ./../../dots/tmux;
    };

    dataFile = {
      "rofi".source = ./../../dots/rofi/share;
    };
  };

  home.file = {
    ".fehbg".source = ./../../dots/feh/.fehbg;
    ".wallpaper".source = ./../../dots/wallpaper;
  };
}
