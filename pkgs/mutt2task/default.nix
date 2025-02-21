{
  lib,
  fetchFromGitHub,
  stdenv,
  python3Packages,
}: let
  pname = "mutt2task";
  version = "unstable";
in with python3Packages; buildPythonApplication rec {
    inherit pname version;
    pyproject = false;
    src = fetchFromGitHub {
      owner = "artur-shaik";
      repo = "mutt2task";
      rev = "34d120f3d3e8f2153fbd7847335d474959dfa425";
      hash = "sha256-wP39LJmCt446XwOtGaE/CYXP8zBNnsGrXx1JjEytlLc=";
    };

    installPhase = "install -Dm755 ./mutt2task.py $out/bin/mutt2task";

    meta = with lib; {
      maintainers = with maintainers; [shymega];
      mainProgram = "mutt2task";
      platforms = with platforms; unix;
    };
  }
