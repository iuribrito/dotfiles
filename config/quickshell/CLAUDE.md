# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A **Quickshell** desktop shell configuration written in **QML/Qt6**. It provides a top panel, notification center, power menu, and quick settings panel for the **Hyprland** window manager with Catppuccin Mocha theming.

## Running

```bash
# Launch the shell (replaces any running instance)
quickshell -c /home/brito/dotfiles/config/quickshell/shell.qml

# Reload config (Quickshell hot-reloads on file change when running)
# Just save any .qml file while quickshell is running

# Trigger power menu via IPC
echo "toggle_power" > /tmp/qs_powermenu
```

There is no build step — Quickshell interprets QML directly.

## Architecture

### Entry Point

`shell.qml` is the `ShellRoot`. It creates per-screen `Variants` of all panels and owns the single global boolean `isPowerMenuOpen`, which is exposed via a named FIFO at `/tmp/qs_powermenu`.

### Singleton Services (global state)

| File | Namespace | Responsibility |
|------|-----------|----------------|
| `modules/theme/Theme.qml` | `Theme` | Catppuccin Mocha color palette |
| `modules/notifications/NotificationService.qml` | `NotificationService` | DBus notification server, 5s auto-dismiss |
| `modules/quicksettings/QuickSettingsService.qml` | `QuickSettingsService` | Audio (Pipewire), brightness (`brightnessctl`), VPN (NetworkManager), WiFi/BT toggles |

Singletons are registered in their module's `qmldir` file and available anywhere via their namespace.

### Per-Screen Variants

```qml
Variants {
    model: Quickshell.screens
    // One instance of each panel per monitor
}
```

Every panel (bar, notification window, power menu, quick settings) is instantiated once per connected screen.

### Module Layout

- `modules/bar/` — Top panel (`Painel.qml` is the container). Sub-components: Workspaces, Clock (with calendar popup), SystemMonitor, Tray, Battery, PowerButton.
- `modules/notifications/` — Overlay notification window anchored top-right.
- `modules/powermenu/` — Slide-in side panel with system actions (logout/poweroff/suspend/reboot).
- `modules/quicksettings/` — Slide-down panel with volume, brightness, WiFi, BT, VPN controls.
- `modules/theme/` — Single `Theme.qml` singleton with all color constants.

### Key Patterns

**Process integration** — System commands run via Quickshell's `Process` type with stdout parsing. Examples: `vmstat` / `free` for system monitor, `brightnessctl` for display brightness, `nmcli` for VPN.

**State machine animations** — Panels (QuickSettingsPanel, PowerMenu) use `states: [State { name: "open" }, State { name: "closed" }]` with `Transitions` for smooth open/close.

**IPC via named pipe** — `shell.qml` reads `/tmp/qs_powermenu` continuously; external tools (Hyprland keybinds) write to it to toggle the power menu.

**Fillet corners** — `QuickSettingsPanel.qml` draws inverted rounded corners using `Canvas` components to create the visual cutout effect where the panel meets the bar.

### External Dependencies

- `Quickshell.Hyprland` — workspace/monitor state
- `Quickshell.Services.Notifications` — DBus notification server
- `Quickshell.Services.Pipewire` — default audio sink
- `Quickshell.Services.UPower` — battery status
- `Quickshell.Services.SystemTray` — tray icons
- `Quickshell.Wayland` / `Quickshell.Wayland.WlrLayershell` — layer-shell positioning

### VPN Configuration

`QuickSettingsService.qml` targets a specific NetworkManager connection by UUID (`da890faa-1b3a-448a-bb74-157329793fb3`). Update this UUID to match the local machine's VPN connection.

### Theme

All colors live in `modules/theme/Theme.qml` as a singleton. Palette is Catppuccin Mocha with some Tokyo Night accent names (`blueTokyo`, `redTokyo`, `orangeAlt`). Never hardcode hex values in component files — always reference `Theme.*`.

### Examples

In the example/ii folder, there is a project by 4end with some interesting features that can also be used as a base.
