#!/usr/bin/env bash
# Sends a desktop notification (notify-send) when a Claude Code session needs
# you, complementing the tmux tab icon from tmux-claude-state.sh:
#
#   waiting -> Notification   (permission prompt / question waiting on you)
#   done    -> Stop           (Claude finished the turn)
#
# Skipped when you are already looking at the session (its tmux window is the
# active one AND the terminal holding it has focus). Clicking the notification
# (or "Abrir") switches tmux to that window and raises the terminal via KWin
# (focus-terminal.sh).
# Reads the hook JSON from stdin. Always exits 0 so a hook can never block a turn.

state="$1"
input=$(cat)

command -v notify-send >/dev/null 2>&1 || exit 0

target=""
if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ]; then
    # Some attached client is showing this window and its terminal is focused?
    looking_at_it=$(tmux list-clients -F \
        '#{&&:#{==:#{client_session},#{session_name}},#{m:*focused*,#{client_flags}}}' \
        -t "$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}')" 2>/dev/null \
        | grep -c '^1$')
    window_active=$(tmux display-message -p -t "$TMUX_PANE" '#{window_active}' 2>/dev/null)
    if [ "$window_active" = "1" ] && [ "${looking_at_it:-0}" -gt 0 ]; then
        exit 0
    fi
    target=$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}:#{window_index}' 2>/dev/null)
    label=$(tmux display-message -p -t "$TMUX_PANE" '#{window_index}:#{window_name}' 2>/dev/null)
fi

cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
project=$(basename "${cwd:-$PWD}")
where="$project${label:+ — tmux $label}"

case "$state" in
    waiting)
        title="Claude aguardando você"
        body=$(printf '%s' "$input" | jq -r '.message // empty' 2>/dev/null)
        body="${body:-Precisa da sua atenção}"
        urgency=critical
        icon=dialog-question
        ;;
    done)
        title="Claude terminou"
        body=$(printf '%s' "$input" | jq -r '.last_assistant_message // empty' 2>/dev/null \
            | tr '\n' ' ' | cut -c1-160)
        body="${body:-Turno concluído}"
        urgency=normal
        icon=dialog-information
        ;;
    *) exit 0 ;;
esac

# Detach so the hook returns immediately; -w waits for a click. "default" is a
# click on the notification body, "open" the "Abrir" button: both jump there.
(
    action=$(notify-send -a "Claude Code" -u "$urgency" -i "$icon" \
        ${target:+-A default=Abrir -A open=Abrir} ${target:+-w} \
        "$title · $where" "$body" 2>/dev/null)
    if { [ "$action" = "open" ] || [ "$action" = "default" ]; } && [ -n "$target" ]; then
        # Most recently used tmux client: move it to the session's window...
        client=$(tmux list-clients -F '#{client_activity} #{client_name} #{client_pid}' 2>/dev/null \
            | sort -rn | head -1)
        client_name=$(echo "$client" | awk '{print $2}')
        client_pid=$(echo "$client" | awk '{print $3}')
        tmux switch-client ${client_name:+-c "$client_name"} -t "$target" 2>/dev/null
        tmux select-window -t "$target" 2>/dev/null
        # ...and raise the terminal window (its parent process) via KWin.
        term_pid=$(ps -o ppid= -p "$client_pid" 2>/dev/null | tr -d ' ')
        "$HOME/.claude/hooks/focus-terminal.sh" "$term_pid"
    fi
) </dev/null >/dev/null 2>&1 &
disown 2>/dev/null

exit 0
