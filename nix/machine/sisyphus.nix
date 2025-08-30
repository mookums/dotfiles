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
    # ./../module/wgns.nix
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
    mullvad-wg-key = {
      file = ./../../secrets/mullvad-wg-key.age;
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

  services = {
    # wgns = {
    #   enable = true;
    #   instances = {
    #     mullvad = {
    #       namespace = "mullvad";
    #       addresses = [
    #         "10.72.143.32/32"
    #         "fc00:bbbb:bbbb:bb01::9:8f1f/128"
    #       ];
    #       privateKeyFile = config.age.secrets.mullvad-wg-key.path;
    #       peers = [
    #         {
    #           publicKey = "G6+A375GVmuFCAtvwgx3SWCWhrMvdQ+cboXQ8zp2ang=";
    #           allowedIPs = [
    #             "0.0.0.0/0"
    #             "::/0"
    #           ];
    #           endpoint = "23.234.81.127:51820";
    #           persistentKeepalive = 25;
    #         }
    #       ];
    #       dns = "100.64.0.7";
    #       portForwarding = [ ];
    #     };
    #   };
    # };

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
          extra_records = [ ];
        };
      };
    };

    # mcWrap = {
    #   enable = true;
    #   scriptPath = "/home/minecraft/atm9/run.sh";
    #   user = "minecraft";
    #   group = "minecraft";
    # };
  };
}
