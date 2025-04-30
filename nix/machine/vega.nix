{
  config,
  ...
}:
{
  imports = [
    ./common.nix
    ./hardware/vega.nix
    ../display/i3.nix
  ];

  system.stateVersion = "24.11";
  time.timeZone = "America/Los_Angeles";
  boot.loader.systemd-boot.enable = true;
  networking.hostName = "vega";

  deployment = {
    targetHost = null;
    tags = [ "thome" ];
    allowLocalDeployment = true;
  };

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
}
