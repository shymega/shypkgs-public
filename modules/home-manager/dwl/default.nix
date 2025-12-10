{
  inputs,
  hostPlatform,
  ...
}: {
  config,
  pkgs,
  lib,
  ...
}:
with lib;
assert lib.hasSuffix "-linux" hostPlatform; let
  cfg = config.programs.dwl;
  dwlPkg = import ../../../pkgs/dwl {
    inherit pkgs inputs hostPlatform;
    inherit (cfg) patches cmd;
  };
in {
  options.programs.dwl = {
    enable = mkEnableOption "dwl";
    package = mkOption {
      type = types.package;
      default = dwlPkg;
    };
    patches = mkOption {
      type = types.listOf types.path;
      default = [
        ../../../pkgs/dwl/dwl-patches/attachbottom.patch
        ../../../pkgs/dwl/dwl-patches/vanitygaps.patch
        ../../../pkgs/dwl/dwl-patches/focusdirection.patch
      ];
    };
    cmd = {
      terminal = mkOption {
        type = types.str;
        default = "wezterm";
      };
      menu = mkOption {
        type = types.str;
        default = "${pkgs.lib.getExe pkgs.wm-menu}"; # FIXME: Add wrapper package for `wofi`?
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

  config = mkIf cfg.enable {home.packages = singleton cfg.package;};
}
