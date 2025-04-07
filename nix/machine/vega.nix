{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./common.nix
    ./hardware/vega.nix
    ../display/i3.nix
  ];

  # https://nixos.wiki/wiki/Nvidia
  hardware.graphics = {
    enable = true;
  };

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

  networking.hostName = "vega";
}
