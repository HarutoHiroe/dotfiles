local M = {}
function M:peek(job)
    local child = Command("pandoc")
        :args({ "-t", "markdown", tostring(job.file.url) })
        :stdout(Command.PIPED)
        :spawn()

    if not child then return end
    local output = child:wait_with_output()
    if output then
        ya.preview_code(output.stdout)
    end
end
function M:seek(job) end
return M
