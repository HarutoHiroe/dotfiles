# dotfiles 🎛️

ハル の macOS 環境 dotfiles。**GNU Stow** で symlink 管理。

`~/nix-config`（Nix 環境）と組み合わせて使う構成：

- **`~/nix-config`** → Nix で入れる CLI ツール群（ripgrep, fd, bat, eza, stow, direnv 等）
- **`~/dotfiles`** （このリポジトリ） → brew で入れたツールの設定ファイル
- **`brew/Brewfile`** → brew で入れるパッケージ一覧

---

## 含まれる設定

| Package | 内容 | リンク先 |
|---|---|---|
| `zsh` | `.zshrc` | `~/.zshrc` |
| `tmux` | `.tmux.conf` | `~/.tmux.conf` |
| `nvim` | Neovim 設定 | `~/.config/nvim` |
| `wezterm` | WezTerm ターミナル | `~/.config/wezterm` |
| `yazi` | yazi ファイルマネージャー | `~/.config/yazi` |
| `cmus` | cmus 音楽プレイヤー | `~/.config/cmus` |
| `starship` | starship プロンプト | `~/.config/starship.toml` |
| `fastfetch` | fastfetch システム情報 | `~/.config/fastfetch` |
| `btop` | btop システム監視 | `~/.config/btop` |
| `cava` | cava 音楽ビジュアライザー | `~/.config/cava` |
| `fancy-cat` | fancy-cat（PDFビューア） | `~/.config/fancy-cat` |
| `mpv` | mpv 動画プレイヤー | `~/.config/mpv` |
| `aerospace` | AeroSpace ウィンドウマネージャー | `~/.config/aerospace` |
| `yt-x` | yt-x | `~/.config/yt-x` |
| `brew` | Brewfile | `~/Brewfile` |

---

## 新 Mac でのセットアップ

```bash
# 1. Determinate Nix インストール
curl -fsSL https://install.determinate.systems/nix | sh -s -- install

# 2. nix-config 適用（stow 含む CLI ツール群が入る）
git clone https://github.com/HarutoHiroe/nix-config ~/nix-config
sudo nix run nix-darwin/master#darwin-rebuild -- \
  switch --flake ~/nix-config#hiroeharutonoMacBook-Air

# 3. Homebrew インストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 4. dotfiles clone
git clone https://github.com/HarutoHiroe/dotfiles ~/dotfiles

# 5. Brewfile から brew パッケージ復元
brew bundle --file=~/dotfiles/brew/Brewfile

# 6. stow で全 symlink 一発
cd ~/dotfiles
stow zsh tmux nvim wezterm yazi cmus starship fastfetch \
     btop cava fancy-cat mpv aerospace yt-x
```

---

## 日常運用

### 新しい設定ファイル追加

```bash
# 例: ~/.config/foo を管理に入れる
mkdir -p ~/dotfiles/foo/.config
mv ~/.config/foo ~/dotfiles/foo/.config/foo
cd ~/dotfiles && stow foo
git add foo && git commit -m "add foo config" && git push
```

### 既存設定の編集

通常通り `~/.zshrc` 等を編集 → 実体は `~/dotfiles/zsh/.zshrc`。
`cd ~/dotfiles && git add . && git commit -m "..." && git push` で反映。

### symlink 解除（不要になった package）

```bash
cd ~/dotfiles && stow -D <package名>
```

---

## 除外している設定（機密理由）

- `~/.config/gh` → GitHub CLI 認証トークン
- `~/.config/syrics` → Spotify `sp_dc` クッキー
- `~/.config/kadai` → Notion API キー
- `~/.config/opencode` → AI ツール（API キーの可能性）
- `~/.config/git` → home-manager で `~/nix-config/home.nix` に宣言済み
