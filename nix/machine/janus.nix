{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ./hardware/janus.nix
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.videoDrivers = [ "intel" "modesetting" ];

  # X11 Extras
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [ dex dunst i3status i3lock ];
  };

  services.libinput.enable = true;

  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  programs.light.enable = true;

  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  environment.systemPackages = with pkgs; [
    rofi
    playerctl
    pavucontrol
    pcmanfm
    lxmenu-data
    xfce.xfce4-power-manager
    feh
    arandr
    xclip
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  networking.hostName = "janus";
}
