{
  self,
  config,
  pkgs,
  agenix,
  home-manager,
  zen-browser,
  ...
}:
let
  hostName = "albatross";
  stateVersion = "24.11";
in
{
  imports = [
    ./hardware/albatross.nix
    ../display/sway.nix
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
            zen-browser
            ;
        };
    }
  ];

  age.secrets = {
    mullvad-wg-key = {
      file = ./../../secrets/mullvad-wg-key.age;
    };
  };

  system.stateVersion = stateVersion;
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  boot.loader.systemd-boot.enable = true;

  networking.hostName = hostName;

  # systemd.services."netns@" = {
  #   description = "%I network namespace";
  #   before = [ "network.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     PrivateNetwork = true;
  #     ExecStart = "${pkgs.iproute2}/bin/ip netns add %I";
  #     ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
  #     PrivateMounts = false;
  #   };
  # };

  # systemd.services.wg-mullvad = {
  #   description = "wg network interface (mullvad)";
  #   bindsTo = [ "netns@mullvad.service" ];
  #   requires = [
  #     "netns@mullvad.service"
  #     "network-online.target"
  #   ];
  #   after = [
  #     "netns@mullvad.service"
  #     "network-online.target"
  #   ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     ExecStart =
  #       with pkgs;
  #       writers.writeBash "wg-up" ''
  #         set -e

  #         # Loopback in namespace
  #         ${iproute2}/bin/ip -n mullvad link set lo up
  #         # Create new link for Mullvad
  #         ${iproute2}/bin/ip link add wg-mullvad type wireguard
  #         # Move link into the namespace.
  #         ${iproute2}/bin/ip link set wg-mullvad netns mullvad
  #         # Add IPs for the new link.
  #         ${iproute2}/bin/ip -n mullvad address add 10.72.143.32/32 dev wg-mullvad
  #         ${iproute2}/bin/ip -n mullvad  -6 address add fc00:bbbb:bbbb:bb01::9:8f1f/128 dev wg-mullvad
  #         # Configure Wireguard inside of the namespace.
  #         ${iproute2}/bin/ip netns exec mullvad \
  #           ${wireguard-tools}/bin/wg set wg-mullvad \
  #             private-key ${config.age.secrets.mullvad-wg-key.path} \
  #             peer G6+A375GVmuFCAtvwgx3SWCWhrMvdQ+cboXQ8zp2ang= \
  #             allowed-ips 0.0.0.0/0,::0/0 \
  #             endpoint 23.234.81.127:51820 \
  #             persistent-keepalive 25
  #         ${iproute2}/bin/ip -n mullvad link set wg-mullvad up
  #         ${iproute2}/bin/ip -n mullvad route add default dev wg-mullvad
  #         ${iproute2}/bin/ip -n mullvad -6 route add default dev wg-mullvad
  #       '';
  #     ExecStop =
  #       with pkgs;
  #       writers.writeBash "wg-down" ''
  #         ${iproute2}/bin/ip -n mullvad route del default dev wg-mullvad || true
  #         ${iproute2}/bin/ip -n mullvad -6 route del default dev wg-mullvad || true
  #         ${iproute2}/bin/ip -n mullvad link del wg-mullvad || true
  #       '';
  #   };
  # };

  # systemd.services.tailscale-mullvad-proxy = {
  #   description = "Proxy Tailscale access to mullvad namespace";
  #   after = [
  #     "wg-mullvad.service"
  #     "tailscaled.service"
  #   ];
  #   wants = [
  #     "wg-mullvad.service"
  #     "tailscaled.service"
  #   ];
  #   wantedBy = [ "multi-user.target" ];

  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart =
  #       with pkgs;
  #       writers.writeBash "tailscale-proxy" ''
  #         # Get the Tailscale IP
  #         TAILSCALE_IP=$(${iproute2}/bin/ip addr show tailscale0 | grep -oP 'inet \K[^/]+')

  #         # Proxy Transmission web UI from namespace to Tailscale interface
  #         exec ${socat}/bin/socat TCP-LISTEN:9091,bind=$TAILSCALE_IP,reuseaddr,fork \
  #           EXEC:"${iproute2}/bin/ip netns exec mullvad ${socat}/bin/socat STDIO TCP\:127.0.0.1\:9091"
  #       '';
  #     Restart = "always";
  #   };
  # };

  # DNS for the mullvad namespace
  # environment.etc."netns/mullvad/resolv.conf".text = "nameserver 100.64.0.7";

  deployment = {
    targetUser = "root";
    targetHost = "${hostName}.intra.muki.gg";
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
