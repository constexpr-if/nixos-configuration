# 트레이딩 인프라: PostgreSQL 18 (전용 파티션 p7) + KIS-Broker.
# 설계는 ~/Workspaces/Backtest/KIS-Broker/DESIGN.md 참고.
{ pkgs, ... }:
{
  # PG 데이터 전용 파티션 (nvme0n1p7, 80GiB). DB 증가를 /home 과 격리한다.
  fileSystems."/var/lib/postgresql" = {
    device = "/dev/disk/by-label/postgres";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  # Market-History-Database 와 공유하는 단일 인스턴스. broker DB/롤은
  # kis-broker 모듈이 ensure* 로 얹는다. JIT 는 MHD 분석 쿼리용 —
  # 브로커 OLTP 는 비용 문턱에 도달하지 않아 무관하다.
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
    enableJIT = true;
  };

  # 로거 프록시 (1단계: 관찰자 모드). tailscale 주소에만 바인딩하므로
  # tailnet 밖에서는 보이지 않는다 — 방화벽 포트를 열 필요가 없다.
  services.kis-broker = {
    enable = true;
    instances.prod = {
      market = "prod";
      listenAddress = "100.74.26.112";
      port = 8443;
    };
    instances.vts = {
      market = "vts";
      listenAddress = "100.74.26.112";
      port = 8444;
    };
  };
}
