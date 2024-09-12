{ pkgs, ... }:

{
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
  };

  services.openssh.enable = true;
  programs.gnupg.agent.enable = true;

  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

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

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  programs.zsh.enable = true;

  users.users.muki = {
    isNormalUser = true;
    shell = pkgs.zsh;
    home = "/home/muki";
    initialPassword = "muki";
    extraGroups = [ "wheel" "networkmanager" "video" "libvirtd" "docker" ];
  };

  environment.systemPackages = with pkgs; [ wget curl zip unzip ];
}
