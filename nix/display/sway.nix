{ pkgs, ... }:
{
  programs.sway = {
    enable = true;
    xwayland.enable = true;
    extraOptions = [ "--unsupported-gpu" ];
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

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  environment.systemPackages = with pkgs; [
    i3status
    rofi-wayland
    pavucontrol
    pcmanfm
    wireplumber
    grim
    slurp
    swaybg
    jq
    mako
    wl-clipboard
    wdisplays
  ];
}
