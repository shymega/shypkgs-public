{pkgs}: let
  inherit (pkgs.lib) getExe;
in
  pkgs.writeShellApplication {
    name = "wm-menu";
    text = ''
      #!/bin/sh
      echo "INFO: Launching menu with X11 support.."
       exec ${getExe pkgs.rofi} -combi-modi "window,drun,ssh,run" -show combi -modi combi -lines 20 -hide-scrollbar

      exit
    '';
  }
