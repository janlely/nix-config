{ pkgs, ... }: {
  gtk.cursorTheme = {
    name = "Breeze_Snow";     # 高对比度白色箭头
    package = pkgs.breeze-cursors;
    size = 24;
  };

  # 关键：绕过 NVIDIA Wayland 光标 Bug
  home.sessionVariables = {
    MUTTER_DEBUG_ENABLE_SOFTWARE_CURSOR = "1";
    WLR_DRM_NO_ATOMIC = "1";  # 减少 DRM 冲突
  };
}
