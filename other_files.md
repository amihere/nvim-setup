#### ~/.tmux.conf

```
set -ga terminal-overrides ",screen-256color*:Tc"
set-option -g default-terminal "screen-256color"
set -s escape-time 0

set -g mouse on

set-option -g detach-on-destroy off

set -g prefix C-a
unbind C-b
bind-key C-a send-prefix
set -g status-style 'bg=#333333 fg=#5eacd3'

unbind %
bind | split-window -h

unbind '"'
bind - split-window -v

bind r source-file ~/.tmux.conf
set -g base-index 1

set-window-option -g mode-keys vi
bind -T copy-mode-vi v send-keys -X begin-selection
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'

# bind -n C-H  previous-window
# bind -n C-L next-window

# vim-like pane switching
bind -r ^ last-window
bind -r k select-pane -U
bind -r j select-pane -D
bind -r h select-pane -L
bind -r l select-pane -R

bind -r m resize-pane -Z
bind -r M resize-pane -D 15

bind-key -r G run-shell "$HOME/.local/share/nvim/site/pack/packer/start/harpoon/scripts/tmux/switch-back-to-nvim"

bind-key -r f run-shell "tmux neww ~/.local/bin/tmux-sessionizer"

# tpm plugin
set -g @plugin 'tmux-plugins/tpm'

# list of tmux plugins

set -g @plugin 'christoomey/vim-tmux-navigator' # move seamlessly from nvim to tmux

set -g @plugin 'srcery-colors/srcery-tmux'
# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'

```

### ~/.local/bin/tmux.sessionizer

```
#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find <ANY DIRECTORIES YOU MAY NEED> -mindepth 1 -maxdepth 1 -type d | fzf)
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
