{ config, pkgs, ... }: {

  services.xserver.videoDrivers = ["nvidia"];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ nvidia-vaapi-driver ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = true;                    # ← 改成 false（最重要）
    nvidiaSettings = true;
    #package = config.boot.kernelPackages.nvidiaPackages.stable;
    # 如果还是不行，可以改成 beta 试试：
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  environment.variables = {
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
    __EGL_VENDOR_LIBRARY_FILENAMES = "/run/current-system/sw/share/glvnd/egl_vendor.d/10_nvidia.json";
    
    # Wayland 相关
    #NIXOS_OZONE_WL = "1";
    #MOZ_ENABLE_WAYLAND = "1";
    #QT_QPA_PLATFORM = "wayland";
    #SDL_VIDEODRIVER = "wayland";
  };

  boot.kernelParams = [
    "nvidia_drm.modeset=1"
    "nvidia_drm.fbdev=1"
  ];
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];
}
