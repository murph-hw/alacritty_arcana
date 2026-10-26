# Terminal setup — Alacritty + Vim + bash prompt

This file holds a full terminal setup copied from another machine. **Claude: when the user hands you
this file, recreate the setup on this machine** by following the steps below. Every file is embedded
verbatim, so you can do it without GitHub access, except that the vim colour schemes and Alacritty
community themes are cloned from public GitHub repos.

## What it looks like

- **Alacritty 0.13+**: no window decorations, starts fullscreen (F11 toggles it), padding 8×6,
  default font (fontconfig `monospace` → DejaVu Sans Mono). Active colour theme: **midnight_haze**
  (background `#0c0c16`).
- Theme switcher `arcana-theme` in `~/.local/bin`, with tour, favorites and a hidden list. `palette`
  shows the 16 colours.
- **Vim 9**: defaults.vim, syntax on, hlsearch/incsearch, line numbers, Esc Esc clears the highlight,
  SystemVerilog filetype for `*.v *.vh *.sv *.svh`, termguicolors, dark background, colourscheme
  **molokai** (falls back to desert). Eight schemes are installed as native packages.
- **bash prompt**: stock Ubuntu colour prompt, `user@host` in bold green, `:`, path in bold blue, `$ `.
  The window title is `user@host: dir`. Effective PS1:
  `\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ `

## Steps for Claude

1. Check what is installed: `alacritty --version`, `vim --version | head -2` (look for `+termguicolors`),
   `git`, `fc-match monospace`. If something is missing, install it with the distro package manager
   (Ubuntu: `sudo apt install alacritty vim git fonts-dejavu-core`). Ask the user before running sudo.
2. Look at the machine's existing `~/.vimrc`, `~/.config/alacritty/`, `~/.bashrc` and `~/.local/bin` and
   tell the user what will be replaced. The install scripts back up existing files as `*.bak.<timestamp>`.
3. Create `~/work/vim_arcana/` and `~/work/alacritty_arcana/` (ask first if they already exist) and
   write every file below at its path. `chmod +x` the `install.sh` files and the files in `bin/`.
4. Run `~/work/vim_arcana/install.sh` and then `~/work/alacritty_arcana/install.sh`. They create symlinks
   (`~/.vimrc`, `~/.config/alacritty/alacritty.toml`, `~/.local/bin/arcana-theme`, `palette`), clone the
   vim schemes and the community themes, and select midnight_haze.
5. If the community clone failed (no network), write the `theme.toml` and `theme.name` embedded below
   straight into `~/.config/alacritty/`, so the colours are still correct.
6. Prompt: make sure `~/.bashrc` produces the PS1 shown above. On a stock Ubuntu `.bashrc` it does when
   `TERM` is `xterm-256color` (Alacritty sets this). Otherwise, or on another distro, uncomment
   `force_color_prompt=yes` or add the PS1 block below. Also make sure `~/.local/bin` is on PATH, and add
   the `md` alias. Back up `~/.bashrc` before you edit it and keep the user's own additions.
7. Verify: `ls -l ~/.vimrc ~/.config/alacritty/alacritty.toml`, `arcana-theme` lists `* midnight_haze`,
   `vim -c 'echo g:colors_name' -c q` prints molokai, and `bash -ic 'echo "$PS1"'` matches the PS1
   above. Tell the user to open a new Alacritty window.

## bash prompt block (only needed if the existing .bashrc does not already produce it)

~~~~bash
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
case "$TERM" in
xterm*|rxvt*) PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1" ;;
esac
export PATH="$HOME/.local/bin:$PATH"
alias md='python3 -m rich.markdown -p'
~~~~

## Files

## Vim (`~/work/vim_arcana`)

### `~/work/vim_arcana/vimrc`

~~~~vim
" vim_arcana: portable Vim setup (SystemVerilog + dark colour schemes)

" keep Vim's built-in defaults (syntax, incsearch, ...) that a vimrc would otherwise turn off
unlet! skip_defaults_vim
if filereadable(expand('$VIMRUNTIME/defaults.vim'))
  source $VIMRUNTIME/defaults.vim
endif
syntax on
filetype plugin indent on

" search: highlight every match, as you type and after Enter
set hlsearch
set incsearch

" line numbers
set number

" Esc twice clears the search highlight
nnoremap <silent> <Esc><Esc> :nohlsearch<CR>

" SystemVerilog: Vim's built-in syntax, also for Verilog files and headers
autocmd BufNewFile,BufRead *.v,*.vh,*.svh,*.sv set filetype=systemverilog

