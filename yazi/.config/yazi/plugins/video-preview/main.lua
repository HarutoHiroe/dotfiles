local M = {}
function M:peek(job)
    local child = Command("chafa")
        :args({
            "--format=iterm",
            "--size=" .. job.area.w .. "x" .. job.area.h,
            "--animate=on",
            "--colors=full",      -- フルカラー指定
            "--dither=none",      -- ディザリングを切ってクッキリさせる
            "--work-factor=9",    -- 処理負荷を上げて最高画質にする
            tostring(job.file.url),
        })
        :stdout(Command.PIPED)
        :spawn()

    if not child then return end
    while true do
        local line = child:read_line()
        if not line then break end
        ya.preview_code(line)
    end
end
function M:seek(job) end
return M
