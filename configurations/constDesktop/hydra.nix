{ lib, ... }:
{
  services.hydra = {
    enable = true;
    # TLS 종단은 webapps의 nginx가 :3000에서 한다. hydra 자신은
    # localhost:3001로 내려 tailnet에 평문으로 직접 노출되지 않게 한다.
    listenHost = "localhost";
    port = 3001;
    hydraURL = "https://constdesktop.tail5b5022.ts.net:3000";
    notificationSender = "hydra@constdesktop";
    # 없으면 cache.nixos.org에 이미 있는 것까지 전부 로컬 빌드한다.
    useSubstitutes = true;
  };
  # 모듈의 hydra-init이 `runuser … createdb -O hydra hydra`를 `--` 없이
  # 호출해 runuser가 -O를 자기 옵션으로 파싱하고 죽는다(nixpkgs 버그;
  # 같은 스크립트의 psql 호출엔 `--`가 있다). DB/유저를 ensure*로 만들고
  # 마커 파일을 미리 둬서 고장난 분기를 통째로 건너뛴다.
  services.postgresql = {
    ensureUsers = [
      {
        name = "hydra";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [ "hydra" ];
  };
  systemd.tmpfiles.rules = [
    "d /var/lib/hydra 0750 hydra hydra - -"
    "f /var/lib/hydra/.db-created 0644 hydra hydra - -"
  ];
  # hydra-evaluator는 restricted eval로 돌므로 flake 입력 fetch 대상을
  # 명시적으로 허용해야 한다.
  nix.settings.allowed-uris = [
    "github:"
    "https://github.com/"
    "https://api.github.com/"
  ];
  # 3000 포트는 공개 방화벽에 열지 않는다 — tailscale0이 trusted라
  # 테일넷에서만 접근 가능(status-web과 동일한 노출 모델).
  webapps.apps.hydra = {
    title = "Hydra CI";
    port = 3000;
    description = "빌드 팜 · jobset · 평가 로그";
    upstream = "http://127.0.0.1:3001";
  };

  # Hydra는 평가·빌드마다 GC 루트를 잡고 keep-outputs/keep-derivations도
  # 켜므로 스토어가 빨리 붇는다. 공유 설정(주간·14d)보다 공격적으로:
  # 매일 7d 보존 GC + 여유 공간이 30G 아래로 내려가면 빌드 중이라도
  # 80G 확보까지 즉시 GC(min-free/max-free, /nix/store 251G 파티션 기준).
  # 루트를 오래 잡는 쪽은 Hydra 자신이므로 jobset의 "evaluations to
  # keep"도 UI에서 1~3으로 둘 것.
  nix.gc = {
    dates = lib.mkForce "daily";
    options = lib.mkForce "--delete-older-than 7d";
  };
  nix.settings = {
    min-free = 30 * 1024 * 1024 * 1024;
    max-free = 80 * 1024 * 1024 * 1024;
  };
}
