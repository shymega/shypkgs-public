{ lib
, writeShellApplication
, pkgs
,
}:
let
  inherit (lib) getExe getExe';
  bash = getExe pkgs.bash;
  swaymsg = getExe' pkgs.sway "swaymsg";
  jq = getExe pkgs.jq;
in
writeShellApplication {
  name = "wl-screen-share-stop";

  text = ''
      #!/usr/bin/env ${bash}

    # Get all outputs with names starting with HEADLESS-
    headless_outputs=$(${swaymsg} -t get_outputs | ${jq} -r '.[] | select(.name | startswith("HEADLESS-")) | .name')

    # Check if there are any HEADLESS outputs
    if [ -z "$headless_outputs" ]; then
        echo "No HEADLESS outputs found."
        exit 0
    fi

    # Unplug each HEADLESS output
    for output in $headless_outputs; do
        echo "Unplugging $output..."
        ${swaymsg} output "$output" unplug
    done

    echo "All HEADLESS outputs have been unplugged."
  '';

  meta = {
    maintainers = with lib.maintainers; [ shymega ];
  };
}