" colour scheme options (read when the scheme loads, so set them first)
let g:gruvbox_contrast_dark = 'hard'
let g:tokyonight_style = 'night'
let g:sonokai_style = 'default'

" colours: true colour when the terminal supports it, dark background
if has('termguicolors')
  set termguicolors
endif
set background=dark

" pick the scheme here; falls back to a built-in one if themes are not installed
try
  colorscheme molokai
catch
  colorscheme desert
endtry
~~~~

### `~/work/vim_arcana/install.sh`

~~~~bash
#!/usr/bin/env bash
# vim_arcana installer: links ~/.vimrc to this repo and installs the colour schemes.
# Safe to re-run: existing themes are updated, an existing ~/.vimrc is backed up once.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$HOME/.vim/pack/themes/start"

# name  git-url
THEMES=(
  "catppuccin   https://github.com/catppuccin/vim.git"
  "tokyonight   https://github.com/ghifarit53/tokyonight-vim.git"
  "molokai      https://github.com/tomasr/molokai.git"
  "gruvbox      https://github.com/morhetz/gruvbox.git"
  "dracula      https://github.com/dracula/vim.git"
  "onedark      https://github.com/joshdick/onedark.vim.git"
  "sonokai      https://github.com/sainnhe/sonokai.git"
  "nord         https://github.com/nordtheme/vim.git"
)

# 1. ~/.vimrc -> repo vimrc
if [ -L "$HOME/.vimrc" ] && [ "$(readlink "$HOME/.vimrc")" = "$REPO_DIR/vimrc" ]; then
  echo "~/.vimrc already linked"
else
  if [ -e "$HOME/.vimrc" ] || [ -L "$HOME/.vimrc" ]; then
    backup="$HOME/.vimrc.bak.$(date +%Y%m%d%H%M%S)"
    mv "$HOME/.vimrc" "$backup"
    echo "backed up old ~/.vimrc to $backup"
  fi
  ln -s "$REPO_DIR/vimrc" "$HOME/.vimrc"
  echo "linked ~/.vimrc -> $REPO_DIR/vimrc"
fi

# 2. colour schemes (Vim 8+ native packages, no plugin manager needed)
mkdir -p "$PACK_DIR"
for entry in "${THEMES[@]}"; do
  read -r name url <<< "$entry"
  dest="$PACK_DIR/$name"
  if [ -d "$dest/.git" ]; then
    git -C "$dest" pull -q --ff-only && echo "updated $name" || echo "could not update $name"
  elif [ -e "$dest" ]; then
    echo "skipped $name: $dest exists and is not a git clone"
  else
    git clone -q --depth 1 "$url" "$dest" && echo "installed $name" || echo "could not install $name"
  fi
done

# 3. checks
if ! command -v vim >/dev/null; then
  echo "warning: vim not found"
elif ! vim --version | grep -q '+termguicolors'; then
  echo "note: this vim has no termguicolors; colours will use the 256-colour fallback"
fi
echo "done. open vim, or run :source ~/.vimrc in an open vim"
~~~~

### `~/work/vim_arcana/.gitignore`

~~~~
*.swp
*.swo
*~
~~~~

## Alacritty (`~/work/alacritty_arcana`)

### `~/work/alacritty_arcana/alacritty.toml`

~~~~toml
# alacritty_arcana: portable Alacritty setup.
# The active theme is a copy in ~/.config/alacritty/theme.toml, written by arcana-theme,
# so switching themes never changes this file.
import = ["~/.config/alacritty/theme.toml"]

[window]
decorations = "None"
startup_mode = "Fullscreen"
padding = { x = 8, y = 6 }
dynamic_padding = true

[keyboard]
bindings = [{ key = "F11", action = "ToggleFullscreen" }]
~~~~

### `~/work/alacritty_arcana/install.sh`

~~~~bash
#!/usr/bin/env bash
# alacritty_arcana installer: links the Alacritty config and theme switcher to this repo,
# clones the community themes and sets the default theme.
# Safe to re-run: themes are updated, existing files are backed up once, the active theme is kept.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_DIR="$HOME/.config/alacritty"
BIN_DIR="$HOME/.local/bin"
COMMUNITY_URL="https://github.com/alacritty/alacritty-theme.git"
DEFAULT_THEME="midnight_haze"

# link <target> <link>: point <link> at <target>, backing up whatever was there
link() {
  if [ -L "$2" ] && [ "$(readlink "$2")" = "$1" ]; then
    echo "$2 already linked"
    return
  fi
  if [ -e "$2" ] || [ -L "$2" ]; then
    backup="$2.bak.$(date +%Y%m%d%H%M%S)"
    mv "$2" "$backup"
    echo "backed up old $2 to $backup"
  fi
  ln -s "$1" "$2"
  echo "linked $2 -> $1"
}

