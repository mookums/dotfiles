{ config, pkgs, ... }:

{
    imports = [
        ./common.nix
        /etc/nixos/hardware-configuration.nix
        # Jupiter uses i3.
        ../display/i3.nix
    ];

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/vda";

    networking.hostName = "jupiter";
}
