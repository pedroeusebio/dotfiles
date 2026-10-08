# dotfiles
:computer: Personal dotfiles (in progress)

## Claude Code hooks

`claude/hooks/` holds Claude Code hook scripts. They signal when a session is
waiting on you or has finished:

- `tmux-claude-state.sh`: marks the tmux window (⏳ waiting / ✅ done), rendered by `tmux/.tmux.conf`
- `desktop-notify.sh`: sends a desktop notification (`notify-send`). Clicking it jumps to the tmux window
- `focus-terminal.sh`: raises the terminal on KDE Plasma (Wayland/X11) via a one-shot KWin script (`qdbus6`)

Only the scripts are versioned. `~/.claude` itself is not. Symlink each file:

```sh
mkdir -p ~/.claude/hooks
for f in ~/dotfiles/claude/hooks/*.sh; do ln -sf "$f" ~/.claude/hooks/; done
```

Then merge these entries into `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [{ "hooks": [
      { "type": "command", "command": "\"$HOME/.claude/hooks/tmux-claude-state.sh\" waiting", "timeout": 5 },
      { "type": "command", "command": "\"$HOME/.claude/hooks/desktop-notify.sh\" waiting", "timeout": 5 }
    ]}],
    "Stop": [{ "hooks": [
      { "type": "command", "command": "\"$HOME/.claude/hooks/tmux-claude-state.sh\" done", "timeout": 5 },
      { "type": "command", "command": "\"$HOME/.claude/hooks/desktop-notify.sh\" done", "timeout": 5 }
    ]}],
    "UserPromptSubmit": [{ "hooks": [
      { "type": "command", "command": "\"$HOME/.claude/hooks/tmux-claude-state.sh\" clear", "timeout": 5 }
    ]}],
    "SessionStart": [{ "hooks": [
      { "type": "command", "command": "\"$HOME/.claude/hooks/tmux-claude-state.sh\" clear", "timeout": 5 }
    ]}]
  }
}
```

Requires `tmux`, `jq`, `notify-send` (libnotify) and, for raising the window, `qdbus6` on KDE Plasma 6.
