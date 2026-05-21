# 基本設定
preview_enabled=false       # サムネは重いので一旦オフが安定
search_count=30             # 検索件数

# mpvの動作（ここが重要！）
# --ontop: 常に最前面, --no-border: 枠なし, --autofit: サイズ指定
mpv_options="--hwdec=auto --ontop --no-border --autofit=60% --volume=50"

# 画質設定（1080p以下で最高画質）
ytdl_format="bestvideo[height<=1080]+bestaudio/best"

