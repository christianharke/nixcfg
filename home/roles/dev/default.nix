{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.custom.roles.dev;

in

{
  options = {
    custom.roles.dev = {
      enable = mkEnableOption "Development configs";
    };
  };

  config = mkIf cfg.enable {
    custom.roles.dev = {
      embedmongo.enable = false;
      intellij = {
        enable = true;
        ultimate = true;
      };
      java.enable = true;
      js.enable = true;
      plantuml.enable = true;
      scala.enable = true;
    };

    home.packages = with pkgs; [
      ascii
      libxml2
      wrk
    ];
  };
}
