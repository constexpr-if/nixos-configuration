{ nixpkgs, haumea, ... }:
with nixpkgs.lib;
{
  mergeAttrs = foldl' recursiveUpdate { };
  flatdir-module = p: {
    imports = pipe p [
      readDir
      attrNames
      (map (path.append p))
    ];
  };
  haumea-module =
    src:
    { pkgs, ... }@args:
    haumea.lib.load {
      inherit src;
      inputs = args // {
        inherit haumea-module;
      };
    };
}
