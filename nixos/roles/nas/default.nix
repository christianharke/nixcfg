{
  config,
  lib,
  pkgs,
  ...
}:

let

  inherit (lib) getExe mkEnableOption mkIf;

  cfg = config.custom.roles.nas;

  secretNtfyToken = "${config.custom.base.hostname}/ntfy-token";
  secretNtfyUrl = "${config.custom.base.hostname}/ntfy-url";

in

{
  options = {
    custom.roles.nas = {
      enable = mkEnableOption "NAS config";
    };
  };

  config = mkIf cfg.enable {
    custom = {
      base = {
        agenix.secrets = [
          secretNtfyToken
          secretNtfyUrl
        ];

        system = {
          boot.secureBoot = true;
          btrfs.impermanence.enable = true;
          luks.remoteUnlock = true;
          network.wol.enable = true;
        };
      };

      roles.nas = {
        plex.enable = true;
        syncthing.enable = true;
      };
    };

    powerManagement =
      let
        ntfyTopic = "chris-alerts";
        mkNtfyCommand = body: ''
          ${getExe pkgs.curl} \
            -H "Authorization:Bearer $(${pkgs.coreutils}/bin/cat ${
              config.age.secrets.${secretNtfyToken}.path
            })" \
            -d '${builtins.toJSON (body // { topic = ntfyTopic; })}' \
            "$(${pkgs.coreutils}/bin/cat ${config.age.secrets.${secretNtfyUrl}.path})"
        '';
      in
      {
        powerDownCommands = mkNtfyCommand {
          title = "Hyperion is going to save some power...";
          message = "See you later!";
          tags = [ "electric_plug" ];
          actions = [
            {
              action = "view";
              label = "Wake up";
              url = "http://sv-syno-01:8090/";
              clear = true;
            }
          ];
        };

        powerUpCommands = mkNtfyCommand {
          title = "Hyperion is ready to serve data";
          message = "Lets goo!";
          tags = [ "floppy_disk" ];
          actions = [
            {
              action = "view";
              label = "Check status";
              url = "http://hyperion:61208/";
              clear = true;
            }
          ];
        };
      };

    services.glances = {
      enable = true;
      openFirewall = true;
    };
  };
}
