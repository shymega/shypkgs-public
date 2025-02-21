{ stdenv
, fetchFromGitLab
, cmake
, pkg-config
, ninja
, grpc
, gbenchmark
, gtest
, protobuf
, glog
, nlohmann_json
, zlib
, openssl
, libuuid
, tomlplusplus
, fuse3
}:
let
  version = "1.2.25";
in
stdenv.mkDerivation {
  pname = "buildbox";
  inherit version;

  buildInputs = [ cmake pkg-config ninja ];
  nativeBuildInputs = [ grpc gbenchmark gtest glog protobuf nlohmann_json zlib openssl libuuid tomlplusplus fuse3 ];

  src = fetchFromGitLab {
    domain = "gitlab.com";
    owner = "BuildGrid";
    repo = "buildbox/buildbox";
    rev = "${version}";
    sha256 = "sha256-8umP9tUnSiB+ujlaMDrkwpU9269h/MGZZ2MsZS/c/Xs=";
  };
}
