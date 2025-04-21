#!/bin/bash

rename_session="ctrl-r"
kill_session="ctrl-d"

INFO='tmux ls | grep -m1 ^{} '
INFO+='|| echo New Session: $(basename {} | sed "s/\ /_/g")'

fzf_opts=(
  --preview-window=right,50%,,
  --layout=reverse
  --print-query
  --padding 1
  --info=inline
  --tac
  --scrollbar=▌▐
  --color=16,pointer:9,spinner:92,marker:46
  --pointer=
  --border
)

SESSIONS="tmux list-sessions | sed -E 's/:.*$//' "

SESSION_VIEW="reload($SESSIONS)"
SESSION_VIEW+="+change-preview(tmux capture-pane -ep -t {})"
SESSION_VIEW+="+change-border-label( 󰍉 ACTIVE TMUX SESSIONS  )"
SESSION_VIEW+="+change-header(rename: $rename_session, kill: $kill_session)"

KILL_SESSION_EXEC="tmux kill-session -t {}"
KILL_SESSION="execute-silent($KILL_SESSION_EXEC)+reload($SESSIONS)"

test="$(printf "%s " ${fzf_opts[@]})"
RENAME_SESSION_EXEC="zsh -c echo | fzf $test --query {} | xargs tmux rename-session -t {}"
RENAME_SESSION="execute($RENAME_SESSION_EXEC)+reload($SESSIONS)"

ZOXIDE_RELOAD="zoxide query -l | sed 's|^/home/[a-z]*/||'"
ZOXIDE_VIEW="reload($ZOXIDE_RELOAD)"
ZOXIDE_VIEW+="+change-preview(zoxide query {} | xargs -I {} eza -1 --group-directories-first --color=always --icons "{}")"
ZOXIDE_VIEW+="+change-border-label( 󰍉 CHOOSE DIRECTORY   )"
ZOXIDE_VIEW+="+change-header(enter: create session)"

args=(
  --bind "start:$SESSION_VIEW"
  --bind "zero:$ZOXIDE_VIEW"
  --bind "backward-eof:$SESSION_VIEW"
  --bind "$kill_session:$KILL_SESSION"
  --bind "$rename_session:$RENAME_SESSION"
)

RESULT=$(fzf "${fzf_opts[@]}" "${args[@]}" --info-command "$INFO" --tmux 100% | tail -n1)

target=$(echo $RESULT | sed -E 's/:.*$//' | tr -d '\n')

if [[ -z "$target" ]]; then
  exit 0
fi

directory=$(zoxide query "$target")
target=$(basename "$target" | sed 's/\ /_/g')

if ! tmux has-session -t="$target"; then
  tmux new-session -ds "$target" -c "$directory" -n "$target"
fi

if [[ -z $TMUX ]]; then
  tmux attach-session -t "$target"
else
  tmux switch-client -t "$target"
fi
