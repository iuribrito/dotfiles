//@ pragma UseQApplication
import Quickshell
import QtQuick
import Quickshell.Io // IMPORTANTE: Adicione isso para o Process funcionar!
import Quickshell.Services.Notifications // 1. ADICIONE ESTE IMPORT AQUI NO TOPO

import "modules/bar" as Bar
import "modules/notifications" as Notify // Importa a pasta nova
import "modules/powermenu" as Power // Importando a nova pasta

ShellRoot {
    id: root
    
    property bool isPowerMenuOpen: false

    // A MÁGICA: Sincroniza o Hyprland com o Menu visual
    onIsPowerMenuOpenChanged: {
        hyprSync.command = isPowerMenuOpen ? ["hyprctl", "dispatch", "submap", "powermenu"] : ["hyprctl", "dispatch", "submap", "reset"];
        hyprSync.running = true;
    }

    // Processo invisível só para rodar o comando acima
    Process {
        id: hyprSync
    }

    Process {
        running: true
        // 1. Apaga o tubo antigo (se existir)
        // 2. Cria um tubo novo (mkfifo)
        // 3. Fica lendo o que entra no tubo para sempre (while true; cat)
        command: ["sh", "-c", "rm -f /tmp/qs_powermenu; mkfifo /tmp/qs_powermenu; while true; do cat /tmp/qs_powermenu; done"]

        stdout: SplitParser {
            onRead: data => {
                let msg = data.trim();

                // Se a mensagem for "toggle_power", ele inverte a tela (abre/fecha)
                if (msg === "toggle_power") {
                    root.isPowerMenuOpen = !root.isPowerMenuOpen;
                }

            // Dica: No futuro você pode colocar outros atalhos aqui!
            // if (msg === "toggle_calendario") root.isCalendarOpen = !...
            }
        }
    }

    Variants {
        model: Quickshell.screens

        Bar.Painel {
            onTogglePowerMenu: root.isPowerMenuOpen = !root.isPowerMenuOpen
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: Power.PowerMenu {
            modelData: modelData

            // Fica olhando para a variável global
            isVisible: root.isPowerMenuOpen

            // Quando o menu quiser se fechar, avisa a variável global
            onClose: root.isPowerMenuOpen = false
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: Notify.Notification {
            modelData: modelData
        }
    }
}
