#!/bin/bash

INFO=$(cmus-remote -Q 2>/dev/null)

FILE=$(echo "$INFO" | grep "^file " | sed 's/^file //')
RAW_TITLE=$(echo "$FILE" | sed 's|.*/||' | sed 's/ \[.*\]//' | sed 's/\.[^.]*$//')
TITLE=$(echo "$RAW_TITLE" | sed 's/ ⧸.*$//' | sed 's/【[^】]*】//g' | sed 's/(cv\.[^)]*)//g' | sed 's/  */ /g;s/^ //;s/ $//')
ARTIST=$(echo "$INFO" | grep "^tag artist " | sed 's/^tag artist //')
# タグにアーティストがなければffprobeで試みる
if [ -z "$ARTIST" ] && [ -n "$FILE" ] && command -v ffprobe &>/dev/null; then
  ARTIST=$(ffprobe -v quiet -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 "$FILE" 2>/dev/null)
fi
# それでも空ならファイル名から推測（"タイトル - アーティスト" パターン）
if [ -z "$ARTIST" ]; then
  BASENAME=$(basename "${FILE%.*}")
  ARTIST=$(echo "$BASENAME" | sed 's/ \[.*\]//' | grep -o ' [-–] .*' | sed 's/^ [-–] //' | cut -c1-50)
fi

# 再生履歴を記録
HISTORY_FILE="$HOME/.local/share/cmus/history.log"
mkdir -p "$(dirname "$HISTORY_FILE")"
STATUS=$(echo "$INFO" | grep "^status " | sed 's/^status //')

if [ "$STATUS" = "playing" ] && [ -n "$TITLE" ]; then
  terminal-notifier \
  -title "$TITLE" \
  -message "cmus 🎶"
fi
if [ "$STATUS" = "playing" ] && [ -n "$TITLE" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') | ${ARTIST:--} | $TITLE" >> "$HISTORY_FILE"
fi

# Last.fm / Discord / Notion 連携（バックグラウンド）
if [ "$STATUS" = "playing" ] && [ -n "$TITLE" ]; then
  (python3 "$HOME/.config/cmus/music_integrations.py" "$TITLE" "${ARTIST:--}" 2>/dev/null) &
fi

# 歌詞が未取得なら自動ダウンロード（バックグラウンド）
LRC_FILE="${FILE%.*}.lrc"
if [ "$STATUS" = "playing" ] && [ -n "$FILE" ] && [ ! -f "$LRC_FILE" ]; then
  (
    lyrics=$(syncedlyrics "$TITLE" 2>/dev/null)
    if [ -n "$lyrics" ]; then
      echo "$lyrics" > "$LRC_FILE"
    elif yt-sub2lrc "$FILE" 2>/dev/null; then
      :
    else
      whisper2lrc "$FILE" 2>/dev/null
    fi
  ) &
fi
