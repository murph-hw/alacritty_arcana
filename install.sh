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
