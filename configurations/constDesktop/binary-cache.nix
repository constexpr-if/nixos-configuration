{
  # Hydra가 빌드한 결과물을 노트북에 서명된 바이너리 캐시로 내준다.
  # cache.nixos.org에 없는 것(unfree 앱, 호스트 고유 구성물)을 노트북이
  # 원격 빌드 경로를 거치지 않고 바로 받게 하려는 것이다.
  #
  # 노출 모델은 status-web·webapps와 같다: 5000 포트는 공개 방화벽에
  # 열지 않고 tailscale0(trusted)로만 도달 가능. 전송은 WireGuard가
  # 감싸고 내용 무결성은 narinfo 서명으로 보장하므로 평문 HTTP로 둔다.
  #
  # 서명키는 스토어에 들어가지 않도록 root 소유 0400 파일로 두고
  # LoadCredential로 넘긴다. 없으면 harmonia가 시작하지 않으므로
  # 스위치 전에 만들 것:
  #   sudo install -d -m 0700 /var/lib/secrets
  #   sudo nix key generate-secret --key-name constdesktop-1 \
  #     | sudo install -m 0400 /dev/stdin /var/lib/secrets/harmonia.secret
  #   sudo sh -c 'nix key convert-secret-to-public < /var/lib/secrets/harmonia.secret'
  # 공개키는 노트북 설정의 trusted-public-keys에 들어간다.
  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [ "/var/lib/secrets/harmonia.secret" ];
  };
}
