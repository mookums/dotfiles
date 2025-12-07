{
  pkgs,
  config,
  agenix,
  ...
}:
let
  hostName = "sisyphus";
  stateVersion = "24.11";
in
{
  imports = [
    ./hardware/sisyphus.nix
    agenix.nixosModules.default
    # ./../module/mcwrap.nix
    # ./../module/wgns.nix
  ];

  deployment = {
    targetUser = "root";
    targetHost = hostName;
    tags = [ "server" ];
  };

  age.secrets = { };

  system.stateVersion = stateVersion;
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  boot.loader.systemd-boot.enable = true;

  networking = {
    hostName = hostName;
    firewall = {
      allowedTCPPorts = [ ];
    };
  };

  services = { };
}
