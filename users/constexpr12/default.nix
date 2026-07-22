{ libpp, ... }: with libpp;
{
  imports = [
    (haumea-module ./configuration)
  ];
}
