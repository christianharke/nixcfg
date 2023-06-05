{
  description = "NixOS & Home-Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        utils.follows = "flake-utils";
      };
    };

    # Modules

    flake-commons = {
      #url = "github:christianharke/flake-commons";
      url = "/home/chr/code/flake-commons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix-cli = {
      url = "github:cole-h/agenix-cli";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };

    homeage = {
      url = "github:jordanisaacs/homeage/release";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kmonad = {
      url = "github:christianharke/kmonad?dir=nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    nixgl = {
      url = "github:guibou/nixGL";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
      };
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spacevim = {
      url = "github:christianharke/spacevim-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      nixcfgLib = import ./lib {
        inherit inputs;
      };
      inherit (inputs.flake-utils.lib.system) x86_64-linux;
      inherit (nixpkgs.lib) listToAttrs;
    in
    with nixcfgLib;
    {
      lib = { inputs }:
        import ./lib { inputs = inputs // self.inputs; };

      formatter = forEachSystem (system:
        customLibFor."${system}".formatter
      );

      homeConfigurations = listToAttrs [
        (mkHome x86_64-linux "demo@non-nixos-vm")
        (mkHome x86_64-linux "christian@non-nixos-vm")
      ];

      nixosConfigurations = listToAttrs [
        (mkNixos x86_64-linux "nixos-vm")
      ];

      apps = mkForEachSystem [
        (mkApp "setup" {
          file = "setup.sh";
          envs = {
            _doNotClearPath = true;
            flakePath = "/home/\$(logname)/.nix-config";
          };
          path = pkgs: with pkgs; [
            git
            hostname
            jq
          ];
        })

        (mkApp "nixos-install" {
          file = "nixos-install.sh";
          envs = {
            _doNotClearPath = true;
          };
          path = pkgs: with pkgs; [
            git
            hostname
            util-linux
            parted
            cryptsetup
            lvm2
          ];
        })
      ];

      overlays.default = nixpkgs.lib.composeManyExtensions [
        (final: prev: {
          shellcheckPicky = prev.writeShellScriptBin "shellcheck" ''
            ${inputs.nixpkgs.lib.getExe prev.shellcheck} \
            --check-sourced --enable all --external-sources \
            "$@"
          '';
        })
      ];

      checks = mkForEachSystem [
        #(mkGeneric "pre-commit-check" (system:
        #  let
        #    pkgs = import nixpkgs {
        #      inherit system;
        #      overlays = [ self.overlays.default ];
        #    };
        #  in
        #  inputs.pre-commit-hooks.lib."${system}".run {
        #    src = ./.;
        #    hooks = {
        #      nixpkgs-fmt.enable = true;
        #      shellcheck = {
        #        enable = true;
        #        entry = nixpkgs.lib.mkForce "${pkgs.lib.getExe pkgs.shellcheckPicky}";
        #      };
        #      statix.enable = true;
        #    };
        #  }))

        (mkBuild "build-nixos-vm" self.nixosConfigurations.nixos-vm.config.system.build.toplevel)
        (mkBuild "build-demo@non-nixos-vm" self.homeConfigurations."demo@non-nixos-vm".activationPackage)
        (mkBuild "build-christian@non-nixos-vm" self.homeConfigurations."christian@non-nixos-vm".activationPackage)
        (mkGeneric "deadnix" (system: customLibFor."${system}".checks.deadnix))
        (mkGeneric "nixpkgs-fmt" (system: customLibFor."${system}".checks.nixpkgs-fmt))
        (mkGeneric "statix" (system: customLibFor."${system}".checks.statix))
        (mkGeneric "markdownlint" (system: customLibFor."${system}".checks.markdownlint))
        (mkGeneric "shellcheck" (system: customLibFor."${system}".checks.shellcheck))
        (mkGeneric "yamllint" (system: customLibFor."${system}".checks.yamllint))
      ];

      # TODO: Migrate to customLib.mkShell
      devShells = mkForEachSystem [
        (mkDevShell "default" {
          name = "nixcfg";
          packages = pkgs: with pkgs; [ nixpkgs-fmt shellcheck statix ];
        })
      ];
    };
}
