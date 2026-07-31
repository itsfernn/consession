#!/bin/bash

# ─── fzf appearance ───────────────────────────────────────────────────────────

fzf_args=(
  '--preview-window=right,50%'
  '--layout=reverse'
  '--print-query'
  '--padding=1'
  '--scrollbar=▌▐'
  '--color=16,current-bg:0'
  '--pointer='
  '--border'
  '--ansi'
  '--info=inline-right'
)

# ─── keybindings ──────────────────────────────────────────────────────────────

kill_key="ctrl-x"
zoxide_key="ctrl-n"
session_key="ctrl-p"

# ─── session info display (inline shell for fzf --info-command) ───────────────

format_session_info='{ IFS=" " read -r name windows ts;'
format_session_info+=' d=$(( $(date +%s) - ts )); d=${d#-}; h=$((d/3600)); m=$(( (d%3600)/60 ));'
format_session_info+=' delta=""; [ "$h" -gt 0 ] && delta="${h}h "; delta="${delta}${m}m ago";'
format_session_info+=' dir=$(tmux display-message -p -t "$name" "#{pane_start_path}" 2>/dev/null);'
format_session_info+=' branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null);'
format_session_info+=' [ -n "$branch" ] && printf " %s" "$branch · ";'
format_session_info+=' printf "%s · %s windows" "$delta" "$windows";'
format_session_info+=' echo; }'

list_sessions='tmux ls -F "#{session_name} #{session_windows} #{session_last_attached}"'
selected_session='$(echo {} | cut -d\  -f1)'
new_session_name='$(basename "$(echo $HOME/{})" | tr " " "_")'

INFO='si=$('$list_sessions'| grep -m1 '$selected_session');'
INFO+='[ -n "$si" ] && echo $si | '$format_session_info';'
INFO+='[ -z "$si" ] && echo New Session: '$new_session_name

# ─── session view ─────────────────────────────────────────────────────────────

highlight='sed '\''s/ /[3m[90m [0m/'\'''
sorted_sessions='tmux list-sessions -F "#{session_last_attached} #{session_name}#{?session_attached,  ,}" | sort -rn | cut -d\  -f2- |'$highlight

SESSION_VIEW="reload($sorted_sessions)"
SESSION_VIEW+="+change-preview(tmux capture-pane -ep -t $selected_session)"
SESSION_VIEW+="+change-border-label( 󰍉 ACTIVE TMUX SESSIONS  )"
SESSION_VIEW+="+change-header(󱩾 $zoxide_key • 󱘅 $kill_key)"

kill_selected_session='tmux kill-session -t "'$selected_session'"'
KILL_SESSION="execute-silent($kill_selected_session)+reload($sorted_sessions)"

# ─── zoxide directory view ───────────────────────────────────────────────────

list_dirs="zoxide query -l | sed 's|^/home/[a-z]*/||'"
zoxide_preview='eza -1 --group-directories-first --color=always --icons $HOME/{}'

ZOXIDE_VIEW="reload($list_dirs)"
ZOXIDE_VIEW+="+change-preview($zoxide_preview)"
ZOXIDE_VIEW+="+change-border-label( 󰍉 CHOOSE DIRECTORY   )"
ZOXIDE_VIEW+="+change-header(⏎ $session_key)"

# ─── fzf bindings ────────────────────────────────────────────────────────────

bindings=(
  --bind "start:$SESSION_VIEW"
  --bind "zero:$ZOXIDE_VIEW"
  --bind "backward-eof:$SESSION_VIEW"
  --bind "$kill_key:$KILL_SESSION"
  --bind "$zoxide_key:$ZOXIDE_VIEW"
  --bind "$session_key:$SESSION_VIEW"
)

# ─── launch ──────────────────────────────────────────────────────────────────

selection=$(fzf "${fzf_args[@]}" "${bindings[@]}" --info-command "$INFO" --tmux 100% | tail -n1)

if [[ -z "$selection" ]]; then
  exit 0
fi

session_name=$(echo "$selection" | cut -d' ' -f1)
directory="$HOME/$selection"

# ─── create or attach ────────────────────────────────────────────────────────

if ! tmux has-session -t "$session_name"; then
  session_name=$(basename "$directory" | tr ' ' '_')

  if tmux has-session -t "$session_name" 2>/dev/null; then
    existing_dir=$(tmux display-message -p -t "$session_name" "#{pane_start_path}" 2>/dev/null)
    if [[ "$existing_dir" == "$directory" ]]; then
      :
    elif [[ -n "$existing_dir" ]]; then
      existing_parent=$(basename "$(dirname "$existing_dir")")
      existing_name="${existing_parent}/$(basename "$existing_dir" | tr ' ' '_')"
      new_parent=$(basename "$(dirname "$directory")")

      tmux rename-session -t "$session_name" "$existing_name" 2>/dev/null || true
      session_name="${new_parent}/${session_name}"

      tmux new-session -d -s "$session_name" -c "$directory"
    fi
  else
    tmux new-session -d -s "$session_name" -c "$directory"
  fi
fi

if [[ -z $TMUX ]]; then
  tmux attach-session -t "$session_name"
else
  tmux switch-client -t "$session_name"
fi
