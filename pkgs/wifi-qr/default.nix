{ lib
, stdenv
}:
stdenv.mkDerivation {
  pname = "syncall";
  version = "0.3";

  meta = {
    maintainers = with lib.maintainers;
      [ shymega ];
  };
}
