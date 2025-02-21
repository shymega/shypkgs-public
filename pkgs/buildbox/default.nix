{
  lib,
  stdenv,
  fetchFromGitLab,
  bubblewrap,
  makeWrapper,
  cmake,
  pkg-config,
  ninja,
  grpc,
  gbenchmark,
  gtest,
  protobuf,
  glog,
  nlohmann_json,
  zlib,
  openssl,
  libuuid,
  tomlplusplus,
  fuse3,
}: let
  pname = "buildbox";
  version = "1.2.25";
in
  stdenv.mkDerivation {
    inherit pname version;

    buildInputs = [
      cmake
      pkg-config
      ninja
      bubblewrap
    ];
    nativeBuildInputs = [
      grpc
      gbenchmark
      gtest
      glog
      protobuf
      nlohmann_json
      zlib
      openssl
      libuuid
      tomlplusplus
      fuse3
      makeWrapper
    ];

    src = fetchFromGitLab {
      domain = "gitlab.com";
      owner = "BuildGrid";
      repo = "${pname}/${pname}";
      rev = "${version}";
      hash = "sha256-8umP9tUnSiB+ujlaMDrkwpU9269h/MGZZ2MsZS/c/Xs=";
    };

    postFixup = ''
      wrapProgram $out/bin/buildbox-run-bubblewrap --prefix PATH : ${lib.makeBinPath [bubblewrap]}
      ln -s buildbox-run-bubblewrap $out/bin/buildbox-run
    '';

    meta = {
      platforms = lib.platforms.linux;
    };
  }
