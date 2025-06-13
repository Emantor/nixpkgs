{ config
, lib
, pkgs
, ...
}:
with lib;

let
  cfg = config.services.labgrid.coordinator;
in
{


  ###### interface

  options = {
    services.labgrid.coordinator = {
      enable = lib.mkEnableOption "Labgrid Coordinator";
      bindAddress = lib.mkOption {
        default = "0.0.0.0";
        type = lib.types.str;
        description = "Bind address for the labgrid coordinator.";
      };
      port = lib.mkOption {
        default = 20408;
        type = lib.types.port;
        description = "Coordinator port to bind to.";
      };
      openFirewall = lib.mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to automatically open the coordinator listen port in the firewall.
        '';
      };

      package = mkPackageOption pkgs [ "python3Packages" "labgrid" ] { };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Additional command line parameters";
        example = [ "-d" ];
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.labgrid-coordinator = {
      description = "Labgrid Coordinator Service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = escapeShellArgs (
          [
            "${getBin cfg.package}/bin/labgrid-coordinator"
            "-l"
            "${cfg.bindAddress}:${toString cfg.port}"
          ]
          ++ cfg.extraArgs
        );
        DynamicUser = true;
        User = "labgrid-coordinator";
        StateDirectory = "labgrid-coordinator";
        StandardOutput = "journal";
        WorkingDirectory = "/var/lib/labgrid-coordinator";
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
        RestrictAddressFamilies = "AF_INET AF_INET6";
        RestrictNamespaces = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
      };
    };
  };
}
