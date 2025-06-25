#!/bin/bash

known_dirs=(~/Documents/Projects/ ~/Documents/Uni /home/lukas ~/.config)

sorted_dirs=$(printf "%s\n" "${known_dirs[@]}" | xargs -I {} realpath -m {} | awk '{ print length, $0 }' | sort -rn | cut -d' ' -f2-)

trim_known_dirs=$(printf "%s\n" "${known_dirs[@]}" | xargs -I {} realpath -m {} | awk '{ print length, $0 }' | sort -rn | cut -d' ' -f2- | xargs -I {} echo ' | sed '\''s|'{}'/||'\''\' | cat)

test='| sed '\''s|^/home/[a-z]*/||'\'

fzf_args=(
    '--preview-window=right,50%'
    '--layout=reverse'
    '--print-query'
    '--padding=1'
    '--info=inline'
    '--tac'
    '--scrollbar=▌▐'
    '--color=16,pointer:9,spinner:92,marker:46'
    '--pointer= '
    '--border'
    '--ansi'
)

rename_key="ctrl-r"
kill_key="ctrl-x"

session_info='tmux ls -F "#{session_name} #{session_windows} win [last attached: #{t/p:session_last_attached}]"'
selected_session='$(echo {} | awk '\''{print $1}'\'')'
new_session_name='$(zoxide query {}'$trim_known_dirs' | sed '\''s/[\ .]/_/g'\'')'

INFO=$session_info'| grep -m1 '$selected_session
INFO+='|| echo New Session: '$new_session_name

highlight='sed '\''s/attached/[3m[90mattached[0m/'\'''
sorted_sessions='tmux list-sessions -F "#{session_last_attached} #{session_name}#{?session_attached, attached,}" | sort -nr | cut -d\  -f2- |'$highlight

SESSION_VIEW="reload($sorted_sessions)"
SESSION_VIEW+="+change-preview(tmux capture-pane -ep -t $selected_session)"
SESSION_VIEW+="+change-border-label( 󰍉 ACTIVE TMUX SESSIONS  )"
SESSION_VIEW+="+change-header(rename: $rename_key, kill: $kill_key)"

kill_selected_session='tmux kill-session -t '$selected_session
KILL_SESSION="execute-silent($kill_selected_session)+reload($sorted_sessions)"

rename_selected_session="zsh -c echo | fzf ${fzf_args[*]} --query $selected_session | xargs tmux rename-session -t $selected_session"
RENAME_SESSION="execute($rename_selected_session)+reload($sorted_sessions)"

list_dirs="zoxide query -l | sed 's|^/home/[a-z]*/||'"
zoxide_preview='zoxide query {} | xargs eza -1 --group-directories-first --color=always --icons'
ZOXIDE_VIEW="reload($list_dirs)"
ZOXIDE_VIEW+="+change-preview($zoxide_preview)"
ZOXIDE_VIEW+="+change-border-label( 󰍉 CHOOSE DIRECTORY   )"
ZOXIDE_VIEW+="+change-header(enter: create session)"

bindings=(
    --bind "start:$SESSION_VIEW"
    --bind "zero:$ZOXIDE_VIEW"
    --bind "backward-eof:$SESSION_VIEW"
    --bind "$kill_key:$KILL_SESSION"
    --bind "$rename_key:$RENAME_SESSION"
)

target=$(fzf "${fzf_args[@]}" "${bindings[@]}" --info-command "$INFO" --tmux 100% | tail -n1)

if [[ -z "$target" ]]; then
    exit 0
fi

directory=$(zoxide query "$target")
zoxide add "$directory" >/dev/null

if ! tmux has-session -t "$target"; then
    target=$(eval 'echo "$directory" '$trim_known_dirs' | sed '\''s/[\ .]/_/g'\')
    tmux new-session -d -s "$target" -c "$directory"
fi

if [[ -z $TMUX ]]; then
    tmux attach-session -t "$target"
else
    tmux switch-client -t "$target"
fi
