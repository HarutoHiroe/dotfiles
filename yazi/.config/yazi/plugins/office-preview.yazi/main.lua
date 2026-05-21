local M = {}
function M:peek(job)
    local url = tostring(job.file.url)
    local ext = url:match("%.([^%.]+)$"):lower()
    local child

    if ext == "xlsx" then
        child = Command("xlsx2csv"):args({ url }):stdout(Command.PIPED):spawn()
    else
        -- docx, pptx 用
        child = Command("pandoc"):args({ "--from", ext, "--to", "plain", url }):stdout(Command.PIPED):spawn()
    end

    if child then
        local out = child:wait_with_output()
        if out then ya.preview_code(out.stdout) end
    end
end
function M:seek(job) end
return M
