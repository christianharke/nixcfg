{ config, lib, ... }:

let

  inherit (lib) mkEnableOption mkIf;

  cfg = config.custom.roles.nas.syncthing;

in

{
  options = {
    custom.roles.nas.syncthing = {
      enable = mkEnableOption "Syncthing config";
    };
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      dataDir = "/var/lib/syncthing";
      guiAddress = "0.0.0.0:8384";
      openDefaultPorts = true;
      settings = {
        devices = {
          altair = {
            addresses = [ "tcp://172.16.4.1:22000" ];
            id = "BOSJDVM-QMEQTKP-JSKLGT5-WLIBLRY-QFVJOKO-LMR3XNT-YXJA7OD-7LEJ3AA";
          };
          malmok = {
            addresses = [ "tcp://10.0.10.2:22000" ];
            id = "JJXAPCO-MOJLFVL-3YHBIXK-YUGQWXF-SWEGZTH-7DW2XAS-GDSQ3KC-RUQVBAB";
          };
          pc-win10-chr = {
            addresses = [ "tcp://172.16.4.1:22000" ];
            id = "CU6527N-PEXYFOV-YZSY5AI-UDRMM46-FM3BKUU-X3DSU4Y-JLEJ2YO-2CZBJAV";
          };
          pixel-7a = {
            addresses = [ "tcp://10.0.10.7:22000" ];
            id = "XKSHGGN-JSMIPZ3-MUDZHEM-LH2I6KZ-B3WTV3X-R2ZLCBI-QHPJTFR-ELYCIQN";
          };
          sirius-a = {
            addresses = [ ];
            id = "Z5CMWGO-QVYSG5A-ERDY57R-CZSI56V-6ZRRQ6U-WPA37ZL-DCT3MSZ-57MQWAW";
          };
          sv-syno-01 = {
            addresses = [ "tcp://172.16.2.3:22000" ];
            id = "EEEGHSK-UVNRNLA-2TFEOEV-RHMALFK-T4IT65L-TIJB5EA-25UXOGH-J4ZURQ7";
          };
        };

        folders = {
          FreeTube = {
            enable = true;
            devices = [
              config.services.syncthing.settings.devices.altair.name
              config.services.syncthing.settings.devices.pc-win10-chr.name
              config.services.syncthing.settings.devices.malmok.name
              config.services.syncthing.settings.devices.pixel-7a.name
            ];
            path = "/data/syncthing/FreeTube";
          };
          RetroDeck = {
            enable = true;
            devices = [
              config.services.syncthing.settings.devices.sirius-a.name
            ];
            path = "/data/syncthing/RetroDeck";
          };
        };
      };
    };
  };
}
