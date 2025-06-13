{ config
, lib
, pkgs
, ...
}:
with lib;

let
  cfg = config.services.labgrid.exporter;
  configFile = pkgs.stdenv.mkDerivation {
    name = "labgrid-exporter.conf";

    text = cfg.exporterConfig;

    preferLocalBuild = true;

    buildCommand = ''
      echo -n "$text" > $out
    '';
  };
in
{


  ###### interface

  options = {
    services.labgrid.exporter = {
      enable = lib.mkEnableOption "Labgrid Exporter";

      coordinator = mkOption {
        type = types.str;
        description = ''
          Labgrid coordinator URL
        '';
        example = "labgrid:20408";
      };

      exporterHostname = mkOption {
        type = types.str;
        description = "Set the exporter hostname";
      };

      isolated = mkOption {
        type = types.bool;
        default = false;
        description = "Enable isolated mode, forces ssh tunneling to the exporter";
        example = true;
      };

      package = mkPackageOption pkgs [ "python3Packages" "labgrid" ] { };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Additional command line parameters";
        example = [ "-d" ];
      };

      exporterConfig = mkOption {
        type = types.lines;
        description = "Exporter configuration.";
      };

      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ pkgs.ser2net ];
        defaultText = literalExpression "[ pkgs.ser2net ]";
        description = "Extra packages available to the labgrid exporter.";
        example = lib.literalExpression "[ pkgs.ser2net pkgs.usbsdmux ]";
      };

      extraGroups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "adbusers" "dialout" ];
        description = ''
          Additional groups for the systemd service.
        '';
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    systemd.tmpfiles = {
      rules = [
        "d /var/cache/labgrid	1775	root	users	2d"
      ];
    };

    systemd.services.labgrid-exporter = {
      description = "Labgrid Exporter Service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      path = cfg.extraPackages;
      serviceConfig = {
        ExecStart = escapeShellArgs (
          [
            "${getBin cfg.package}/bin/labgrid-exporter"
            "-c"
            cfg.coordinator
            configFile
          ]
          ++ cfg.extraArgs
        );
        DynamicUser = true;
        User = "labgrid-exporter";
        StandardOutput = "journal";
        SupplementaryGroups = cfg.extraGroups;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        RestrictNamespaces = true;
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_NETLINK AF_UNIX";
      };
    };
  };
}
