{ config, pkgs, ... }:

{
  imports = [ ./common.nix ./hardware/albatross.nix ../display/i3.nix ];

  programs.steam = { enable = true; };

  # https://nixos.wiki/wiki/Nvidia
  hardware.opengl = { enable = true; };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  boot.loader.systemd-boot.enable = true;

  networking.hostName = "albatross";
}
