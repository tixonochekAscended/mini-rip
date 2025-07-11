local sigils = {}
for k, _ in pairs(Sigils) do
    table.insert(sigils, k)
end

local numerical = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-'
}

local identifiable = {
    'a', 'A', '0',
    'b', 'B', '1',
    'c', 'C', '2',
    'd', 'D', '3',
    'e', 'E', '4',
    'f', 'F', '5',
    'g', 'G', '6',
    'h', 'H', '7',
    'i', 'I', '8',
    'j', 'J', '9',
    'k', 'K', '_',
    'l', 'L',
    'm', 'M',
    'n', 'N',
    'o', 'O',
    'p', 'P',
    'q', 'Q',
    'r', 'R',
    's', 'S',
    't', 'T',
    'u', 'U',
    'v', 'V',
    'w', 'W',
    'x', 'X',
    'y', 'Y',
    'z', 'Z'
}

function Lex(script)
    local cur_lexing = 'nothing'

    local tokens = Map(function(line_index, line)
        local buffer = ''
        cur_lexing = 'nothing'

        local tkns = {}

        local j = 1
        while j <= #line do
            local char = line:sub(j, j)
            local previous_char = line:sub(j - 1, j - 1)

            if char == '"' then
                if cur_lexing == 'string' then
                    if previous_char ~= [[\]] then
                        InsertToken(tkns, "String", buffer, line_index)
                        cur_lexing = 'nothing'
                        buffer = ''
                        goto continue
                    else
                        buffer = buffer .. char
                    end
                else
                    buffer = ''
                    cur_lexing = 'string'
                end
            end

            if cur_lexing == 'nothing' and In(char, numerical) and j ~= 1 then
                cur_lexing = 'number'
                buffer = ''
            end

            if cur_lexing == 'number' and not In(char, numerical) then
                InsertToken(tkns, "Number", buffer, line_index)
                buffer = ''
                cur_lexing = 'nothing'
                goto continue
            end

            if cur_lexing == 'nothing' and In(char, identifiable) then
                cur_lexing = 'ident'
                buffer = ''
            end

            if cur_lexing == 'ident' and not In(char, identifiable) then
                InsertToken(tkns, "Ident", buffer, line_index)
                buffer = ''
                cur_lexing = 'nothing'
                goto continue
            end

            if cur_lexing == 'nothing' and In(char, sigils) then
                InsertToken(tkns, "Sigil", char, line_index)
                goto continue
            end

            if cur_lexing ~= 'nothing' and char ~= '"' then
                buffer = buffer .. char
                goto continue
            end

            if char ~= ' ' and char ~= '"' then
                Panic('UnknownCharacter', line_index)
            end
            ::continue::
            j = j + 1
        end

        if cur_lexing == 'string' then Panic('UnterminatedStringLiteral', line_index) end
        if cur_lexing == 'number' then InsertToken(tkns, 'Number', buffer, line_index) end
        if cur_lexing == 'ident' then InsertToken(tkns, 'Ident', buffer, line_index) end

        return tkns
    end, Map(Trim, script:split('\n')), true)

    return tokens
end
