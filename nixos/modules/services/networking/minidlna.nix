{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.services.minidlna;
  format = pkgs.formats.keyValue { listsAsDuplicateKeys = true; };
  cfgfile = format.generate "minidlna.conf" cfg.settings;

in {
  options.services.minidlna.enable = mkEnableOption "MiniDLNA, a simple DLNA server. Consider adding `services.minidlna.openFirewall = true;` into your config";
  options.services.minidlna.openFirewall = mkEnableOption "opening of both HTTP (TCP) and SSDP (UDP) ports in the firewall";

  options.services.minidlna.settings = mkOption {
    default = {};
    description = "";
    type = types.submodule {
      freeformType = format.type;

      options.media_dir = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "/data/media" "V,/home/alice/video" ];
        description = ''
          Directories to be scanned for media files.
          The `A,` `V,` `P,` prefixes restrict a directory to audio, video or image files.
          The directories must be accessible to the `minidlna` user account.
        '';
      };
      options.notify_interval = mkOption {
        type = types.int;
        default = 90000;
        description = ''
          The interval between announces (in seconds).
          Instead of waiting for announces, you should set `openFirewall` option to use SSDP discovery.
          Lower values (e.g. 30 seconds) should be used if your network is blocking the SSDP multicast.
          Some relevant information can be found [here](https://sourceforge.net/p/minidlna/discussion/879957/thread/1389d197/).
        '';
      };
      options.port = mkOption {
        type = types.port;
        default = 8200;
        description = "Port number for HTTP traffic (descriptions, SOAP, media transfer).";
      };
      options.db_dir = mkOption {
        type = types.path;
        default = "/var/cache/minidlna";
        example = "/tmp/minidlna";
        description = "Specify the directory where you want MiniDLNA to store its database and album art cache.";
      };
      options.friendly_name = mkOption {
        type = types.str;
        default = config.networking.hostName;
        defaultText = literalExpression "config.networking.hostName";
        example = "rpi3";
        description = "Name that the DLNA server presents to clients.";
      };
      options.root_container = mkOption {
        type = types.str;
        default = "B";
        example = ".";
        description = "Use a different container as the root of the directory tree presented to clients.";
      };
      options.log_level = mkOption {
        type = types.str;
        default = "warn";
        example = "general,artwork,database,inotify,scanner,metadata,http,ssdp,tivo=warn";
        description = "Defines the type of messages that should be logged and down to which level of importance.";
      };
      options.enable_subtitles = mkOption {
        type = types.enum [ "yes" "no" ];
        default = "yes";
        description = "Enable subtitle support on unknown clients.";
      };
      options.inotify = mkOption {
        type = types.enum [ "yes" "no" ];
        default = "no";
        description = "Whether to enable inotify monitoring to automatically discover new files.";
      };
      options.enable_tivo = mkOption {
        type = types.enum [ "yes" "no" ];
        default = "no";
        description = "Support for streaming .jpg and .mp3 files to a TiVo supporting HMO.";
      };
      options.wide_links = mkOption {
        type = types.enum [ "yes" "no" ];
        default = "no";
        description = "Set this to yes to allow symlinks that point outside user-defined `media_dir`.";
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.settings.port ];
    networking.firewall.allowedUDPPorts = mkIf cfg.openFirewall [ 1900 ];

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
        ExecStart = "${pkgs.minidlna}/sbin/minidlnad -S -P /run/minidlna/pid -f ${cfgfile}";
      };
    };
  };
}
