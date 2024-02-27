{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.custom.roles.desktop.kmonad;

  mkService = kbd-dev: kbd-path:
    {
      name = "kmonad-${kbd-dev}";
      value = {
        Unit = {
          Description = "KMonad Instance for: ${kbd-dev}";
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
  options.custom.roles.desktop.kmonad = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable KMonad service.
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
      default = pkgs.haskellPackages.kmonad;
      description = ''
        The KMonad package.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    systemd.user.services = listToAttrs (mapAttrsToList mkService cfg.configFiles);
  };
}
