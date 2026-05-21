const rpc = require("discord-rich-presence")("1380000000000000000"); // ← Discord App の Client ID に変更

const { execSync } = require("child_process");

let lastTitle = "";

function getCmusInfo() {
    try {
        return execSync("cmus-remote -Q 2>/dev/null").toString();
    } catch {
        return null;
    }
}

function extractArtistFromFilename(filepath) {
    if (!filepath) return null;
    const filename = filepath.split("/").pop().replace(/\.[^.]+$/, "");
    // "タイトル - アーティスト" or "アーティスト - タイトル" パターン
    const match = filename.match(/^(.+?)\s*[-–]\s*(.+)/);
    if (match) return match[1].trim();
    return null;
}

function getInfo() {
    const output = getCmusInfo();
    if (!output) {
        rpc.disconnect?.();
        return;
    }

    const status = output.match(/^status (.*)$/m)?.[1]?.trim();
    if (status !== "playing") return;

    const title = output.match(/^tag title (.*)$/m)?.[1]?.trim()
        || output.match(/^file (.*)$/m)?.[1]?.split("/").pop()?.replace(/\.[^.]+$/, "")
        || "Unknown";

    const filepath = output.match(/^file (.*)$/m)?.[1]?.trim();
    const artist = output.match(/^tag artist (.*)$/m)?.[1]?.trim()
        || extractArtistFromFilename(filepath)
        || "cmus";

    const pos = parseInt(output.match(/^position (\d+)$/m)?.[1] || "0");
    const dur = parseInt(output.match(/^duration (\d+)$/m)?.[1] || "0");

    if (title === lastTitle) return;
    lastTitle = title;

    const startTimestamp = Math.floor(Date.now() / 1000) - pos;
    const endTimestamp = dur > 0 ? startTimestamp + dur : undefined;

    rpc.updatePresence({
        details: title.slice(0, 128),
        state: `by ${artist}`.slice(0, 128),
        largeImageKey: "music",
        largeImageText: "cmus 🎵",
        startTimestamp,
        ...(endTimestamp ? { endTimestamp } : {}),
        instance: false,
    });
}

setInterval(getInfo, 5000);
getInfo();
