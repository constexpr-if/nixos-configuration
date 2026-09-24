{
  config,
  lib,
  pkgs,
  ...
}:
# tailnet 전용 웹 앱 호스팅의 공통 기반.
#
# 앱은 `webapps.apps.<name>`에 선언적으로 등록한다. 등록하면:
#  - 포털(http://<host>/ → https)에 링크가 생긴다 — 포트를 외울 필요가 없다.
#  - `upstream`(리버스 프록시) 또는 `root`(정적 루트)를 주면 해당 포트에
#    nginx vhost가 생긴다. 둘 다 없으면 링크만 만든다.
#
# 앱 코드 자체는 이 repo에 두지 않는다. kis-broker처럼 앱마다 자체
# flake(패키지 + NixOS 모듈)를 가진 저장소를 만들고 시스템 flake의
# input으로 끌어온 뒤, 그 모듈이 systemd 유닛과 webapps 등록을 함께
# 정의하는 것이 규약이다.
#
# 노출 모델: 공개 방화벽에는 아무 포트도 열지 않고 tailscale0(trusted)로만
# 도달 가능하다. TLS는 `tailscale cert`(DNS-01, 공개 노출 불필요)로 받은
# ts.net 인증서 하나를 모든 vhost가 공유한다 — 관리 콘솔에서 HTTPS
# Certificates를 켜야 발급된다. 인증서는 FQDN에만 유효하므로 TLS를 켜면
# 링크가 단축명 대신 FQDN을 쓴다.
let
  cfg = config.webapps;

  portalApps = lib.filterAttrs (_: app: app.portal) cfg.apps;
  servedApps = lib.filterAttrs (_: app: app.upstream != null || app.root != null) cfg.apps;

  tls = cfg.tls.enable;
  certDir = "/var/lib/webapps-certs";
  linkHost = if tls then cfg.tls.fqdn else cfg.hostName;
  scheme = if tls then "https" else "http";
  appUrl = app: "${scheme}://${linkHost}:${toString app.port}${app.path}";

  listenOn = port: [
    {
      addr = "0.0.0.0";
      inherit port;
      ssl = tls;
    }
    {
      addr = "[::]";
      inherit port;
      ssl = tls;
    }
  ];
  # onlySSL이 없으면 nginx 모듈이 ssl_certificate 지시자를 생략해
  # "no ssl_certificate is defined"로 죽는다 — listen의 ssl 플래그만으로는
  # hasSSL로 인정되지 않는다.
  sslFiles = lib.optionalAttrs tls {
    onlySSL = true;
    sslCertificate = "${certDir}/cert.pem";
    sslCertificateKey = "${certDir}/key.pem";
  };

  # 레지스트리에서 빌드 타임에 생성하는 정적 포털. 런타임 스크립트가
  # 없으므로 깨질 게 없고, 내용 변경은 곧 시스템 세대 변경이다.
  portalRoot =
    let
      entry = name: app: ''
        <li><a href="${appUrl app}">
          <span class="n">${app.title}</span><span class="p">:${toString app.port}</span>
          ${lib.optionalString (app.description != "") ''<span class="d">${app.description}</span>''}
        </a></li>
      '';
      entries = lib.concatStrings (
        map (name: entry name portalApps.${name}) (
          lib.sortOn (name: portalApps.${name}.port) (lib.attrNames portalApps)
        )
      );
    in
    pkgs.writeTextDir "index.html" ''
      <!DOCTYPE html><html lang="ko"><head><meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>${cfg.hostName}</title>
      <style>
        body{background:#111;color:#ddd;font-family:monospace;font-size:15px;margin:0;padding:16px}
        h1{font-size:16px;margin:0 0 12px}
        ul{list-style:none;margin:0;padding:0}
        li a{display:block;padding:12px 10px;margin:6px 0;background:#1a1a1a;border:1px solid #2a2a2a;
             border-radius:6px;color:#ddd;text-decoration:none}
        li a:active{background:#222}
        .n{font-weight:bold}
        .p{color:#666;margin-left:6px;font-size:13px}
        .d{display:block;color:#888;font-size:13px;margin-top:2px}
      </style></head><body>
      <h1>${cfg.hostName}</h1>
      <ul>${entries}</ul>
      </body></html>
    '';
in
{
  options.webapps = {
    hostName = lib.mkOption {
      type = lib.types.str;
      default = lib.toLower config.networking.hostName;
      description = "TLS 미사용 시 포털 링크에 쓸 호스트명 (MagicDNS 단축명)";
    };
    portalPort = lib.mkOption {
      type = lib.types.port;
      default = if tls then 443 else 80;
      defaultText = lib.literalExpression "if tls then 443 else 80";
      description = "포털 페이지 포트";
    };
    tls = {
      enable = lib.mkEnableOption "tailscale cert 기반 TLS";
      fqdn = lib.mkOption {
        type = lib.types.str;
        example = "constdesktop.tail5b5022.ts.net";
        description = "tailnet FQDN — 인증서와 링크가 이 이름을 쓴다";
      };
      certCommand = lib.mkOption {
        type = lib.types.lines;
        internal = true;
        default = ''
          ${pkgs.tailscale}/bin/tailscale cert \
            --cert-file "$CERT_FILE" --key-file "$KEY_FILE" ${cfg.tls.fqdn}
        '';
        description = ''
          인증서를 $CERT_FILE/$KEY_FILE에 쓰는 명령. VM 테스트가 tailscale
          없이 자체 서명 인증서로 바꿔 끼우는 용도다.
        '';
      };
    };
    apps = lib.mkOption {
      default = { };
      description = "등록된 웹 앱. 이름당 하나의 포트.";
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              title = lib.mkOption {
                type = lib.types.str;
                default = name;
                description = "포털에 표시할 이름";
              };
              description = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "포털에 표시할 한 줄 설명";
              };
              port = lib.mkOption {
                type = lib.types.port;
                description = "앱이 서빙되는 tailnet 포트";
              };
              path = lib.mkOption {
                type = lib.types.str;
                default = "/";
                description = "포털 링크의 경로";
              };
              upstream = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                example = "http://unix:/run/myapp/http.sock";
                description = ''
                  nginx proxy_pass 대상. root와 함께 null이면 앱이 직접
                  그 포트에서 듣는다고 보고 포털 링크만 만든다 — 단, 그런
                  앱은 TLS 종단을 받을 수 없으니 가능하면 localhost로
                  내리고 여기로 프록시할 것.
                '';
              };
              root = lib.mkOption {
                type = lib.types.nullOr lib.types.path;
                default = null;
                description = "정적 파일 루트 (upstream과 배타적)";
              };
              portal = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "포털 목록에 표시할지 (API 전용 앱은 false)";
              };
            };
          }
        )
      );
    };
  };

  config = {
    assertions = [
      {
        assertion =
          let
            ports = map (app: app.port) (lib.attrValues cfg.apps) ++ [ cfg.portalPort ];
          in
          lib.length ports == lib.length (lib.unique ports);
        message = "webapps: 포트가 중복 등록되었습니다 (포털 포트 포함)";
      }
      {
        assertion = lib.all (app: app.upstream == null || app.root == null) (lib.attrValues cfg.apps);
        message = "webapps: upstream과 root는 동시에 설정할 수 없습니다";
      }
    ];

    services.nginx = {
      enable = true;
      recommendedProxySettings = lib.mkDefault true;
      recommendedTlsSettings = lib.mkDefault tls;
      virtualHosts = {
        webapps-portal = {
          listen = listenOn cfg.portalPort;
          root = portalRoot;
        }
        // sslFiles;
      }
      # TLS 시 80은 포털로 301 — 옛 http 북마크와 맨손 `http://host` 입력을 받는다.
      // lib.optionalAttrs tls {
        webapps-portal-redirect = {
          listen = [
            {
              addr = "0.0.0.0";
              port = 80;
            }
            {
              addr = "[::]";
              port = 80;
            }
          ];
          locations."/".return = "301 https://${cfg.tls.fqdn}$request_uri";
        };
      }
      // lib.mapAttrs' (
        name: app:
        lib.nameValuePair "webapps-${name}" (
          {
            listen = listenOn app.port;
          }
          // sslFiles
          // lib.optionalAttrs (app.upstream != null) {
            locations."/" = {
              proxyPass = app.upstream;
              proxyWebsockets = true;
              # 비표준 포트 vhost라 recommended 헤더의 `Host $host`로는
              # 포트가 탈락해 앱이 :포트 없는 절대 URL을 만든다(hydra
              # CSS 404). 포트를 보존해 직접 넘긴다 — location에
              # proxy_set_header가 하나라도 있으면 상위 것은 상속되지
              # 않으므로 전부 명시한다.
              recommendedProxySettings = false;
              extraConfig = ''
                proxy_set_header Host $host:$server_port;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header X-Forwarded-Host $host:$server_port;
              '';
            };
          }
          // lib.optionalAttrs (app.root != null) { root = app.root; }
        )
      ) servedApps;
    };

    # ts.net 인증서 발급·갱신. `tailscale cert`는 만료가 가까울 때만 LE에
    # 가므로 매일 돌려도 싸다. nginx보다 먼저 한 번 실행해 파일을 보장한다.
    systemd.services.webapps-cert = lib.mkIf tls {
      description = "Fetch/renew tailscale TLS certificate for webapps";
      after = [
        "network-online.target"
        "tailscaled.service"
      ];
      wants = [ "network-online.target" ];
      before = [ "nginx.service" ];
      wantedBy = [
        "multi-user.target"
        "nginx.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        install -d -m 750 -o root -g nginx ${certDir}
        CERT_FILE=${certDir}/cert.pem KEY_FILE=${certDir}/key.pem
        ${cfg.tls.certCommand}
        chgrp nginx ${certDir}/cert.pem ${certDir}/key.pem
        chmod 640 ${certDir}/cert.pem ${certDir}/key.pem
        # 부팅 경로(Before=nginx)에서는 nginx가 아직 inactive라 건너뛴다.
        if ${pkgs.systemd}/bin/systemctl is-active --quiet nginx; then
          ${pkgs.systemd}/bin/systemctl reload nginx
        fi
      '';
    };
    systemd.timers.webapps-cert = lib.mkIf tls {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = "1h";
        Persistent = true;
      };
    };
  };
}
