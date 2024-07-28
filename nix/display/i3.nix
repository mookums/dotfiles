{ pkgs, ... }: {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # X11 Extras
    services.xserver.windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
            rofi
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
        pavucontrol 
    ];
}
