{ config, ... }: {
  programs.git = {
    enable = true;
    userName = "constexpr-if";
    userEmail = "constexpr12@gmail.com";
  };
}
