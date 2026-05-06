# ~/nix-config/home.nix
{ config, pkgs, inputs, ... }: {
  home.username = "janlely";           # ← 你的用户名
  home.homeDirectory = "/home/janlely"; # ← 你的家目录
  nixpkgs.config.allowUnfree = true;
  fonts.fontconfig.enable = true;


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
    rofimoji
    unipicker
    wofi
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    grim
    libnotify
    jq
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.fira-code
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    font-awesome
    pkgs.wpsoffice
    pkgs.obsidian
    pkgs.syncthing
    pkgs.socat
    pkgs.wechat
    pkgs.proxychains-ng

    (pkgs.writeShellScriptBin "hypr-fullscreen" ''
      #!/usr/bin/env bash
      WINDOW_INFO=$(hyprctl activewindow -j)
      IS_FULLSCREEN=$(echo "$WINDOW_INFO" | jq '.fullscreen')
      CURRENT_WORKSPACE=$(echo "$WINDOW_INFO" | jq '.workspace.id')
      
      # 逻辑判断
      if [ "$IS_FULLSCREEN" -eq 2 ]; then
          # 状态 A: 已经是全屏 -> 退出全屏并移回工作区 1
          hyprctl dispatch fullscreen 0
          hyprctl dispatch movetoworkspace 1
      elif [ "$IS_FULLSCREEN" -eq 1 ]; then
          hyprctl dispatch fullscreen 1
          hyprctl dispatch movetoworkspace 1
      else
          # 状态 B: 不是全屏 -> 移到右侧新工作区并全屏
          # 这里使用 r+1 是为了灵活性，如果你固定想去某个区也可以改号
          hyprctl dispatch movetoworkspace r+1
          sleep 0.1
          hyprctl dispatch fullscreen $1
      fi
    '')
  ];

  services.syncthing.enable = true;
  #services.syncthing = {
  #  enable = true;
  #  guiAddress = "0.0.0.0:8384";
  #  insecureSkipHostcheck = true;
  #};

  programs.yazi.enable = true;

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
      if command -v fzf >/dev/null 2>&1; then
        eval "$(fzf --zsh)"
      fi

      bindkey '^R' fzf-history-widget
      bindkey '^T' fzf-file-widget
      bindkey '^[c' fzf-cd-widget
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

    settings = {

      "$mod" = "SUPER";

      exec-once = [
	"fcitx5"
      ];

      general = {
        layout = "master";
	border_size = 2;
        resize_on_border = true;
        extend_border_grab_area = 15;
        hover_icon_on_border = true;
      };


      workspace = [
        "f[1], gapsout:0, gapsin:0"
      ];



      decoration = {
        rounding = 10;
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
          ''$mod, D, exec, rofi -show drun -show-icons''
          ''$mod, Tab, exec, rofi -show window -show-icons''
          ''$mod, A, exec, flameshot gui -p ~/Pictures/Screenshots''
	  ''$mod, left,  workspace, e-1''
	  ''$mod, right,  workspace, e+1''
	  ''$mod, L, exec, hyprlock''
	  ''$mod, mouse:272, movewindow''
	  ''$mod, E, exec, rofimoji --selector wofi --action copy''
	  ''$mod, F, exec, hypr-fullscreen 1''
	  ''$mod SHIFT, F, exec, hypr-fullscreen 0''
	  ''$mod, T, togglesplit, ''
        ];
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
