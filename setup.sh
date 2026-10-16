#!/usr/bin/env bash
# Sets up a fresh Debian/Ubuntu machine with these dotfiles:
#   system packages, Neovim, Node.js, Rust, JetBrainsMono Nerd Font,
#   symlinks into $HOME and a headless NvChad bootstrap (plugins, LSPs, parsers).
# Safe to re-run. Run as your normal user; sudo is used where needed.
#
#   ./setup.sh                        # everything
#   ./setup.sh --python-only          # python/django + html: no Node.js, no Rust
#   ./setup.sh --cip                  # everything, without sudo/apt (e.g. university pool computers):
#                                     # uses system-wide tools where possible, installs the rest to ~/.local
#   NVIM_VERSION=v0.11.5 ./setup.sh   # pick another Neovim release
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_VERSION="${NVIM_VERSION:-v0.11.4}"
NVIM_MIN_VERSION="v0.11.0" # oldest system-wide Neovim --cip accepts (NvChad v2.5 needs 0.11)
NODE_MAJOR="${NODE_MAJOR:-22}"
RG_VERSION="${RG_VERSION:-14.1.1}"
FONT="JetBrainsMono"
PYTHON_ONLY=false
CIP=false
# mason packages for --python-only (none of them need node or cargo)
PYTHON_PKGS=(python-lsp-server ruff django-template-lsp djlint superhtml)

LOCAL_BIN="$HOME/.local/bin"
LOCAL_OPT="$HOME/.local/opt"
export PATH="$LOCAL_BIN:$HOME/.cargo/bin:$PATH"

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# true if version $1 >= version $2 (e.g. v0.11.4 v0.11.0)
version_ge() {
  [[ -n "$1" && "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" == "$2" ]]
}

usage() {
  echo "usage: $0 [--python-only | --cip]"
}

detect_arch() {
  case "$(uname -m)" in
    x86_64) ARCH=x86_64 ;;
    aarch64 | arm64) ARCH=arm64 ;;
    *) echo "unsupported architecture: $(uname -m)" >&2; exit 1 ;;
  esac
}

# move an unpacked release from $1 to <opt>/$2 and link the binaries $3... into <bin>
# (<opt>/<bin> are /opt and /usr/local/bin, or ~/.local/opt and ~/.local/bin with --cip)
install_release() {
  local src="$1" name="$2"
  shift 2
  local opt=/opt bin=/usr/local/bin run=sudo
  if $CIP; then
    opt="$LOCAL_OPT" bin="$LOCAL_BIN" run=""
    mkdir -p "$opt" "$bin"
  fi
  $run rm -rf "${opt:?}/$name"
  $run mv "$src" "$opt/$name"
  for exe in "$@"; do
    $run ln -sf "$opt/$name/$exe" "$bin/$(basename "$exe")"
  done
  hash -r
}

install_packages() {
  log "Installing system packages"
  # build-essential is needed in every mode: treesitter compiles its parsers with gcc
  local pkgs=(
    git curl wget ca-certificates unzip tar gzip xz-utils
    build-essential
    ripgrep xclip wl-clipboard
    python3 python3-pip python3-venv
    tmux fontconfig
  )
  $PYTHON_ONLY || pkgs+=(cmake)
  sudo apt-get update
  sudo apt-get install -y "${pkgs[@]}"
}

