{
  self,
  pkgs,
  home-manager,
  ...
}:
let
  hostName = "janus";
  stateVersion = "24.11";
in
{
  imports = [
    ./hardware/janus.nix
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.muki =
        { ... }:
        import ../users/muki.nix {
          inherit
            self
            pkgs
            stateVersion
            ;
          minimal = true;
        };
    }
  ];

  system.stateVersion = stateVersion;
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  networking = {
    hostName = hostName;
    firewall = {
      trustedInterfaces = [ "tailscale0" ];
    };
  };

  deployment = {
    targetUser = "root";
    targetHost = "${hostName}.local";
    tags = [ "laptop" ];
    allowLocalDeployment = true;
  };

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
}
