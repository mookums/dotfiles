#   - albatross: main desktop
#   - vega: satellite desktop
#   - sirius: main laptop
#   - jupiter: vm image

{
    description = "Muki's NixOS :3";
    
    inputs = rec {
        nixpkgs.url = "github:nixos/nixpkgs/7e7c39ea35c5cdd002cd4588b03a3fb9ece6fad9";
        nixos-hardware.url = "github:NixOS/nixos-hardware";

        home-manager.url = "github:nix-community/home-manager";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = inputs@{ self, home-manager, nixpkgs, ...}:
    let
        system = "x86_64-linux";
        stateVersion = "24.05";

        pkgs = import nixpkgs {
            inherit system;
        };

        utils = import ./nix/utils.nix {
            inherit self home-manager nixpkgs pkgs system stateVersion;
        };
    in
    rec {
        nixosConfigurations =
            {
                albatross = utils.mkComputer {
                    machineConfig = ./nix/machine/albatross.nix;
                };

                sirius = utils.mkComputer {
                    machineConfig = ./nix/machine/sirius.nix;
                };

                vega = utils.mkComputer {
                    machineConfig = ./nix/machine/vega.nix;  
                };

                jupiter = utils.mkComputer {
                    machineConfig = ./nix/machine/jupiter.nix;  
                };
            };
    };
}
