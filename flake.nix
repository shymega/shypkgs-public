{
  description = "My public packages repo [LEGACY]";

  nixConfig = {
    substituters = [
      "https://shypkgs.cachix.org?priority=10"
      "https://cache.nixos.org?priority=15"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "shypkgs.cachix.org-1:MlhLc9bDMhpLoKefzZ5OUH24kxtcWGXHw7lzwAn8i9I="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
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
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
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
    inherit forAllSystems allSystems;
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
      inherit
        (self.packages.${final.system})
        arch-test
        bst-to-lorry
        buildstream-source-api-patched
        dwl
        email-gitsync
        git-wip
        is-net-metered
        isync-exchange-patched
        mutt2task
        wl-share-screen
        wl-share-screen-stop
        wm-menu
        ;
      inherit (inputs.nixpkgs.legacyPackages.${final.system}) buildbox buildstream;
    };
  };
}
