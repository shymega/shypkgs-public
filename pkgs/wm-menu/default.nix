{ pkgs }:
let
  inherit (pkgs.lib) getExe;
in
pkgs.writeShellApplication {
  name = "wm-menu";
  text = ''
    #!/bin/sh
    if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
      echo "INFO: Launching menu with Wayland support.."
      exec ${getExe pkgs.rofi-wayland} -combi-modi "window,drun,ssh,run" -show combi -modi combi -lines 20 -hide-scrollbar
    else
      echo "INFO: Launching menu with X11 support.."
       exec ${getExe pkgs.rofi} -combi-modi "window,drun,ssh,run" -show combi -modi combi -lines 20 -hide-scrollbar
    fi

    exit
  '';
}
