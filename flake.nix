# - albatross: main desktop

{
  description = "Muki's NixOS :3";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs =
    {
      self,
      home-manager,
      nixpkgs,
      zen-browser,
      ...
    }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [
          (final: prev: {
            zen-browser = zen-browser.packages.${system}.default;
          })
        ];
      };

    in
    {
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [ colmena ];
      };

      colmena = {
        meta = {
          nixpkgs = pkgs;
          specialArgs = { inherit self home-manager; };
        };

        defaults = import ./nix/machine/common.nix;
        
        albatross = import ./nix/machine/albatross.nix;
        # vega = import ./nix/machine/vega.nix { inherit pkgs; };
      };

    };
}
