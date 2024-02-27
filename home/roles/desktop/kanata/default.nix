{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.custom.roles.desktop.kanata;

  mkService = kbd-dev: kbd-path:
    {
      name = "kanata-${kbd-dev}";
      value = {
        Unit = {
          Description = "Kanata Instance for: ${kbd-dev}";
        };
        Service = {
          Type = "simple";
          Restart = "always";
          RestartSec = 10;
          ExecStart = "${lib.getExe cfg.package} ${kbd-path}";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };

in

{
  options.custom.roles.desktop.kanata = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable Kanata service.
      '';
    };

    configFiles = mkOption {
      type = types.attrsOf types.path;
      default = { };
      example = ''
        { G512 = ./my-config.kbd };
      '';
      description = ''
        Input devices mapped to their respective configuration file.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.unstable.kanata;
      description = ''
        The Kanata package.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    launchd.agents = {
      "kanata-macbook".config = {
        Program = "${cfg.package}";
      };
    };
    systemd.user.services = listToAttrs (mapAttrsToList mkService cfg.configFiles);
  };
}
