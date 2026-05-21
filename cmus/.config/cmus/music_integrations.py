#!/usr/bin/env python3
"""cmus連携スクリプト: Last.fm / Discord / Notion"""
import sys
import os
import json
from pathlib import Path

CONFIG_FILE = Path.home() / ".config" / "cmus" / "integrations.json"


def load_config():
    if not CONFIG_FILE.exists():
        return {}
    return json.loads(CONFIG_FILE.read_text())


def scrobble_lastfm(title, artist, config):
    try:
        import pylast
        cfg = config.get("lastfm", {})
        if not cfg.get("api_key"):
            return
        network = pylast.LastFMNetwork(
            api_key=cfg["api_key"],
            api_secret=cfg["api_secret"],
            username=cfg["username"],
            password_hash=pylast.md5(cfg["password"]),
        )
        import time
        network.scrobble(artist=artist or "Unknown", title=title, timestamp=int(time.time()))
    except Exception:
        pass


def update_discord(title, artist, config):
    try:
        from pypresence import Presence
        cfg = config.get("discord", {})
        client_id = cfg.get("client_id")
        if not client_id:
            return
        rpc = Presence(client_id)
        rpc.connect()
        rpc.update(
            details=title[:128] if title else "Unknown",
            state=f"by {artist}" if artist and artist != "-" else "cmus",
            large_image="music",
            large_text="cmus 🎵",
        )
    except Exception:
        pass


def log_notion(title, artist, config):
    try:
        from notion_client import Client
        cfg = config.get("notion", {})
        token = cfg.get("token")
        db_id = cfg.get("database_id")
        if not token or not db_id:
            return
        notion = Client(auth=token)
        import datetime
        notion.pages.create(
            parent={"database_id": db_id},
            properties={
                "曲名": {"title": [{"text": {"content": title or ""}}]},
                "アーティスト": {"rich_text": [{"text": {"content": artist or "-"}}]},
                "日時": {"date": {"start": datetime.datetime.now().isoformat()}},
            },
        )
    except Exception:
        pass


def main():
    if len(sys.argv) < 2:
        print("Usage: music_integrations.py <title> [artist]")
        sys.exit(1)

    title = sys.argv[1]
    artist = sys.argv[2] if len(sys.argv) > 2 else "-"
    config = load_config()

    scrobble_lastfm(title, artist, config)
    update_discord(title, artist, config)
    log_notion(title, artist, config)


if __name__ == "__main__":
    main()
