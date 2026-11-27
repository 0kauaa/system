
# pacote personalizado do sklauncher (minecraft)

{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "sklauncher";
  version = "3.2.18";

  # download do arquivo original.
  src = pkgs.fetchurl {
    url = "https://skmedix.pl/binaries/skl/3.2.18/SKlauncher-3.2.18.jar";
    hash = "sha256-Jac+N3Ch2NFLzlPokg4uiTqsw8cV0Psi+HjvIJDQOGM=";
  };

  # ferramentas necessárias durante a construção do pacote
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];

  # aquivo JAR não precisa de unpacking
  dontUnpack = true;

  # instalação dos arquivos no nix store
  installPhase = ''
    runHook preInstall

    # cria o diretório e instala o JAR com permissões de leitura
    install -Dm644 "$src" "$out/share/sklauncher/SKlauncher.jar"

    # cria um wrapper para iniciar o java com as bibliotecas necessárias
    makeWrapper ${pkgs.jdk21}/bin/java $out/bin/sklauncher \
      --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath (with pkgs; [
        gtk3
        glib
        pango
        atk
        cairo
        gdk-pixbuf
        libXxf86vm
        libX11
        libXtst
        libGL
        vulkan-loader
        alsa-lib
        libpulseaudio
        flite
        wayland
        libxkbcommon
        libdecor
      ])}" \
      --set JAVA_TOOL_OPTIONS "-DMC_DEBUG_ENABLED=true -DMC_DEBUG_PREFER_WAYLAND=true" \
      --add-flags "-Djava.library.path=${pkgs.openjfx21}/modules_libs/javafx.graphics:${pkgs.openjfx21}/modules_libs/javafx.media -jar $out/share/sklauncher/SKlauncher.jar"

    # cria a entrada do aplicativo para os menus gráficos do GNOME
    install -Dm755 /dev/null "$out/share/applications/sklauncher.desktop"

    # arquivo de integração com o ambiente gráfico
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

  # metadados do pacote
  meta = with pkgs.lib; {
    description = "Unofficial community Minecraft launcher";
    homepage = "https://skmedix.pl/";
    license = licenses.unfree;
    mainProgram = "sklauncher";
    platforms = platforms.linux;
  };
}
