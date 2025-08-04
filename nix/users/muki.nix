{
  pkgs,
  config,
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
    BROWSER = "zen";
  };
in
{
  imports = [
    zen-browser.homeModules.beta
  ];

  home.stateVersion = stateVersion;

  home.packages = selectedPackages;
  fonts.fontconfig.enable = true;

  home.shellAliases = sharedAliases;
  home.sessionVariables = sharedSessionVariables;

  programs = {
    zen-browser = {
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
