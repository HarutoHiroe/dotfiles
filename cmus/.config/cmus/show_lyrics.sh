#!/bin/bash

FILE="$1"
if [ -z "$FILE" ]; then
  echo "使い方: show_lyrics.sh <音楽ファイルパス>"
  exit 1
fi

# 同名の.lrcファイルを探す
LRC="${FILE%.*}.lrc"

if [ ! -f "$LRC" ]; then
  echo "歌詞ファイルが見つかりません"
  echo "$LRC"
  exit 1
fi

# LRCを読んでタイムスタンプ付きで表示
echo "=== $(basename "$FILE") ==="
echo ""

while IFS= read -r line; do
  # タイムスタンプ行を処理
  if [[ "$line" =~ ^\[([0-9]+):([0-9]+\.[0-9]+)\](.*) ]]; then
    min="${BASH_REMATCH[1]}"
    sec="${BASH_REMATCH[2]}"
    text="${BASH_REMATCH[3]}"
    # 秒数に変換
    total=$(echo "$min * 60 + $sec" | bc)
    printf "[%s] %s\n" "$total" "$text"
  fi
done < "$LRC"
