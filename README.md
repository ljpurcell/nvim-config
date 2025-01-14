# Nvim Config

### One:
Backup previous configuration:
```sh
mv ~/.config/nvim ~/.config/nvim.bak-`date +%Y-%m-%d`
```

### Two:
Clean up any old files:
```sh
rm -rf ~/.local/share/nvim/
```

### Three:

Bash
```sh
git clone https://github.com/ljpurcell/nvim-config "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
```

Fish
```sh
git clone https://github.com/ljpurcell/nvim-config (or echo $XDG_CONFIG_HOME; echo $HOME/.config)/nvim
```

### Go!

Also personalised kickstart [here](https://github.com/ljpurcell/ljpurcell.kickstart.nvim)
