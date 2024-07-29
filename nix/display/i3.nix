{ pkgs, ... }: {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # X11 Extras
    services.xserver.windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
            dex
            dunst
            i3status
            i3lock
        ];
    };

    services.libinput.enable = true;

    sound.enable = true;
    hardware.pulseaudio = {
        enable = true;
        package = pkgs.pulseaudioFull;
    };

    environment.systemPackages = with pkgs; [
        rofi
        playerctl
        pavucontrol 
        xfce.xfce4-power-manager
        feh
        arandr
        xclip
        light
        (polybar.override { pulseSupport = true; })
    ];
}
