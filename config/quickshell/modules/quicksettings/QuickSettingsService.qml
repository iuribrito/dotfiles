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
            root.updateHyprsunsetStatus();
            root.updateWifiStatus();
            root.updateBluetoothStatus();
        }
    }

    onPanelOpenChanged: {
        if (panelOpen) {
            root.updateBrightness();
            root.updateVpnStatus();
            root.updateHypridleStatus();
            root.updateHyprsunsetStatus();
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

    // --- Hyprsunset ---
    property bool hyprsunsetActive: false

    Process {
        id: hyprsunsetCheckProc
        command: ["sh", "-c", "pgrep -x hyprsunset > /dev/null && echo running || echo stopped"]
        stdout: SplitParser {
            onRead: data => {
                root.hyprsunsetActive = data.trim() === "running";
            }
        }
    }

    function updateHyprsunsetStatus() {
        hyprsunsetCheckProc.running = false;
        hyprsunsetCheckProc.running = true;
    }

    function toggleHyprsunset() {
        if (root.hyprsunsetActive) {
            root.hyprsunsetActive = false;
            Quickshell.execDetached(["pkill", "hyprsunset"]);
        } else {
            root.hyprsunsetActive = true;
            Quickshell.execDetached(["hyprsunset", "-t", "3500"]);
        }
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
    property var activeScreen: null

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

    // --- WiFi Networks List ---
    property bool wifiExpanded: false
    property var wifiNetworks: []
    property var wifiScanBuffer: []

    Process {
        id: wifiListProc
        command: ["sh", "-c", "nmcli -t -f SSID,SIGNAL,ACTIVE device wifi list 2>/dev/null | head -20"]
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim();
                if (!line) return;
                const lastColon = line.lastIndexOf(":");
                if (lastColon === -1) return;
                const active = line.substring(lastColon + 1).trim();
                const secondLastColon = line.lastIndexOf(":", lastColon - 1);
                if (secondLastColon === -1) return;
                const signal = parseInt(line.substring(secondLastColon + 1, lastColon));
                const ssid = line.substring(0, secondLastColon);
                if (!ssid || isNaN(signal)) return;
                const temp = root.wifiScanBuffer.slice();
                if (!temp.find(n => n.ssid === ssid)) {
                    temp.push({ ssid: ssid, signal: signal, connected: active === "yes" });
                }
                root.wifiScanBuffer = temp;
            }
        }
        onRunningChanged: {
            if (!running) {
                root.wifiNetworks = root.wifiScanBuffer.slice().sort((a, b) => b.signal - a.signal);
            }
        }
    }

    Timer { id: wifiRescanTimer; interval: 3000; repeat: false; onTriggered: root.scanWifi() }

    function scanWifi() {
        root.wifiScanBuffer = [];
        wifiListProc.running = false;
        wifiListProc.running = true;
    }

    function connectWifi(ssid) {
        Quickshell.execDetached(["nmcli", "device", "wifi", "connect", ssid]);
        wifiRescanTimer.restart();
    }

    // --- Bluetooth Devices List ---
    property bool bluetoothExpanded: false
    property var bluetoothDevices: []
    property var btScanBuffer: []

    Process {
        id: btListProc
        command: ["sh", "-c", "bluetoothctl devices 2>/dev/null | while IFS= read -r line; do mac=$(echo \"$line\" | awk '{print $2}'); info=$(bluetoothctl info \"$mac\" 2>/dev/null); name=$(echo \"$info\" | grep -m1 'Name:' | sed 's/.*Name: //'); connected=$(echo \"$info\" | grep -c 'Connected: yes'); printf \"%s\\t%s\\t%s\\n\" \"$mac\" \"$name\" \"$connected\"; done"]
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim();
                if (!line) return;
                const parts = line.split("\t");
                if (parts.length >= 2 && parts[0].length >= 10) {
                    const temp = root.btScanBuffer.slice();
                    temp.push({ mac: parts[0].trim(), name: (parts[1] || parts[0]).trim(), connected: parseInt(parts[2] || "0") > 0 });
                    root.btScanBuffer = temp;
                }
            }
        }
        onRunningChanged: {
            if (!running) {
                root.bluetoothDevices = root.btScanBuffer.slice();
            }
        }
    }

    Timer { id: btRescanTimer; interval: 3000; repeat: false; onTriggered: root.scanBluetooth() }

    function scanBluetooth() {
        root.btScanBuffer = [];
        btListProc.running = false;
        btListProc.running = true;
    }

    function connectBluetooth(mac, isConnected) {
        if (isConnected) {
            Quickshell.execDetached(["bluetoothctl", "disconnect", mac]);
        } else {
            Quickshell.execDetached(["bluetoothctl", "connect", mac]);
        }
        btRescanTimer.restart();
    }

    Component.onCompleted: {
        root.updateBrightness();
        root.updateHypridleStatus();
        root.updateHyprsunsetStatus();
        root.updateWifiStatus();
        root.updateBluetoothStatus();
    }
}
