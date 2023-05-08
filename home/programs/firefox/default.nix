{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.custom.programs.firefox;

in

{
  options = {
    custom.programs.firefox = {
      enable = mkEnableOption "Firefox web browser";

      extensions = mkOption {
        type = with types; listOf package;
        default = [ ];
        description = ''
          List of extension names to be installed. Source: https://gitlab.com/rycee/nur-expressions/-/blob/master/pkgs/firefox-addons/generated-firefox-addons.nix
        '';
      };

      homepage = mkOption {
        type = types.str;
        default = "https://harke.ch/";
        description = ''
          Home page for new tabs and windows.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      inherit (cfg) enable extensions;

      profiles."ztbvdcs8.default" = {
        isDefault = true;
        settings = {
          "browser.startup.homepage" = cfg.homepage;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
      };
    };
  };
}
