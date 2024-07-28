{ config, lib, pkgs, ... }:

let
    home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz";
in
{
    imports = [
        ./hardware-configuration.nix
        (import "${home-manager}/nixos")
    ];

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/vda";

    networking.hostName = "jupiter";
    networking.networkmanager.enable = true;

    # time.timeZone = "Europe/Amsterdam";

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Select internationalisation properties.
    # i18n.defaultLocale = "en_US.UTF-8";
    # console = {
    #   font = "Lat2-Terminus16";
    #   keyMap = "us";
    #   useXkbConfig = true; # use xkb.options in tty.
    # };

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # X11 Extras
    services.xserver.windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
            rofi
            i3status
            i3lock
        ];
    };
  
    # Configure keymap in X11
    # services.xserver.xkb.layout = "us";
    # services.xserver.xkb.options = "eurosign:e,caps:escape";

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound.
    hardware.pulseaudio.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    # services.libinput.enable = true;

    users.users.muki = {
        isNormalUser = true;
        home = "/home/muki";
        extraGroups = [ "wheel" ];
    };

    home-manager.users.muki = { pkgs, ... }: {
        home.packages = with pkgs; [
            alacritty
            git
            tmux
            polybar
            feh
            firefox
            neovim
            clang
            ripgrep
            cargo
            clippy
            (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        ];

        fonts.fontconfig.enable = true;

        #xdg.configFile."alacritty".source = "${dotfiles}/alacritty/.config/alacritty";
        #xdg.configFile."i3".source = "${dotfiles}/i3/.config/i3";
        #xdg.configFile."nvim".source = "${dotfiles}/nvim/.config/nvim";
        #xdg.configFile."rofi".source = "${dotfiles}/rofi/.config/rofi";
        #home.file.".local/share/rofi".source = "${dotfiles}/rofi/.local/share/rofi";

        #home.file.".tmux.conf".source = "${dotfiles}/tmux/.tmux.conf";

        home.stateVersion = "24.05";
    };

    environment.systemPackages = with pkgs; [
        wget
        curl
        gnupg
        openssl
    ];

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    system.stateVersion = "24.05";
}
