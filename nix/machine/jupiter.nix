{ config, pkgs, ... }:

{
    imports = [
        ./hardware/jupiter.nix
        # Jupiter uses i3.
        ../display/i3.nix
    ];

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/vda";

    networking.hostName = "jupiter";
    i18n.defaultLocale = "en_US.UTF-8";

    users.users.muki = {
    	isNormalUser = true;
        home = "/home/muki";
        extraGroups = [ "wheel" ];
    };
   
    environment.systemPackages = with pkgs; [
        wget
        curl
        gnupg
        openssl
    ];

    services.openssh.enable = true;
}
