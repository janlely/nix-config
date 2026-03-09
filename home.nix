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
  ];



  programs.git = {
    enable = true;
    settings = {
      user.name = "janlely";
      user.email = "janlely@163.com";
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
    '';
  };

  # 启用 Home Manager 的状态版本（类似 system.stateVersion）
  home.stateVersion = "25.11";
}
