{ config, ... }: {
  firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";
  zsh.dotDir = "${config.xdg.configHome}/zsh";
}
