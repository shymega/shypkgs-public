{
  hostPlatform,
  inputs,
}: let
  inherit (inputs.nixpkgs.lib) hasSuffix optionalAttrs;
in {
  dwl = optionalAttrs (hasSuffix "-linux" hostPlatform) import ./dwl {inherit inputs hostPlatform;};
}
