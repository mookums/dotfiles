{ pkgs, ...}:

{
    time.timeZone = "America/Los_Angeles";
    i18n.defaultLocale = "en_US.UTF-8";

    services.openssh.enable = true;
    networking.networkmanager.enable = true;
    programs.zsh.enable = true;

    users.users.muki = {
    	isNormalUser = true;
        shell = pkgs.zsh;
        home = "/home/muki";
        extraGroups = [ 
            "wheel" 
            "networkmanager"
            "video"
        ];
    };

    environment.systemPackages = with pkgs; [
        wget
        curl
        gnupg
        openssl
    ];
}
