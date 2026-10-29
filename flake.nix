{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    inputactions-ctl = {
      url = "git+https://github.com/InputActions/ctl?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    inputactions-kwin = {
      url = "git+https://github.com/InputActions/kwin?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    inputactions-overlay = {
      url = "git+https://github.com/InputActions/overlay?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, inputactions-ctl, inputactions-kwin,
              inputactions-overlay, ... }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./configuration.nix

          ({ pkgs, ... }: {
            nix.settings = {
              extra-substituters = [
                "https://inputactions.cachix.org"
              ];
              extra-trusted-public-keys = [
                "inputactions.cachix.org-1:yBGhAqTOv0V08lrOTBwMAkU7V/9a0i2UPvsvCu39CjE="
              ];
            };

            environment.systemPackages = [
              inputactions-ctl.packages.${pkgs.system}.default
              inputactions-kwin.packages.${pkgs.system}.default
              inputactions-overlay.packages.${pkgs.system}.default
            ];
          })
        ];
      };
    };
}
