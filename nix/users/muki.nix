{ pkgs, stateVersion, self, ... }:

{
    home.packages = with pkgs; [
        alacritty
        git
        tmux
        polybar
        feh
        firefox
        # Mason will not work...
        # We need to manually install the lsp and point lsp-zero to it.
        neovim
        clang
        ripgrep
        cargo
        clippy
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];

    fonts.fontconfig.enable = true;

    xdg.configFile."alacritty".source = self + "/dots/alacritty/.config/alacritty";
    xdg.configFile."i3".source = self + "/dots/i3/.config/i3";
    xdg.configFile."nvim" = {
        source = self + "/dots/nvim/.config/nvim";
        recursive = true;
    };
    xdg.configFile."rofi".source = self + "/dots/rofi/.config/rofi";
    home.file.".local/share/rofi".source = self + "/dots/rofi/.local/share/rofi";

    home.stateVersion = stateVersion;
}
