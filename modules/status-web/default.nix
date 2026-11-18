{
  config,
  lib,
  pkgs,
  ...
}:
# Phone-checkable status page for the server: a systemd timer writes
# status.json every minute, and nginx serves it next to a static frontend
# (a whole directory — index.html, style.css, app.js — that fetches and
# renders the JSON) on :8434.
# Reachable from the tailnet only (tailscale0 is a trusted interface;
# 8434 is deliberately absent from the public firewall), so WireGuard
# provides the transport encryption and peer authentication — no TLS or
# basic auth needed. If the page is unreachable, the box is down — that
# is signal too.
let
  cfg = config.status-web;
  stateDir = "/var/lib/status-web";
  jq = "${pkgs.jq}/bin/jq";
  awk = "${pkgs.gawk}/bin/awk";
  # Root-only: RAPL energy_uj is 0400 and the sshd journal needs root (or
  # systemd-journal) — which is why the data is precomputed here instead
  # of served on demand.
  genScript = pkgs.writeShellScript "status-web-generate" ''
    set -eu
    export LC_ALL=C
    mkdir -p ${stateDir}
    now=$(date +%s)

    sshd=$(${pkgs.systemd}/bin/systemctl is-active sshd || true)
    j=$(${pkgs.systemd}/bin/journalctl -u sshd --since "-24 hours" --no-pager || true)
    ok=$(printf '%s' "$j" | grep -c 'Accepted' || true)
    rej=$(printf '%s' "$j" | grep -cE 'Invalid user|Failed|not allowed' || true)

    uptime=$(cut -d' ' -f1 /proc/uptime)
    load=$(${awk} '{printf "[%s,%s,%s]", $1, $2, $3}' /proc/loadavg)

    e1=$(cat /sys/class/powercap/intel-rapl:0/energy_uj 2>/dev/null || echo 0)
    sleep 1
    e2=$(cat /sys/class/powercap/intel-rapl:0/energy_uj 2>/dev/null || echo 0)
    cpu=$(${awk} -v a="$e1" -v b="$e2" \
      'BEGIN{if(a==0||b<a)print "null";else printf "%.2f",(b-a)/1e6}')
    # A runtime-suspended GPU rejects sensor reads (without waking up);
    # report that state honestly instead of a misleading 0W.
    gpurt=$(cat /sys/class/drm/card[0-9]/device/power/runtime_status 2>/dev/null | head -1)
    if [ "$gpurt" = suspended ]; then
      gpu=null
      asleep=true
    else
      g=$(cat /sys/class/drm/card[0-9]/device/hwmon/hwmon*/power1_average 2>/dev/null | head -1 || true)
      gpu=$(${awk} -v g="$g" 'BEGIN{if(g=="")print "null";else printf "%.2f",g/1e6}')
      asleep=false
    fi

    mem=$(${pkgs.procps}/bin/free -b | ${awk} \
      'NR==2{printf "{\"used\":%s,\"total\":%s,\"available\":%s}", $3, $2, $7}')
    disks=$(${pkgs.coreutils}/bin/df -B1 --output=target,pcent,avail / /home /nix/store | ${awk} '
      BEGIN { printf "[" }
      NR > 1 { sub("%", "", $2); printf "%s{\"mount\":\"%s\",\"usedPct\":%s,\"avail\":%s}", (n++ ? "," : ""), $1, $2, $3 }
      END { printf "]" }')

    # Traffic per linked interface: average rate since the previous run
    # (counters kept in net.prev) plus totals since boot. A gap over 5min
    # (hibernate, stopped timer) or a counter reset yields null rather than
    # a misleading average.
    prev=${stateDir}/net.prev
    [ -f "$prev" ] || : > "$prev"
    cur=""
    for d in /sys/class/net/*; do
      i=$(basename "$d")
      [ "$i" = lo ] && continue
      [ "$(cat "$d/carrier" 2>/dev/null || echo 0)" = 1 ] || continue
      cur="$cur$i $(cat "$d/statistics/rx_bytes") $(cat "$d/statistics/tx_bytes") $now"$'\n'
    done
    net=$(printf '%s' "$cur" | ${awk} -v pf="$prev" '
      BEGIN { printf "[" }
      FILENAME == pf { pr[$1] = $2; pt[$1] = $3; pts[$1] = $4; next }
      NF == 4 {
        dt = $4 - pts[$1]
        if (($1 in pr) && dt > 0 && dt <= 300 && $2 >= pr[$1] && $3 >= pt[$1]) {
          rr = sprintf("%.1f", ($2 - pr[$1]) / dt); tr = sprintf("%.1f", ($3 - pt[$1]) / dt)
        } else {
          rr = "null"; tr = "null"
        }
        printf "%s{\"iface\":\"%s\",\"rx\":%s,\"tx\":%s,\"rxRate\":%s,\"txRate\":%s}", (n++ ? "," : ""), $1, $2, $3, rr, tr
      }
      END { printf "]" }' "$prev" -)
    printf '%s' "$cur" > "$prev"

    ${jq} -n \
      --arg host ${lib.escapeShellArg config.networking.hostName} \
      --argjson time "$now" \
      --arg sshd "$sshd" \
      --argjson ok "$ok" --argjson reject "$rej" \
      --argjson uptime "$uptime" \
      --argjson load "$load" \
      --argjson cpu "$cpu" --argjson gpu "$gpu" --argjson asleep "$asleep" \
      --argjson mem "$mem" \
      --argjson disks "$disks" \
      --argjson net "$net" \
      '{host: $host, time: $time, sshd: $sshd, ssh24h: {ok: $ok, reject: $reject},
        uptime: $uptime, load: $load,
        power: {cpu: $cpu, gpu: $gpu, gpuAsleep: $asleep},
        mem: $mem, disks: $disks, net: $net}' \
      > ${stateDir}/status.json.tmp
    mv ${stateDir}/status.json.tmp ${stateDir}/status.json
  '';
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
    # vhost(TLS 포함)는 webapps 모듈이 만든다; 여기는 데이터 생성만 남는다.
    webapps.apps.status = {
      title = "Status";
      port = 8434;
      description = "전력 · 부하 · 디스크 · 네트워크 · SSH 대시보드";
      root = cfg.frontend;
      locations."= /status.json" = {
        root = stateDir;
        extraConfig = ''
          add_header Cache-Control "no-store";
        '';
      };
    };

    # Writes the data once at activation so the page never fetches a 404.
    # The site/ directory is the pre-JSON layout (server-rendered HTML).
    systemd.services.status-web-setup = {
      wantedBy = [ "multi-user.target" ];
      requiredBy = [ "nginx.service" ];
      before = [ "nginx.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        rm -rf ${stateDir}/site
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
        OnBootSec = "1min";
        OnUnitActiveSec = "1min";
      };
    };
  };
}
