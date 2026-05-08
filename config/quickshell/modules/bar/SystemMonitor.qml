import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"

Item {
    id: sysMonitor
    implicitWidth: layout.width
    implicitHeight: 24

    // Propriedades de Texto
    property string cpuUsage: "0%"
    property string ramUsage: "0%"
    property string swapUsage: "0%"

    // Histórico para a CPU (mantemos os gráficos em pé aqui)
    property var cpuHistory: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    // Valores numéricos para as Barras de Progresso da RAM e Swap
    property int ramValue: 0
    property int swapValue: 0

    Process {
        id: proc
        running: true

        // O script agora extrai CPU, RAM e SWAP de uma vez
        command: ["sh", "-c", "while true; do " + "cpu=$(vmstat 1 2 | tail -1 | awk '{print 100 - $15}'); " + "mem_swap=$(free | awk '/Mem:/ {ram=int($3/$2 * 100)} /Swap:/ {if($2>0) swap=int($3/$2 * 100); else swap=0} END {print ram \" \" swap}'); " + "echo \"$cpu $mem_swap\"; " + "sleep 2; " + "done"]

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(" ");
                // Agora esperamos 3 partes: [CPU, RAM, SWAP]
                if (parts.length >= 3) {
                    let cpuVal = parseInt(parts[0]);
                    let rVal = parseInt(parts[1]);
                    let sVal = parseInt(parts[2]);

                    // Atualiza a CPU (Texto e Gráfico)
                    sysMonitor.cpuUsage = cpuVal + "%";
                    let newCpuHist = sysMonitor.cpuHistory.slice(1);
                    newCpuHist.push(cpuVal);
                    sysMonitor.cpuHistory = newCpuHist;

                    // Atualiza a RAM (Texto e Barra)
                    sysMonitor.ramUsage = rVal + "%";
                    sysMonitor.ramValue = rVal;

                    // Atualiza o SWAP (Texto e Barra)
                    sysMonitor.swapUsage = sVal + "%";
                    sysMonitor.swapValue = sVal;
                }
            }
        }
    }

    Row {
        id: layout
        spacing: 15
        anchors.verticalCenter: parent.verticalCenter

        // --- 1. BLOCO DA CPU (Mini Gráfico) ---
        Row {
            spacing: 0
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                width: 25
                height: 24
                topLeftRadius: 5
                bottomLeftRadius: 5
                topRightRadius: 0
                bottomRightRadius: 0
                color: Theme.bgSurface
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: ""
                    width: 20
                    color: Theme.blueTokyo
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            // O Fundo Cinza APENAS para o gráfico
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.bgMain // Fundo cinza escuro/azulado
                radius: 5 // Arredondamento suave da caixinha

                // O tamanho da caixinha abraça o gráfico dando uma pequena margem (4px de cada lado)
                width: graficoCpu.implicitWidth + 8
                height: graficoCpu.implicitHeight + 8

                Row {
                    id: graficoCpu
                    anchors.centerIn: parent // Centraliza as barras dentro da caixinha cinza
                    spacing: 1 // 1 pixel de espaço entre as barras fica mais bonito!

                    Repeater {
                        model: sysMonitor.cpuHistory
                        delegate: Item {
                            width: 3
                            height: 16 // Altura máxima de cada barrinha

                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: Math.max(2, (modelData / 100.0) * parent.height)
                                color: Theme.blueTokyo
                                radius: 2

                                Behavior on height {
                                    NumberAnimation {
                                        duration: 300
                                        easing.type: Easing.OutQuint
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Rectangle {
                width: 35
                height: 24
                topLeftRadius: 0
                bottomLeftRadius: 0
                topRightRadius: 5
                bottomRightRadius: 5
                color: Theme.bgSurface
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: sysMonitor.cpuUsage
                    color: Theme.blueTokyo
                    width: 35
                    font.pixelSize: 13
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // --- 2. BLOCO DA RAM (Barra de Progresso) ---
        Row {
            spacing: 0
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                width: 25
                height: 24
                topLeftRadius: 5
                bottomLeftRadius: 5
                topRightRadius: 0
                bottomRightRadius: 0
                color: Theme.bgSurface
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: ""
                    width: 20
                    color: Theme.green
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            // Container da Barra de Progresso
            Rectangle {
                width: 50 // Largura total da barra de progresso aumentada
                height: 24 // Fica mais fina e elegante
                radius: 5
                color: Theme.bgMain // Cor de fundo (vazio)
                anchors.verticalCenter: parent.verticalCenter

                // A barra que enche (verde)
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 5
                    // A mágica: a largura é uma porcentagem da largura do container (parent)
                    width: (parent.width - 10) * (sysMonitor.ramValue / 100.0)
                    radius: 2
                    color: Theme.green

                    // Suaviza quando a memória enche ou esvazia
                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutQuint
                        }
                    }
                }
            }

            Rectangle {
                width: 35
                height: 24
                topLeftRadius: 0
                bottomLeftRadius: 0
                topRightRadius: 5
                bottomRightRadius: 5
                color: Theme.bgSurface
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: sysMonitor.ramUsage
                    color: Theme.green
                    width: 35
                    font.pixelSize: 13
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
        Row {
            Rectangle {
                width: 25
                height: 24
                topLeftRadius: 5
                bottomLeftRadius: 5
                topRightRadius: 0
                bottomRightRadius: 0
                color: Theme.bgSurface
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: ""
                    width: 20
                    color: Theme.orangeTokyo
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            Rectangle {
                width: 50
                height: 24
                radius: 5
                color: Theme.bgMain
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 5
                    width: (parent.width - 10) * (sysMonitor.swapValue / 100.0)
                    radius: 2
                    color: Theme.orangeTokyo // Laranja para o Swap
                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutQuint
                        }
                    }
                }

            }

            Rectangle {
                width: 35
                height: 24
                topLeftRadius: 0
                bottomLeftRadius: 0
                topRightRadius: 5
                bottomRightRadius: 5
                color: Theme.bgSurface
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: sysMonitor.swapUsage
                    width: 35
                    color: Theme.orangeTokyo
                    font.pixelSize: 13
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
