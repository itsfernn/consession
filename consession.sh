#!/bin/bash

# create rename dir and file if not exists
consession_dir="$HOME/.local/share/consession"
rename_file="$HOME/.local/share/consession/rename.txt"
mkdir -p "$consession_dir"
touch "$rename_file"

fzf_args=(
    '--preview-window=right,50%'
    '--layout=reverse'
    '--print-query'
    '--padding=1'
    '--info=inline'
    '--scrollbar=▌▐'
    '--color=16,pointer:9,spinner:92,marker:46'
    '--pointer='
    '--border'
    '--ansi'
)

rename_key="ctrl-r"
kill_key="ctrl-x"

format_time='"d=$(($(date +%s)-" $3 ")); d=${d#-}; h=$((d/3600)); m=$(( (d%3600)/60 )); ((h)) && printf \"%dh \" $h; printf \"%dm ago\n\" $m"'
format_session_info='awk '\''{ cmd = '$format_time'; cmd | getline delta; close(cmd); print $1 ": " delta "; "  $2 " windows " }'\'

list_sessions='tmux ls -F "#{session_name} #{session_windows} #{session_last_attached}"'
selected_session='$(echo {} | cut -d\  -f1)'
selected_session_old_name='$(tmux display-message -p -t '$selected_session' "#{pane_start_path}")'

new_session_name='$(result=$(awk -F '\''\t'\'' -v q="$(echo $HOME/{})" '\'' $1 == q'\'' '$rename_file' | tail -n 1 | cut -f2); [[ -z "$result" ]] && result='$selected_session'; echo $result | sed '\''s/[\ .]/_/g'\'')'

INFO='si=$('$list_sessions'| grep -m1 '$selected_session');'
INFO+='[ -n "$si" ] && echo $si | '$format_session_info';'
INFO+='[ -z "$si" ] && echo New Session: '$new_session_name

highlight='sed '\''s/attached/[3m[90mattached[0m/'\'''
sorted_sessions='tmux list-sessions -F "#{session_last_attached} #{session_name}#{?session_attached, attached,}" | sort -rn | cut -d\  -f2- |'$highlight

SESSION_VIEW="reload($sorted_sessions)"
SESSION_VIEW+="+change-preview(tmux capture-pane -ep -t $selected_session)"
SESSION_VIEW+="+change-border-label( 󰍉 ACTIVE TMUX SESSIONS  )"
SESSION_VIEW+="+change-header(rename: $rename_key, kill: $kill_key)"

kill_selected_session='tmux kill-session -t "'$selected_session'"'
KILL_SESSION="execute-silent($kill_selected_session)+reload($sorted_sessions)"

rename_selected_session='new_name=$(echo | fzf '${fzf_args[*]}' --query '$selected_session' | sed '\''s/[\ .]/_/g'\'');'
rename_selected_session+='echo -e "'$selected_session_old_name'\\t$new_name" >> '$rename_file';'
rename_selected_session+='tmux rename-session -t '$selected_session' $new_name;'
RENAME_SESSION="execute($rename_selected_session)+reload($sorted_sessions)"

list_dirs="zoxide query -l | sed 's|^/home/[a-z]*/||'"
zoxide_preview='eza -1 --group-directories-first --color=always --icons $HOME/{}'
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

selection=$(fzf "${fzf_args[@]}" "${bindings[@]}" --info-command "$INFO" --tmux 100% | tail -n1)

if [[ -z "$selection" ]]; then
    exit 0
fi

session_name=$(echo "$selection" | cut -d' ' -f1)
directory="$HOME/$selection"

if ! tmux has-session -t "$session_name"; then
    matched_name=$(awk -F '\t' -v q="$directory" '$1 == q' $rename_file | tail -n 1 | cut -f2)
    if [[ -n $matched_name ]]; then
        session_name=$matched_name
    else
        session_name=$(echo "$directory" | sed 's|^/home/[a-z]*/||' | sed 's/[\ .]/_/g')
    fi

    tmux new-session -d -s "$session_name" -c "$directory"
fi

if [[ -z $TMUX ]]; then
    tmux attach-session -t "$session_name"
else
    tmux switch-client -t "$session_name"
fi
