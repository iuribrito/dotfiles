# Dotfiles

Configurações de ambiente Linux 100% focadas em **Hyprland** (Wayland), com tema **Catppuccin Mocha**, shell **Fish**, terminal **Foot** / **WezTerm**, multiplexador **Tmux** e bar customizada em **Quickshell**.

---

## 📋 Requisitos & Pacotes de Software (Arch Linux)

Para rodar o ambiente Hyprland corretamente no Arch Linux, instale os pacotes necessários categorizados abaixo.

### 1. Compositor & Portais Wayland
- `hyprland` - Compositor Wayland principal
- `xdg-desktop-portal-hyprland`, `xdg-desktop-portal-gtk` - Portais de integração para Wayland/GTK

### 2. Utilitários Hyprland
- `hyprpaper` - Gerenciador de papéis de parede
- `hyprlock` - Tela de bloqueio (`Super + O`)
- `hypridle` - Daemon de inatividade

### 3. Interface, Barra, Notificações & Menus
- `quickshell-git` *(AUR)* - Topbar, menu de energia e quicksettings em QML/Qt6
- `ags` *(AUR)* - Aylur's GTK Shell (integração secundária)
- `dunst` - Daemon de notificações
- `fuzzel` - Application launcher Wayland

### 4. Terminal, Shell & Ferramentas CLI
- `foot` - Terminal Wayland principal (`Super + T`)
- `wezterm` - Terminal secundário
- `fish` - Shell interativo
- `starship` - Prompt customizado
- `tmux` - Multiplexador de terminal
- `jq` - Processador de JSON para scripts

### 5. Áudio, Rede, Brilho & Bateria
- `pipewire`, `wireplumber`, `pipewire-pulse` - Servidor de áudio
- `networkmanager` - Gerenciamento de rede (`nmcli`)
- `brightnessctl` - Controle de brilho da tela
- `upower` - Gerenciamento de energia/bateria

### 6. Captura de Tela & Área de Transferência
- `grim` - Captura de tela no Wayland
- `slurp` - Seleção de região na tela
- `satty` *(AUR)* - Anotador/editor de screenshots (`Super + P`)
- `wl-clipboard` - Manipulação do clipboard (`wl-copy`, `wl-paste`)
- `cliphist` - Gerenciador de histórico do clipboard
- `clipcat` *(AUR)* - Daemon e CLI alternativo de clipboard

### 7. Aplicativos de Uso Diário & Fontes
- `nautilus` - Gerenciador de arquivos (`Super + E`)
- `cinny-desktop-bin` *(AUR)* - Cliente Matrix (scratchpad `Super + C`)
- `ttf-jetbrains-mono-nerd` - Fonte JetBrains Mono com Nerd Icons

### 8. Runtimes & Dev
- `bun-bin` *(AUR)* - Runtime JS/TS
- `pnpm` - Gerenciador de pacotes JS
- `git` - Controle de versão

---

## 🚀 Instalação Rápida

O **`yay`** é um *AUR helper* que envelopa o `pacman`. Ele instala tanto os pacotes dos repositórios oficiais do Arch Linux quanto os pacotes do AUR em um único comando.

### 1. Instalar o `yay` (caso ainda não tenha instalado)
```bash
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd .. && rm -rf yay
```

### 2. Instalar todos os pacotes (Oficiais + AUR)
```bash
yay -S --needed \
  hyprland hyprpaper hyprlock hypridle \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  foot wezterm fish starship tmux jq \
  dunst fuzzel \
  grim slurp wl-clipboard cliphist clipcat \
  pipewire wireplumber pipewire-pulse networkmanager brightnessctl upower \
  nautilus ttf-jetbrains-mono-nerd git pnpm \
  quickshell-git ags satty bun-bin
```

---

## 🛠️ Pós-Instalação & Configuração

1. **Tmux Plugin Manager (TPM)**
   Instale o TPM para gerenciar os plugins e o tema Catppuccin Mocha no Tmux:
   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```
   Abra o `tmux` e pressione `Ctrl + Space` seguido de `I` para instalar os plugins.

2. **Ativar Serviços do Sistema**
   ```bash
   sudo systemctl enable --now NetworkManager
   ```

3. **Shell padrão (Fish)**
   Para definir o Fish como seu shell padrão:
   ```bash
   chsh -s $(which fish)
   ```
