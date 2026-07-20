{
  config,
  ...
}:
let
  HOME = config.home.homeDirectory;
in
{
  enable = true;
  cacheHome = "${HOME}/.cache";
  configHome = "${HOME}/.config";
  dataHome = "${HOME}/.local/share";
  stateHome = "${HOME}/.local/state";
}
