#### ~/.tmux.conf

```
set -ga terminal-overrides ",screen-256color*:Tc"
set-option -g default-terminal "screen-256color"
set -s escape-time 0

set -g mouse on

set-option -g detach-on-destroy off

set -g renumber-windows on # renumber windows

set -g prefix C-a
unbind C-b
bind-key C-a send-prefix
set -g status-style 'bg=#333333 fg=#5eacd3'

bind -r Tab last-window

unbind %
bind | split-window -fh -c "#{pane_current_path}"
bind-key "\\" split-window -h -c "#{pane_current_path}"

unbind '"'
bind - split-window -v -c "#{pane_current_path}"

bind-key "_" split-window -fv -c "#{pane_current_path}"

bind r source-file ~/.tmux.conf \; display "Reloaded!"

set -g base-index 1

set-window-option -g mode-keys vi
bind -T copy-mode-vi v send-keys -X begin-selection
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"

# vim-like pane switching
bind -r k select-pane -U
bind -r j select-pane -D
bind -r h select-pane -L
bind -r l select-pane -R

bind -r M resize-pane -Z
bind -r m resize-pane -D 15
# bind -r C-M resize-pane -U 15
bind -r C-M select-layout tiled

bind c new-window -c "#{pane_current_path}"
bind-key & kill-window
bind-key X kill-pane

bind-key -r f run-shell "tmux neww ~/.local/bin/tmux-sessionizer"

bind Q confirm-before -p "shutdown? (y/n)" kill-server

# tmux search

# Search backwards with prefix-/
bind / copy-mode \; send ?

bind C-u copy-mode \; send -X search-backward "(https?://|git@|git://|ssh://|ftp://|file:///)[[:alnum:]?=%/_.:,;~@!#$&()*+-]*"

bind C-f copy-mode \; send -X search-backward "(^|^\.|[[:space:]]|[[:space:]]\.|[[:space:]]\.\.|^\.\.)[[:alnum:]~_-]*/[][[:alnum:]_.#$%&+=/@-]*"

# tpm plugin
set -g @plugin 'tmux-plugins/tpm'

# list of tmux plugins

set -g @plugin 'christoomey/vim-tmux-navigator' # move seamlessly from nvim to tmux

set -g @plugin 'tmux-plugins/tmux-resurrect'

# plugin setup
set -g @resurrect-strategy-nvim 'session'

# hardcoded tmux resurrect to save on each detach event. todo: abstract call.
set-hook -g 'client-detached' 'run "~/.tmux/plugins/tmux-resurrect/scripts/save.sh"'

### theme settings ###
source-file "~/.tmux.theme.conf"

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'

```

### ~/.tmux.conf.theme
```
# window separators
set-option -wg window-status-separator " "

# set statusbar update interval
set-option -g status-interval 1

### colorscheme ###
# change window screen colors
set-option -wg mode-style bg="#f6c177",fg="#3c3836"

# default statusbar colors (terminal bg should be #282828)
set-option -g status-style bg=terminal,fg="#f6c177"

# default window title colors
set-option -wg window-status-style bg="#000000",fg="#848884"

# colors for windows with activity
set-option -wg window-status-activity-style bg="#3c3836",fg="#a89984"

# colors for windows with bells
set-option -wg window-status-bell-style bg="#3c3836",fg="#f6c177"

# active window title colors
set-option -wg window-status-current-style bg="#000000",fg="#f6c177"

# pane border
set-option -g pane-active-border-style fg="#f6c177"
set-option -g pane-border-style fg="#3c3836"

# message info
set-option -g message-style bg="#f6c177",fg="#3c3836"

# writing commands inactive
set-option -g message-command-style bg="#a89984",fg="#3c3836"

# pane number display
set-option -g display-panes-active-colour "#f6c177"
set-option -g display-panes-colour "#848884"

# clock
set-option -wg clock-mode-colour "#f6c177"

# copy mode highlighting
%if #{>=:#{version},3.2}
    set-option -wg copy-mode-match-style "bg=#a89984,fg=#3c3836"
    set-option -wg copy-mode-current-match-style "bg=#f6c177,fg=#3c3836"
%endif

# statusbar formatting
# "#a89986" MUST be in lowercase here (conflicts with statusline alias otherwise)
set-option -g status-left "#[bg=#000000, fg=default bold] #{window_index} "
set-option -g status-right "#[bg=#000000, fg=#848884] %a %d %H:%M    #[bg=#000000, fg=default]#{session_name}    #[bg=#000003, fg=#848884]#{?client_prefix,#[fg=#f6c177],#[bg=#000000]} #{host_short} "

set-option -wg window-status-current-format "#{?window_zoomed_flag,#[fg=default bold],#[fg=default]} #{?window_zoomed_flag, #{window_name}*, #{window_name}} "
set-option -wg window-status-format "#{?window_zoomed_flag,#[fg=default bold],#[fg=default]} #{window_name} "
```

### ~/.local/bin/tmux.sessionizer

```
#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/.config ~/.config/nvim -mindepth 1 -maxdepth 1 -type d | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]]; then
  # not in tmux
  tmux new-session -As "$selected_name" -c "$selected"
else
  # inside tmux
  if tmux has-session -t "$selected_name" 2> /dev/null; then
    tmux switch-client -t "$selected_name"
  else
    TMUX= tmux new-session -ds "$selected_name" -c "$selected"
    tmux switch-client -t "$selected_name"
  fi
fi
```

## Open Git merge [~/.gitconfig]
```
[diff]
    tool = nvimdiff
[difftool]
    prompt = false
[difftool "nvimdiff"]
    cmd = "nvim -d \"$LOCAL\" \"$REMOTE\""
[merge]
    tool = nvimdiff
[mergetool]
    prompt = true
[mergetool "nvimdiff"]
    cmd = "nvim -d \"$LOCAL\" \"$REMOTE\" \"$MERGED\" -c 'wincmd w' -c 'wincmd J'"
```
