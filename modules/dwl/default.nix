{ inputs, system, ... }:
{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.programs.dwl;
  dwlPkg = import ../../pkgs/dwl { inherit pkgs inputs system; inherit (cfg) patches cmd; dwl-ver = "0.7"; };
in
{
  options.programs.dwl = {
    enable = mkEnableOption "dwl";
    package = mkOption {
      type = types.package;
      default = dwlPkg;
    };
    patches = mkOption {
      type = types.listOf types.path;
      default = [
        ../../pkgs/dwl/dwl-patches/attachbottom.patch
        ../../pkgs/dwl/dwl-patches/vanitygaps.patch
        ../../pkgs/dwl/dwl-patches/focusdirection.patch
      ];
    };
    cmd = {
      terminal = mkOption {
        type = types.str;
        default = "wezterm";
      };
      menu = mkOption {
        type = types.str;
        default = "${pkgs.dmenu}/bin/dmenu"; # FIXME: Add wrapper package for `wofi`?
      };
      editor = mkOption {
        type = types.str;
        default = "emacsclient -cnq";
      };
      chat = mkOption {
        type = types.str;
        default = "weechat";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = singleton cfg.package;
  };
}
