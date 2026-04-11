{
  lib,
  hyprland,
  fetchFromGitHub,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hyprscope";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "bajankristof";
    repo = finalAttrs.pname;
    rev = "5dcb36788c487a6947b8209f8743c563629c118e";
    hash = "sha256-9p4hiX4595QeJ6gzHFjUbtzLqkb8gyydvAS4OP1yaWs=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 -t $out/bin hyprscope
  '';

  meta = with lib; {
    maintainers = with maintainers; [shymega];
    mainProgram = finalAtrs.pname;
    platforms = hyprland.meta.platforms;
  };
})
