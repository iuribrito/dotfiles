import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "../theme"

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

    // Variáveis reativas para monitoramento
    property real batteryPct: root.activeBattery ? root.activeBattery.percentage * 100 : 0
    property bool isCharging: root.activeBattery ? root.activeBattery.state === UPowerDevice.Charging : false

    // Controle para evitar notificação na hora que liga o PC
    property bool _isStartup: true
    Timer {
        interval: 2000
        running: true
        onTriggered: root._isStartup = false
    }

    onIsChargingChanged: {
        if (!root.activeBattery || _isStartup) return;

        if (isCharging) {
            Quickshell.execDetached(["notify-send", "-u", "normal", "-a", "Quickshell", "-i", "battery-level-0-charging-symbolic", "Carregador Conectado", "A bateria está sendo carregada."]);
        } else {
            Quickshell.execDetached(["notify-send", "-u", "normal", "-a", "Quickshell", "-i", "battery-missing-symbolic", "Carregador Desconectado", "O sistema está usando a bateria."]);
        }
    }

    // Controle de notificações para evitar spam
    property bool notified50: false
    property bool notified10: false
    property bool notified5: false

    onBatteryPctChanged: {
        if (!root.activeBattery) return;

        // Se conectou o carregador, reseta os alertas para notificar novamente no futuro
        if (isCharging) {
            notified50 = false;
            notified10 = false;
            notified5 = false;
            return;
        }

        let pct = Math.floor(batteryPct);

        // Dispara as notificações dependendo do nível e se já foi notificado
        if (pct <= 50 && pct > 10 && !notified50) {
            Quickshell.execDetached(["notify-send", "-u", "normal", "-a", "Quickshell", "-i", "battery-level-50", "Bateria a 50%", "Ainda tem carga, mas fique de olho."]);
            notified50 = true;
        } else if (pct <= 10 && pct > 5 && !notified10) {
            Quickshell.execDetached(["notify-send", "-u", "critical", "-a", "Quickshell", "-i", "battery-low", "Bateria Fraca!", "A bateria chegou a 10%. Conecte o carregador."]);
            notified10 = true;
            // Garante que o de 50% seja marcado como notificado também (caso o shell abra já com 10%)
            notified50 = true; 
        } else if (pct <= 5 && !notified5) {
            Quickshell.execDetached(["notify-send", "-u", "critical", "-a", "Quickshell", "-i", "battery-caution", "BATERIA CRÍTICA!", "5% restantes. O sistema vai desligar em breve."]);
            notified5 = true;
            notified10 = true;
            notified50 = true;
        }
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
                const pct = Math.floor(root.batteryPct);

                if (state === UPowerDevice.Charging) return "󰂄"; // Raio
                if (state === UPowerDevice.FullyCharged) return "󱊦"; // Cheia
                
                // Ícones baseados na carga
                if (pct > 90) return "󱊣"; // Cheia
                if (pct > 60) return "󱊢";
                if (pct > 10) return "󱊡";
                return "󰂎"; // Vazia
            }
            color: {
                if (!root.activeBattery) return Theme.red;
                const state = root.activeBattery.state;
                const pct = Math.floor(root.batteryPct);
                
                if (state === UPowerDevice.Charging) return Theme.green; // Verde Carregando
                if (pct < 10) return Theme.redTokyo; // Vermelho Crítico
                return Theme.blueTokyo; // Azul Normal
            }
            font.pixelSize: 16
            font.family: "JetBrainsMono Nerd Font"
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            // Math.floor para não mostrar decimais loucos
            text: Math.floor(root.batteryPct) + "%"
            color: Theme.white
            font.pixelSize: 12
            font.bold: true
            font.family: "JetBrainsMono Nerd Font"
        }
    }
}
