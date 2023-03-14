{ config, lib, pkgs, ... }:

with lib;

let

  desktopCfg = config.custom.roles.desktop;
  cfg = desktopCfg.locker;

  lockScript = pkgs.writeShellScriptBin "lock" ''
    PAUSE=$\{PAUSE:-1}
    PLAY=0

    pauseMusic() {
      if [ "$\{PAUSE}" -eq 1 ]; then
        # playerctl is allowed to fail as it's the fastest way to determine if a player
        # is currently active
        set +e
        rs=$(playerctl status)
        playerctl pause 2> /dev/null
        set -e

        if [ "$\{rs}" = "Playing" ]; then
          PLAY=1
        fi
      fi
    }

    # locking workflow
    pauseMusic && \
    ${cfg.lockCmd}

    if [ "$\{PLAY}" -eq 1 ]; then
      playerctl play
    fi
  '';

in

{
  options = {
    custom.roles.desktop.locker = {
      package = mkOption {
        type = types.package;
        default = pkgs.betterlockscreen;
        description = "Locker package to use";
      };

      lockCmd = mkOption {
        type = types.str;
        default = "${lib.getExe pkgs.betterlockscreen} --lock dim";
        description = "Command to activate locker";
      };
    };
  };

  config = {
    home.packages = [
      cfg.package
    ] ++ (with pkgs; [
      playerctl
    ]);

    # Update random lock image on login
    xsession.initExtra = ''
      ${lib.getExe pkgs.betterlockscreen} --update ${desktopCfg.wallpapersDir} --fx dim &
    '';
  };
}
