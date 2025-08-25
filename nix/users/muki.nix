{
  pkgs,
  config,
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
    chromium
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

  dotfilesPath = "${config.home.homeDirectory}/.dotfiles";

  sharedAliases = {
    # Generic Aliases
    nxh = "nix develop -c hx";
    nxy = "nix develop -c yazi";
    nxd = "nix develop -c nu";

    # Quick Dev Shells
    nxd-js = "nix develop ${dotfilesPath}/nix/templates/js -c nu";
  };

  sharedSessionVariables = {
    SHELL = "${pkgs.nushell}/bin/nu";
    EDITOR = "hx";
    GIT_EDITOR = "hx";
    DOTFILES = dotfilesPath;
    BROWSER = "firefox";
    NIXOS_OZONE_WL = "1";
  };
in
{
  home.stateVersion = stateVersion;

  home.packages = selectedPackages;
  fonts.fontconfig.enable = true;

  home.shellAliases = sharedAliases;
  home.sessionVariables = sharedSessionVariables;

  programs = {
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

    neovim = {
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

    helix = {
      enable = true;
      extraPackages = with pkgs; [
        nil
        nixfmt-rfc-style
      ];
    };

    nushell = {
      enable = true;
      environmentVariables = sharedSessionVariables;
      extraConfig = ''
        let carapace_completer = {|spans|
         carapace $spans.0 nushell ...$spans | from json
         }

        $env.config = {
          buffer_editor: 'hx',
          edit_mode: 'vi',
          show_banner: false,
          completions: {
            case_sensitive: false,
            quick: true,
            partial: true,
            algorithm: 'fuzzy',
            external: {
              enable: true,
              completer: $carapace_completer
            }
          }
        }

        $env.path ++= ["$DOTFILES/helpers"]
        # Fix ncurses GPG
        $env.GPG_TTY = (tty)
      '';
    };

    carapace = {
      enable = true;
      enableNushellIntegration = true;
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
  };

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = "zathura.desktop";
    "image/jpeg" = "feh.desktop";
    "image/png" = "feh.desktop";
    # Firefox as Browser
    "default-web-browser" = [ "firefox.desktop" ];
    "text/html" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
    "x-scheme-handler/about" = [ "firefox.desktop" ];
    "x-scheme-handler/unknown" = [ "firefox.desktop" ];
  };

  xdg.configFile = {
    "alacritty".source = ./../../dots/alacritty;
    "sway".source = ./../../dots/sway;
    "helix".source = ./../../dots/helix;
    "nvim".source = ./../../dots/nvim;
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
