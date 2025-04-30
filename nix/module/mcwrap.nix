{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mcWrap;
  exec = pkgs.writeShellApplication {
    name = "run-minecraft-script";

    runtimeInputs = [
      cfg.javaPackage
      pkgs.bash
    ];

    text = ''
      bash ${cfg.scriptPath};
    '';
  };
in
{
  options.services.mcWrap = {
    enable = lib.mkEnableOption "McWrap";

    user = lib.mkOption {
      type = lib.types.str;
      default = "minecraft";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "minecraft";
    };

    scriptPath = lib.mkOption {
      type = lib.types.str;
    };

    javaPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.openjdk;
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      home = "/home/${cfg.user}";
      group = cfg.group;
      createHome = true;
    };

    users.groups.${cfg.group} = { };

    systemd.services.mcWrap = {
      description = "Minecraft Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";
        RestartSec = "5s";
        ExecStart = lib.getExe exec;
        WorkingDirectory = builtins.dirOf cfg.scriptPath;
      };
    };
  };
}
