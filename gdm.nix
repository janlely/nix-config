{ config, pkgs, ... }: {

  services.displayManager.gdm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;
  
  systemd.user.services.plasma-nm = {
    enable = false;
  };

}
