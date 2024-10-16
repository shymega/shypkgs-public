{ system, inputs }:
let
  inherit (inputs.nixpkgs.lib) hasSuffix optionalAttrs;
in
{
  dwl = optionalAttrs (hasSuffix "-linux" system) (import ../home-manager/dwl { inherit inputs system; });
}
