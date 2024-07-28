{ config, pkgs, stateVersion, self, ... }:

{
    home.packages = with pkgs; [
        alacritty
        git
        tmux
        polybar
        feh
        firefox
        ripgrep
        neovim
        vlc
        flameshot
        gimp
        discord
        spotify
        arandr
        obsidian
        # For GTK themes
        dconf
        papirus-icon-theme
        # Fonts
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];

    fonts.fontconfig.enable = true;

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
    };
    
    xdg.dataFile = {
        "rofi".source = "${self}/dots/rofi/share";
    };

    home.stateVersion = stateVersion;
}
