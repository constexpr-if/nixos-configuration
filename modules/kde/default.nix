{
  config,
  lib,
  pkgs,
  ...
}:
let
  mkNodes =
    kdePackages:
    lib.mapAttrs (
      key: node:
      assert node.name == key;
      node
    ) (import ./dependency.nix { inherit pkgs kdePackages; });
  nodes = mkNodes pkgs.kdePackages;
  scopedNodes = mkNodes config.kdepackages.kdePackages;
  enabled = node: config.kdepackages.${node.name}.enable;
in
{
  imports = [
    ./partition-manager.nix
    ./plasma.nix
    ./sddm.nix
  ];
  options.kdepackages = {
    kdePackages = lib.mkOption {
      type = lib.types.raw;
      default = pkgs.kdePackages;
      defaultText = lib.literalExpression "pkgs.kdePackages";
      description = "앱 유닛들이 패키지를 가져올 kdePackages 스코프";
    };
  }
  // lib.mapAttrs (
    _: node:
    {
      enable = lib.mkEnableOption node.name;
    }
    // lib.optionalAttrs (node.package != null) {
      package = lib.mkOption {
        type = lib.types.package;
        default = scopedNodes.${node.name}.package;
        description = "${node.name} 패키지";
      };
    }
  ) nodes;
  config = {
    kdepackages = lib.mkMerge (
      map (
        node:
        lib.mkIf (enabled node) (
          lib.genAttrs (map (dep: dep.name) node.depends) (_: {
            enable = true;
          })
        )
      ) (lib.attrValues nodes)
    );
    home-manager.sharedModules = [
      {
        home.packages = lib.concatMap (
          node: lib.optional (enabled node && node.package != null) config.kdepackages.${node.name}.package
        ) (lib.attrValues nodes);
      }
    ];
  };
}
