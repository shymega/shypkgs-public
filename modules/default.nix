{ system, inputs }: {
  hmModules = import ./home-manager { inherit inputs system; };
  nixosModules = import ./nixos { inherit inputs system; };
}
