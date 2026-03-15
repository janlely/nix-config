{ config, pkgs, lib, ... }:

{
  # 覆盖或补充主配置

  # 关闭其他显示管理器
  services.displayManager.gdm.enable = lib.mkForce false;
  services.displayManager.sddm.enable = lib.mkForce false;

  # 启用 Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    
    # 如果你用 flakes 引入的 hyprland，可以这样指定最新版
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    
    # 推荐开启 portal（屏幕共享、文件选择等）
    portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };
  };

  # Wayland 环境变量（重要，尤其是 NVIDIA）
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";

    # 如果是 NVIDIA
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
  };

  # 常用 Hyprland 相关软件包
  environment.systemPackages = with pkgs; [
    hyprland
    waybar
    hyprpaper
    hyprlock
    hypridle
    rofi-wayland
    dunst
    cliphist
    wl-clipboard
    grim
    slurp
    swappy
    swww
    kitty
    nautilus
    pavucontrol
    brightnessctl
    playerctl
  ];

  # polkit（图形权限提升）
  security.polkit.enable = true;

  # pipewire（音频）
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # 如果有 NVIDIA，保留或覆盖驱动设置
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # 可选：默认启动 Hyprland（如果想让这个 specialisation 默认进 Hyprland）
  # services.displayManager.defaultSession = "hyprland";
}
