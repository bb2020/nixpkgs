{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.minidlna;
  format = pkgs.formats.keyValue { listsAsDuplicateKeys = true; };
  cfgfile = format.generate "minidlna.conf" cfg.settings;

in
{
  options.services.minidlna.enable = lib.mkEnableOption "MiniDLNA, a simple DLNA server. Consider adding `openFirewall = true` into your config";
  options.services.minidlna.openFirewall = lib.mkEnableOption "opening HTTP (TCP) and SSDP (UDP) ports in the firewall";
  options.services.minidlna.package = lib.mkPackageOption pkgs "minidlna" { };

  options.services.minidlna.settings = lib.mkOption {
    default = { };
    description = "";
    type = lib.types.submodule {
      freeformType = format.type;

      options.media_dir = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "/data/media" ];
        description = ''
          Directories to be scanned for media files.
          The `A,` `V,` `P,` prefixes restrict a directory to audio, video or image files.
          The directories must be accessible to the `minidlna` user account.
        '';
      };
      options.notify_interval = lib.mkOption {
        type = lib.types.int;
        default = 90000;
        description = ''
          The interval between announces (in seconds).
          Instead of waiting for announces, you should set `openFirewall` option to use SSDP discovery.
          Lower values (e.g. 30 seconds) should be used if your network is blocking the SSDP multicast.
          Some relevant information can be found [here](https://sourceforge.net/p/minidlna/discussion/879957/thread/1389d197/).
        '';
      };
      options.port = lib.mkOption {
        type = lib.types.port;
        default = 8200;
        description = "Port number for HTTP traffic (descriptions, SOAP, media transfer).";
      };
      options.db_dir = lib.mkOption {
        type = lib.types.path;
        default = "/var/cache/minidlna";
        example = "/tmp/minidlna";
        description = "Directory to store database and album art cache.";
      };
      options.friendly_name = lib.mkOption {
        type = lib.types.str;
        default = config.networking.hostName;
        defaultText = lib.literalExpression "config.networking.hostName";
        example = "rpi3";
        description = "Name that the server presents to clients.";
      };
      options.root_container = lib.mkOption {
        type = lib.types.str;
        default = "B";
        example = ".";
        description = "Root of the directory tree presented to clients.";
      };
      options.log_level = lib.mkOption {
        type = lib.types.str;
        default = "warn";
        example = "general,artwork,database,inotify,scanner,metadata,http,ssdp,tivo=warn";
        description = "Messages to log and their level of importance.";
      };
      options.enable_subtitles = lib.mkOption {
        type = lib.types.enum [
          "yes"
          "no"
        ];
        default = "yes";
        description = "Subtitle support on unknown clients.";
      };
      options.inotify = lib.mkOption {
        type = lib.types.enum [
          "yes"
          "no"
        ];
        default = "no";
        description = "Discover new files automatically.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.settings.port ];
    networking.firewall.allowedUDPPorts = lib.mkIf cfg.openFirewall [ 1900 ];

    users.groups.minidlna.gid = config.ids.gids.minidlna;
    users.users.minidlna = {
      description = "MiniDLNA daemon user";
      group = "minidlna";
      uid = config.ids.uids.minidlna;
    };

    systemd.services.minidlna = {
      description = "MiniDLNA Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        User = "minidlna";
        Group = "minidlna";
        CacheDirectory = "minidlna";
        RuntimeDirectory = "minidlna";
        PIDFile = "/run/minidlna/pid";
        ExecStart = "${lib.getExe cfg.package} -S -P /run/minidlna/pid -f ${cfgfile}";
      };
    };
  };
}
