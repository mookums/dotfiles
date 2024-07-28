{self, home-manager, nixpkgs, pkgs, system, stateVersion}: {
    mkComputer = {machineConfig}:
        nixpkgs.lib.nixosSystem {
            inherit system pkgs;

            modules = [
                machineConfig
		        { system.stateVersion = stateVersion; }

                home-manager.nixosModules.home-manager {
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
		            home-manager.extraSpecialArgs = { inherit self; };
                    home-manager.users.muki = import ./users/muki.nix {
                        inherit pkgs stateVersion self;
                    };
                }
            ];
	};
}
