{ config, pkgs, ... }:

{
    imports = [
        ./common.nix
        ./hardware/sirius.nix
        # Sirius uses i3.
        ../display/i3.nix
    ];

    # Wireless Peripherals
    hardware.logitech.wireless = {
        enable = true;
        enableGraphical = true;
    };

    # https://nixos.wiki/wiki/Nvidia
    hardware.opengl = {
        enable = true;
    };

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;

        prime = {
            offload = {
                enable = true;
                enableOffloadCmd = true;
            };

            intelBusId = "PCI:0:2:0";
            nvidiaBusId = "PCI:1:0:0";
        };
    };

    boot.loader.systemd-boot.enable = true;

    networking.hostName = "sirius";
}
