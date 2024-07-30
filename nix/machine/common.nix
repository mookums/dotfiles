{ pkgs, ... }:

{
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.enable = true;
  programs.gnupg.agent.enable = true;

  networking.networkmanager.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  programs.zsh.enable = true;

  users.users.muki = {
    isNormalUser = true;
    shell = pkgs.zsh;
    home = "/home/muki";
    initialPassword = "muki";
    extraGroups = [ "wheel" "networkmanager" "video" ];
  };

  environment.systemPackages = with pkgs; [ wget curl openssl ];
}
