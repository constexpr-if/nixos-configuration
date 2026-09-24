{ lib, ... }:
{
  services.hydra = {
    enable = true;
    hydraURL = "http://constdesktop:3000";
    notificationSender = "hydra@constdesktop";
    # 없으면 cache.nixos.org에 이미 있는 것까지 전부 로컬 빌드한다.
    useSubstitutes = true;
  };
  # hydra-evaluator는 restricted eval로 돌므로 flake 입력 fetch 대상을
  # 명시적으로 허용해야 한다.
  nix.settings.allowed-uris = [
    "github:"
    "https://github.com/"
    "https://api.github.com/"
  ];
  # 3000 포트는 공개 방화벽에 열지 않는다 — tailscale0이 trusted라
  # 테일넷에서만 접근 가능(status-web과 동일한 노출 모델).

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
