{ config, pkgs, stateVersion, self, ... }:

{
    home.packages = with pkgs; [
        alacritty
        git
        tmux
        fzf
        twm
        firefox
        ripgrep
        fastfetch
        vlc
        flameshot
        gimp
        discord
        spotify
        obsidian
        hotspot
        # Video
        obs-studio
        kdenlive
        # For GTK themes
        dconf
        papirus-icon-theme
        # Fonts
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
    fonts.fontconfig.enable = true;

    home.sessionVariables = {
        TERMINAL = "alacritty";
        SHELL="${pkgs.zsh}/bin/zsh";
        EDITOR="nvim";
        GIT_EDITOR="nvim";
        DOTFILES="$HOME/.dotfiles";
    };

    programs.neovim = {
        enable = true;
        package = pkgs.neovim-unwrapped;
        plugins = [
            # Prefer just using Lazy but TreeSitter is an exception.
            pkgs.vimPlugins.nvim-treesitter.withAllGrammars
        ];
        extraPackages = with pkgs; [
            # Lua
            luarocks
            luajitPackages.jsregexp
            lua-language-server
        ];
    };

    programs.zsh = {
        enable = true;
        autosuggestion.enable = true;
        #syntaxHighlighting.enable = true;
        oh-my-zsh = {
            enable = true;
            theme = "muki";
            custom = "${self}/dots/zsh/.oh-my-zsh/themes";
            plugins = [ "git" ];
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
        "polybar".source = "${self}/dots/polybar";
    	"rofi".source = "${self}/dots/rofi/config";
    };
    
    xdg.dataFile = {
        "rofi".source = "${self}/dots/rofi/share";
    };

    home.file.".fehbg".source = "${self}/dots/feh/.fehbg";
    home.file.".wallpaper".source = "${self}/dots/wallpaper";
    home.file.".tmux.conf".source = "${self}/dot/tmux/.tmux.conf";

    home.stateVersion = stateVersion;
}
