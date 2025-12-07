{
  pkgs,
  config,
  agenix,
  ...
}:
let
  hostName = "fog";
  hostStaticIp = "5.78.88.217";
  stateVersion = "25.05";
  headscalePort = 9892;
in
{
  imports = [
    ./hardware/fog.nix
    agenix.nixosModules.default
  ];

  deployment = {
    targetUser = "root";
    targetHost = hostStaticIp;
    tags = [ "server" ];
  };

  age.secrets = { };

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
      allowedTCPPorts = [ 443 ];
    };
  };

  services = {
    caddy = {
      enable = true;
      email = "muki@muki.gg";
      virtualHosts = {
        "tail.muki.gg".extraConfig = ''
          reverse_proxy 127.0.0.1:${toString headscalePort}
        '';
      };
    };

    headscale = {
      enable = true;
      address = "127.0.0.1";
      port = headscalePort;
      settings = {
        server_url = "https://tail.muki.gg";
        tls_key_path = null;
        tls_cert_path = null;

        dns = {
          magic_dns = true;
          base_domain = "intra.muki.gg";

          override_local_dns = false;
          extra_records = [ ];
        };
      };
    };
  };
}
