#!/bin/bash
LYRICS_DIR="${HOME}/動画ファイル"
OFFSET_DIR="${HOME}/.config/cmus/offsets"
LYRICS_CACHE="/tmp/current_lyrics.lrc"
CURRENT_SONG_CACHE="/tmp/current_song"

mkdir -p "$OFFSET_DIR"

get_cmus_info() {
    cmus-remote -Q 2>/dev/null
}

get_offset() {
    local song="$1"
    local offset_file="${OFFSET_DIR}/${song}.offset"
    if [ -f "$offset_file" ]; then
        cat "$offset_file"
    else
        echo "0"
    fi
}

timestamp_to_seconds() {
    local ts="$1"
    if [[ $ts =~ \[([0-9]+):([0-9]+)(\.[0-9]+)?\] ]]; then
        local mm="${BASH_REMATCH[1]}"
        local ss="${BASH_REMATCH[2]}"
        echo $(( 10#${mm} * 60 + 10#${ss} ))
    fi
}

format_time() {
    local sec="$1"
    printf "%d:%02d" $((sec / 60)) $((sec % 60))
}

draw_progress() {
    local pos="$1" dur="$2" width=40
    [[ -z "$pos" || -z "$dur" || "$dur" -le 0 ]] 2>/dev/null && return
    local filled=$(( pos * width / dur ))
    [ "$filled" -gt "$width" ] && filled=$width
    local bar=""
    for ((i=0; i<width; i++)); do
        [ $i -lt $filled ] && bar+="█" || bar+="░"
    done
    local pos_str dur_str remain
    pos_str=$(format_time "$pos")
    dur_str=$(format_time "$dur")
    remain=$(format_time $(( dur - pos )))
    printf "\033[2m %s \033[0m\033[36m%s\033[0m\033[2m %s (-%s)\033[0m\n" \
        "$pos_str" "$bar" "$dur_str" "$remain"
}

load_lyrics() {
    local filename="$1"
    local base="${filename%.*}"
    local lrc_file="${LYRICS_DIR}/${base}.lrc"
    if [ -f "$lrc_file" ]; then
        cp "$lrc_file" "$LYRICS_CACHE"
        echo "$base" > "$CURRENT_SONG_CACHE"
        return 0
    else
        rm -f "$LYRICS_CACHE"
        return 1
    fi
}

is_unsynced() {
    local total zero
    total=$(grep -c '^\[' "$LYRICS_CACHE" 2>/dev/null); total=${total:-0}
    zero=$(grep -c '^\[00:00\.00\]' "$LYRICS_CACHE" 2>/dev/null); zero=${zero:-0}
    [ "$total" -gt 0 ] && [ "$zero" -eq "$total" ]
}

display_lyrics() {
    local position="$1" offset="$2" duration="$3" status="${4:-playing}"

    if [ ! -f "$LYRICS_CACHE" ]; then
        return
    fi

    tput cup 0 0
    local song_name
    song_name=$(cat "$CURRENT_SONG_CACHE" 2>/dev/null | sed 's/ \[.*\]//' | cut -c1-50)
    local icon="🎵"
    [ "$status" = "paused" ] && icon="⏸"
    printf "\033[1;36m%s %s\033[0m  \033[2m[Offset: %+.1fs]\033[0m\n" "$icon" "$song_name" "$offset"
    draw_progress "$position" "$duration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "\033[J"

    if is_unsynced; then
        printf "\033[2m  (タイムスタンプなし)\033[0m\n\n"
        grep -v '^\[' "$LYRICS_CACHE" | grep -v '^$' | head -20 | while IFS= read -r line; do
            printf "  \033[2m%s\033[0m\n" "$line"
        done
        return
    fi

    local adjusted_position
    adjusted_position=$(awk "BEGIN {printf \"%d\", $position - $offset}")

    local current_line_num=0 line_num=0
    while IFS= read -r line; do
        ((line_num++))
        if [[ $line =~ \[([0-9]+):([0-9]+) ]]; then
            local ts_sec
            ts_sec=$(timestamp_to_seconds "$line")
            if [ "$ts_sec" -le "$adjusted_position" ]; then
                current_line_num=$line_num
            fi
        fi
    done < "$LYRICS_CACHE"

    local start=$((current_line_num - 4))
    local end=$((current_line_num + 6))
    [ "$start" -lt 1 ] && start=1

    line_num=0
    while IFS= read -r line; do
        ((line_num++))
        if [ "$line_num" -lt "$start" ] || [ "$line_num" -gt "$end" ]; then
            continue
        fi
        local lyrics_text
        lyrics_text=$(echo "$line" | sed 's/\[[0-9:\.]*\]//')
        if [ "$line_num" -eq "$current_line_num" ]; then
            printf "\033[1;33m▶ %-60s\033[0m\n" "$lyrics_text"
        elif [ "$line_num" -eq $((current_line_num + 1)) ]; then
            printf "\033[0;37m  %-60s\033[0m\n" "$lyrics_text"
        else
            printf "\033[2m  %s\033[0m\n" "$lyrics_text"
        fi
    done < "$LYRICS_CACHE"
}

main() {
    local last_song=""
    while true; do
        local INFO
        INFO=$(get_cmus_info)

        local status current_song position duration base offset
        status=$(echo "$INFO" | grep '^status' | awk '{print $2}')
        current_song=$(echo "$INFO" | grep '^file' | sed 's|.*/||')
        position=$(echo "$INFO" | grep '^position' | awk '{print $2}')
        duration=$(echo "$INFO" | grep '^duration' | awk '{print $2}')
        base="${current_song%.*}"
        offset=$(get_offset "$base")

        if [ -z "$INFO" ] || [ "$status" = "stopped" ]; then
            tput cup 0 0
            printf "\033[J"
            printf "\033[2m  ■ stopped\033[0m\n"
            sleep 1
            continue
        fi

        if [ "$status" = "paused" ]; then
            display_lyrics "$position" "$offset" "$duration" "paused"
            sleep 0.5
            continue
        fi

        if [ "$current_song" != "$last_song" ]; then
            if load_lyrics "$current_song"; then
                last_song="$current_song"
            else
                tput cup 0 0
                printf "\033[J"
                echo "⚠️ 歌詞ファイルが見つかりません"
                echo "$current_song"
            fi
        fi
        display_lyrics "$position" "$offset" "$duration"
        sleep 0.5
    done
}

main
