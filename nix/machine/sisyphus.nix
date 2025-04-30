{
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
  ];

  deployment = {
    targetUser = "root";
    targetHost = "${hostName}.home";
    buildOnTarget = false;
    tags = [ "home" ];
  };

  age.secrets = {
    cloudflare-api = {
      file = ./../../secrets/cloudflare-api.age;
    };
  };

  system.stateVersion = stateVersion;
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  boot.loader.systemd-boot.enable = true;

  networking = {
    hostName = hostName;
    # domain = "sisyphus.home";
    firewall.allowedTCPPorts = [
      80
      443
    ];
  };

  services = {
    ddclient = {
      enable = true;
      server = "api.cloudflare.com/client/v4";
      passwordFile = config.age.secrets.cloudflare-api.path;
      protocol = "cloudflare";
      domains = [ "muki.gg" ];
      usev4 = "webv4";
      usev6 = "no";
      extraConfig = ''
        ssl=yes
        zone=muki.gg
        webv4=ipify-ipv4
      '';
    };

    caddy = {
      enable = true;
      email = "muki@muki.gg";
      virtualHosts = {
        "muki.gg".extraConfig = ''
          reverse_proxy 127.0.0.1:9862
        '';
      };
    };
  };
}