# 1. config and switcher
mkdir -p "$CONF_DIR" "$BIN_DIR"
link "$REPO_DIR/alacritty.toml" "$CONF_DIR/alacritty.toml"
link "$REPO_DIR/bin/arcana-theme" "$BIN_DIR/arcana-theme"
link "$REPO_DIR/bin/arcana-theme" "$BIN_DIR/dracula-theme"   # old name
link "$REPO_DIR/bin/palette" "$BIN_DIR/palette"

# 2. community themes
dest="$CONF_DIR/community"
if [ -d "$dest/.git" ]; then
  git -C "$dest" pull -q --ff-only && echo "updated community themes" || echo "could not update community themes"
elif [ -e "$dest" ]; then
  echo "skipped community themes: $dest exists and is not a git clone"
else
  git clone -q --depth 1 "$COMMUNITY_URL" "$dest" && echo "installed community themes" || echo "could not install community themes"
fi

# 3. active theme (kept if one is already set)
if [ -f "$CONF_DIR/theme.toml" ]; then
  echo "keeping theme $(cat "$CONF_DIR/theme.name" 2>/dev/null || echo '(unknown)')"
else
  "$REPO_DIR/bin/arcana-theme" "$DEFAULT_THEME" || "$REPO_DIR/bin/arcana-theme" dracula
fi

# 4. checks
if ! command -v alacritty >/dev/null; then
  echo "warning: alacritty not found"
fi
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) echo "note: add $BIN_DIR to PATH to use arcana-theme" ;;
esac
echo "done. a running Alacritty picks up the config live; run arcana-theme to list themes"
~~~~

### `~/work/alacritty_arcana/bin/arcana-theme`

