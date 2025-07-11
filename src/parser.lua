local sequences = {
    [ [[\t]] ] = '\t',
    [ [[\n]] ] = '\n',
    [ [[\e]] ] = '\27',
    [ [[\"]] ] = '"'
}

local function escape_string(str)
    local escaped = str
    for key, value in pairs(sequences) do
        escaped = escaped:gsub(key, value)
    end
    return escaped
end

local function numberize(str)
    local ret = {}

    for i = 1, #str do
        local ascii = string.byte(str, i)
        table.insert(ret, ascii)
    end

    return ret
end

function Parse(tokens)
    local horder_tokens = Map(function (line_index, line)
        if #line > 0 and line[1].type ~= 'Sigil' then
            Panic('StartIsntSigil', line_index)
        end

        if #line < 1 then return {} end

        local sigil = line[1].value
        local args = {}

        local j = 2
        while j <= #line do
            local arg = line[j]

            if arg.type == 'Number' and not tonumber(arg.value) then
                Panic('CantParseNumber', line_index)
            elseif arg.type == 'Number' and tonumber(arg.value) then
                arg.value = tonumber(arg.value)
            end

            if arg.type == 'String' then
                for _, cpoint in ipairs(numberize(escape_string(arg.value))) do
                    InsertToken(args, 'Number', cpoint, line_index)
                end

                goto continue
            end

            table.insert(args, arg)

            ::continue::
            j = j + 1
        end

        return {
            sigil = sigil, args = args
        }
    end, tokens, true)
    

    return horder_tokens
end
