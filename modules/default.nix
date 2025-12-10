{
  hostPlatform,
  inputs,
}: {
  hmModules = import ./home-manager {inherit inputs hostPlatform;};
  nixosModules = import ./nixos {inherit inputs hostPlatform;};
}
