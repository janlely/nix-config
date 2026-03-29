# ~/nix-config/home.nix
{ config, pkgs, inputs, ... }: {
  home.username = "janlely";           # ← 你的用户名
  home.homeDirectory = "/home/janlely"; # ← 你的家目录
  nixpkgs.config.allowUnfree = true;


  # 安装用户级软件包
  home.packages = with pkgs; [
    curl
    wget
    google-chrome
    virt-manager          # 图形 virt-manager
    vulkan-tools vulkan-loader mesa-demos   # 如果你玩游戏/测试图形
    neovim htop ripgrep fd bat eza
    fnm
    qwen-code
    wl-clipboard
    fzf
    pkgs.telegram-desktop
    pkgs.claude-code
    uv
    rofi
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    grim
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "janlely";
      user.email = "janlely@163.com";
      core.editor = "nvim";
    };
  };


  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # 可选：oh-my-zsh
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "docker" ];
      theme = "robbyrussell";  # 或你喜欢的
    };

    shellAliases = {
      ll = "eza -l";
      vim = "nvim";
      update = "sudo nixos-rebuild switch --flake ~/nix-config#janlely-nixos";
      clearboot = "sudo nix profile wipe-history --profile /nix/var/nix/profiles/system && sudo nix store gc && sudo nixos-rebuild boot --flake ~/nix-config#janlely-nixos";
      # 加你常用的别名
    };
    initContent = ''
      eval "$(fnm env --use-on-cd --shell zsh --corepack-enabled)"
      source /etc/profiles/per-user/$USER/share/fzf/key-bindings.zsh
    '';
  };

  # 启用 Home Manager 的状态版本（类似 system.stateVersion）
  home.stateVersion = "25.11";

  home.sessionVariables = {
    MUTTER_DEBUG_DISABLE_HW_CURSORS = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    GSK_RENDERER = "ngl";
  };


  home.pointerCursor = {
    gtk.enable = true;        # 让 GTK 应用生效
    x11.enable = true;        # 让 X11 / XWayland 生效
    name = "Bibata-Modern-Ice";   # 光标主题名称
    package = pkgs.bibata-cursors;    # 提供这个主题的包
    size = 24;                        # 光标大小
  };


  wayland.windowManager.hyprland = {
    enable = true;
    # set the flake package
    #package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    #portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    settings = {
      "$mod" = "SUPER";
      general = {
        layout = "master";
	gaps_in = 5;
	gaps_out = 10;
	border_size = 2;
      };
      master = {
        orientation = "center";       # 主窗口居中，从窗口左右交替垂直排列
        mfact = 0.70;                 # 主窗口占据约 70% 空间（推荐 0.65~0.75，根据喜好调整）
        new_status = "master";         # 新窗口默认成为主窗口
        new_on_top = true;
        allow_small_split = false;    # 通常保持 false（不想多个主窗口水平小分割）

        # 控制何时真正居中（推荐设 0：始终居中，即使只有一个窗口）
        slave_count_for_center_master = 0;
      };

      bezier = [
        "easeOutQuint, 0.23, 1, 0.32, 1"
      ];

      animation = [
        "workspaces, 1, 7, easeOutQuint, fade"
        "workspacesIn, 1, 6, easeOutQuint, fade"
        "workspacesOut, 1, 6, easeOutQuint, fade"
        "windows, 1, 7, easeOutQuint, popin 85%"
        "fade, 1, 6, easeOutQuint"
      ];

      windowrule = [
      ];
      windowrulev2 = [
      ];
      bind =
        [
          ''$mod, RETURN, exec, kitty''
          ''$mod, M, layoutmsg, swapwithmaster''
          ''$mod, D, exec, rofi -show drun''
          ''$mod, A, exec, flameshot gui -p ~/Pictures/Screenshots''
	  ''$mod, left,  workspace, e-1''
	  ''$mod, right,  workspace, e+1''
	  ''$mod, L, exec, hyprlock''
        ]
        ++ (
           builtins.concatLists (builtins.genList (i:
             let ws = i + 1;
             in [
      	 "$mod, code:1${toString i}, workspace, ${toString ws}"
      	 "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
             ]
           )
           9)
        );
    };
  };

  services.flameshot = {
    enable = true;
  
    settings = {
      General = {
        # 关键选项：强制使用 grim-based Wayland adapter（推荐）
        useGrimAdapter = true;
  
        # 可选：禁用 grim 相关的警告（干净一点）
        disabledGrimWarning = true;
  
        # 其他常用设置（根据喜好调整）
        savePath = "/home/janlely/Pictures/Screenshots";
        saveAsFileExtension = "png";
        uiColor = "#00ff00";           # 截图 UI 颜色
        showHelp = true;
        copyPathAfterSave = true;
        # showDesktopNotification = true;
      };
    };
  };

  # 安装 hyprlock
  programs.hyprlock = {
    enable = true;

    # 可选：声明式配置锁屏界面（推荐从简单开始）
    settings = {
      general = {
        disable_loading_bar = false;
        grace = 300;           # 锁定后 5 分钟内输入密码无需再次解锁（单位：秒）
        hide_cursor = false;
        no_fade_in = false;
      };

      background = [
        {
          path = "screenshot";        # 使用当前屏幕截图作为背景（推荐）
          # path = "~/Pictures/wallpaper/lock.jpg";  # 或者使用固定壁纸
          blur_passes = 3;
          blur_size = 8;
          color = "rgba(0, 0, 0, 0.5)";
        }
      ];

      input-field = [
        {
          size = "300, 50";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          outer_color = "rgba(255, 255, 255, 0.3)";
          inner_color = "rgba(0, 0, 0, 0.5)";
          font_color = "rgb(255, 255, 255)";
          fade_on_empty = false;
          placeholder_text = "输入密码...";
          hide_input = false;
          position = "0, -120";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        {
          text = "$TIME";
          color = "rgba(255, 255, 255, 0.9)";
          font_size = 80;
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
