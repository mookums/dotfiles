{
  config,
  pkgs,
  ...
}: {
  # imports = [./common.nix ./hardware/albatross.nix ../display/i3.nix];
  imports = [./common.nix ./hardware/albatross.nix ../display/hyprland.nix];

  programs.steam = {enable = true;};

  # https://nixos.wiki/wiki/Nvidia
  hardware.graphics = {enable = true;};
  boot.kernelParams = ["nvidia-drm.modeset=1"];
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  boot.loader.systemd-boot.enable = true;

  services.ollama = {
    enable = true;
    acceleration = "cuda";
    port = 11434;
  };

  services.open-webui = {
    enable = true;
    environment.OLLAMA_API_BASE_URL = "http://localhost:11434";
  };

  networking.hostName = "albatross";
}
