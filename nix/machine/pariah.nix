{
  self,
  pkgs,
  agenix,
  home-manager,
  ...
}:
let
  hostName = "pariah";
  stateVersion = "24.11";
in
{
  imports = [
    ./hardware/pariah.nix
    ../display/i3.nix
    # ../display/sway.nix
    # ../display/niri.nix
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
    tags = [ "laptop" ];
    allowLocalDeployment = true;
  };

  services.printing.enable = true;
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;

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
}
