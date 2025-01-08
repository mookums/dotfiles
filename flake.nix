# - albatross: main desktop
#   - vega: satellite desktop
#   - sirius: main laptop
{
  description = "Muki's NixOS :3";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-alien.url = "github:thiagokokada/nix-alien";
    ghostty.url = "github:ghostty-org/ghostty/v1.0.1";
  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
    nix-alien,
    ghostty,
    ...
  }: let
    system = "x86_64-linux";
    stateVersion = "24.11";

    pkgs = import nixpkgs {
      inherit system;
      config = {allowUnfree = true;};
      overlays = [
        nix-alien.overlays.default
        (final: prev: {ghostty = ghostty.packages.${system}.default;})
      ];
    };

    utils = import ./nix/utils.nix {
      inherit self home-manager nixpkgs pkgs system stateVersion;
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [lua-language-server];
    };

    nixosConfigurations = {
      albatross =
        utils.mkComputer {machineConfig = ./nix/machine/albatross.nix;};

      sirius = utils.mkComputer {machineConfig = ./nix/machine/sirius.nix;};

      vega = utils.mkComputer {machineConfig = ./nix/machine/vega.nix;};

      owl = utils.mkComputer {machineConfig = ./nix/machine/owl.nix;};
    };
  };
}
