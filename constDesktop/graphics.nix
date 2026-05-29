{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  systemd.tmpfiles.rules =
    let
      rocmEnv = pkgs.symlinkJoin {
        name = "rocmEnv";
        paths = with pkgs.rocmPackages; [
          hipcc
          clr
          rocblas
          hipblas
          rocfft
          hipfft
          rocsolver
          hipsolver
          rocsparse
          hipsparse
        ];
      };
    in
    [
      "L+ /opt/rocm - - - - ${rocmEnv}"
    ];
  hardware.amdgpu.opencl.enable = true;
  services.lact.enable = true;
}
