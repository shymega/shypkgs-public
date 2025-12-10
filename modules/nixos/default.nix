{
  hostPlatform,
  inputs,
}: let
  inherit (inputs.nixpkgs.lib) hasSuffix optionalAttrs;
in {
  dwl = optionalAttrs (hasSuffix "-linux" hostPlatform) (
    import ../home-manager/dwl {inherit inputs hostPlatform;}
  );
}
