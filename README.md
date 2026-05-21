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

### 🚀 一発インストール（推奨）

```bash
curl -fsSL https://raw.githubusercontent.com/HarutoHiroe/dotfiles/master/setup.sh | bash
```

`setup.sh` が以下を順番に実行：

1. Command Line Tools（必要なら）
2. Determinate Nix
3. `~/nix-config` clone + `darwin-rebuild switch`
4. Homebrew
5. `~/dotfiles` clone
6. Brewfile 適用（`brew bundle`）
7. `stow` で全 symlink 作成

**冪等性あり：再実行しても安全。** 既存環境はスキップ or 最新化される。

### 🔧 手動セットアップ（参考）

```bash
# 1. Determinate Nix インストール
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate

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

### 🔐 セットアップ後の手動アクション

1. **新シェル起動**：`exec zsh`（direnv hook / PATH 反映）
2. **gh CLI 認証**：`gh auth login`
3. **GUI 設定確認**：
   - System Settings → Apple Account → iCloud → **Keychain** オン
   - System Settings → Apple Account → iCloud → **Photos** オン
   - Time Machine 用外付け SSD 接続 & 設定
4. **機密設定ファイルの復元**（iCloud Drive 経由などで手動コピー）：
   - `~/.config/gh/`, `~/.config/syrics/`, `~/.config/kadai/`, `~/.config/opencode/`

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
