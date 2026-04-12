{
  writeShellApplication,
  rofi,
  lib,
}: let
  inherit (lib) getExe;
in
  writeShellApplication rec {
    name = "wm-menu";
    text = ''
      #!/bin/sh
      echo "INFO: Launching menu with X11 support.."
       exec ${getExe rofi} -combi-modi "window,drun,ssh,run" -show combi -modi combi -lines 20 -hide-scrollbar

      exit
    '';

    meta = {
      mainProgram = name;
      inherit (rofi.meta) platforms;
    };
  }
