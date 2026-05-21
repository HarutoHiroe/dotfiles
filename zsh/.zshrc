# homebrew（最初に）
eval "$(/opt/homebrew/bin/brew shellenv)"

export DEFAULT_USER=$USER
export PATH="$PATH:/Users/hiroeharuto/Library/Python/3.9/bin"

function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

eval "$(starship init zsh)"
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  # 曖昧検索
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fcd() {
  local dir
  dir=$(find ${1:-.} -type d 2>/dev/null | fzf --height 40% --reverse --border=rounded) && cd "$dir" && clear
}
 # エリアス
alias vi='nvim'
  # eza
alias ll='eza --icons -al --group-directories-first'

# AIエイリアス
alias ai='opencode -c -m zai/default'
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export EDITOR=nano
export EDITOR=nvim
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/bin:$PATH"


alias dison='sudo pmset -c disablesleep 1 && echo "スリープ無効化しました"'
alias disoff='sudo pmset -c disablesleep 0 && echo "スリープ有効に戻しました"'

# Nix per-user profile（home-manager で入れたツール群を PATH に通す）
export PATH="/etc/profiles/per-user/hiroeharuto/bin:$PATH"

# direnv hook（cd で .envrc 自動ロード）
eval "$(direnv hook zsh)"

