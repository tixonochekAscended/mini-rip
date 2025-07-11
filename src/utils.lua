local errors = {
    ['NotEnoughArguments'] =
    'To execute ".mrip" files you need to provide the filename to the mrip interpreter as an application argument.',
    ['NotEnoughSigilArguments'] =
    'Not enough arguments were provided to the sigil on line {arg}. Greater amount of arguments was expected.',
    ['FileDoesntExist'] = 'File you have provided as the script, {arg}, does not exist or can not be opened /or/ found.',
    ['UnterminatedStringLiteral'] = 'There is an unterminated string literal on line {arg}.',
    ['UnknownCharacter'] = 'There is an unknown character that was not supposed to be there on line {arg}.',
    ['StartIsntSigil'] = 'Line {arg} does not start with a sigil, which is necessary for a line to be considered valid.',
    ['CantParseNumber'] = 'There is an invalid number on line {arg} (can not be parsed).',
    ['InvalidLabelDefinition'] = 'There is an invalid label definition on line {arg}.',
    ['InvalidSigilArgType'] = 'One (or more) of the arguments provided to the sigil on line {arg} is invalid - a different type of argument was expected.',
    ['TooManySigilArguments'] = 'Too many arguments were provided to the sigil on line {arg}. Lower amount of arguments was expected.',
    ['IdentifierPointsToNothing'] = 'One of the identifiers found on line {arg} does not point to any actual container (scalar /or/ collection). Perhaps you made a typo?',
    ['BadIdentifier'] = 'On line {arg} there is an identifier that upon being unwrapped turned out to be a wrong type of container (scalar or collection). A different type was expected for this specific sigil - perhaps an identifier is a collection, meanwhile just a singular value from a scalar was expected - or the other way around.',
    ['UndefinedLabel'] = 'There is a jump to an undefined label on line {arg}.',
    ['BadArgument'] = 'An argument was given to the sigil on line {arg}, the value of which was expected to be different - that means either lower or greater. This is a universal error for those kinds of situations.'
}

function Panic(error_code, optional_arg)
    if not errors[error_code] then
        print('An unknown error has occured. Please notify the develop of such madness.')
        os.exit(1)
    end

    if optional_arg then
        print('\n\27[31m[err]\27[0m ' .. errors[error_code]:gsub('{arg}', tostring(optional_arg)))
    else
        print('\n\27[31m[err]\27[0m ' .. errors[error_code])
    end
    os.exit(1)
end

function AttemptRead(filename)
    local file = io.open(filename, 'r')

    if file then
        local contents = file:read('*a')
        file:close()
        return contents
    end
    Panic('FileDoesntExist', filename)
end

function InsertToken(tbl, type, value, origin)
    table.insert(tbl, {
        type = type,
        value = value,
        origin = origin
    })
end

function Map(func, tbl, special)
    local ret = {}

    for i, j in ipairs(tbl) do
        if special then
            if func(i, j) then table.insert(ret, func(i, j)) end
        else
            if func(j) then table.insert(ret, func(j)) end
        end
    end

    return ret
end

function Trim(str)
    return str:match("^%s*(.-)%s*$")
end

function In(val, tbl)
    for _, j in ipairs(tbl) do
        if j == val then
            return true
        end
    end

    return false
end

function string.split(self, delimiter)
    local result = { }
    local from  = 1
    local delim_from, delim_to = string.find( self, delimiter, from  )
    while delim_from do
      table.insert( result, string.sub( self, from , delim_from-1 ) )
      from  = delim_to + 1
      delim_from, delim_to = string.find( self, delimiter, from  )
    end
    table.insert( result, string.sub( self, from  ) )
    return result
end
