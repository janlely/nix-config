{ config, pkgs, gtk, ... }: {

  services.displayManager.gdm.enable = true;

  services.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme          # GNOME 默认光标主题（解决白色方块）
    hicolor-icon-theme          # fallback 图标主题
    noto-fonts
    noto-fonts-lgc-plus
    noto-fonts-color-emoji
    liberation_ttf
    dejavu_fonts
  ];

  xdg.icons.enable = true;

}
