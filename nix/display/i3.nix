{ pkgs, ... }: {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # X11 Extras
    services.xserver.windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
            dex
            rofi
            i3status
            i3lock
            dunst
            xfce.xfce4-power-manager
            polybar
            feh
            arandr
            xclip
            light
        ];
    };

    services.libinput.enable = true;
    sound.enable = true;
    hardware.pulseaudio = {
        enable = true;
        package = pkgs.pulseaudioFull;
    };

    environment.systemPackages = with pkgs; [
        playerctl
        pavucontrol 
    ];
}
