# nvim-setup
neovim dotfiles. Supports: Go, Java, Elixir, Svelte, Python

## some extra steps needed

#### nerd font
Download from here: https://www.nerdfonts.com/#home<br>
Install by double clicking and install, then configure iTerm to use in **Preferences/Profiles/Text/Font**<br>
(only if icons don't show) Go to cheat sheet here: https://www.nerdfonts.com/cheat-sheet. Copy icons and replace in lua plugin files.

#### install these

+ Homebrew  
```brew install fd ripgrep fzf```

#### tmux 
Run ```brew install tmux```
Create files ```~/.tmux.conf``` and ```~/.local/bin/tmux-sessionizer```. See other_files.md
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


