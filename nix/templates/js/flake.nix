{
  description = "quick development shell for js/ts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Javascript
            nodejs_22
            pnpm
            typescript
            typescript-language-server
          ];

          shellHook = "echo 'Quick DevShell for Javascript/Typescript...'";
        };
      }
    );
}
