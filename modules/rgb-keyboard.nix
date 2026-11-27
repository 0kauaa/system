
# módulo personalizado para controlar a iluminação rgb do teclado via tecla 'scroll lock' (SL)
{ config, pkgs, lib, ... }:

# ambiente python isolado
let
  pythonWithEvdev = pkgs.python3.withPackages (ps: [
    ps.evdev
  ]);

  # script responsável por monitorar o teclado
  scrolllockScript = ''
    import glob
    import time
    import evdev
    from evdev import ecodes

    LED_PATHS = "/sys/class/leds/*scrolllock*/brightness"

    KEYBOARD_NAME = "USB USB Keyboard"

    def set_leds(value):
        for path in glob.glob(LED_PATHS):
            try:
                with open(path, "w") as led:
                    led.write(str(value) + "\n")
            except OSError as error:
                print("Erro ao controlar LED:", error, flush=True)

    while True:
        keyboard = None

        try:
            for path in evdev.list_devices():
                device = evdev.InputDevice(path)

                capabilities = device.capabilities().get(
                    ecodes.EV_KEY, []
                )

                if (
                    device.name == KEYBOARD_NAME
                    and ecodes.KEY_SCROLLLOCK in capabilities
                    and ecodes.KEY_A in capabilities
                ):
                    keyboard = device
                    break

                device.close()

            if keyboard is None:
                print("Aguardando teclado USB...", flush=True)
                time.sleep(2)
                continue

            print(
                "Monitorando: " + keyboard.name + " em " + keyboard.path,
                flush=True,
            )

            state = 0
            set_leds(state)

            for event in keyboard.read_loop():

                if (
                    event.type == ecodes.EV_KEY
                    and event.code == ecodes.KEY_SCROLLLOCK
                    and event.value == 1
                ):
                    state = 1 - state
                    set_leds(state)

                    print(
                        "RGB: " + ("ligado" if state else "desligado"),
                        flush=True,
                    )

                elif event.type == ecodes.EV_LED:
                    time.sleep(0.05)
                    set_leds(state)

        except (OSError, IOError) as error:
            print("Teclado desconectado: " + str(error), flush=True)

        finally:
            if keyboard is not None:
                keyboard.close()

        time.sleep(2)
  '';

in
{
  # disponibiliza o script no sistema como /etc/rgb-keyboard.py
  environment.etc."rgb-keyboard.py".text = scrolllockScript;

  # define o serviço Systemd
  systemd.services.scrolllock-rgb = {
    description = "Controle RGB do teclado via Scroll Lock";

    # inicia automaticamente durante a inicialização do sistema
    wantedBy = [ "multi-user.target" ];

    # aguarda a inicialização dos dispositivos de entrada
    after = [ "systemd-udev-settle.service" ];

    serviceConfig = {
      # serviço executado continuamente em primeiro plano
      Type = "simple";

      # executa o script
      ExecStart =
        "${pythonWithEvdev}/bin/python3 /etc/scrolllock-rgb.py";

      # reinicia automaticamente em caso de encerramento
      Restart = "always";
      RestartSec = "2s";
    };
  };
}
