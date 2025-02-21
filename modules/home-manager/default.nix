{ system, inputs }:
let
  inherit (inputs.nixpkgs.lib) hasSuffix optionalAttrs;
in
{
  dwl = optionalAttrs (hasSuffix "-linux" system) import ./dwl { inherit inputs system; };
}
