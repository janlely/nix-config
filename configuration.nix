# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = false;

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?


  services.xserver.enable = true;

  specialisation = {
    gdm.configuration = {
    	imports = [ ./gdm.nix ./nvidia.nix ];
    };

    sddm.configuration = {
    	imports = [ ./sddm.nix ./nvidia.nix ];
    };
  };

  # fcitx 
  environment.variables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };


  boot.kernelParams = ["nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" "kvm-intel"];


  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.swtpm.enable = true;
  
  
  environment.systemPackages = with pkgs; [
    qemu
    virt-manager
    libvirt
    bridge-utils
    docker
    mihomo
    flameshot
  ];


  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
    };
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-gtk
      qt6Packages.fcitx5-configtool
      qt6Packages.fcitx5-chinese-addons
      fcitx5-nord
      rime-data
    ];
  };
  
  users.users.janlely = {
    isNormalUser = true;
    extraGroups = ["wheel" "video" "audio" "libvirtd"];
  };

  security.sudo.wheelNeedsPassword = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };


  # networking
  networking.hostName = "janlely-nixos";
  #networking.useDHCP = lib.mkForce false;
  #networking.bridges = {
  #  "br0" = {
  #    interfaces = [ "enp0s3" ];
  #  };
  #};
  #
  #networking.interfaces."enp0s3".useDHCP = lib.mkForce false;
  #networking.interfaces."enp0s3".optional = true;
  #networking.interfaces."br0".useDHCP = true;
  #

  #systemd.services."br0-netdev".serviceConfig.TimeoutStartSec = 10;
  #systemd.services."network-addresses-br0".serviceConfig.TimeoutStartSec = 10;
  networking.useNetworkd = true;
  systemd.network.enable = true;
  systemd.network.netdevs."10-br0" = {
    netdevConfig = {
      Name = "br0";
      Kind = "bridge";
    };
  };

  systemd.network.networks."20-enp3s0" = {
    matchConfig.Name = "enp3s0";
    networkConfig = {
      Bridge = "br0";
    };
  };
   
  systemd.network.networks."30-br0" = {
    matchConfig.Name = "br0";
    networkConfig = {
      DHCP = "ipv4";
    };
    dhcpV4Config = {
      UseDNS = true;
      UseNTP = true;
      UseHostname = true;
      UseDomains = true;
    };
  };
  
  systemd.network.wait-online = {
    enable = true;
    anyInterface = true;
  };
  

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" "janlely" ];  # 或只加 "janlely" 也行

    trusted-substituters = [
      "https://mirrors.cernet.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];

    substituters = [
      "https://mirrors.cernet.edu.cn/nix-channels/store?priority=5"   # 加 priority 让它优先（数字越小优先越高）
      "https://cache.nixos.org?priority=100"                         # 官方放最后
    ];
  };

  nixpkgs.config.allowUnfree = true;


  services.openssh.enable = true;

  programs.steam.enable = true;
  programs.zsh.enable = true;
  users.users.janlely.shell = pkgs.zsh;


  # docker
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "janlely" ];

  programs.nix-ld.enable = true;
 
}

