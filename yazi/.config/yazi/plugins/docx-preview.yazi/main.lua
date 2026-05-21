local M = {}
function M:peek(job)
    local child = Command("pandoc")
        :args({ "--from", "docx", "--to", "plain", tostring(job.file.url) })
        :stdout(Command.PIPED)
        :spawn()
    if child then
        local out = child:wait_with_output()
        if out then ya.preview_code(out.stdout) end
    end
end
function M:seek(job) end
return M
