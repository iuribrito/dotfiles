pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Scope {
    id: root

    // --- Audio ---
    readonly property var sink: Pipewire.defaultAudioSink
    
    // O Tracker mantém a conexão viva e bound
    PwObjectTracker {
        objects: [root.sink]
    }

    // Sincronização automática: 
    // Sempre que o volume do sistema mudar, atualiza nossa propriedade local
    property real volume: sink?.audio?.volume ?? 0
    property bool muted: sink?.audio?.muted ?? false

    // Conexões para capturar mudanças externas em tempo real
    Connections {
        target: root.sink?.audio ?? null
        function onVolumeChanged() { 
            if (root.sink.audio) root.volume = root.sink.audio.volume;
        }
        function onMutedChanged() { 
            if (root.sink.audio) root.muted = root.sink.audio.muted;
        }
    }
    
    function setVolume(val) {
        if (sink && sink.audio) {
            sink.audio.volume = val;
            // Não precisamos setar root.volume aqui, 
            // pois o Connection acima já vai detectar e atualizar!
        }
    }

    function toggleMute() {
        if (sink && sink.audio) {
            sink.audio.muted = !sink.audio.muted;
        }
    }

    // --- Microfone ---
    readonly property var source: Pipewire.defaultAudioSource

    PwObjectTracker {
        objects: [root.source]
    }

    property real micVolume: source?.audio?.volume ?? 0
    property bool micMuted: source?.audio?.muted ?? false

    Connections {
        target: root.source?.audio ?? null
        function onVolumeChanged() {
            if (root.source?.audio) root.micVolume = root.source.audio.volume;
        }
        function onMutedChanged() {
            if (root.source?.audio) root.micMuted = root.source.audio.muted;
        }
    }

    function setMicVolume(val) {
        if (source && source.audio) {
            source.audio.volume = val;
        }
    }

    function toggleMicMute() {
        if (source && source.audio) {
            source.audio.muted = !source.audio.muted;
        }
    }

    // --- Brilho (Mantendo o que funcionou) ---
    property real brightness: 0.0
    
    Process {
        id: brightnessUpdateProc
        command: ["sh", "-c", "echo $(brightnessctl g) $(brightnessctl m)"]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(" ");
                if (parts.length >= 2) {
                    const current = parseInt(parts[0]);
                    const max = parseInt(parts[1]);
                    if (max > 0) {
                        root.brightness = current / max;
                    }
                }
            }
        }
    }

    function updateBrightness() {
        if (!brightnessUpdateProc.running) {
            brightnessUpdateProc.running = true;
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            root.updateBrightness();
            root.updateVpnStatus();
            root.updateHypridleStatus();
            root.updateWifiStatus();
            root.updateBluetoothStatus();
        }
    }

    onPanelOpenChanged: {
        if (panelOpen) {
            root.updateBrightness();
            root.updateVpnStatus();
            root.updateHypridleStatus();
            root.updateWifiStatus();
            root.updateBluetoothStatus();
        }
    }

    function setBrightness(val) {
        root.brightness = val; 
        let percent = Math.round(val * 100);
        if (percent < 1) percent = 1;
        Quickshell.execDetached(["brightnessctl", "s", percent + "%", "--quiet"]);
    }

    // --- VPN (PPP/LTI) ---
    property bool vpnActive: false
    property string vpnStatus: "unknown"
    readonly property string vpnUUID: "da890faa-1b3a-448a-bb74-157329793fb3"
    property bool vpnUserAction: false

    onVpnActiveChanged: {
        if (!vpnActive && !vpnUserAction) {
            Quickshell.execDetached(["notify-send", "-u", "critical", "-a", "Quickshell",
                "-i", "network-vpn-disconnected-symbolic",
                "VPN Desconectada", "A conexão VPN caiu inesperadamente."]);
        }
    }

    Process {
        id: vpnStatusProc
        command: ["sh", "-c", "nmcli -g UUID con show --active 2>/dev/null | grep -qF " + root.vpnUUID + " && echo activated || echo deactivated"]
        stdout: SplitParser {
            onRead: data => {
                const status = data.trim().toLowerCase();
                root.vpnStatus = status;
                root.vpnActive = status === "activated";
            }
        }
    }

    function updateVpnStatus() {
        vpnStatusProc.running = false;
        vpnStatusProc.running = true;
    }

    function toggleVpn() {
        const isCurrentlyActive = root.vpnActive;
        const cmd = isCurrentlyActive ? "down" : "up";

        root.vpnUserAction = true;
        if (isCurrentlyActive) root.vpnActive = false;

        root.vpnStatus = isCurrentlyActive ? "deactivating" : "activating";
        Quickshell.execDetached(["nmcli", "connection", cmd, root.vpnUUID]);

        let attempts = 0;
        let notified = false;
        let timer = Qt.createQmlObject("import QtQuick; Timer { interval: 500; repeat: true }", root);
        timer.triggered.connect(() => {
            root.updateVpnStatus();
            attempts++;

            const connected = !isCurrentlyActive && root.vpnStatus === "activated";
            const disconnected = isCurrentlyActive && root.vpnStatus === "deactivated";
            const timedOut = attempts > 30;

            if (!notified && (connected || disconnected || timedOut)) {
                notified = true;
                timer.stop();
                timer.destroy();
                root.vpnUserAction = false;

                if (timedOut && !connected && !disconnected) {
                    Quickshell.execDetached(["notify-send", "-u", "critical", "-a", "Quickshell", "-i", "network-vpn-symbolic", "VPN", "Tempo esgotado. Verifique a conexão."]);
                } else if (connected) {
                    Quickshell.execDetached(["notify-send", "-u", "normal", "-a", "Quickshell", "-i", "network-vpn-symbolic", "VPN Conectada", "Conexão VPN estabelecida com sucesso."]);
                } else {
                    Quickshell.execDetached(["notify-send", "-u", "normal", "-a", "Quickshell", "-i", "network-vpn-disconnected-symbolic", "VPN Desconectada", "Conexão VPN encerrada."]);
                }
            }
        });
        timer.start();
    }

    // --- Hypridle ---
    property bool hypridleActive: false

    Process {
        id: hypridleCheckProc
        command: ["sh", "-c", "pgrep -x hypridle > /dev/null && echo running || echo stopped"]
        stdout: SplitParser {
            onRead: data => {
                root.hypridleActive = data.trim() === "running";
            }
        }
    }

    function updateHypridleStatus() {
        hypridleCheckProc.running = false;
        hypridleCheckProc.running = true;
    }

    function toggleHypridle() {
        if (root.hypridleActive) {
            root.hypridleActive = false;
            Quickshell.execDetached(["pkill", "-x", "hypridle"]);
        } else {
            root.hypridleActive = true;
            Quickshell.execDetached(["hypridle"]);
        }
    }

    // --- WiFi ---
    property bool wifiEnabled: false
    property bool panelOpen: false

    Process {
        id: wifiStatusProc
        command: ["sh", "-c", "nmcli radio wifi"]
        stdout: SplitParser {
            onRead: data => {
                root.wifiEnabled = data.trim() === "enabled";
            }
        }
    }

    function updateWifiStatus() {
        wifiStatusProc.running = false;
        wifiStatusProc.running = true;
    }

    function toggleWifi() {
        const next = !root.wifiEnabled;
        root.wifiEnabled = next;
        Quickshell.execDetached(["nmcli", "radio", "wifi", next ? "on" : "off"]);
    }

    // --- Bluetooth ---
    property bool bluetoothEnabled: false

    Process {
        id: bluetoothStatusProc
        command: ["sh", "-c", "bluetoothctl show | grep -c 'Powered: yes'"]
        stdout: SplitParser {
            onRead: data => {
                root.bluetoothEnabled = parseInt(data.trim()) > 0;
            }
        }
    }

    function updateBluetoothStatus() {
        bluetoothStatusProc.running = false;
        bluetoothStatusProc.running = true;
    }

    function toggleBluetooth() {
        const next = !root.bluetoothEnabled;
        root.bluetoothEnabled = next;
        Quickshell.execDetached(["bluetoothctl", "power", next ? "on" : "off"]);
    }

    Component.onCompleted: {
        root.updateBrightness();
        root.updateHypridleStatus();
        root.updateWifiStatus();
        root.updateBluetoothStatus();
    }
}
