#!/usr/bin/env bash
# ハル の macOS 環境 一発セットアップスクリプト 🚀
# 使い方:
#   curl -fsSL https://raw.githubusercontent.com/HarutoHiroe/dotfiles/master/setup.sh | bash
#
# 何をするか:
#   1. xcode-select（必要なら）
#   2. Determinate Nix インストール
#   3. ~/nix-config clone & darwin-rebuild switch
#   4. Homebrew インストール
#   5. ~/dotfiles clone & Brewfile bundle & stow

set -euo pipefail

# === カラー定義 ===
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly RESET='\033[0m'

log()    { echo -e "${CYAN}${BOLD}==>${RESET} ${BOLD}$*${RESET}"; }
ok()     { echo -e "${GREEN}✓${RESET} $*"; }
warn()   { echo -e "${YELLOW}⚠${RESET}  $*"; }
err()    { echo -e "${RED}✗${RESET} $*" >&2; }
header() { echo; echo -e "${BLUE}${BOLD}━━━ $* ━━━${RESET}"; echo; }

# === macOS チェック ===
if [[ "$(uname)" != "Darwin" ]]; then
  err "macOS 専用スクリプトです（uname: $(uname)）"
  exit 1
fi

# === Apple Silicon チェック ===
if [[ "$(uname -m)" != "arm64" ]]; then
  warn "Apple Silicon (arm64) 想定のスクリプト。Intel Mac だと Brewfile が動かない可能性あり"
fi

# === sudo キープアライブ ===
log "sudo パスワード入力してね（後で 4 回くらい必要なので keepalive します）"
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
readonly KEEPALIVE_PID=$!
trap "kill $KEEPALIVE_PID 2>/dev/null" EXIT

# ======================================================================
header "1/8: xcode-select Command Line Tools"
# ======================================================================
if xcode-select -p &>/dev/null; then
  ok "Command Line Tools インストール済み"
else
  log "Command Line Tools をインストール（GUI ダイアログ出るよ）"
  xcode-select --install || true
  echo "GUI ダイアログでインストール完了するまで待ってから Enter キーを押してね…"
  read -r
  ok "Command Line Tools 完了"
fi

# ======================================================================
header "2/8: Determinate Nix インストール"
# ======================================================================
if command -v nix &>/dev/null; then
  ok "Nix インストール済み: $(nix --version)"
else
  log "Determinate Nix をインストール"
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
  # PATH 設定（新規シェル起動するまで PATH 通らないので明示）
  if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    # shellcheck disable=SC1091
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
  ok "Nix インストール完了: $(nix --version 2>/dev/null || echo "PATH 反映には新規シェル必要")"
fi

# ======================================================================
header "3/8: ~/nix-config clone"
# ======================================================================
if [[ -d "$HOME/nix-config/.git" ]]; then
  ok "~/nix-config 既存 → pull で最新化"
  git -C "$HOME/nix-config" pull --ff-only || warn "pull 失敗（手動確認推奨）"
else
  log "~/nix-config を clone"
  git clone https://github.com/HarutoHiroe/nix-config.git "$HOME/nix-config"
  ok "clone 完了"
fi

# ======================================================================
header "4/8: darwin-rebuild switch（CLI ツール群 + stow 投入）"
# ======================================================================
if command -v darwin-rebuild &>/dev/null; then
  log "darwin-rebuild switch を実行"
  sudo darwin-rebuild switch --flake "$HOME/nix-config"
else
  log "初回 darwin-rebuild（nix run 経由）"
  sudo nix run nix-darwin/master#darwin-rebuild -- \
    switch --flake "$HOME/nix-config#hiroeharutonoMacBook-Air"
fi
ok "nix-darwin 適用完了"

# PATH に per-user profile 追加（このシェル内で stow 等使えるように）
export PATH="/etc/profiles/per-user/${USER}/bin:$PATH"

# ======================================================================
header "5/8: Homebrew インストール"
# ======================================================================
if command -v brew &>/dev/null; then
  ok "Homebrew インストール済み: $(brew --version | head -1)"
else
  log "Homebrew をインストール"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ok "Homebrew インストール完了"
fi

# PATH 通す（Apple Silicon は /opt/homebrew）
if [[ -d /opt/homebrew/bin ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ======================================================================
header "6/8: ~/dotfiles clone"
# ======================================================================
if [[ -d "$HOME/dotfiles/.git" ]]; then
  ok "~/dotfiles 既存 → pull で最新化"
  git -C "$HOME/dotfiles" pull --ff-only || warn "pull 失敗（手動確認推奨）"
else
  log "~/dotfiles を clone"
  git clone https://github.com/HarutoHiroe/dotfiles.git "$HOME/dotfiles"
  ok "clone 完了"
fi

# ======================================================================
header "7/8: Brewfile 適用（brew bundle）"
# ======================================================================
log "brew bundle で Brewfile のパッケージを一括インストール（数分かかる）"
brew bundle --file="$HOME/dotfiles/brew/Brewfile" || warn "一部失敗してる可能性あり（再実行で OK な場合多い）"
ok "Brewfile 適用完了"

# ======================================================================
header "8/8: stow で symlink 作成"
# ======================================================================
readonly STOW_PACKAGES=(
  zsh tmux nvim wezterm yazi cmus starship fastfetch
  btop cava fancy-cat mpv aerospace yt-x borders sketchybar
)
log "stow パッケージを一括 link: ${STOW_PACKAGES[*]}"

# 既存ファイルとコンフリクトする可能性に備え、--adopt で取り込む選択もあるが
# 通常は事前に手動退避を推奨。ここはエラーになったら止まる
cd "$HOME/dotfiles"
stow -v "${STOW_PACKAGES[@]}"
ok "stow 完了"

# ======================================================================
header "🎉 セットアップ完了！"
# ======================================================================
cat <<EOF

${GREEN}${BOLD}全部終わったよ！${RESET} ${BOLD}現実、最高！${RESET} 🎤✨

${YELLOW}${BOLD}次のステップ:${RESET}
  1. ${CYAN}新しいターミナル開く（or 'exec zsh'）${RESET}
     → direnv hook と PATH が反映される

  2. ${CYAN}gh CLI 認証${RESET}
     → gh auth login

  3. ${CYAN}GUI 系の手動設定${RESET}
     → System Settings で iCloud Keychain / Photos オン確認
     → Time Machine 用外付け SSD 接続 & 設定

  4. ${CYAN}機密入りの設定は手動コピー（iCloud Drive 経由 等）${RESET}
     - ~/.config/gh, syrics, kadai, opencode

${BLUE}リポジトリ:${RESET}
  - nix-config: https://github.com/HarutoHiroe/nix-config
  - dotfiles:   https://github.com/HarutoHiroe/dotfiles

EOF
