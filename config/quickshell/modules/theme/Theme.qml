pragma Singleton
import QtQuick

QtObject {
    id: theme

    // Fundos (Backgrounds) - Catppuccin Mocha
    property color bgMain: "#1e1e2e"    // Base
    property color bgMainAlpha: "#CC1e1e2e" // Base com 80% opacidade para painéis translúcidos
    property color bgSurface: "#313244" // Surface0
    property color bgHover: "#45475a"   // Surface1
    property color bgDark: "#181825"    // Mantle
    property color bgEmpty: "#11111b"   // Crust
    property color bgLight: "#f5e0dc"   // Rosewater

    // Textos (Texts) - Catppuccin Mocha
    property color textMain: "#cdd6f4"  // Text
    property color textMuted: "#6c7086" // Overlay0
    property color textSub: "#a6adc8"   // Subtext0
    property color white: "#ffffff"

    // Cores de Destaque (Accents) - Catppuccin Mocha
    property color primary: "#cba6f7"   // Mauve
    
    property color blue: "#89b4fa"      // Blue
    property color blueTokyo: "#74c7ec" // Sapphire (substituindo o antigo azul Tokyonight)
    property color blueMuted: "#b4befe" // Lavender (substituindo o azul mutado)
    
    property color red: "#f38ba8"       // Red
    property color redTokyo: "#eba0ac"  // Maroon (substituindo o vermelho Tokyonight)
    
    property color greenLight: "#6ed166"     // Green
    property color green: "#a6e3a1"     // Green
    
    property color yellow: "#f9e2af"    // Yellow
    property color orange: "#fab387"    // Peach
    property color orangeTokyo: "#f2cdcd"// Flamingo (substituindo o laranja Tokyonight)
    property color orangeAlt: "#f5c2e7"  // Pink (substituindo o laranja alternativo)
}
