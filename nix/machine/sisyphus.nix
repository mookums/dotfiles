{
  pkgs,
  config,
  agenix,
  ...
}:
let
  hostName = "sisyphus";
  stateVersion = "24.11";

  tailscaleIp = "100.64.0.4";
  headscalePort = 9892;

  jellyfinPort = 8096;
  jellyseerrPort = 5055;
  transmissionPort = 9091;
  sonarrPort = 8989;
  radarrPort = 7878;
  prowlarrPort = 9696;
in
{
  imports = [
    ./hardware/sisyphus.nix
    agenix.nixosModules.default
    ./../module/mcwrap.nix
    ./../module/wgns.nix
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

  # Groups and Folders for Media.
  users.groups.media = { };
  users.users = {
    transmission.extraGroups = [ "media" ];
    sonarr.extraGroups = [ "media" ];
    radarr.extraGroups = [ "media" ];
    jellyfin.extraGroups = [ "media" ];
  };

  systemd.tmpfiles.rules = [
    "d /media 0755 root root -"
    "d /media/downloads 0775 transmission media -"
    "d /media/downloads/complete 0775 transmission media -"
    "d /media/downloads/incomplete 0775 transmission media -"
    "d /media/downloads/watch 0775 transmission media -"
    "d /media/movies 0775 radarr media -"
    "d /media/downloads/complete/radarr 0775 radarr media -"
    "d /media/tv 0775 sonarr media -"
    "d /media/downloads/complete/sonarr 0775 sonarr media -"
    "d /media/music 0775 jellyfin media -"
    "Z /media/downloads/complete/radarr 0664 radarr media -"
    "Z /media/downloads/complete/sonarr 0664 sonarr media -"
  ];

  services.wgns = {
    enable = true;
    instances = {
      mullvad = {
        namespace = "mullvad";
        addresses = [
          "10.72.143.32/32"
          "fc00:bbbb:bbbb:bb01::9:8f1f/128"
        ];
        privateKeyFile = config.age.secrets.mullvad-wg-key.path;
        peers = [
          {
            publicKey = "G6+A375GVmuFCAtvwgx3SWCWhrMvdQ+cboXQ8zp2ang=";
            allowedIPs = [
              "0.0.0.0/0"
              "::/0"
            ];
            endpoint = "23.234.81.127:51820";
            persistentKeepalive = 25;
          }
        ];
        dns = "100.64.0.7";
        portForwarding = [
          # Transmission
          {
            port = transmissionPort;
            hostPort = transmissionPort;
          }
        ];
      };
    };
  };

  # Override transmission so it runs inside of Mullvad.
  systemd.services.transmission = {
    requires = [ "wgns-mullvad.service" ];
    after = [ "wgns-mullvad.service" ];
    serviceConfig.NetworkNamespacePath = "/var/run/netns/mullvad";
  };

  systemd.services.caddy = {
    after = [ "headscale.service" ];
    wants = [ "headscale.service" ];
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

        "jellyfin.intra.muki.gg:80".extraConfig = ''
          reverse_proxy 127.0.0.1:${toString jellyfinPort}
        '';

        "jellyseerr.intra.muki.gg:80".extraConfig = ''
          reverse_proxy 127.0.0.1:${toString jellyseerrPort}
        '';

        "transmission.intra.muki.gg:80".extraConfig = ''
          reverse_proxy 127.0.0.1:${toString transmissionPort}
        '';

        "sonarr.intra.muki.gg:80".extraConfig = ''
          reverse_proxy 127.0.0.1:${toString sonarrPort}
        '';

        "radarr.intra.muki.gg:80".extraConfig = ''
          reverse_proxy 127.0.0.1:${toString radarrPort}
        '';

        "prowlarr.intra.muki.gg:80".extraConfig = ''
          reverse_proxy 127.0.0.1:${toString prowlarrPort}
        '';
      };
    };

    transmission = {
      enable = true;
      package = pkgs.transmission_4;
      settings = {
        # RPC/UI Settings
        rpc-port = transmissionPort;
        rpc-bind-address = "127.0.0.1";
        rpc-host-whitelist-enabled = false;
        rpc-whitelist-enabled = true;
        rpc-whitelist = "127.0.0.1,100.64.0.*";
        rpc-authentication-required = false;

        # Download directories
        download-dir = "/media/downloads/complete";
        incomplete-dir = "/media/downloads/incomplete";
        incomplete-dir-enabled = true;

        # Watch folder for .torrent files
        watch-dir = "/media/downloads/watch";
        watch-dir-enabled = true;

        # Other useful settings
        trash-original-torrent-files = true;
        rename-partial-files = true;
      };
    };

    prowlarr = {
      enable = true;
      settings.server.port = prowlarrPort;
    };

    sonarr = {
      enable = true;
      settings.server.port = sonarrPort;
    };

    radarr = {
      enable = true;
      settings.server.port = radarrPort;
    };

    jellyfin = {
      enable = true;
    };

    jellyseerr = {
      enable = true;
      port = jellyseerrPort;
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
          extra_records = [
            {
              name = "jellyfin.intra.muki.gg";
              type = "A";
              value = tailscaleIp;
            }
            {
              name = "jellyseerr.intra.muki.gg";
              type = "A";
              value = tailscaleIp;
            }
            {
              name = "transmission.intra.muki.gg";
              type = "A";
              value = tailscaleIp;
            }
            {
              name = "sonarr.intra.muki.gg";
              type = "A";
              value = tailscaleIp;
            }
            {
              name = "radarr.intra.muki.gg";
              type = "A";
              value = tailscaleIp;
            }
            {
              name = "prowlarr.intra.muki.gg";
              type = "A";
              value = tailscaleIp;
            }
          ];
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
