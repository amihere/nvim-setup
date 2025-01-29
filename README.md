# nvim-setup
neovim dotfiles. Supports: Go, Java, Elixir, Svelte, Python

## some extra steps needed

#### nerd font
Download from here: https://www.nerdfonts.com/#home<br>
Install by double clicking and install, then configure iTerm to use in **Preferences/Profiles/Text/Font**<br>
(only if icons don't show) Go to cheat sheet here: https://www.nerdfonts.com/cheat-sheet. Copy icons and replace in lua plugin files.

#### search & regex 

+ Homebrew  
```brew install fd ripgrep fzf make```
```brew install go```

#### tmux 
Run ```brew install tmux```
Create files ```~/.tmux.conf``` and ```~/.local/bin/tmux-sessionizer```. See other_files.md
Include TPM (TMUX plugin manager) by running: `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`  
Make tmux-sessionizer executable by using ```chmod u+x```

#### create a .zshrc.local in your ~ folder, if zsh is your shell. Use .bashrc if needed
```bindkey -s "^f" "~/.local/bin/tmux-sessionizer^M"```

#### packer not installing
At the beginning packer (plugin manager) was acting funny. Use this command in the shell to fix it: <br>
```nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'```

## environment

Macbook Pro, OS: Monterrey. Homebrew, iTerm2

## credit

Josean Martinez  
https://www.youtube.com/watch?v=vdn_pKJUda8  

ThePrimeagen  
https://github.com/ThePrimeagen/.dotfiles  

Matthias  
https://github.com/mfussenegger  

## full deps for linux (eg. ubuntu)
```
sudo apt update
sudo apt upgrade -y
sudo apt install wget unzip git neovim xclip tmux ripgrep fzf make fd-find -y
sudo apt install python3 python3-pip python3-venv elixir golang-go nodejs npm

# Create the neovim folder
mkdir -p .config/nvim
mkdir -p .tmux/plugins
mkdir -p .local/bin

# Clone
git clone https://github.com/tmux-plugins/tpm .tmux/plugins/tpm
git clone https://github.com/amihere/nvim-setup .config/nvim

rm -rf .config/nvim/.git

# Symbolic links for tmux
ln -s .config/nvim/tmux/.tmux.theme.conf $HOME/.tmux.theme.conf
ln -s .config/nvim/tmux/.tmux.conf $HOME/.tmux.conf

chmod u+x .config/nvim/tmux/.local/bin/tmux.sessionizer
ln -s .config/nvim/tmux/.local/bin/tmux.sessionizer $HOME/.local/bin/.tmux.sessionizer

```


