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
        onTriggered: root.updateBrightness()
    }

    onPanelOpenChanged: if (panelOpen) root.updateBrightness()

    function setBrightness(val) {
        root.brightness = val; 
        let percent = Math.round(val * 100);
        if (percent < 1) percent = 1;
        Quickshell.execDetached(["brightnessctl", "s", percent + "%", "--quiet"]);
    }

    // --- Outros ---
    property bool wifiEnabled: true
    property bool bluetoothEnabled: true
    property bool panelOpen: false

    Component.onCompleted: {
        console.log("[DEBUG] Serviço QuickSettings pronto.");
        root.updateBrightness();
    }
}
