# ~/.zshrc — canonical source: $DOTFILES/.zshrc (symlinked from ~/.zshrc)
# Single Oh My Zsh init lives here. Do NOT source full desktop configs
# (e.g. cachyos-config.zsh) from ~/.zshrc.local — they re-init OMZ.

# Repo root, resolved through this file's symlink so it follows the repo.
export DOTFILES="${${(%):-%x}:A:h}"

# Path to Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Hyphen-insensitive completion (_ and - interchangeable).
HYPHEN_INSENSITIVE="true"

# Show dots while waiting for completion.
COMPLETION_WAITING_DOTS="true"

# OMZ auto-update: remind, weekly.
zstyle ':omz:update' mode reminder
zstyle ':omz:update' frequency 13

# Completion tuning (set before OMZ loads its completion lib).
# Case-insensitive, substring and partial-word matching + caching.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.oh-my-zsh/cache"

# Plugins. zsh-syntax-highlighting must stay last.
plugins=(git docker kubectl zsh-autosuggestions zsh-syntax-highlighting)

source "$ZSH/oh-my-zsh.sh"

# --- Plugin tuning (after OMZ) ---

# Autosuggestions: history + completion, capped buffer.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# --- History ---

HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY SHARE_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_VERIFY
# Skip trivial commands in history.
HISTORY_IGNORE="(l|ls|ll|la|c|clear|history|exit|q|pwd|* --help)"

# --- Editor / locale ---

export LANG="${LANG:-en_US.UTF-8}"
export EDITOR="${EDITOR:-vim}"

# Readable man pages via less colors.
export LESS_TERMCAP_md="$(tput bold 2>/dev/null; tput setaf 2 2>/dev/null)"
export LESS_TERMCAP_me="$(tput sgr0 2>/dev/null)"

# --- PATH additions (guarded, no duplicates on re-source) ---

# user-local binaries
if [ -d "$HOME/.local/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
  esac
fi

# opencode
if [ -d "$HOME/.opencode/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.opencode/bin:"*) ;;
    *) export PATH="$HOME/.opencode/bin:$PATH" ;;
  esac
fi

# pyenv
if [ -d "$HOME/.pyenv" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  case ":$PATH:" in
    *":$PYENV_ROOT/bin:"*) ;;
    *) export PATH="$PYENV_ROOT/bin:$PATH" ;;
  esac
  eval "$(pyenv init - zsh)"
fi

# fnm (Node version manager)
if [ -x "$HOME/.local/share/fnm/fnm" ]; then
  case ":$PATH:" in
    *":$HOME/.local/share/fnm:"*) ;;
    *) export PATH="$HOME/.local/share/fnm:$PATH" ;;
  esac
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# envman
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# --- Tool init (guarded, needs PATH set above) ---

# uv (Python toolchain) — shell completion for uv and uvx
if command -v uv >/dev/null 2>&1; then
  eval "$(uv generate-shell-completion zsh)"
  command -v uvx >/dev/null 2>&1 && eval "$(uvx --generate-shell-completion zsh)"
fi

# zoxide (smarter cd) — 'z' jumps to frecent dirs, 'zi' picks interactively
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# lesspipe
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# fzf (Arch/CachyOS ships keybindings + completion separately)
if [ -d /usr/share/fzf ]; then
  export FZF_BASE=/usr/share/fzf
  [ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
  [ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
fi

# pkgfile "command not found" handler (Arch/CachyOS)
[ -f /usr/share/doc/pkgfile/command-not-found.zsh ] && source /usr/share/doc/pkgfile/command-not-found.zsh

# History substring search (system plugin, standalone — no OMZ re-init)
if [ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
  source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey -M emacs '^P' history-substring-search-up
  bindkey -M emacs '^N' history-substring-search-down
fi

# --- Ollama defaults (override per-machine in ~/.zshrc.local) ---

export OLLAMA_FLASH_ATTENTION=1
export OLLAMA_KV_CACHE_TYPE=q8_0
export OLLAMA_KEEP_ALIVE=24h
export OLLAMA_MAX_LOADED_MODELS=1
export OLLAMA_NUM_PARALLEL=1
export OLLAMA_GPU_OVERHEAD=256000000

# systemd ssh-agent (before .zshrc.local, which may override it)
[ -n "$XDG_RUNTIME_DIR" ] && [ -S "$XDG_RUNTIME_DIR/ssh-agent.socket" ] &&
  export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# bun
export BUN_INSTALL="$HOME/.bun"
[ -d "$BUN_INSTALL/bin" ] && export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# Personal / machine-local overrides — LAST so they win.
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
