{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.aesmd;
  dataDir = "/var/lib/aesmd";
in {
  options.services.aesmd.enable = mkEnableOption "Intel(R) Architectural Enclave Service Manager";

  config = mkIf cfg.enable {
    # udev rules.
    environment.systemPackages = [ pkgs.sgx-psw ];

    systemd.services.aesmd = {
      description = "Intel(R) Architectural Enclave Service Manager";
      after = [ "syslog.target" "network.target" "auditd.service" ];
      wantedBy = [ "multi-user.target" ];
      environment.AESM_DATA_FOLDER = "${dataDir}/data";
      preStart = ''
        if [[ ! -d '${dataDir}/data' ]]; then
          cp -r '${pkgs.sgx-psw.aesm}/share/aesm' -T '${dataDir}/data'
        fi
      '';

      serviceConfig = {
        Type = "forking";
        DynamicUser = true;
        WorkingDirectory = dataDir;
        StateDirectory = "aesmd";
        StateDirectoryMode = "0755";

        ExecStart = "${pkgs.sgx-psw.aesm}/bin/aesm_service";
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGHUP $MAINPID";
        Restart = "on-failure";
        RestartSec = "15s";

        ReadWritePaths = [ dataDir ];
        ProtectHome = true;
        DevicePolicy = "closed";
        DeviceAllow = [
          "/dev/isgx rw"
          "/dev/sgx rw"
          "/dev/sgx/enclave rw"
          "/dev/sgx/provision rw"
        ];
      };
    };
  };
}
