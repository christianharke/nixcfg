{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.custom.roles.office;

in

{
  options = {
    custom.roles.office = {
      enable = mkEnableOption "Office";
    };
  };

  config = mkIf cfg.enable {
    custom.roles.office.cli.enable = true;

    home.packages = with pkgs; [
      reveal-md
    ]
    ++ optionals (!config.custom.base.non-nixos.isDarwin) [
      libreoffice
    ];
  };
}
