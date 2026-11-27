
{
  description = "Minha configuracao NixOS baseada em Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs, ... }@inputs:

  let
    # arquitetura
    system = "x86_64-linux";

    # pacotes oficiais
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    # pacotes personalizados (programas sem suporte oficial)
    customPackages = import ./packages {
      inherit pkgs;
    };

  in {
    # disponibiliza build individuais para os pacotes personalizados
    packages.${system} = customPackages;

    # configuração do sistema
    nixosConfigurations."0kauaa" = nixpkgs.lib.nixosSystem {
      inherit system;

      # módulos que compõem o sistema
      modules = [
        # Configuração principal do NixOS.
        ./configuration.nix

        # módulo adicional para instalar nossos pacotes personalizados
        {
          environment.systemPackages =
            builtins.attrValues customPackages;
        }
      ];
    };
  };
}
