{
  config,
  ...
}:
let
  hostName = "vega";
in
{
  imports = [
    ./common.nix
    ./hardware/vega.nix
    ../display/sway.nix
  ];

  system.stateVersion = "24.11";
  time.timeZone = "America/Los_Angeles";
  boot.loader.systemd-boot.enable = true;
  networking.hostName = hostName;

  deployment = {
    targetHost = "${hostName}.intra.muki.gg";
    tags = [ "desktop" ];
    allowLocalDeployment = true;
  };

  # https://nixos.wiki/wiki/Nvidia
  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    enable = true;
  };
}
