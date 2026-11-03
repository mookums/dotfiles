{ pkgs, ... }:
{
  programs.sway = {
    enable = true;
    xwayland.enable = true;
    extraOptions = [ "--unsupported-gpu" ];
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd sway";
      };
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;
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
    rofi
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
    brightnessctl
    flameshot
  ];
}
