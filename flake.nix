{
  description = "Hyprland on Nixos";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = { nixpkgs, catppuccin, home-manager, ... }: {
    nixosConfigurations.enma-ai = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/enma-ai/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.kid_goth = {
              imports = [ 
                ./modules/kid_goth.home.nix
                catppuccin.homeModules.catppuccin
              ];
            };
            backupFileExtension = "backup";
          };
        }
      ];
    };
  };
}
