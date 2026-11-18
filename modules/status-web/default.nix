{
  config,
  lib,
  pkgs,
  ...
}:
# Phone-checkable status page for the server on :8434: nginx serves a
# static frontend (a whole directory — index.html, style.css, app.js) and
# proxies its `status.json` fetch to status-api
# (github:Icicle-Nix/status-api), which measures the machine on each
# request behind a socket-activated Unix socket — no timer, no state file.
# Reachable from the tailnet only (tailscale0 is a trusted interface;
# 8434 is deliberately absent from the public firewall), so WireGuard
# provides the transport encryption and peer authentication — no TLS or
# basic auth needed. If the page is unreachable, the box is down — that
# is signal too.
let
  cfg = config.status-web;
in
{
  options.status-web.frontend = lib.mkOption {
    type = lib.types.path;
    default = pkgs.status-web-frontend;
    defaultText = lib.literalExpression "pkgs.status-web-frontend";
    description = ''
      정적 프론트엔드 디렉터리(또는 그런 디렉터리를 내놓는 derivation).
      통째로 웹 루트가 되며, 같은 오리진의 status.json을 fetch해 그린다.
      기본값은 github:Icicle-Nix/status-web flake의 패키지.
    '';
  };

  config = {
    # 데이터 서버. 소켓은 0660 root:nginx라 nginx만 붙을 수 있다.
    services.status-api = {
      enable = true;
      socketGroup = "nginx";
      disks = [
        "/"
        "/home"
        "/nix/store"
      ];
    };

    # vhost(TLS 포함)는 webapps 모듈이 만든다. Cache-Control: no-store는
    # status-api가 직접 붙인다.
    webapps.apps.status = {
      title = "Status";
      port = 8434;
      description = "전력 · 부하 · 디스크 · 네트워크 · SSH 대시보드";
      root = cfg.frontend;
      locations."= /status.json".proxyPass = "http://unix:${config.services.status-api.socket}";
    };
  };
}
