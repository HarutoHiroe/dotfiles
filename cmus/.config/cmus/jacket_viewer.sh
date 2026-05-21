#!/bin/bash

LAST_FILE=""

while true; do
    INFO=$(cmus-remote -Q 2>/dev/null)
    STATUS=$(echo "$INFO" | grep "^status " | awk '{print $2}')
    FILE=$(echo "$INFO" | grep "^file " | sed 's/^file //')

    if [ "$STATUS" != "playing" ]; then
        sleep 1
        continue
    fi

    if [ "$FILE" != "$LAST_FILE" ]; then
        LAST_FILE="$FILE"
        clear

        BASE="${FILE%.*}"
        TITLE=$(basename "$BASE" | sed 's/ \[.*\]//' | cut -c1-40)

        printf "\033[1;36m♪ %s\033[0m\n" "$TITLE"
        echo "────────────────────────────────────────"
        echo ""

        for EXT in jpg png jpeg; do
            IMG="${BASE}.${EXT}"
            if [ -f "$IMG" ]; then
                chafa --format sixels --size 40x20 "$IMG"
                break
            fi
        done

        if [ ! -f "${BASE}.jpg" ] && [ ! -f "${BASE}.png" ] && [ ! -f "${BASE}.jpeg" ]; then
            echo "  (No Jacket Image)"
        fi
    fi

    sleep 1
done
