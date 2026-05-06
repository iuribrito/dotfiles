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
        }
    }

    onPanelOpenChanged: {
        if (panelOpen) {
            root.updateBrightness();
            root.updateVpnStatus();
            root.updateHypridleStatus();
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

    Process {
        id: vpnStatusProc
        command: ["sh", "-c", "nmcli -g GENERAL.STATE con show " + root.vpnUUID + " 2>/dev/null || echo 'deactivated'"]
        stdout: SplitParser {
            onRead: data => {
                const status = data.trim().toLowerCase();
                root.vpnStatus = status;
                // Atualiza a propriedade que o botão usa
                if (status === "activated") {
                    root.vpnActive = true;
                } else if (status === "deactivated" || status === "") {
                    root.vpnActive = false;
                }
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
        
        // Feedback visual imediato: se estamos desligando, já assume cinza
        if (isCurrentlyActive) root.vpnActive = false;
        
        root.vpnStatus = isCurrentlyActive ? "deactivating" : "activating";
        Quickshell.execDetached(["nmcli", "connection", cmd, root.vpnUUID]);
        
        // Polling para confirmar o estado real após a ação
        let attempts = 0;
        let timer = Qt.createQmlObject("import QtQuick; Timer { interval: 500; repeat: true }", root);
        timer.triggered.connect(() => {
            root.updateVpnStatus();
            attempts++;
            
            // Para o timer após o estado confirmar a mudança ou 15s
            if (attempts > 30 || (isCurrentlyActive && root.vpnStatus === "deactivated") || (!isCurrentlyActive && root.vpnStatus === "activated")) {
                timer.stop();
                timer.destroy();
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

    // --- Outros ---
    property bool wifiEnabled: true
    property bool bluetoothEnabled: true
    property bool panelOpen: false

    Component.onCompleted: {
        console.log("[DEBUG] Serviço QuickSettings pronto.");
        root.updateBrightness();
        root.updateHypridleStatus();
    }
}
