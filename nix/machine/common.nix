{
  pkgs,
  ...
}:
{
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
      trusted-users = ["@wheel"];
      allowed-users = ["@wheel"];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  services.openssh.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  programs.zsh.enable = true;

  users.users.muki = {
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

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

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
