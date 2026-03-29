# ~/nix-config/flake.nix {
{
  description = "My NixOS system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 可选：NUR（社区包仓库）
    nur.url = "github:nix-community/NUR";
    hyprland.url = "github:hyprwm/Hyprland";

    #hyprland-plugins = {
    #  url = "github:hyprwm/hyprland-plugins";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
  };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      hostname = "janlely-nixos";
      username = "janlely";
    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.janlely = import ./home.nix;
            home-manager.backupFileExtension = "hm.bak";
          }

          {
            nixpkgs.config.allowUnfree = true;
          }

        ];
      };

      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { inherit inputs; };

        modules = [
          ./home.nix

        ];
      };


      packages.${system}.default = self.nixosConfigurations.${hostname}.config.system.build.toplevel;
      formatter.${system} = pkgs.alejandra;
       
    };
}
