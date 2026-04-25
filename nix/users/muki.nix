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
  ];

  guiPackages = with pkgs; [
    ghostty
    feh
    zathura
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
    BROWSER = "firefox";
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

    firefox = {
      enable = true;
      languagePacks = [ "en-US" ];

      # about:policies#documentation
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        DisableProfileImport = true;
        DisplayBookmarksToolbar = "never";
        DisplayMenuBar = "default-off";
        SearchBar = "unified";

        ExtensionSettings = {
          # uBlock Origin
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          # Privacy Badger
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            installation_mode = "force_installed";
          };
          # Bitwarden
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "force_installed";
          };
          # Consent-O-Matic
          "gdpr@cavi.au.dk" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/consent-o-matic/latest.xpi";
            installation_mode = "force_installed";
          };
        };

        # about:config
        Preferences = {
          "sidebar.verticalTabs" = {
            Value = true;
            Status = "locked";
          };
          "browser.ml.chat.enabled" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.enabled" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.feeds.section.topstories" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.feeds.topsites" = {
            Value = false;
            Status = "locked";
          };
        };
      };
    };

    helix = {
      enable = true;
      extraPackages = with pkgs; [
        nil
        nixfmt-rfc-style
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

        "images/jpeg" = "feh.desktop";
        "images/png" = "feh.desktop";
        # Firefox as Browser
        "default-web-browser" = "firefox.desktop";
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
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
