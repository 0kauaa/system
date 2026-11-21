{
  description = "Minha configuracao NixOS baseada em Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    # opencode
    opencode-automatico = pkgs.writeShellApplication {
      name = "opencode";
      runtimeInputs = with pkgs; [ nodejs_22 bun git ];
      text = ''
        exec ${pkgs.nodejs_22}/bin/npx --yes opencode-ai@latest "$@"
      '';
    };

    # sklauncher
    sklauncher = pkgs.stdenv.mkDerivation {
      pname = "sklauncher";
      version = "3.2.18";

      src = pkgs.fetchurl {
        url = "https://skmedix.pl/binaries/skl/3.2.18/SKlauncher-3.2.18.jar";
        hash = "sha256-Jac+N3Ch2NFLzlPokg4uiTqsw8cV0Psi+HjvIJDQOGM=";
      };

      nativeBuildInputs = [ pkgs.makeWrapper ];
      dontUnpack = true;

      installPhase = ''
        runHook preInstall

        install -Dm644 "$src" "$out/share/sklauncher/SKlauncher.jar"
        makeWrapper ${pkgs.jdk21}/bin/java $out/bin/sklauncher \
          --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath (with pkgs; [ gtk3 glib pango atk cairo gdk-pixbuf libXxf86vm libGL libX11 libXtst vulkan-loader alsa-lib libpulseaudio flite wayland libxkbcommon libdecor ])}" \
          --set JAVA_TOOL_OPTIONS "-DMC_DEBUG_ENABLED=true -DMC_DEBUG_PREFER_WAYLAND=true" \
          --add-flags "-Djava.library.path=${pkgs.openjfx21}/modules_libs/javafx.graphics:${pkgs.openjfx21}/modules_libs/javafx.media -jar $out/share/sklauncher/SKlauncher.jar"

        install -Dm755 /dev/null "$out/share/applications/sklauncher.desktop"
        cat > "$out/share/applications/sklauncher.desktop" <<'EOF'
[Desktop Entry]
Name=SKlauncher
Comment=Community Minecraft launcher
Exec=sklauncher
Terminal=false
Type=Application
Categories=Game;
StartupNotify=true
EOF

        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "Unofficial community Minecraft launcher";
        homepage = "https://skmedix.pl/";
        license = licenses.unfree;
        mainProgram = "sklauncher";
        platforms = platforms.linux;
      };
    };
  in {
    nixosConfigurations."0kauaa" = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix

        {
          environment.systemPackages = [
            opencode-automatico
            sklauncher
          ];
        }
      ];
    };
  };
}
