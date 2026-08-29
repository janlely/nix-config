# ~/nix-config/home.nix
{ config, pkgs, inputs, ... }: let
  # Mac 沉浸式窗口切换：SUPER+F
  hypr-fullscreen = pkgs.writeShellScriptBin "hypr-fullscreen" ''
    #!/usr/bin/env bash
    if [ -n "$1" ]; then
      WIN_ADDR="$1"
    else
      WIN_ADDR=$(hyprctl activewindow -j | jq -r '.address')
    fi
    [ -z "$WIN_ADDR" ] || [ "$WIN_ADDR" = "null" ] && exit 0
    WS_ID=$(hyprctl clients -j | jq -r --arg a "$WIN_ADDR" '.[] | select(.address==$a) | .workspace.id')
    IS_FULLSCREEN=$(hyprctl clients -j | jq -r --arg a "$WIN_ADDR" '.[] | select(.address==$a) | .fullscreen')
    [ -z "$WS_ID" ] || [ "$WS_ID" = "null" ] && exit 0
    if [ "$IS_FULLSCREEN" != "0" ]; then
      hyprctl dispatch focuswindow address:"$WIN_ADDR" 2>/dev/null
      sleep 0.15
      hyprctl dispatch movetoworkspace 1 2>/dev/null
      sleep 0.2
      hyprctl dispatch fullscreen 2>/dev/null
      sleep 0.1
      hyprctl dispatch fullscreen 2>/dev/null
    elif [ "$WS_ID" = "1" ]; then
      EXISTING=$(hyprctl workspaces -j | jq -r '[.[] | .id] | sort | .[]')
      MAX_WS=$(hyprctl workspaces -j | jq 'map(.id) | max // 0')
      TARGET=""
      for i in $(seq 2 $((MAX_WS + 1))); do
        if ! echo "$EXISTING" | grep -qx "$i"; then
          TARGET="$i"; break
        fi
      done
      [ -z "$TARGET" ] && TARGET=$((MAX_WS + 1))
      hyprctl dispatch focuswindow address:"$WIN_ADDR" 2>/dev/null
      sleep 0.15
      hyprctl dispatch movetoworkspace "$TARGET" 2>/dev/null
      sleep 0.2
      hyprctl dispatch fullscreen 1 2>/dev/null
    fi
  '';

  # 后台监控：ws1内窗口自动浮动 + 路由非ws1窗口 + 默认半屏大小
  hypr-float-ws1 = pkgs.writeShellScriptBin "hypr-float-ws1" ''
    #!/usr/bin/env bash
    TARGET_W=1720
    TARGET_H=720
    STEP=100
    while true; do
      sleep 3
      NEW_W=$(hyprctl monitors -j 2>/dev/null | jq '.[0].width // 1920')
      NEW_H=$(hyprctl monitors -j 2>/dev/null | jq '.[0].height // 1080')
      TARGET_W=$((NEW_W / 2))
      TARGET_H=$((NEW_H / 2))
      ADDRESSES=$(hyprctl clients -j 2>/dev/null | jq -r '.[].address')
      for addr in $ADDRESSES; do
        [ -z "$addr" ] && continue
        WS_ID=$(hyprctl clients -j 2>/dev/null | jq -r --arg a "$addr" '.[] | select(.address==$a) | .workspace.id')
        FS=$(hyprctl clients -j 2>/dev/null | jq -r --arg a "$addr" '.[] | select(.address==$a) | .fullscreen')
        [ -z "$WS_ID" ] && continue
        [ "$FS" = "1" ] && continue
        if [ "$WS_ID" != "1" ]; then
          hyprctl dispatch focuswindow address:"$addr" 2>/dev/null
          sleep 0.05
          hyprctl dispatch movetoworkspace 1 2>/dev/null
        fi
        IF=$(hyprctl clients -j 2>/dev/null | jq -r --arg a "$addr" '.[] | select(.address==$a) | .floating')
        if [ "$IF" = "false" ]; then
          hyprctl dispatch togglefloating address:"$addr" 2>/dev/null
          sleep 0.2
        fi
        CUR_W=$(hyprctl clients -j 2>/dev/null | jq -r --arg a "$addr" '.[] | select(.address==$a) | .size[0]')
        CUR_H=$(hyprctl clients -j 2>/dev/null | jq -r --arg a "$addr" '.[] | select(.address==$a) | .size[1]')
        [ "$CUR_W" = "null" ] && continue
        [ "$CUR_H" = "null" ] && continue
        [ -z "$CUR_W" ] && continue
        [ -z "$CUR_H" ] && continue
        DW=$((TARGET_W - CUR_W))
        DH=$((TARGET_H - CUR_H))
        if [ "$DW" -gt "$STEP" ]; then
          hyprctl dispatch focuswindow address:"$addr" 2>/dev/null
          sleep 0.03
          hyprctl dispatch resizeactive "$STEP" 0 2>/dev/null
        elif [ "$DW" -lt "-$STEP" ]; then
          hyprctl dispatch focuswindow address:"$addr" 2>/dev/null
          sleep 0.03
          hyprctl dispatch resizeactive "-$STEP" 0 2>/dev/null
        fi
        if [ "$DH" -gt "$STEP" ]; then
          hyprctl dispatch focuswindow address:"$addr" 2>/dev/null
          sleep 0.03
          hyprctl dispatch resizeactive 0 "$STEP" 2>/dev/null
        elif [ "$DH" -lt "-$STEP" ]; then
          hyprctl dispatch focuswindow address:"$addr" 2>/dev/null
          sleep 0.03
          hyprctl dispatch resizeactive 0 "-$STEP" 2>/dev/null
        fi
      done
    done
  '';
