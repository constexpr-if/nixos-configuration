{ pkgs, ... }:
# Phone-checkable status page for the server: a systemd timer renders a
# static HTML dashboard every 30 minutes and nginx serves it on :8434.
# Reachable from the tailnet only (tailscale0 is a trusted interface;
# 8434 is deliberately absent from the public firewall), so WireGuard
# provides the transport encryption and peer authentication — no TLS or
# basic auth needed. If the page is unreachable, the box is down — that
# is signal too.
let
  stateDir = "/var/lib/status-web";
  # Raw `free`/`df` tables wrap badly on a phone screen; render compact
  # fixed-width summary lines instead so nothing exceeds ~34 columns.
  genScript = pkgs.writeShellScript "status-web-generate" ''
    set -eu
    export LC_ALL=C
    mkdir -p ${stateDir}/site
    {
      echo '<!DOCTYPE html><html lang="ko"><head><meta charset="utf-8">'
      echo '<meta name="viewport" content="width=device-width, initial-scale=1">'
      echo '<meta http-equiv="refresh" content="1800">'
      echo '<title>constDesktop status</title>'
      echo '<style>body{background:#111;color:#ddd;font-family:monospace;font-size:14px;line-height:1.5;margin:0;padding:12px}h1{font-size:16px;margin:0}.t{color:#888;font-size:12px}.ok{color:#7c6}.bad{color:#e66}pre{margin:10px 0 0;white-space:pre}</style>'
      echo '</head><body>'
      echo '<h1>constDesktop</h1>'
      echo "<div class=\"t\">$(date '+%Y-%m-%d %H:%M %Z')</div>"
      sshd=$(${pkgs.systemd}/bin/systemctl is-active sshd || true)
      if [ "$sshd" = active ]; then cls=ok; else cls=bad; fi
      j=$(${pkgs.systemd}/bin/journalctl -u sshd --since "-24 hours" --no-pager || true)
      ok=$(printf '%s' "$j" | grep -c 'Accepted' || true)
      rej=$(printf '%s' "$j" | grep -cE 'Invalid user|Failed|not allowed' || true)
      echo '<pre>'
      echo "sshd     <span class=\"$cls\">$sshd</span>"
      echo "SSH 24h  ok $ok / reject $rej"
      echo "up       $(${pkgs.procps}/bin/uptime -p | sed 's/^up //')"
      echo "load     $(cut -d' ' -f1-3 /proc/loadavg)"
      ${pkgs.procps}/bin/free -b | ${pkgs.gawk}/bin/awk \
        'NR==2{printf "RAM      %.1f/%.0fGi (free %.0fGi)\n", $3/2^30, $2/2^30, $7/2^30}'
      ${pkgs.coreutils}/bin/df -h --output=target,pcent,avail / /home /nix/store | \
        ${pkgs.gawk}/bin/awk 'NR>1{printf "%-10s %4s (%s free)\n", $1, $2, $3}'
      echo '</pre></body></html>'
    } > ${stateDir}/site/index.html.tmp
    mv ${stateDir}/site/index.html.tmp ${stateDir}/site/index.html
  '';
in
{
  services.nginx = {
    enable = true;
    virtualHosts."status" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 8434;
        }
        {
          addr = "[::]";
          port = 8434;
        }
      ];
      root = "${stateDir}/site";
    };
  };

  # Renders the page once at activation so nginx never serves an empty root.
  systemd.services.status-web-setup = {
    wantedBy = [ "multi-user.target" ];
    requiredBy = [ "nginx.service" ];
    before = [ "nginx.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p ${stateDir}/site
      ${genScript}
    '';
  };

  systemd.services.status-web-generate = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = genScript;
    };
  };
  systemd.timers.status-web-generate = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "30min";
    };
  };
}
