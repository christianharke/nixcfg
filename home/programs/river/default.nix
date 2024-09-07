{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.custom.programs.river;

  package =
    if config.custom.base.non-nixos.enable
    then config.lib.custom.nixGLWrap pkgs.river
    else pkgs.river;

in

{
  options = {
    custom.programs.river = {
      enable = mkEnableOption "River window manager";

      modKey = mkOption {
        type = types.enum [ "mod1" "mod2" "mod4" ];
        default = "mod4";
        description = ''
          The window manager mod key.
          <itemizedList>
            <listItem>Alt key is <code>mod1</code></listItem>
            <listItem>Apple key on OSX is <code>mod2</code></listItem>
            <listItem>Windows key is <code>mod4</code></listItem>
          <itemizedList>
        '';
      };

      autoruns = mkOption {
        type = with types; attrsOf int;
        default = { };
        description = ''
          applications to be launched in a workspace of choice.
        '';
        example = literalExpression ''
          {
            "firefox" = 1;
            "slack" = 2;
            "spotify" = 3;
          }
        '';
      };

      colorScheme = {
        foreground = mkOption {
          type = types.str;
          default = "#BBBBBB";
        };

        background = mkOption {
          type = types.str;
          default = "#000000";
        };

        base = mkOption {
          type = types.str;
          default = "#6586c8";
        };

        accent = mkOption {
          type = types.str;
          default = "#FF7F00";
        };

        warn = mkOption {
          type = types.str;
          default = "#FF5555";
        };
      };

      launcherCmd = mkOption {
        type = types.str;
        default = "${pkgs.dmenu}/bin/dmenu_run";
        description = "Command to run dmenu";
      };

      locker = {
        package = mkOption {
          type = types.package;
          default = pkgs.i3lock;
          description = "Locker util";
        };

        lockCmd = mkOption {
          type = types.str;
          default = "${pkgs.i3lock}/bin/i3lock";
          description = "Command for locking screen";
        };
      };

      screenshot = {
        package = mkOption {
          type = types.package;
          default = pkgs.scrot;
          description = "Screenshot util";
        };

        runCmdFull = mkOption {
          type = types.str;
          default = "${./scripts/screenshot.sh} full";
          description = "Command for taking full-screen screenshots";
        };

        runCmdSelect = mkOption {
          type = types.str;
          default = "${./scripts/screenshot.sh} select";
          description = "Command for taking selection screenshots";
        };

        runCmdWindow = mkOption {
          type = types.str;
          default = "${./scripts/screenshot.sh} window";
          description = "Command for taking window screenshots";
        };
      };

      passwordManager = {
        command = mkOption {
          type = types.str;
          description = "Command to spawn the default password manager";
        };
        wmClassName = mkOption {
          type = types.str;
          description = "Window manager class name retrieved via `xprop` utility";
        };
      };

      terminalCmd = mkOption {
        type = types.str;
        description = "Command to spawn the default terminal emulator";
      };

      wiki = {
        command = mkOption {
          type = types.str;
          description = "Command to spawn the default wiki app";
        };
        wmClassName = mkOption {
          type = types.str;
          description = "Window manager class name retrieved via `xprop` utility";
        };
      };

    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [
        #cfg.locker.package
        #cfg.screenshot.package
      ];
    };

    wayland.windowManager.river = {
      inherit package;

      enable = true;
      settings = {
        #border-width = 2;
        #declare-mode = [
        #  "locked"
        #  "normal"
        #  "passthrough"
        #];
        #input = {
        #  pointer-foo-bar = {
        #    accel-profile = "flat";
        #    events = true;
        #    pointer-accel = -0.3;
        #    tap = false;
        #  };
        #};
        map = {
          normal = {
            "Super+Shift Return" = "spawn alacritty";
            "Super+Shift C" = "close";
            "Super+Shift Q" = "exit";
            "Super J" = "focus-view next";
            "Super K" = "focus-view previous";
            "Super+Shift J" = "swap next";
            "Super+Shift K" = "swap previous";
          };
        };
        #rule-add = {
        #  "-app-id" = {
        #    "'bar'" = "csd";
        #    "'float*'" = {
        #      "-title" = {
        #        "'foo'" = "float";
        #      };
        #    };
        #  };
        #};
        #set-cursor-warp = "on-output-change";
        #set-repeat = "50 300";
        spawn = [
          "alacritty"
          "firefox"
        ];
        #xcursor-theme = "someGreatTheme 12";
      };
    };
  };
}