~~~~bash
#!/usr/bin/env bash
# Switch the Alacritty theme.
#   arcana-theme            list themes (* = active)
#   arcana-theme <name>     switch to a theme
#   arcana-theme fav [add|rm <name>]  list / edit favorites (tour fav = tour only favorites)
#   arcana-theme tour [pat] step through themes (matching pat): Enter/→ = next, b/← = back, f = toggle favorite, k = keep, q = quit
# The theme is copied to ~/.config/alacritty/theme.toml (imported by alacritty.toml); Alacritty reloads it live.
repo=$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)
active=~/.config/alacritty/theme.toml
active_name=~/.config/alacritty/theme.name
favs=$repo/favorites; touch "$favs"
hidden=$repo/hidden
is_fav() { grep -qx -- "$1" "$favs"; }
toggle_fav() { if is_fav "$1"; then sed -i "/^$1\$/d" "$favs"; else echo "$1" >> "$favs"; fi; }
dirs=("$repo/themes" ~/.config/alacritty/community/themes)
names() { for d in "${dirs[@]}"; do ls "$d"/*.toml 2>/dev/null; done | xargs -n1 basename | sed 's/\.toml$//' | sort -u \
  | grep -vxF -f <(grep -v '^#' "$hidden" 2>/dev/null; echo '#'); }
path_of() { for d in "${dirs[@]}"; do [ -f "$d/$1.toml" ] && { echo "$d/$1.toml"; return; }; done; }
current() { cat "$active_name" 2>/dev/null; }
set_theme() { p=$(path_of "$1"); [ -n "$p" ] || { echo "no theme: $1"; return 1; }
  cp "$p" "$active" && echo "$1" > "$active_name"; }
case "$1" in
  "") cur=$(current); names | while read -r n; do [ "$n" = "$cur" ] && echo "* $n" || echo "  $n"; done ;;
  tour) start=$(current); if [ "$2" = fav ]; then mapfile -t list < "$favs"; else mapfile -t list < <(names | grep -i -- "${2:-.}"); fi
    total=${#list[@]}; [ "$total" -gt 0 ] || { echo "no theme matches: $2"; exit 1; }
    i=0
    while [ "$i" -lt "$total" ]; do n=${list[$i]}; set_theme "$n"; clear
      is_fav "$n" && star=" ★" || star=""
      echo "== [$((i+1))/$total] $n$star =="; "$repo/bin/palette"
      read -rsn1 -p "Enter/→=next  b/←=back  f=favorite  k=keep  q=quit " key; echo
      # Arrow keys arrive as ESC [ C / ESC [ D
      [ "$key" = $'\e' ] && { read -rsn2 -t 0.1 rest; key=$rest; }
      case "$key" in
        k) echo "kept $n"; exit ;;
        q) break ;;
        f) toggle_fav "$n" ;;
        b|'[D') [ "$i" -gt 0 ] && i=$((i-1)) ;;
        *) i=$((i+1)) ;;
      esac
    done; [ -n "$start" ] && set_theme "$start" && echo "restored $start" ;;
  fav) case "$2" in
      add) path_of "$3" >/dev/null && ! is_fav "$3" && echo "$3" >> "$favs" ;;
      rm) is_fav "$3" && toggle_fav "$3" ;;
    esac; cat "$favs" ;;
  *) set_theme "$1" && echo "theme -> $1" ;;
esac
~~~~

### `~/work/alacritty_arcana/bin/palette`

~~~~bash
#!/usr/bin/env bash
# Show the 16 terminal colors as swatches
for i in 0 1 2 3 4 5 6 7; do printf "\e[4%sm   \e[0m\e[3%sm %-3s\e[0m" $i $i $i; done; echo
for i in 0 1 2 3 4 5 6 7; do printf "\e[10%sm   \e[0m\e[9%sm %-3s\e[0m" $i $i $((i+8)); done; echo
~~~~

### `~/work/alacritty_arcana/favorites`

~~~~
linux
monokai_charcoal
moonfly
omni
oxocarbon
modus_vivendi
midnight_haze
dracula-oled
tokyo_night
catppuccin_mocha
kanagawa_wave
rose_pine
gruvbox_dark
~~~~

### `~/work/alacritty_arcana/hidden`

~~~~
# Light themes skipped by the switcher (one name per line)
acme
alabaster
ashes_light
ayu_light
catppuccin_latte
dawnfox
dayfox
enfocado_light
everforest_light
everforest_light_hard
everforest_light_medium
everforest_light_soft
flexoki-light
github_light
github_light_colorblind
github_light_default
github_light_high_contrast
github_light_tritanopia
gruvbox_light
gruvbox_material_hard_light
gruvbox_material_medium_light
kimbie_light
modus_operandi
night_owlish_light
noctis_lux
nord_light
one_light
papercolor_light
papertheme
pencil_light
rose_pine_dawn
selenized_light
seoul256-light
solarized_light
solarized_osaka_day
tokyo_night_light
tomorrow
~~~~

### `~/work/alacritty_arcana/.gitignore`

~~~~
*.swp
*~
~~~~

### `~/work/alacritty_arcana/themes/dracula-midnight.toml`

~~~~toml
# Dracula Midnight — darker background

[colors.primary]
background = "#1e1f29"
foreground = "#f8f8f2"
bright_foreground = "#ffffff"

[colors.cursor]
text = "#1e1f29"
cursor = "#f8f8f2"

[colors.vi_mode_cursor]
text = "CellBackground"
cursor = "CellForeground"

[colors.selection]
text = "CellForeground"
background = "#44475a"

[colors.search.matches]
foreground = "#44475a"
background = "#50fa7b"

[colors.search.focused_match]
foreground = "#44475a"
background = "#ffb86c"

[colors.footer_bar]
background = "#1e1f29"
foreground = "#f8f8f2"

[colors.hints.start]
foreground = "#1e1f29"
background = "#f1fa8c"

[colors.hints.end]
foreground = "#f1fa8c"
background = "#1e1f29"

[colors.normal]
black = "#191a21"
red = "#ff5555"
green = "#50fa7b"
yellow = "#f1fa8c"
blue = "#bd93f9"
magenta = "#ff79c6"
cyan = "#8be9fd"
white = "#f8f8f2"

[colors.bright]
black = "#6272a4"
red = "#ff6e6e"
green = "#69ff94"
yellow = "#ffffa5"
blue = "#d6acff"
magenta = "#ff92df"
cyan = "#a4ffff"
white = "#ffffff"
~~~~

### `~/work/alacritty_arcana/themes/dracula-oled.toml`

~~~~toml
# Dracula OLED — pure black background

[colors.primary]
background = "#000000"
foreground = "#f8f8f2"
bright_foreground = "#ffffff"

[colors.cursor]
text = "#000000"
cursor = "#f8f8f2"

[colors.vi_mode_cursor]
text = "CellBackground"
cursor = "CellForeground"

[colors.selection]
text = "CellForeground"
background = "#44475a"

[colors.search.matches]
foreground = "#44475a"
background = "#50fa7b"

[colors.search.focused_match]
foreground = "#44475a"
background = "#ffb86c"

[colors.footer_bar]
background = "#000000"
foreground = "#f8f8f2"

[colors.hints.start]
foreground = "#000000"
background = "#f1fa8c"

[colors.hints.end]
foreground = "#f1fa8c"
background = "#000000"

[colors.normal]
black = "#000000"
red = "#ff5555"
green = "#50fa7b"
yellow = "#f1fa8c"
blue = "#bd93f9"
magenta = "#ff79c6"
cyan = "#8be9fd"
white = "#f8f8f2"

[colors.bright]
black = "#6272a4"
red = "#ff6e6e"
green = "#69ff94"
yellow = "#ffffa5"
blue = "#d6acff"
magenta = "#ff92df"
cyan = "#a4ffff"
white = "#ffffff"
~~~~

### `~/work/alacritty_arcana/themes/dracula-soft.toml`

~~~~toml
# Dracula Soft — lower contrast

[colors.primary]
background = "#343746"
foreground = "#e6e6de"
bright_foreground = "#ffffff"

[colors.cursor]
text = "#343746"
cursor = "#e6e6de"

[colors.vi_mode_cursor]
text = "CellBackground"
cursor = "CellForeground"

[colors.selection]
text = "CellForeground"
background = "#44475a"

[colors.search.matches]
foreground = "#44475a"
background = "#50fa7b"

[colors.search.focused_match]
foreground = "#44475a"
background = "#ffb86c"

[colors.footer_bar]
background = "#343746"
foreground = "#e6e6de"

[colors.hints.start]
foreground = "#343746"
background = "#f1fa8c"

[colors.hints.end]
foreground = "#f1fa8c"
background = "#343746"

[colors.normal]
black = "#21222c"
red = "#ff5555"
green = "#50fa7b"
yellow = "#f1fa8c"
blue = "#bd93f9"
magenta = "#ff79c6"
cyan = "#8be9fd"
white = "#e6e6de"

[colors.bright]
black = "#6272a4"
red = "#ff6e6e"
green = "#69ff94"
yellow = "#ffffa5"
blue = "#d6acff"
magenta = "#ff92df"
cyan = "#a4ffff"
white = "#ffffff"
~~~~

### `~/work/alacritty_arcana/themes/dracula.toml`

~~~~toml
# Dracula theme for Alacritty — https://draculatheme.com/alacritty

[colors.primary]
background = "#282a36"
foreground = "#f8f8f2"
bright_foreground = "#ffffff"

[colors.cursor]
text = "#282a36"
cursor = "#f8f8f2"

[colors.vi_mode_cursor]
text = "CellBackground"
cursor = "CellForeground"

[colors.selection]
text = "CellForeground"
background = "#44475a"

[colors.search.matches]
foreground = "#44475a"
background = "#50fa7b"

[colors.search.focused_match]
foreground = "#44475a"
background = "#ffb86c"

[colors.footer_bar]
background = "#282a36"
foreground = "#f8f8f2"

[colors.hints.start]
foreground = "#282a36"
background = "#f1fa8c"

[colors.hints.end]
foreground = "#f1fa8c"
background = "#282a36"

[colors.normal]
black = "#21222c"
red = "#ff5555"
green = "#50fa7b"
yellow = "#f1fa8c"
blue = "#bd93f9"
magenta = "#ff79c6"
cyan = "#8be9fd"
white = "#f8f8f2"

[colors.bright]
black = "#6272a4"
red = "#ff6e6e"
green = "#69ff94"
yellow = "#ffffa5"
blue = "#d6acff"
magenta = "#ff92df"
cyan = "#a4ffff"
white = "#ffffff"
~~~~

## Active theme (fallback if the community themes cannot be cloned)

### `~/.config/alacritty/theme.toml`

~~~~toml
# Midnight Haze theme
# Source https//github.com/hafiz-muhammad/midnight-haze-alacritty-theme

# Default colors
[colors.primary]
background = '#0c0c16'
foreground = '#d8dee9'

# Normal colors
[colors.normal]
black   = '#2c2c3d'
red     = '#ff6e6e'
green   = '#9ec875'
yellow  = '#ffa759'
blue    = '#70a7d4'
magenta = '#d291e0'
cyan    = '#96e0e0'
white   = '#d8dee9'

# Bright colors
[colors.bright]
black   = '#414166'
red     = '#ff8d8d'
green   = '#b3d987'
yellow  = '#ffc57f'
blue    = '#9bb3d3'
magenta = '#ffa1ff'
cyan    = '#9cd8d8'
white   = '#ffffff'
~~~~

### `~/.config/alacritty/theme.name`

~~~~
midnight_haze
~~~~
