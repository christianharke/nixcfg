{ config, lib, pkgs, ... }:

with lib;

let

  username = "christian";

  secretSmb = "smb-home-christian";

in

{
  custom.base.agenix.secrets = [
    secretSmb
  ];

  fileSystems =
    let
      target = "/mnt/home";
      fileserver = "sv-syno-01";
      fsType = "cifs";
      credentials = config.age.secrets."${secretSmb}".path;
      automount_opts = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=60" "x-systemd.device-timeout=5s" "x-systemd.mount-timeout=5s" ];
      auth_opts = [ "uid=1000" "gid=100" "credentials=${credentials}" ];
      options = automount_opts ++ auth_opts;
    in
    {
      "${target}/home" = {
        device = "//${fileserver}/home";
        inherit fsType;
        inherit options;
      };

      "${target}/music" = {
        device = "//${fileserver}/music";
        inherit fsType;
        inherit options;
      };

      "${target}/photo" = {
        device = "//${fileserver}/photo";
        inherit fsType;
        inherit options;
      };

      "${target}/public" = {
        device = "//${fileserver}/public";
        inherit fsType;
        inherit options;
      };

      "${target}/video" = {
        device = "//${fileserver}/video";
        inherit fsType;
        inherit options;
      };
    };

  users.users."${username}" = {
    shell = pkgs.zsh;
    name = username;
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "wheel"
      "audio"
      "video"
      "scanner"
    ];
    initialPassword = "changeme";
    openssh.authorizedKeys.keyFiles = [ ./christian_id_rsa.pub ];
  };
}
