{
  lib,
  hyprland,
  fetchFromGitLab,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hyprland-cursor-lock";
  version = "unstable";

  src = fetchFromGitLab {
    domain = "gitlab.com";
    owner = "oriionn";
    repo = finalAttrs.pname;
    rev = "69b3eefd6d46cb3fa33dcf077551bf25c3a54ff0";
    hash = "sha256-TEEQK7cwCFgPx+KDD07bwL9OCtvczkB4lA93RoQc634=";
  };

  cargoHash = "sha256-qQJOi2AZfKAl+JCDUQniSh0c1aH9ofM8Jrg54bqIvQo=";

  meta = with lib; {
    maintainers = with maintainers; [shymega];
    mainProgram = finalAttrs.pname;
    inherit (hyprland.meta) platforms;
  };
})
