{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./common.nix
    ./hardware/albatross.nix
    ../display/sway.nix
  ];

  programs.steam = {
    enable = true;
  };

  # https://nixos.wiki/wiki/Nvidia
  hardware.graphics = {
    enable = true;
  };
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.tailscale.enable = true;

  boot.loader.systemd-boot.enable = true;

  networking.hostName = "albatross";
}
