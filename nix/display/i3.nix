{ pkgs, ... }: {
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # X11 Extras
  services.xserver.displayManager.lightdm.enable = true;

  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [ dex dunst i3status i3lock ];
  };

  services.pipewire = {
      enable = true;
      pulse.enable = true;
  };

  services.libinput.enable = true;

  programs.light.enable = true;

  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  environment.systemPackages = with pkgs; [
    rofi
    playerctl
    pavucontrol
    pcmanfm
    feh
    arandr
    xclip
  ];
}
