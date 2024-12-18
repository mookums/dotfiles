{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./common.nix
    ./hardware/owl.nix
    ../display/i3.nix
  ];

  services.xserver.videoDrivers = ["intel"];

  # Fingerprint Support
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;

  boot.loader.systemd-boot.enable = true;

  networking.hostName = "owl";
}
