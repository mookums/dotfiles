{ config, pkgs, self, ... }:

{
    networking.hostName = "albatross";
    i18n.defaultLocale = "en_US.UTF-8";

    services.xserver.videoDrivers = [ "nvidia" ];
}