in {
  home.username = "janlely";
  home.homeDirectory = "/home/janlely";
  nixpkgs.config.allowUnfree = true;
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    curl wget google-chrome virt-manager
    vulkan-tools vulkan-loader mesa-demos
    neovim htop ripgrep fd bat eza
    fnm qwen-code wl-clipboard fzf
    rofi rofimoji unipicker wofi
    xdg-desktop-portal xdg-desktop-portal-hyprland
    grim libnotify jq
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.fira-code
    noto-fonts noto-fonts-cjk-sans
    noto-fonts-color-emoji font-awesome
    pkgs.wpsoffice pkgs.obsidian
    pkgs.syncthing pkgs.socat
    pkgs.wechat pkgs.proxychains-ng
    pkgs.stack pkgs.zellij
    pkgs.localsend pkgs.pi-coding-agent
    nomacs tauon hypr-fullscreen hypr-float-ws1
  ];
  services.syncthing.enable = true;
  programs.yazi.enable = true;
  programs.git = {
    enable = true;
    settings = { user.name = "janlely"; user.email = "janlely@163.com"; core.editor = "nvim"; };
  };
  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "eza -l"; vim = "nvim";
      update = "sudo nixos-rebuild switch --flake ~/nix-config#janlely-nixos";
      clearboot = "sudo nix profile wipe-history --profile /nix/var/nix/profiles/system && sudo nix store gc && sudo nixos-rebuild boot --flake ~/nix-config#janlely-nixos";
    };
    interactiveShellInit = ''
      eval (fnm env --use-on-cd --shell fish --corepack-enabled | string collect)
      if command -v fzf >/dev/null 2>&1; then eval (fzf --fish | string collect); fi
      set -q fish_user_key_bindings; and eval (fish_user_key_bindings)
      set -gx PATH "$HOME/.local/bin" $PATH
    '';
  };
  home.stateVersion = "26.05";
  home.sessionVariables = {
    MUTTER_DEBUG_DISABLE_HW_CURSORS = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    GSK_RENDERER = "ngl";
  };
  home.pointerCursor = {
    gtk.enable = true; x11.enable = true;
    name = "Bibata-Modern-Ice"; package = pkgs.bibata-cursors; size = 24;
  };
  wayland.windowManager.hyprland = {
    enable = true; configType = "hyprlang";
    settings = {
      autogenerated = 0; "$mod" = "SUPER";
      exec-once = ["fcitx5" "${config.home.homeDirectory}/bin/hypr-float-ws1.sh"];
      general = {
        layout = "master"; border_size = 2;
        resize_on_border = true; extend_border_grab_area = 15; hover_icon_on_border = true;
      };
      workspace = ["f[1], gapsout:0, gapsin:0"];
      decoration = { rounding = 10; };
      bezier = ["easeOutQuint, 0.23, 1, 0.32, 1"];
      animation = [
        "workspaces, 1, 7, easeOutQuint, fade"
        "workspacesIn, 1, 6, easeOutQuint, fade"
        "workspacesOut, 1, 6, easeOutQuint, fade"
        "windows, 1, 7, easeOutQuint, popin 85%"
        "fade, 1, 6, easeOutQuint"
      ];
      bind = [
        ''SUPER, RETURN, exec, wezterm''
        ''SUPER, C, killactive''
        ''SUPER, M, layoutmsg, swapwithmaster''
        ''SUPER, D, exec, rofi -show drun -show-icons''
        ''SUPER, Tab, exec, rofi -show window -show-icons''
        ''SUPER, A, exec, flameshot gui -p ~/Pictures/Screenshots''
        ''SUPER, left, workspace, e-1''
        ''SUPER, right, workspace, e+1''
        ''SUPER, L, exec, hyprlock''
        ''SUPER, E, exec, rofimoji --selector wofi --action copy''
        ''SUPER, F, exec, ${pkgs.lib.getExe hypr-fullscreen}''
        ''SUPER, T, layoutmsg, togglesplit''
        ''SUPER, 1, workspace, 1'' ''SUPER, 2, workspace, 2''
        ''SUPER, 3, workspace, 3'' ''SUPER, 4, workspace, 4''
        ''SUPER, 5, workspace, 5'' ''SUPER, 6, workspace, 6''
        ''SUPER, 7, workspace, 7'' ''SUPER, 8, workspace, 8''
        ''SUPER, 9, workspace, 9'' ''SUPER, 0, workspace, 0''
      ];
      bindm = [''SUPER, mouse:272, movewindow''];
    };
  };
  services.flameshot = {
    enable = true;
    settings = { General = { useGrimAdapter = true; disabledGrimWarning = true; savePath = "/home/janlely/Pictures/Screenshots"; saveAsFileExtension = "png"; uiColor = "#00ff00"; showHelp = true; copyPathAfterSave = true; }; };
  };
  programs.hyprlock = {
    enable = true;
    settings = {
      general = { disable_loading_bar = false; grace = 300; hide_cursor = false; no_fade_in = false; };
      background = [{ path = "screenshot"; blur_passes = 3; blur_size = 8; color = "rgba(0, 0, 0, 0.5)"; }];
      input-field = [{ size = "300, 50"; outline_thickness = 2; dots_size = 0.2; dots_spacing = 0.2; dots_center = true; outer_color = "rgba(255, 255, 255, 0.3)"; inner_color = "rgba(0, 0, 0, 0.5)"; font_color = "rgb(255, 255, 255)"; fade_on_empty = false; placeholder_text = "输入密码..."; hide_input = false; position = "0, -120"; halign = "center"; valign = "center"; }];
      label = [{ text = "$TIME"; color = "rgba(255, 255, 255, 0.9)"; font_size = 80; position = "0, 200"; halign = "center"; valign = "center"; }];
    };
  };
  programs.wezterm = { enable = true; };
  xdg.configFile."wezterm" = { source = ./wezterm-config; recursive = true; };
  home.activation = {
    createPiDir = config.lib.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p $HOME/.pi/agent
      $DRY_RUN_CMD chmod 700 $HOME/.pi/agent
    '';
  };
}
