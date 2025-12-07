{
  self,
  config,
  pkgs,
  agenix,
  home-manager,
  ...
}:
let
  hostName = "albatross";
  stateVersion = "24.11";
in
{
  imports = [
    ./hardware/albatross.nix
    # ../display/sway.nix
    ../display/niri.nix
    agenix.nixosModules.default
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.muki =
        { config, ... }:
        import ../users/muki.nix {
          inherit
            self
            pkgs
            config
            stateVersion
            ;
        };
    }
  ];

  system.stateVersion = stateVersion;
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  boot.loader.systemd-boot.enable = true;

  networking.hostName = hostName;

  deployment = {
    targetUser = "root";
    targetHost = hostName;
    tags = [ "desktop" ];
    allowLocalDeployment = true;
  };

  services.printing.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
      addresses = true;
    };
  };

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  programs.nix-ld.enable = true;
  programs.virt-manager.enable = true;
  programs.steam.enable = true;

  # https://nixos.wiki/wiki/Nvidia
  hardware.graphics.enable = true;
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
}
