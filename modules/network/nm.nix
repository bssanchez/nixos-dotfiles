{ pkgs, ... }: {

  # programs.nm-applet = {
  #   enable = true;
  #   indicator = true;
  # };

  services.network-manager-applet.enable = true;
}
