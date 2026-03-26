# ~/nix-config/flake.nix {
{
  description = "My NixOS system configuration";

  inputs = {
    # 使用稳定分支（推荐）或 unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";  # ← 当前最新 LTS

    # 可选：添加 Home Manager（强烈推荐用于用户环境）
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 可选：NUR（社区包仓库）
    nur.url = "github:nix-community/NUR";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";  # 替换为 aarch64-linux（如 Mac M 系列或 ARM 服务器）
      pkgs = nixpkgs.legacyPackages.${system};
      hostname = "janlely-nixos";
      username = "janlely";
    in
    {
      # 定义 NixOS 系统配置
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix

          # 启用 Home Manager 集成
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.janlely = import ./home.nix;  # ← 替换为你的用户名
            home-manager.backupFileExtension = "hm.bak";
          }

          {
            nixpkgs.config.allowUnfree = true;
          }
          # 可选：启用 NUR overlay
          #{
          #  nixpkgs.overlays = [ inputs.nur.overlay.default ];
          #}
        ];
      };

      # ==================== 新增：Home Manager 配置 ====================
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { inherit inputs; };

        modules = [
          ./home.nix
        ];
      };


      # 便于调试：暴露系统构建产物
      packages.${system}.default = self.nixosConfigurations.${hostname}.config.system.build.toplevel;
      formatter.${system} = pkgs.alejandra;
       
    };
}
