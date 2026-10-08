#!/usr/bin/env bash
# Raises and focuses the terminal window owned by the given PID on KDE Plasma
# (Wayland or X11) by loading a one-shot KWin script over D-Bus.
# Usage: focus-terminal.sh <terminal-pid>
pid="$1"
[ -n "$pid" ] || exit 0
command -v qdbus6 >/dev/null 2>&1 || exit 0

name="claude-focus-$$"
script=$(mktemp --suffix=.js)
cat >"$script" <<JS
const target = $pid;
for (const w of workspace.windowList()) {
    if (w.pid === target && w.normalWindow) {
        if (w.minimized) w.minimized = false;
        if (workspace.currentDesktop !== w.desktops[0] && w.desktops.length) workspace.currentDesktop = w.desktops[0];
        workspace.activeWindow = w;
        print("claude-focus: activated " + w.caption);
        break;
    }
}
JS
qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript "$script" "$name" >/dev/null 2>&1
qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.start >/dev/null 2>&1
sleep 0.5
qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript "$name" >/dev/null 2>&1
rm -f "$script"
exit 0
