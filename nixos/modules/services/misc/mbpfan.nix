{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.services.mbpfan;
  verbose = optionalString cfg.verbose "v";
  format = pkgs.formats.ini {};
  cfgfile = format.generate "mbpfan.ini" cfg.settings;

in {
  options.services.mbpfan.enable = mkEnableOption "mbpfan, fan controller daemon for Apple Macs and MacBooks";
  options.services.mbpfan.verbose = mkEnableOption "set the log level to verbose";
  options.services.mbpfan.aggressive = mkEnableOption "favor higher default fan speeds" // { default = true; };
  options.services.mbpfan.package = mkPackageOption pkgs "mbpfan" {};

  options.services.mbpfan.settings = mkOption {
    default = {};
    description = "";
    type = types.submodule {
      freeformType = format.type;

      options.general.low_temp = mkOption {
        type = types.int;
        default = (if cfg.aggressive then 55 else 63);
        defaultText = literalExpression "55";
        description = "If temperature is below this, fans will run at minimum speed.";
      };
      options.general.high_temp = mkOption {
        type = types.int;
        default = (if cfg.aggressive then 58 else 66);
        defaultText = literalExpression "58";
        description = "If temperature is above this, fan speed will gradually increase.";
      };
      options.general.max_temp = mkOption {
        type = types.int;
        default = (if cfg.aggressive then 78 else 86);
        defaultText = literalExpression "78";
        description = "If temperature is above this, fans will run at maximum speed.";
      };
      options.general.polling_interval = mkOption {
        type = types.int;
        default = 1;
        description = "The polling interval.";
      };
    };
  };

  config = mkIf cfg.enable {
    boot.kernelModules = [ "coretemp" "applesmc" ];
    environment.systemPackages = [ cfg.package ];
    environment.etc."mbpfan.conf".source = cfgfile;

    systemd.services.mbpfan = {
      description = "A fan manager daemon for MacBook Pro";
      wantedBy = [ "sysinit.target" ];
      after = [ "sysinit.target" ];
      restartTriggers = [ config.environment.etc."mbpfan.conf".source ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/mbpfan -f${verbose}";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        PIDFile = "/run/mbpfan.pid";
        Restart = "always";
      };
    };
  };
}
