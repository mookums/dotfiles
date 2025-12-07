{ pkgs, ... }:
{
  programs.niri = {
    enable = true;
  };

  services.displayManager.ly = {
    enable = true;
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
    waybar
    xwayland-satellite
    rofi
    pavucontrol
    pcmanfm
    wireplumber
    swaybg
    mako
    wl-clipboard
    wdisplays
  ];
}
