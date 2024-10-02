{ pkgs
}:
pkgs.writeShellApplication {
  name = "wm-menu";
  text = ''
    #!/bin/sh
    exec ${pkgs.rofi} -combi-modi "window,drun,ssh,run" -show combi -modi combi -lines 20 -hide-scrollbar
  '';
}
