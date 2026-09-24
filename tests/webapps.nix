# modules/webapps.nix 런타임 검증. 빌드는 통과하고 런타임에서 터졌던
# 회귀 두 개를 겨냥한다:
#  - TLS vhost에 ssl_certificate가 빠져 nginx가 기동 실패 (onlySSL 누락)
#  - 비표준 포트 프록시에서 Host의 포트가 탈락해 앱이 잘못된 절대 URL을
#    만듦 (hydra CSS 404)
# tailscale cert 대신 자체 서명 인증서를 certCommand로 끼운다 — 권한
# 설정과 nginx 기동 순서는 실제 경로 그대로 탄다.
{ pkgs, ... }:
let
  fqdn = "server.test";

  # 받은 Host와 X-Forwarded-Proto를 그대로 돌려주는 업스트림.
  echoServer = pkgs.writeText "echo.py" ''
    from http.server import BaseHTTPRequestHandler, HTTPServer

    class H(BaseHTTPRequestHandler):
        def do_GET(self):
            body = "host={} proto={}".format(
                self.headers.get("Host"), self.headers.get("X-Forwarded-Proto")
            ).encode()
            self.send_response(200)
            self.end_headers()
            self.wfile.write(body)

    HTTPServer(("127.0.0.1", 9000), H).serve_forever()
  '';
in
{
  name = "webapps";

  nodes.server =
    { pkgs, ... }:
    {
      imports = [ ../modules/webapps.nix ];
      networking.hosts."127.0.0.1" = [ fqdn ];
      environment.systemPackages = [ pkgs.curl ];

      webapps.tls = {
        enable = true;
        inherit fqdn;
        certCommand = ''
          ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:2048 -nodes -days 1 \
            -subj /CN=${fqdn} -addext subjectAltName=DNS:${fqdn} \
            -keyout "$KEY_FILE" -out "$CERT_FILE"
        '';
      };
      webapps.apps = {
        echo = {
          port = 8443;
          upstream = "http://127.0.0.1:9000";
        };
        static = {
          port = 8434;
          root = pkgs.writeTextDir "index.html" "static-ok";
        };
      };

      systemd.services.echo = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig.ExecStart = "${pkgs.python3}/bin/python3 ${echoServer}";
      };
    };

  testScript = ''
    server.wait_for_unit("nginx.service")
    server.wait_for_unit("echo.service")
    server.wait_for_open_port(9000)
    server.wait_for_open_port(443)

    def get(port):
        return server.succeed(
            f"curl -sSf --cacert /var/lib/webapps-certs/cert.pem https://${fqdn}:{port}/"
        )

    with subtest("포털이 등록된 앱을 FQDN https 링크로 보여준다"):
        portal = get(443)
        assert 'href="https://${fqdn}:8443/"' in portal, portal
        assert 'href="https://${fqdn}:8434/"' in portal, portal

    with subtest("정적 root 앱"):
        assert "static-ok" in get(8434)

    with subtest("프록시가 Host의 포트와 https 스킴을 보존한다"):
        echo = get(8443)
        assert "host=${fqdn}:8443" in echo, echo
        assert "proto=https" in echo, echo

    with subtest("80은 https 포털로 리다이렉트"):
        loc = server.succeed(
            "curl -s -o /dev/null -w '%{redirect_url}' http://${fqdn}/"
        )
        assert loc == "https://${fqdn}/", loc

    with subtest("개인 키는 root:nginx 0640"):
        server.succeed(
            'test "$(stat -c %U:%G:%a /var/lib/webapps-certs/key.pem)" = root:nginx:640'
        )
  '';
}
