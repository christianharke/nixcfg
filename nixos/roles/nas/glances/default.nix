{
  config,
  lib,
  pkgs,
  ...
}:

let

  cfg = config.custom.roles.nas.glances;

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.generators) toINI;

  package = pkgs.glances.overridePythonAttrs (prev: {
    propagatedBuildInputs =
      with pkgs.python3Packages;
      (prev.propagatedBuildInputs or [ ]) ++ [ pymdstat ];
  });

in

{
  options = {
    custom.roles.nas.glances = {
      enable = mkEnableOption "Glances config";

      host = mkOption {
        type = types.str;
        default = "glances.local.harke.ch";
        description = "Host name where glances is available on";
      };
    };
  };

  config = mkIf cfg.enable {
    environment = {
      etc."glances/glances.conf".text = toINI { } {
        global = {
          check_update = false;
        };
        diskio = {
          hide = "dm-.*,loop.*";
        };
        raid = {
          disable = false;
        };
      };

      systemPackages = with pkgs; [ hddtemp ];
    };

    services = {
      glances = {
        inherit package;
        enable = true;
        openFirewall = true;
      };

      traefik = {
        dynamicConfigOptions = {
          http = {
            services = {
              glances.loadBalancer.servers = [
                { url = "http://localhost:${toString config.services.glances.port}"; }
              ];
            };

            routers = {
              glances = {
                entryPoints = [ "websecure" ];
                rule = "Host(`${cfg.host}`)";
                service = "glances";
                tls.certResolver = "letsencrypt";
              };
            };
          };
        };
      };
    };
  };
}
