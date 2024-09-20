{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ./hardware/janus.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  #services.xserver.videoDrivers = [ "intel" "modesetting" ];

  networking.hostName = "janus";
}