# --cip replacement for install_packages: these can't be installed without root, so they must exist
check_prerequisites() {
  log "Checking system-wide prerequisites"
  local missing=() cmd
  for cmd in git curl tar gzip unzip xz gcc python3; do
    have "$cmd" || missing+=("$cmd")
  done
  # mason installs the python tools (pylsp, vsg, ...) into virtualenvs
  if have python3; then
    local venv
    venv="$(mktemp -d)"
    python3 -m venv "$venv" >/dev/null 2>&1 || missing+=("python3-venv")
    rm -rf "$venv"
  fi
  if ((${#missing[@]})); then
    echo "missing system-wide (ask your admins to install them): ${missing[*]}" >&2
    exit 1
  fi

  have tmux || echo "note: tmux not found, .tmux.conf is linked but unused"
  have xclip || have wl-copy || echo "note: neither xclip nor wl-copy found, no system clipboard in nvim"

  local free_mb
  free_mb=$(($(df -Pk "$HOME" | awk 'NR == 2 { print $4 }') / 1024))
  if ((free_mb < 3072)); then
    echo "warning: only ${free_mb} MB free in $HOME, the full setup needs roughly 2-3 GB (check 'quota -s')"
  fi
}

install_neovim() {
  local current=""
  have nvim && current="$(nvim --version | head -n1 | cut -d' ' -f2)"
  if [[ "$current" == "$NVIM_VERSION" ]] || { $CIP && version_ge "$current" "$NVIM_MIN_VERSION"; }; then
    log "Neovim $current already installed"
    return
  fi

  log "Installing Neovim $NVIM_VERSION"
  local tmp
  tmp="$(mktemp -d)"
  curl -fL "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux-$ARCH.tar.gz" |
    tar -xz -C "$tmp"
  install_release "$tmp/nvim-linux-$ARCH" nvim bin/nvim
  rm -rf "$tmp"
}

# --cip only, everywhere else it comes from apt
install_ripgrep() {
  if have rg; then
    log "ripgrep already installed"
    return
  fi
  log "Installing ripgrep $RG_VERSION"
  local target=x86_64-unknown-linux-musl
  [[ $ARCH == arm64 ]] && target=aarch64-unknown-linux-gnu
  local tmp
  tmp="$(mktemp -d)"
  curl -fL "https://github.com/BurntSushi/ripgrep/releases/download/$RG_VERSION/ripgrep-$RG_VERSION-$target.tar.gz" |
    tar -xz -C "$tmp"
  install_release "$tmp/ripgrep-$RG_VERSION-$target" ripgrep rg
  rm -rf "$tmp"
}

# mason installs several servers (ts_ls, html, css, prettier, ...) through npm
install_node() {
  if have node && (($(node -p 'process.versions.node.split(".")[0]') >= NODE_MAJOR)); then
    log "Node.js $(node --version) already installed"
    return
  fi

  if ! $CIP; then
    log "Installing Node.js $NODE_MAJOR (NodeSource)"
    curl -fsSL "https://deb.nodesource.com/setup_$NODE_MAJOR.x" | sudo -E bash -
    sudo apt-get install -y nodejs
    return
  fi

  log "Installing Node.js $NODE_MAJOR (nodejs.org)"
  local arch=x64
  [[ $ARCH == arm64 ]] && arch=arm64
  local base="https://nodejs.org/dist/latest-v$NODE_MAJOR.x" file tmp
  file="$(curl -fsSL "$base/SHASUMS256.txt" | awk -v want="linux-$arch.tar.xz" '$2 ~ want "$" { f = $2 } END { print f }')"
  [[ -n "$file" ]] || { echo "no Node.js $NODE_MAJOR release for linux-$arch" >&2; exit 1; }
  tmp="$(mktemp -d)"
  curl -fL "$base/$file" | tar -xJ -C "$tmp"
  install_release "$tmp/${file%.tar.xz}" node bin/node bin/npm bin/npx
  rm -rf "$tmp"
}

install_rust() {
  if ! have rustup && have cargo && have rust-analyzer; then
    log "Rust $(cargo --version | cut -d' ' -f2) already installed"
    return
  fi
  if ! have rustup; then
    log "Installing Rust (rustup)"
    # --cip: the minimal profile skips the offline docs (~600 MB) to spare the home quota
    local profile=default
    $CIP && profile=minimal
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |
      sh -s -- -y --no-modify-path --profile "$profile"
  fi
  rustup component add rust-analyzer rustfmt clippy
}

install_font() {
  if ! have fc-cache; then
    log "fontconfig not found, skipping $FONT Nerd Font"
    return
  fi
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

# symlink $DOTFILES/<src> to ~/<dst>, backing up whatever is there
link() {
  local src="$DOTFILES/$1" dst="$HOME/$2"
  if [[ ! -e "$src" ]]; then
    echo "missing $src" >&2
    exit 1
  fi
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
  link .bashrc .bashrc
  link .tmux.conf .tmux.conf
  link .vimrc .vimrc
  link nvim .config/nvim
}

bootstrap_nvim() {
  log "Installing Neovim plugins (lazy.nvim, versions from lazy-lock.json)"
  nvim --headless "+Lazy! restore" +qa

  log "Installing LSP servers and formatters (mason)"
  local script
  script="$(mktemp --suffix=.lua)"
  cat >"$script" <<'EOF'
-- $MASON_PKGS if set, else the same package list as NvChad's :MasonInstallAll (but blocking)
require("lazy").load { plugins = { "mason.nvim", "nvim-lspconfig", "conform.nvim" } }
local registry = require "mason-registry"
registry.refresh()
local wanted = vim.env.MASON_PKGS and vim.split(vim.env.MASON_PKGS, " ", { trimempty = true })
  or require("nvchad.mason").get_pkgs()
local missing = {}
for _, pkg in ipairs(wanted) do
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
  if $PYTHON_ONLY; then
    MASON_PKGS="${PYTHON_PKGS[*]}" nvim --headless -c "luafile $script" -c qa
  else
    nvim --headless -c "luafile $script" -c qa
  fi
  rm -f "$script"

  log "Installing treesitter parsers"
  nvim --headless -c "lua require('lazy').load { plugins = { 'nvim-treesitter' } }" -c qa
}

main() {
  while (($#)); do
    case "$1" in
      --python-only) PYTHON_ONLY=true ;;
      --cip) CIP=true ;;
      -h | --help) usage; exit 0 ;;
      *) usage >&2; exit 1 ;;
    esac
    shift
  done

  if $CIP && $PYTHON_ONLY; then
    echo "--cip and --python-only can't be combined" >&2
    exit 1
  fi
  if [[ $EUID -eq 0 ]]; then
    echo "run as your normal user, not root" >&2
    exit 1
  fi

  detect_arch
  if $CIP; then
    check_prerequisites
    install_ripgrep
  else
    install_packages
  fi
  install_neovim
  if ! $PYTHON_ONLY; then
    install_node
    install_rust
  fi
  install_font
  link_dotfiles
  bootstrap_nvim

  log "Done! Open a new shell (or 'source ~/.bashrc') and run nvim."
  echo "Set your terminal font to 'JetBrainsMono Nerd Font'."
  if $PYTHON_ONLY; then
    echo "Python-only: LSPs for other languages and the CSS server (needs Node.js) are not installed."
    echo "Run ./setup.sh without --python-only later to add them."
  fi
}

main "$@"
