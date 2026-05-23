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

# ターミナルブラウザ系
alias gweb='bunx @ghostty-web/demo@0.4.0'

# ターミナル内動画再生（Ghostty/WezTerm の kitty graphics）
# 480x270 / 15fps / 80x24セル に絞って A-V 同期取れるレベルまで軽量化
# --osd-level=0 で OSD オフ、終了後 clear で残骸消す関数
unalias mpvk mpvkl mpvkh mpvs 2>/dev/null  # 旧 alias を消してから function 定義
mpvk() {
  mpv --vo=kitty --vf=scale=480:270,fps=15 --vo-kitty-cols=80 --vo-kitty-rows=24 --osd-level=0 "$@"
  printf '\033[?25h'  # カーソル戻す
  clear              # kitty graphics 残骸消す
}
# 軽さ重視（360x202 / 12fps）
mpvkl() {
  mpv --vo=kitty --vf=scale=360:202,fps=12 --vo-kitty-cols=64 --vo-kitty-rows=20 --osd-level=0 "$@"
  printf '\033[?25h'
  clear
}
# 画質重視（重い、ハイスペック時用 640x360 / 24fps）
mpvkh() {
  mpv --vo=kitty --vf=scale=640:360 --vo-kitty-cols=100 --vo-kitty-rows=30 --osd-level=0 "$@"
  printf '\033[?25h'
  clear
}
# 動画専用の小窓 Ghostty で mpv 起動（描画範囲とウィンドウぴったり）
mpvw() {
  local file="$(realpath "$1")"
  open -na /Applications/Ghostty.app --args \
    --config-file="$HOME/.config/ghostty/config-video" \
    -e zsh -ic "mpv --vo=kitty --vf=scale=480:270,fps=15 --vo-kitty-cols=80 --vo-kitty-rows=24 --osd-level=0 '$file'; exit"
}

# Nix per-user profile（home-manager で入れたツール群を PATH に通す）
export PATH="/etc/profiles/per-user/hiroeharuto/bin:$PATH"

# direnv hook（cd で .envrc 自動ロード）
eval "$(direnv hook zsh)"

