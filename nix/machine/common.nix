{
  pkgs,
  ...
}:
let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHuLvCc5ZJ3JSbfwYlSJZRNDFKhoKPsdu/TDV1YYs8rL muki@muki.gg"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJt49sSWYCcxVio2h9aWroPw5qiGnD/9T/zyqoCXgJZr muki@pariah"
  ];
in
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [ "@wheel" ];
      allowed-users = [ "@wheel" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };
  programs.zsh.enable = true;

  users.users = {
    root = {
      openssh.authorizedKeys = {
        keys = authorizedKeys;
      };
    };

    muki = {
      openssh.authorizedKeys = {
        keys = authorizedKeys;
      };
      isNormalUser = true;
      shell = pkgs.zsh;
      home = "/home/muki";
      initialPassword = "muki";
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "libvirtd"
        "docker"
      ];
    };
  };

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  services.fail2ban.enable = true;

  environment.systemPackages = with pkgs; [
    helix
    wget
    curl
    git
    tmux
    zip
    unzip
    file
    nix-output-monitor
  ];
}
