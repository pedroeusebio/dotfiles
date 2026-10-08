#!/usr/bin/env bash
# Marks the tmux window holding this Claude Code session with its current state,
# so the status bar can show an icon for it. Driven by Claude Code hooks:
#
#   waiting -> Notification   (permission prompt / question waiting on you)
#   done    -> Stop           (Claude finished the turn)
#   clear   -> UserPromptSubmit / SessionStart
#
# The state lives in the window option @claude_state; .tmux.conf renders it.
# Always exits 0 so a hook can never block or fail a turn.

state="$1"

# Not inside tmux (or no pane to target) -> nothing to do.
[ -n "$TMUX" ] || exit 0
[ -n "$TMUX_PANE" ] || exit 0

if [ "$state" = "clear" ]; then
    tmux set-option -w -u -t "$TMUX_PANE" @claude_state 2>/dev/null
    exit 0
fi

# If you are already looking at this window, there is nothing to flag: skip
# marking so the icon never lingers on the window you are actively watching.
looking_at_it=$(tmux display-message -p -t "$TMUX_PANE" \
    '#{&&:#{window_active},#{session_attached}}' 2>/dev/null)
if [ "$looking_at_it" = "1" ]; then
    tmux set-option -w -u -t "$TMUX_PANE" @claude_state 2>/dev/null
    exit 0
fi

tmux set-option -w -t "$TMUX_PANE" @claude_state "$state" 2>/dev/null
exit 0
