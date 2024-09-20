{ pkgs, ... }:

{
  # Enable Printing
  services.printing.enable = true;

  # Enable Virtualization & Docker
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}
