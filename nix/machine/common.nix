{ pkgs, ...}:

{
    i18n.defaultLocale = "en_US.UTF-8";

    services.openssh.enable = true;
    networking.networkmanager.enable = true;

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
}
