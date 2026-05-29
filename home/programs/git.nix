{ config, ... }:
{
  programs.git = {
    enable = true;
    settings.user = {
      name = "constexpr-if";
      email = "constexpr12@gmail.com";
    };
  };
}
