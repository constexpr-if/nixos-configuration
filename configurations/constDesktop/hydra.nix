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
}
