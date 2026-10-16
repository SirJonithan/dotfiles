#!/usr/bin/env bash
# Sets up a fresh Debian/Ubuntu machine with these dotfiles:
#   system packages, Neovim, Node.js, Rust, JetBrainsMono Nerd Font,
#   symlinks into $HOME and a headless NvChad bootstrap (plugins, LSPs, parsers).
# Safe to re-run. Run as your normal user; sudo is used where needed.
#
#   ./setup.sh
#   NVIM_VERSION=v0.11.5 ./setup.sh   # pick another Neovim release
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_VERSION="${NVIM_VERSION:-v0.11.4}"
NODE_MAJOR="${NODE_MAJOR:-22}"
FONT="JetBrainsMono"
LINKS=(.bashrc .tmux.conf .vimrc .config/nvim)

export PATH="$HOME/.cargo/bin:$PATH"

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

install_packages() {
  log "Installing system packages"
  sudo apt-get update
  sudo apt-get install -y \
    git curl wget ca-certificates unzip tar gzip xz-utils \
    build-essential cmake \
    ripgrep xclip wl-clipboard \
    python3 python3-pip python3-venv \
    tmux fontconfig
}

install_neovim() {
  if have nvim && [[ "$(nvim --version | head -n1)" == "NVIM $NVIM_VERSION" ]]; then
    log "Neovim $NVIM_VERSION already installed"
    return
  fi

  local arch
  case "$(uname -m)" in
    x86_64) arch=x86_64 ;;
    aarch64 | arm64) arch=arm64 ;;
    *) echo "unsupported architecture: $(uname -m)" >&2; exit 1 ;;
  esac

  log "Installing Neovim $NVIM_VERSION to /opt/nvim"
  local tmp
  tmp="$(mktemp -d)"
  curl -fL "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux-$arch.tar.gz" |
    tar -xz -C "$tmp"
  sudo rm -rf /opt/nvim
  sudo mv "$tmp/nvim-linux-$arch" /opt/nvim
  sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  rm -rf "$tmp"
  hash -r
}

# mason installs several servers (ts_ls, prettier, ...) through npm; copilot.vim needs node too
install_node() {
  if have node && (($(node -p 'process.versions.node.split(".")[0]') >= NODE_MAJOR)); then
    log "Node.js $(node --version) already installed"
    return
  fi
  log "Installing Node.js $NODE_MAJOR (NodeSource)"
  curl -fsSL "https://deb.nodesource.com/setup_$NODE_MAJOR.x" | sudo -E bash -
  sudo apt-get install -y nodejs
}

install_rust() {
  if ! have rustup; then
    log "Installing Rust (rustup)"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  fi
  rustup component add rust-analyzer
}

install_font() {
  if fc-list | grep -i "$FONT Nerd Font" >/dev/null; then
    log "$FONT Nerd Font already installed"
    return
  fi
  log "Installing $FONT Nerd Font"
  local dir="$HOME/.local/share/fonts/${FONT}NerdFont"
  mkdir -p "$dir"
  curl -fL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FONT.tar.xz" | tar -xJ -C "$dir"
  fc-cache -f "$dir"
}

# symlink $DOTFILES/<path> to ~/<path>, backing up whatever is there
link() {
  local src="$DOTFILES/$1" dst="$HOME/$1"
  [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]] && return
  if [[ -e "$dst" || -L "$dst" ]]; then
    local backup
    backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dst" "$backup"
    echo "backed up $dst -> $backup"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "linked $dst -> $src"
}

link_dotfiles() {
  log "Linking dotfiles"
  for path in "${LINKS[@]}"; do
    link "$path"
  done
}

bootstrap_nvim() {
  log "Installing Neovim plugins (lazy.nvim, versions from lazy-lock.json)"
  nvim --headless "+Lazy! restore" +qa

  log "Installing LSP servers and formatters (mason)"
  local script
  script="$(mktemp --suffix=.lua)"
  cat >"$script" <<'EOF'
-- same package list as NvChad's :MasonInstallAll, but blocking
require("lazy").load { plugins = { "mason.nvim", "nvim-lspconfig", "conform.nvim" } }
local registry = require "mason-registry"
registry.refresh()
local missing = {}
for _, pkg in ipairs(require("nvchad.mason").get_pkgs()) do
  if not registry.has_package(pkg) then
    io.stderr:write("mason: unknown package '" .. pkg .. "', skipping (fix it in chadrc.lua)\n")
  elseif not registry.is_installed(pkg) then
    table.insert(missing, pkg)
  end
end
if #missing > 0 then
  -- headless mason turns installer stderr (e.g. npm warnings) into errors; report, don't abort
  local ok, err = pcall(vim.cmd, "MasonInstall " .. table.concat(missing, " "))
  if not ok then
    io.stderr:write(tostring(err) .. "\n")
  end
end
EOF
  nvim --headless -c "luafile $script" -c qa
  rm -f "$script"

  log "Installing treesitter parsers"
  nvim --headless -c "lua require('lazy').load { plugins = { 'nvim-treesitter' } }" -c qa
}

main() {
  if [[ $EUID -eq 0 ]]; then
    echo "run as your normal user, not root" >&2
    exit 1
  fi

  install_packages
  install_neovim
  install_node
  install_rust
  install_font
  link_dotfiles
  bootstrap_nvim

  log "Done! Open a new shell (or 'source ~/.bashrc') and run nvim."
  echo "Set your terminal font to 'JetBrainsMono Nerd Font'. Run :Copilot setup once to log in to Copilot."
}

main "$@"
