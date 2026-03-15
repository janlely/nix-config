{ config, pkgs, ... }: {

  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };
  services.desktopManager.plasma6.enable = true;
  
  systemd.user.services.plasma-nm = {
    enable = false;
  };

}
