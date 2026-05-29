{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    pipe
    filterAttrs
    mapAttrsToList
    flatten
    escapeShellArgs
    concatStringsSep
    makeBinPath
    ;
  inherit (lib.hm.dag)
    entryAfter
    ;
  inherit (pkgs)
    symlinkJoin
    makeWrapper
    openssh
    ;
  cfg = config.services.mutagen;
  mutagenWrapped = symlinkJoin {
    pname = "mutagen-wrapped";
    version = cfg.package.version;
    paths = [ cfg.package ];
    buildInputs = [ makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/mutagen \
        --prefix PATH : ${makeBinPath [ openssh ]}
    '';
  };
  mutagen = "${mutagenWrapped}/bin/mutagen";
  mutagen-types =
    let
      flag-types =
        let
          inherit (lib) types;
        in
        {
          probe-mode = types.enum [
            "probe"
            "assume"
          ];
          sync-mode = types.enum [
            "two-way-safe"
            "two-way-resolved"
            "one-way-safe"
            "one-way-replica"
          ];
          hash = types.enum [
            "sha1"
            "sha256"
          ];
          scan-mode = types.enum [
            "full"
            "accelerated"
          ];
          stage-mode = types.enum [
            "mutagen"
            "neighboring"
          ];
          symlink-mode = types.enum [
            "ignore"
            "portable"
            "posix-raw"
          ];
          watch-mode = types.enum [
            "portable"
            "force-poll"
            "no-watch"
          ];
          ignore-syntax = types.enum [
            "mutagen"
            "docker"
          ];
          permissions-mode = types.enum [
            "portable"
            "manual"
          ];
          compression = types.enum [
            "none"
            "deflate"
          ];
          socket-overwrite-mode = types.enum [
            "leave"
            "overwrite"
          ];
        };
      types = lib.types // flag-types;
      mkNullableOption =
        type:
        mkOption {
          type = lib.types.nullOr type;
          default = null;
        };
      mkListOption =
        type:
        mkOption {
          type = lib.types.listOf type;
          default = [ ];
        };
      sync-flags = {
        label = mkListOption types.str;
        paused = mkEnableOption "paused";
        no-global-configuration = mkEnableOption "no-global-configuration";
        configuration-file = mkListOption types.str;
        mode = mkNullableOption types.sync-mode;
        hash = mkNullableOption types.hash;
        max-entry-count = mkNullableOption types.ints.unsigned;
        max-staging-file-size = mkNullableOption types.str;
        probe-mode = mkNullableOption types.probe-mode;
        probe-mode-alpha = mkNullableOption types.probe-mode;
        probe-mode-beta = mkNullableOption types.probe-mode;
        scan-mode = mkNullableOption types.scan-mode;
        scan-mode-alpha = mkNullableOption types.scan-mode;
        scan-mode-beta = mkNullableOption types.scan-mode;
        stage-mode = mkNullableOption types.stage-mode;
        stage-mode-alpha = mkNullableOption types.stage-mode;
        stage-mode-beta = mkNullableOption types.stage-mode;
        symlink-mode = mkNullableOption types.symlink-mode;
        watch-mode = mkNullableOption types.watch-mode;
        watch-mode-alpha = mkNullableOption types.watch-mode;
        watch-mode-beta = mkNullableOption types.watch-mode;
        watch-polling-interval = mkNullableOption types.ints.unsigned;
        watch-polling-interval-alpha = mkNullableOption types.ints.unsigned;
        watch-polling-interval-beta = mkNullableOption types.ints.unsigned;
        ignore-syntax = mkNullableOption types.ignore-syntax;
        ignore = mkListOption types.str;
        ignore-vcs = mkEnableOption "ignore-vcs";
        no-ignore-vcs = mkEnableOption "no-ignore-vcs";
        permissions-mode = mkNullableOption types.permissions-mode;
        default-file-mode = mkNullableOption types.str;
        default-file-mode-alpha = mkNullableOption types.str;
        default-file-mode-beta = mkNullableOption types.str;
        default-directory-mode = mkNullableOption types.str;
        default-directory-mode-alpha = mkNullableOption types.str;
        default-directory-mode-beta = mkNullableOption types.str;
        default-owner = mkNullableOption types.str;
        default-owner-alpha = mkNullableOption types.str;
        default-owner-beta = mkNullableOption types.str;
        default-group = mkNullableOption types.str;
        default-group-alpha = mkNullableOption types.str;
        default-group-beta = mkNullableOption types.str;
        compression = mkNullableOption types.compression;
        compression-alpha = mkNullableOption types.compression;
        compression-beta = mkNullableOption types.compression;
      };
      forward-flags = {
        label = mkListOption types.str;
        paused = mkEnableOption "paused";
        no-global-configuration = mkEnableOption "no-global-configuration";
        configuration-file = mkListOption types.str;
        socket-overwrite-mode = mkNullableOption types.socket-overwrite-mode;
        socket-overwrite-mode-source = mkNullableOption types.socket-overwrite-mode;
        socket-overwrite-mode-destination = mkNullableOption types.socket-overwrite-mode;
        socket-owner = mkNullableOption types.str;
        socket-owner-source = mkNullableOption types.str;
        socket-owner-destination = mkNullableOption types.str;
        socket-group = mkNullableOption types.str;
        socket-group-source = mkNullableOption types.str;
        socket-group-destination = mkNullableOption types.str;
        socket-permission-mode = mkNullableOption types.str;
        socket-permission-mode-source = mkNullableOption types.str;
        socket-permission-mode-destination = mkNullableOption types.str;
      };
    in
    {
      sync = types.submodule {
        options = {
          alpha = mkOption {
            type = types.str;
          };
          beta = mkOption {
            type = types.str;
          };
          flags = mkOption {
            type = types.submodule {
              options = sync-flags;
            };
          };
        };
      };
      forward = types.submodule {
        options = {
          source = mkOption {
            type = types.str;
          };
          destination = mkOption {
            type = types.str;
          };
          flags = mkOption {
            type = types.submodule {
              options = forward-flags;
            };
          };
        };
      };
    };
  types = lib.types // mutagen-types;
  mutagenCommands =
    let
      flagToArgs =
        flags:
        pipe flags [
          (filterAttrs (_: v: v != null && v != false))
          (mapAttrsToList (
            k: v:
            if builtins.isString v then
              [ "--${k}=${v}" ]
            else if builtins.isBool v then
              [ "--${k}" ]
            else if builtins.isList v then
              map (x: "--${k}=${x}") v
            else if builtins.isInt v then
              [ "--${k}=${toString v}" ]
            else
              throw "Unsupported flag type for ${k}"
          ))
          flatten
        ];
      mkCommand = positional: flags: "${mutagen} ${escapeShellArgs (positional ++ flagToArgs flags)}";
      mutagen-sync-create =
        name:
        {
          alpha,
          beta,
          flags,
        }:
        mkCommand [
          "sync"
          "create"
          alpha
          beta
          "--name=${name}"
          "--label=home-manager"
        ] flags;
      mutagen-forward-create =
        name:
        {
          source,
          destination,
          flags,
        }:
        mkCommand [
          "forward"
          "create"
          source
          destination
          "--name=${name}"
          "--label=home-manager"
        ] flags;
    in
    {
      allTerminateList = [
        "${mutagen} sync terminate --label-selector=home-manager"
        "${mutagen} forward terminate --label-selector=home-manager"
      ];
      syncCreateList = mapAttrsToList mutagen-sync-create cfg.sync;
      forwardCreateList = mapAttrsToList mutagen-forward-create cfg.forward;
    };
in
{
  options.services.mutagen = {
    enable = mkEnableOption "mutagen";
    package = mkOption {
      type = types.package;
      default = pkgs.mutagen;
    };
    sync = mkOption {
      type = types.attrsOf types.sync;
      default = { };
    };
    forward = mkOption {
      type = types.attrsOf types.forward;
      default = { };
    };
  };
  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
    systemd.user.services = {
      mutagen = {
        Unit = {
          Description = "Mutagen session";
        };

        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStartPre =
            with mutagenCommands;
            flatten [
              allTerminateList
              syncCreateList
              forwardCreateList
            ];
          ExecStart = [
            "${mutagen} sync resume --label-selector=home-manager"
            "${mutagen} forward resume --label-selector=home-manager"
          ];
          ExecStop = [
            "${mutagen} sync pause --label-selector=home-manager"
            "${mutagen} forward pause --label-selector=home-manager"
          ];
          Restart = "on-failure";
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };
}
