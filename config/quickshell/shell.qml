//@ pragma UseQApplication
import Quickshell
import QtQuick
import Quickshell.Io // IMPORTANTE: Adicione isso para o Process funcionar!
import Quickshell.Services.Notifications // 1. ADICIONE ESTE IMPORT AQUI NO TOPO

import "modules/bar" as Bar
import "modules/notifications" as Notify
import "modules/powermenu" as Power
import "modules/quicksettings" as QS
import "modules/overview" as Overview
import "modules/launcher" as Launcher

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
        command: ["sh", "-c", "rm -f /tmp/qs_powermenu; mkfifo /tmp/qs_powermenu; while true; do cat /tmp/qs_powermenu; done"]
        stdout: SplitParser {
            onRead: data => {
                if (data.trim() === "toggle_power")
                    root.isPowerMenuOpen = !root.isPowerMenuOpen
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
        delegate: QS.QuickSettingsPanel {
            modelData: modelData
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

    Variants {
        model: Quickshell.screens
        delegate: Overview.OverviewPanel {
            modelData: modelData
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: Launcher.LauncherPanel {
            modelData: modelData
        }
    }

    Component.onCompleted: {
        console.log("[DEBUG] Hyprland Signature:", Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE"));
        if (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") === "") {
            console.warn("[AVISO] Variável HYPRLAND_INSTANCE_SIGNATURE não encontrada. O IPC do Hyprland não funcionará!");
        }
    }
}
