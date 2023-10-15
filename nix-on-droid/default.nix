{ config, lib, pkgs, homeModules, inputs, ... }:

with lib;

let

  cfg = config.custom.base;

in

{
  options = {
    custom.base = {
      hostname = mkOption {
        type = types.str;
        description = "Host name.";
      };
    };
  };

  config = {
    environment = {
      etcBackupExtension = ".nod-bak";
      motd = ''
             __     ( )               ___       __            ___   /  __      ___     ( )  ___   /
          //   ) ) / / \\ / / ____  //   ) ) //   ) ) ____  //   ) / //  ) ) //   ) ) / / //   ) /
         //   / / / /   \/ /       //   / / //   / /       //   / / //      //   / / / / //   / /
        //   / / / /    / /\      ((___/ / //   / /       ((___/ / //      ((___/ / / / ((___/ /
      '';

      packages = with pkgs; [
        diffutils
        findutils
        git
        gnugrep
        hostname
        man
        openssh
        vim
      ];
    };

    home-manager = {
      backupFileExtension = "hm-bak";
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };
      sharedModules = homeModules;

      config = "${inputs.self}/hosts/${cfg.hostname}/home-nix-on-droid.nix";
    };

    nix.package = pkgs.nix;

    terminal.font =
      let
        fontPackage = pkgs.nerdfonts.override {
          fonts = [ "VictorMono" ];
        };
        fontPath = "/share/fonts/truetype/NerdFonts/VictorMonoNerdFont-Regular.ttf";
      in
      fontPackage + fontPath;

    time.timeZone = "Europe/Zurich";

    user.shell = "${pkgs.zsh}/bin/zsh";
  };
}
