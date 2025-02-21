{
  description = "My public packages repo";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixfigs-helpers.url = "github:shymega/nixfigs-helpers";
  };
  outputs = {self, ...} @ inputs: let
    genPkgs = system:
      import inputs.nixpkgs {
        inherit system;
        overlays = builtins.attrValues self.overlays;
        config = self.nixpkgs-config;
      };

    allSystems = [
      "x86_64-linux"
      "i686-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "armv6l-linux"
      "armv7l-linux"
    ];
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    forAllSystems = f: inputs.nixpkgs.lib.genAttrs allSystems f;
    forEachSystem = inputs.nixpkgs.lib.genAttrs systems;

    treeFmtEachSystem = f: inputs.nixpkgs.lib.genAttrs systems (system: f inputs.nixpkgs.legacyPackages.${system});
    treeFmtEval = treeFmtEachSystem (
      pkgs:
        inputs.nixfigs-helpers.inputs.treefmt-nix.lib.evalModule pkgs "${
          inputs.nixfigs-helpers.helpers.formatter
        }"
    );
  in {
    packages = forAllSystems (
      system: let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
      in
        import ./pkgs {inherit system inputs pkgs;}
    );
    nixosModules = forAllSystems (system: (import ./modules {inherit system inputs;}).nixosModules);
    hmModules = forAllSystems (system: (import ./modules {inherit system inputs;}).hmModules);

    # for `nix fmt`
    formatter = treeFmtEachSystem (pkgs: treeFmtEval.${pkgs.system}.config.build.wrapper);
    # for `nix flake check`
    checks =
      treeFmtEachSystem (pkgs: {
        formatting = treeFmtEval.${pkgs}.config.build.wrapper;
      })
      // forEachSystem (system: {
        pre-commit-check = import "${inputs.nixfigs-helpers.helpers.checks}" {
          inherit self system;
          inherit (inputs.nixfigs-helpers) inputs;
          inherit (inputs.nixpkgs) lib;
        };
      });
    devShells = forEachSystem (
      system: let
        pkgs = genPkgs system;
      in
        import inputs.nixfigs-helpers.helpers.devShells {inherit pkgs self system;}
    );
    nixpkgs-config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
      allowBroken = true;
      allowInsecurePredicate = _: true;
    };
    overlays.default = final: _: {
      # FIXME: Map over attrset.
      inherit
        (self.packages.${final.system})
        dwl
        email-gitsync
        isync-exchange-patched
        syncall
        is-net-metered
        wm-menu
        wifi-qr
        wl-screen-share
        wl-screen-share-stop
        buildbox
        buildstream1
        buildstream2
        ;
    };
  };
}
