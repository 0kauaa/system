{
  description = "Minha configuracao NixOS baseada em Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    opencode-automatico = pkgs.writeShellApplication {
      name = "opencode";
      runtimeInputs = with pkgs; [ nodejs_22 bun git ];
      text = ''
        exec ${pkgs.nodejs_22}/bin/npx --yes opencode-ai@latest "$@"
      '';
    };
  in {
    nixosConfigurations."0kauaa" = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix

        {
          environment.systemPackages = [
            opencode-automatico
          ];
        }
      ];
    };
  };
}
