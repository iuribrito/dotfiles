import QtQuick
import Quickshell
import Quickshell.Services.UPower

Item {
    id: root
    implicitWidth: batteryRow.width
    implicitHeight: 24

    // LÓGICA DE BUSCA: Encontra a bateria real na lista de dispositivos
    property var activeBattery: {
        if (!UPower.devices.values) return null;

        const devs = UPower.devices.values;
        for (let i = 0; i < devs.length; i++) {
            // O Tipo 2 é 'Battery'. O Tipo 3 é 'Ups', 4 é 'Monitor', 5 é 'Mouse'...
            // Também verificamos se o nativePath tem 'BAT' para garantir que é a do note
            if (devs[i].type === UPowerDevice.Battery && devs[i].nativePath.includes("BAT")) {
                return devs[i];
            }
        }
        // Se não achar nada, retorna nulo
        return null;
    }

    Row {
        id: batteryRow
        spacing: 4
        anchors.verticalCenter: parent.verticalCenter
        
        // Só mostra se achou a bateria
        visible: root.activeBattery !== null

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (!root.activeBattery) return "󱟨"; 
                
                const state = root.activeBattery.state;
                const pct = root.activeBattery.percentage * 100;

                if (state === UPowerDevice.Charging) return "󰂄"; // Raio
                if (state === UPowerDevice.FullyCharged) return "󱊦"; // Cheia
                
                // Ícones baseados na carga
                if (pct > 90) return "󱊣"; // Cheia
                if (pct > 60) return "󱊢";
                if (pct > 10) return "󱊡";
                return "󰂎"; // Vazia
            }
            color: {
                if (!root.activeBattery) return "red";
                const state = root.activeBattery.state;
                const pct = root.activeBattery.percentage * 100;
                
                if (state === UPowerDevice.Charging) return "#9ece6a"; // Verde Carregando
                if (pct < 10) return "#f7768e"; // Vermelho Crítico
                return "#7aa2f7"; // Azul Normal
            }
            font.pixelSize: 16
            font.family: "JetBrainsMono Nerd Font"
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            // Math.floor para não mostrar decimais loucos
            text: root.activeBattery ? Math.floor(root.activeBattery.percentage * 100) + "%" : "N/A"
            color: "white"
            font.pixelSize: 12
            font.bold: true
            font.family: "JetBrainsMono Nerd Font"
        }
    }
}
