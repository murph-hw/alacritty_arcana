# alacritty_arcana

Portable Alacritty setup: borderless fullscreen window, the community theme collection, a few custom Dracula variants and a theme switcher with favorites and a live tour.

Companion to [vim_arcana](../vim_arcana); the default themes on both sides are dark and use similar palettes.

## Install

```
git clone <this repo> ~/alacritty_arcana
cd ~/alacritty_arcana
./install.sh
```

The installer:

- links `~/.config/alacritty/alacritty.toml` to `alacritty.toml` in this repo, so edits in the repo apply right away (Alacritty reloads live)
- links `arcana-theme` (also as `dracula-theme`, the old name) and `palette` into `~/.local/bin`
- clones [alacritty-theme](https://github.com/alacritty/alacritty-theme) into `~/.config/alacritty/community`
- sets the default theme, `midnight_haze`, unless a theme is already active
- backs up any file it replaces as `<file>.bak.<date>`, and is safe to re-run

Needs Alacritty 0.13 or later, git, and network access to GitHub. On 0.14+ Alacritty may warn that the top-level `import` should move under `[general]`; it still works. Running `alacritty migrate` fixes the warning.

## What the config sets

| Setting | Effect |
| --- | --- |
| `import = ["~/.config/alacritty/theme.toml"]` | Active theme, written by `arcana-theme` (not tracked in git) |
| `decorations = "None"` | No title bar or borders |
| `startup_mode = "Fullscreen"` | Opens fullscreen |
| `padding`, `dynamic_padding` | 8x6 px padding, spread evenly around the grid |
| F11 | Toggle fullscreen |

## Switching themes

| Command | Effect |
| --- | --- |
| `arcana-theme` | List themes, `*` marks the active one |
| `arcana-theme <name>` | Switch to a theme |
| `arcana-theme tour [pattern]` | Step through themes live: Enter/→ next, b/← back, f toggle favorite, k keep, q quit (restores the old theme) |
| `arcana-theme tour fav` | Tour only the favorites |
| `arcana-theme fav [add\|rm <name>]` | List or edit favorites |
| `palette` | Print the 16 terminal colours |

The switcher copies the chosen theme to `~/.config/alacritty/theme.toml`, so switching never makes this repo dirty. Favorites live in `favorites` in the repo, so commit them to carry them to the next machine.

Light themes listed in `hidden` are left out of the list and the tour. Remove a name from `hidden` to bring it back.

## Favorites

Darkest first (background colour):

| Theme | Background | Style |
| --- | --- | --- |
| `linux` | `#000000` | Classic Linux console colours |
| `monokai_charcoal` | `#000000` | Monokai on black |
| `modus_vivendi` | `#000000` | High contrast, accessible |
| `dracula-oled` | `#000000` | Dracula on pure black (custom) |
| `moonfly` | `#080808` | Near-black, vivid accents |
| `midnight_haze` | `#0c0c16` | Deep blue-black (default) |
| `omni` | `#191622` | Dark purple |
| `rose_pine` | `#191724` | Muted rose and pine |
| `tokyo_night` | `#1a1b26` | Matches vim `tokyonight` |
| `oxocarbon` | `#1b1b1b` | IBM Carbon grey |
| `catppuccin_mocha` | `#1e1e2e` | Matches vim `catppuccin_mocha` |
| `kanagawa_wave` | `#1f1f28` | Japanese ink and wave |
| `gruvbox_dark` | `#282828` | Matches vim `gruvbox` |

## Custom themes

`themes/` holds Dracula variants: `dracula` (`#282a36`), `dracula-soft` (`#343746`), `dracula-midnight` (`#1e1f29`) and `dracula-oled` (`#000000`). Drop any `<name>.toml` there to add a theme; a name in `themes/` wins over a community theme with the same name.

To change the default theme for new machines, edit `DEFAULT_THEME` in `install.sh`.
