{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.wgns;
in
{
  options.services.wgns = {
    enable = lib.mkEnableOption "Isolated Network Namespaces secured with Wireguard";

    instances = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            namespace = lib.mkOption {
              type = lib.types.str;
              description = "Network namespace name";
            };
            addresses = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              description = "IP addresses for the interface";
            };

            privateKeyFile = lib.mkOption {
              type = lib.types.path;
              description = "Path to private key file";
            };

            listenPort = lib.mkOption {
              type = lib.types.nullOr lib.types.port;
              default = null;
              description = "Port to listen on";
            };

            peers = lib.mkOption {
              type = lib.types.listOf (
                lib.types.submodule {
                  options = {
                    publicKey = lib.mkOption {
                      type = lib.types.str;
                      description = "Peer public key";
                    };

                    allowedIPs = lib.mkOption {
                      type = lib.types.listOf lib.types.str;
                      description = "Allowed IP ranges";
                    };

                    endpoint = lib.mkOption {
                      type = lib.types.str;
                      description = "Peer endpoint";
                    };

                    persistentKeepalive = lib.mkOption {
                      type = lib.types.nullOr lib.types.int;
                      default = null;
                      description = "Persistent keepalive interval";
                    };
                  };
                }
              );
            };

            dns = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "DNS server for the namespace";
            };

            portForwarding = lib.mkOption {
              type = lib.types.listOf (
                lib.types.submodule {
                  options = {
                    port = lib.mkOption { type = lib.types.port; };
                    hostPort = lib.mkOption { type = lib.types.port; };
                    hostIp = lib.mkOption {
                      type = lib.types.str;
                      default = "0.0.0.0";
                    };

                  };
                }
              );
            };
            default = [ ];
            description = "Ports to forward from namespace to host";
          };
        }
      );
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services =
      lib.mapAttrs' (
        name: instanceConfig:
        lib.nameValuePair "netns@${instanceConfig.namespace}" {
          description = "${instanceConfig.namespace} network namespace";
          before = [ "network.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            PrivateNetwork = true;
            ExecStart = "${pkgs.iproute2}/bin/ip netns add ${instanceConfig.namespace}";
            ExecStop = "${pkgs.iproute2}/bin/ip netns del ${instanceConfig.namespace}";
            PrivateMounts = false;
          };
        }
      ) cfg.instances

      // lib.mapAttrs' (
        name: instanceConfig:
        lib.nameValuePair "wgns-${name}" {
          description = "WireGuard interface (${name}) in namespace ${instanceConfig.namespace}";
          bindsTo = [ "netns@${instanceConfig.namespace}.service" ];
          requires = [
            "netns@${instanceConfig.namespace}.service"
            "network-online.target"
          ];
          after = [
            "netns@${instanceConfig.namespace}.service"
            "network-online.target"
          ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart =
              with pkgs;
              writers.writeBash "wg-up-${name}" ''
                set -e

                # Loopback in namespace
                ${iproute2}/bin/ip -n ${instanceConfig.namespace} link set lo up

                # Create new link
                ${iproute2}/bin/ip link add wg-${instanceConfig.namespace} type wireguard

                # Move link into the namespace
                ${iproute2}/bin/ip link set wg-${instanceConfig.namespace} netns ${instanceConfig.namespace}

                # Add IP addresses
                ${lib.concatMapStringsSep "\n" (
                  addr:
                  if lib.hasInfix ":" addr then
                    "${iproute2}/bin/ip -n ${instanceConfig.namespace} -6 address add ${addr} dev wg-${instanceConfig.namespace}"
                  else
                    "${iproute2}/bin/ip -n ${instanceConfig.namespace} address add ${addr} dev wg-${instanceConfig.namespace}"
                ) instanceConfig.addresses}

                # Configure WireGuard
                ${iproute2}/bin/ip netns exec ${instanceConfig.namespace} \
                  ${wireguard-tools}/bin/wg set wg-${instanceConfig.namespace} \
                    ${
                      lib.optionalString (
                        instanceConfig.listenPort != null
                      ) "listen-port ${toString instanceConfig.listenPort}"
                    } \
                    private-key ${instanceConfig.privateKeyFile} \
                    ${lib.concatMapStringsSep " " (
                      peer:
                      "peer ${peer.publicKey} "
                      + "allowed-ips ${lib.concatStringsSep "," peer.allowedIPs} "
                      + "endpoint ${peer.endpoint} "
                      + lib.optionalString (
                        peer.persistentKeepalive or null != null
                      ) "persistent-keepalive ${toString peer.persistentKeepalive}"
                    ) instanceConfig.peers}

                # Bring up interface
                ${iproute2}/bin/ip -n ${instanceConfig.namespace} link set wg-${instanceConfig.namespace} up

                # Add default routes
                ${iproute2}/bin/ip -n ${instanceConfig.namespace} route add default dev wg-${instanceConfig.namespace}
                ${iproute2}/bin/ip -n ${instanceConfig.namespace} -6 route add default dev wg-${instanceConfig.namespace}

                ${lib.optionalString (instanceConfig.dns != null) ''
                  # Set DNS in namespace (if needed)
                  mkdir -p /etc/netns/${instanceConfig.namespace}
                  echo "nameserver ${instanceConfig.dns}" > /etc/netns/${instanceConfig.namespace}/resolv.conf
                ''}

              '';
            ExecStop =
              with pkgs;
              writers.writeBash "wg-down-${name}" ''
                ${iproute2}/bin/ip -n ${instanceConfig.namespace} route del default dev wg-${instanceConfig.namespace} 2>/dev/null || true
                ${iproute2}/bin/ip -n ${instanceConfig.namespace} -6 route del default dev wg-${instanceConfig.namespace} 2>/dev/null || true
                ${iproute2}/bin/ip -n ${instanceConfig.namespace} link del wg-${instanceConfig.namespace} 2>/dev/null || true
              '';
          };
        }
      ) cfg.instances

      // lib.mapAttrs' (
        name: instanceConfig:
        lib.nameValuePair "port-forward-${name}" (
          lib.mkIf (instanceConfig.portForwarding != [ ]) {
            description = "Port forwarding for ${instanceConfig.namespace} namespace";
            after = [ "wgns-${name}.service" ];
            wants = [ "wgns-${name}.service" ];
            bindsTo = [ "wgns-${name}.service" ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig = {
              Type = "simple";
              ExecStart =
                with pkgs;
                writers.writeBash "port-forward-${name}" ''
                  ${lib.concatMapStringsSep "\n" (portConfig: ''
                    echo "Starting proxy: ${portConfig.hostIp}:${toString portConfig.hostPort} -> ${instanceConfig.namespace}:${toString portConfig.port}"
                    ${socat}/bin/socat TCP-LISTEN:${toString portConfig.hostPort},bind=${portConfig.hostIp},reuseaddr,fork \
                      EXEC:"${iproute2}/bin/ip netns exec ${instanceConfig.namespace} ${socat}/bin/socat STDIO TCP\:127.0.0.1\:${toString portConfig.port}" &
                  '') instanceConfig.portForwarding}
                  wait
                '';
              Restart = "always";
            };
          }
        )
      ) cfg.instances;
  };
}
