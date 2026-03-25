# ~/nix-config/home.nix
{ config, pkgs, ... }: {
  home.username = "janlely";           # ← 你的用户名
  home.homeDirectory = "/home/janlely"; # ← 你的家目录



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
    gnome-tweaks
    dconf-editor
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
    name = "Bibata-Modern-Classic";   # 光标主题名称
    package = pkgs.bibata-cursors;    # 提供这个主题的包
    size = 24;                        # 光标大小
  };
}
