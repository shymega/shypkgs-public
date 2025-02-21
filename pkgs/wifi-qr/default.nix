{ lib
, stdenv
}:
stdenv.mkDerivation {
  pname = "wifi-qr";
  version = "0.1.0";

  meta = {
    maintainers = with lib.maintainers;
      [ shymega ];
  };
}
