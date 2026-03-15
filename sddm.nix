{ config, pkgs, ... }: {

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;
  
  systemd.user.services.plasma-nm = {
    enable = false;
  };

  xdg.portal = {
    enable = true;
    # 推荐同时带 gtk 后端作为 fallback，很多应用更稳定
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde    # Plasma 6 专用（注意用 kdePackages. 前缀）
      xdg-desktop-portal-gtk                # 强烈建议加上，fallback + 对话框更可靠
    ];
    # 可选：让 xdg-open 优先走 portal（对 Flameshot 不是必须，但整体体验更好）
    config.common.default = [ "kde" "gtk" ];
  };

}
