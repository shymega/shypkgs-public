{ lib
, stdenv
, fetchgit
, pkg-config
, autoconf
, automake
, perl
, openssl
, db
, cyrus_sasl
, zlib
, withCyrusSaslXoauth2 ? false
, cyrus-sasl-xoauth2
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "isync-exchange-patched";
  version = "1.5.0";

  src = fetchgit {
    url = "https://github.com/shymega/isync";
    rev = "0af93316ff2d62472e3faa23420180910b32d858";
    sha256 = "sha256-yqe+qiZLletTuVD9pQKDX57wCBh2LoOr2QBJFBNnhNE=";
  };

  nativeBuildInputs = [ autoconf automake perl pkg-config ]
    ++ lib.optionals withCyrusSaslXoauth2 [ makeWrapper ];
  buildInputs = [ cyrus_sasl db openssl zlib ];

  preConfigure = ''
    touch ChangeLog
    ./autogen.sh
  '';

  postInstall = lib.optionalString withCyrusSaslXoauth2 ''
    wrapProgram "$out/bin/mbsync" \
        --prefix SASL_PATH : "${lib.makeSearchPath "lib/sasl2" [ cyrus-sasl-xoauth2 cyrus_sasl.out ]}"
  '';

  meta = with lib; {
    homepage = "http://isync.sourceforge.net/";
    # https://sourceforge.net/projects/isync/
    changelog = "https://sourceforge.net/p/isync/isync/ci/v${version}/tree/NEWS";
    description = "Free IMAP and MailDir mailbox synchronizer";
    longDescription = ''
      mbsync (formerly isync) is a command line application which synchronizes
      mailboxes. Currently Maildir and IMAP4 mailboxes are supported. New
      messages, message deletions and flag changes can be propagated both ways.
    '';
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ primeos ];
    mainProgram = "mbsync";
  };
}
