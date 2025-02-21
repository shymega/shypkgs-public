{ pkgs
}:
pkgs.writeShellApplication {
  name = "email-gitsync";
  text = ''
    echo 'Hello World'
  '';
}
