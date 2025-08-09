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

    wg-quick.interfaces.mullvad = {
      address = [
        "10.71.63.172/32"
        "fc00:bbbb:bbbb:bb01::8:3fab/128"
      ];

      privateKeyFile = config.age.secrets.mullvad-wg-key.path;

      peers = [
        {
          publicKey = "bZQF7VRDRK/JUJ8L6EFzF/zRw2tsqMRk6FesGtTgsC0=";
          allowedIPs = [
            "0.0.0.0/0"
            "::/0"
          ];
          endpoint = "138.199.43.91:51820";
          persistentKeepalive = 25;
        }
      ];
    };

  };

  systemd.services."netns@" = {
    description = "%I network namespace";
    before = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      PrivateNetwork = true;
      ExecStart = "${pkgs.writers.writeDash "netns-up" ''
        ${pkgs.iproute2}/bin/ip netns add $1
        ${pkgs.util-linux}/bin/umount /var/run/netns/$1 2>/dev/null || true
        ${pkgs.util-linux}/bin/mount --bind /proc/self/ns/net /var/run/netns/$1
      ''} %I";
      ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
      PrivateMounts = false;
    };
  };

  systemd.services.wg-vpn = {
    description = "WireGuard VPN in vpn namespace";
    bindsTo = [
      "netns@vpn.service"
      "wireguard-mullvad.service"
    ];
    after = [
      "netns@vpn.service"
      "wireguard-mullvad.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "wg-move" ''
        # Set the Mullvad VPN as the standard iface.
        ${pkgs.iproute2}/bin/ip link set mullvad netns vpn
        ${pkgs.iproute2}/bin/ip netns exec vpn ip link set mullvad up
        ${pkgs.iproute2}/bin/ip netns exec vpn ip route add default dev mullvad
      '';
      ExecStop = pkgs.writeShellScript "wg-restore" ''
        # Move interface back to host (for clean shutdown)
        ${pkgs.iproute2}/bin/ip netns exec vpn ip link set mullvad netns 1 || true
      '';
    };
  };

  # Override to use the Mullvad VPN Namespace
  systemd.services.transmission = {
    unitConfig.JoinsNamespaceOf = "netns@vpn.service";
    serviceConfig.PrivateNetwork = true;
    bindsTo = [ "netns@vpn.service" ];
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

    transmission = {
      enable = true;
      package = pkgs.transmission_4;
      settings = {
        # RPC/UI Settings
        rpc-bind-address = "0.0.0.0";
        rpc-host-whitelist-enabled = false;
        rpc-whitelist-enabled = true;
        rpc-whitelist = "127.0.0.1,100.64.0.*";
        rpc-authentication-required = false;
      };
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
