{
  pkgs,
  config,
  agenix,
  ...
}:
let
  hostName = "sisyphus";
  stateVersion = "24.11";

  headscalePort = 9892;
in
{
  imports = [
    ./hardware/sisyphus.nix
    agenix.nixosModules.default
    ./../module/mcwrap.nix
  ];

  deployment = {
    targetUser = "root";
    targetHost = "${hostName}.intra.muki.gg";
    tags = [ "server" ];
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
    firewall = {
      allowedTCPPorts = [
        80
        443
      ];
    };
  };

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  services = {
    ddclient = {
      enable = true;
      server = "api.cloudflare.com/client/v4";
      passwordFile = config.age.secrets.cloudflare-api.path;
      protocol = "cloudflare";
      domains = [
        "tail.muki.gg"
      ];
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
        "tail.muki.gg".extraConfig = ''
          reverse_proxy 127.0.0.1:${toString headscalePort}
        '';
      };
    };

    mullvad-vpn = {
      enable = true;
    };

    transmission = {
      enable = true;
      package = pkgs.transmission_4;
    };

    jellyfin = {
      enable = true;
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
        };
      };
    };

    mcWrap = {
      enable = true;
      scriptPath = "/home/minecraft/atm9/run.sh";
      user = "minecraft";
      group = "minecraft";
    };
  };
}
