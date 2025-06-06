{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  useHostResolvConf = config.networking.resolvconf.enable && config.networking.useHostResolvConf;

  bootStage2 = pkgs.replaceVarsWith {
    src = ./stage-2-init.sh;
    isExecutable = true;
    replacements = {
      shell = "${pkgs.bash}/bin/bash";
      systemConfig = null; # replaced in ../activation/top-level.nix
      inherit (config.boot) readOnlyNixStore systemdExecutable;
      inherit (config.system.nixos) distroName;
      inherit useHostResolvConf;
      inherit (config.system.build) earlyMountScript;
      path = lib.makeBinPath (
        [
          pkgs.coreutils
          pkgs.util-linux
        ]
        ++ lib.optional useHostResolvConf pkgs.openresolv
      );
      postBootCommands = pkgs.writeText "local-cmds" ''
        ${config.boot.postBootCommands}
        ${config.powerManagement.powerUpCommands}
      '';
    };
  };

in

{
  options = {

    boot = {

      postBootCommands = mkOption {
        default = "";
        example = "rm -f /var/log/messages";
        type = types.lines;
        description = ''
          Shell commands to be executed just before systemd is started.
        '';
      };

      readOnlyNixStore = mkOption {
        type = types.bool;
        default = true;
        description = ''
          If set, NixOS will enforce the immutability of the Nix store
          by making {file}`/nix/store` a read-only bind
          mount.  Nix will automatically make the store writable when
          needed.
        '';
      };

      systemdExecutable = mkOption {
        default = "/run/current-system/systemd/lib/systemd/systemd";
        type = types.str;
        description = ''
          The program to execute to start systemd.
        '';
      };

      extraSystemdUnitPaths = mkOption {
        default = [ ];
        type = types.listOf types.str;
        description = ''
          Additional paths that get appended to the SYSTEMD_UNIT_PATH environment variable
          that can contain mutable unit files.
        '';
      };
    };

  };

  config = {

    system.build.bootStage2 = bootStage2;

  };
}
