{
  description = "Muki's NixOS :3";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-25.05";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      agenix,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {

      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          colmena
          agenix.packages.${system}.default
        ];
      };

      colmena = {
        meta = {
          nixpkgs = pkgs;
          specialArgs = {
            inherit
              self
              home-manager
              agenix
              ;
          };
        };

        defaults = import ./nix/machine/common.nix;

        albatross = import ./nix/machine/albatross.nix;
        janus = import ./nix/machine/janus.nix;
        sisyphus = import ./nix/machine/sisyphus.nix;
        pariah = import ./nix/machine/pariah.nix;
        # vega = import ./nix/machine/vega.nix { inherit pkgs; };
      };

    };
}
