{
  nixConfig = {
    extra-substituters = [ "https://matthewcroughan.cachix.org" ];
    extra-trusted-public-keys = [ "matthewcroughan.cachix.org-1:fON2C9BdzJlp1qPan4t5AF0xlnx8sB0ghZf8VDo7+e8=" ];
  };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    mobile-nixos = {
      url = "github:matthewcroughan/mobile-nixos/mc/611";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, mobile-nixos, flake-parts }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-linux"
      ];
      perSystem = {
        packages = {
          clan-mobile-images = self.nixosConfigurations.clan-mobile.config.mobile.outputs.android.android-fastboot-images;
        };
      };
      flake = { ... }: {
        nixosConfigurations = {
          clan-mobile = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              (import "${mobile-nixos}/lib/configuration.nix" { device = "oneplus-enchilada"; })
              ./configuration.nix
            ];
            specialArgs = { inherit inputs; };
          };
        };
      };
    };
}
