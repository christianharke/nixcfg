{ config, lib, ... }:

with lib;

let

  cfg = config.custom.users.christian.hardware.kmonad;

in

{
  options = {
    custom.users.christian.hardware.kmonad = {
      enable = mkEnableOption "Kmonad service";
    };
  };

  config = mkIf cfg.enable {
    custom.roles.desktop.kmonad = {
      enable = true;
      configFiles = {
        WASD_V3 = ./configs/wasd-v3.de-ch.kbd;
        CHERRY_G80 = ./configs/cherry-mx-g80-3000n-tkl-rgb.de-ch.kbd;
      };
    };
  };
}
