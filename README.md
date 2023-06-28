# nvim-setup
basic setup for neovim. using as a basic ide for weird hobby languages.

## some extra steps needed

#### nerd font
Download from here: https://www.nerdfonts.com/#home<br>
Install by double clicking and install, then configure iTerm to use in **Preferences/Profiles/Text/Font**<br>
(only if icons don't show) Go to cheat sheet here: https://www.nerdfonts.com/cheat-sheet. Copy icons and replace in lua plugin files.

#### issues with telescope grep
```brew install fd``` <br>
```brew install ripgrep```
```brew install fzf```

#### packer not installing
At the beginning packer (plugin manager) was acting funny. Use this command in the shell to fix it: <br>
```nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'```

## environment

Macbook Pro, OS: Monterrey. Homebrew, iTerm2

## credit

Josean Martinez
https://www.youtube.com/watch?v=vdn_pKJUda8


