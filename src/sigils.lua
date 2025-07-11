-- '$', '@', -- assigning sigils
-- '!', '#', -- printing sigils
-- '+', '-', '/', '*', '%', -- math sigils
-- '&', '^', -- goto and label sigils
-- '>', '=', '<' -- conditional sigils
-- '?' -- good and old runif sigil
-- '.' pop sigil
-- '|' input sigil
-- ':', ';' OR() and ALL() sigils

local function rc(li, ctx, name) -- ReturnContainer()
    return ctx.containers[name] or Panic('IdentifierPointsToNothing', li)
end

local function rc_s(li, ctx, name) -- ReturnContainer_OnlyScalar()
    local res = rc(li, ctx, name)
    if res.type == 'scalar' then return res else
        Panic('BadIdentifier', li)
    end
end

local function rc_c(li, ctx, name) -- ReturnContainer_OnlyCollection()
    local res = rc(li, ctx, name)
    if res.type == 'collection' then return res else
        Panic('BadIdentifier', li)
    end
end

local function rep_all(li, ctx, args, start_from) -- Replace All Identifiers in { args } to their actual vals
    local ret = {}
    local bank = {}

    for ind, arg in ipairs(args) do
        if ind < (start_from or 0) then
            table.insert(bank, arg)
            goto continue
        end

        if arg.type == 'Ident' then
            local container = rc(li, ctx, arg.value)
            if container.type == 'scalar' then
                table.insert(ret, {
                    type = 'Number',
                    value = container.value
                })
            else
                for _, val in ipairs(container.values) do
                    table.insert(ret, {
                        type = 'Number',
                        value = val
                    })
                end
            end
            goto continue
        end
        table.insert(ret, arg)

        ::continue::
    end

    if start_from then
        return bank, ret
    else return ret end
end

Sigils = {
    ['$'] = {
        min_args = 2,
        max_args = 2,
        callback = function(line_index, ctx, args)
            if args[1].type ~= 'Ident' then
                Panic('InvalidSigilArgType', line_index)
            end

            if args[2].type == 'Ident' then
                args[2].type = 'Number'
                args[2].value = rc_s(line_index, ctx, args[2].value).value
            end

            ctx.containers[args[1].value] = {
                type = 'scalar',
                value = args[2].value
            }

            return ctx
        end
    },

    ['@'] = {
        min_args = 2,
        callback = function(line_index, ctx, args)
            if args[1].type ~= 'Ident' then
                Panic('InvalidSigilArgType', line_index)
            end

            local unchanged, changed = rep_all(line_index, ctx, args, 2)
            
            local new = {}
            for _, arg in ipairs(changed) do
                table.insert(new, arg.value)
            end
            changed = new

            ctx.containers[unchanged[1].value] = {
                type = 'collection',
                values = changed
            }

            return ctx
        end
    },

    ['!'] = {
        min_args = 1,
        callback = function(line_index, ctx, args)
            args = rep_all(line_index, ctx, args)

            for _, arg in ipairs(args) do
                if arg.value < 0 then arg.value = 0 end
                io.write(string.char(arg.value))
            end
            io.flush()
        end
    },

    ['#'] = {
        min_args = 1,
        callback = function(line_index, ctx, args)
            args = rep_all(line_index, ctx, args)

            for _, arg in ipairs(args) do
                io.write(arg.value)
            end
            io.flush()
        end
    },

    ['+'] = {
        min_args = 2,
        callback = function(line_index, ctx, args)
            if args[1].type ~= 'Ident' then
                Panic('InvalidSigilArgType', line_index)
            end

            local con = rc(line_index, ctx, args[1].value)

            if con.type == 'scalar' then
                local _, changed = rep_all(line_index, ctx, args, 2)
                local sum = 0
                for _, arg in ipairs(changed) do
                    sum = sum + arg.value
                end

                ctx.containers[args[1].value] = {
                    type = con.type,
                    value = con.value + sum -- op
                }
            else
                local _, changed = rep_all(line_index, ctx, args, 2)
                local sum = 0
                for _, arg in ipairs(changed) do
                    sum = sum + arg.value
                end

                local vals = {}
                for _, val in ipairs(con.values) do
                    table.insert(vals, val + sum) -- op
                end

                ctx.containers[args[1].value] = {
                    type = con.type,
                    values = vals
                }
            end

            return ctx
        end
    },

    ['-'] = {
        min_args = 2,
        callback = function(line_index, ctx, args)
            if args[1].type ~= 'Ident' then
                Panic('InvalidSigilArgType', line_index)
            end

            local con = rc(line_index, ctx, args[1].value)

            if con.type == 'scalar' then
                local _, changed = rep_all(line_index, ctx, args, 2)
                local sum = 0
                for _, arg in ipairs(changed) do
                    sum = sum + arg.value
                end

                ctx.containers[args[1].value] = {
                    type = con.type,
                    value = con.value - sum -- op
                }
            else
                local _, changed = rep_all(line_index, ctx, args, 2)
                local sum = 0
                for _, arg in ipairs(changed) do
                    sum = sum + arg.value
                end

                local vals = {}
                for _, val in ipairs(con.values) do
                    table.insert(vals, val - sum) -- op
                end

                ctx.containers[args[1].value] = {
                    type = con.type,
                    values = vals
                }
            end

            return ctx
        end
    },

    ['*'] = {
        min_args = 2,
        max_args = 2,
        callback = function(line_index, ctx, args)
            if args[1].type ~= 'Ident' then
                Panic('InvalidSigilArgType', line_index)
            end

            local con = rc(line_index, ctx, args[1].value)

            if con.type == 'scalar' then
                local _, changed = rep_all(line_index, ctx, args, 2)

                ctx.containers[args[1].value] = {
                    type = con.type,
                    value = math.floor(con.value * changed[1].value) -- op
                }
            else
                local _, changed = rep_all(line_index, ctx, args, 2)

                local vals = {}
                for _, val in ipairs(con.values) do
                    table.insert(vals, math.floor(val * changed[1].value)) -- op
                end

                ctx.containers[args[1].value] = {
                    type = con.type,
                    values = vals
                }
            end

            return ctx
        end
    },

    ['/'] = {
        min_args = 2,
        max_args = 2,
        callback = function(line_index, ctx, args)
            if args[1].type ~= 'Ident' then
                Panic('InvalidSigilArgType', line_index)
            end

            local con = rc(line_index, ctx, args[1].value)

            if con.type == 'scalar' then
                local _, changed = rep_all(line_index, ctx, args, 2)

                ctx.containers[args[1].value] = {
                    type = con.type,
                    value = math.floor(con.value / changed[1].value) -- op
                }
            else
                local _, changed = rep_all(line_index, ctx, args, 2)

                local vals = {}
                for _, val in ipairs(con.values) do
                    table.insert(vals, math.floor(val / changed[1].value)) -- op
                end

                ctx.containers[args[1].value] = {
                    type = con.type,
                    values = vals
                }
            end

            return ctx
        end
    },

    ['%'] = {
        min_args = 2,
        max_args = 2,
        callback = function(line_index, ctx, args)
            if args[1].type ~= 'Ident' then
                Panic('InvalidSigilArgType', line_index)
            end

            local con = rc(line_index, ctx, args[1].value)

            if con.type == 'scalar' then
                local _, changed = rep_all(line_index, ctx, args, 2)

                ctx.containers[args[1].value] = {
                    type = con.type,
                    value = math.floor(con.value % changed[1].value) -- op
                }
            else
                local _, changed = rep_all(line_index, ctx, args, 2)

                local vals = {}
                for _, val in ipairs(con.values) do
                    table.insert(vals, math.floor(val % changed[1].value)) -- op
                end

                ctx.containers[args[1].value] = {
                    type = con.type,
                    values = vals
                }
            end

            return ctx
        end
    },

    ['&'] = {
        callback = function(line_index, ctx, args) end -- cuz its already handled
    },

    ['^'] = {
        min_args = 1,
        max_args = 1,
        callback = function(line_index, ctx, args)
            if args[1].type ~= 'Ident' then
                Panic('InvalidSigilArgType', line_index)
            end

            if not ctx.labels[args[1].value] then
                Panic('UndefinedLabel', line_index)
            end

            ctx.jump_prop = ctx.labels[args[1].value]

            return ctx
        end
    },

    ['?'] = {
        min_args = 2,
        max_args = 2,
        callback = function(line_index, ctx, args)
            args = rep_all(line_index, ctx, args)

            if args[1].value ~= 1 then
                if args[2].value < 1 then Panic('BadArgument', line_index) end
                ctx.runif_prop = args[2].value
            end

            return ctx
        end
    },

    ['='] = {
        min_args = 3,
        max_args = 3,
        callback = function(line_index, ctx, args)
            if args[1].type ~= 'Ident' then
                Panic('InvalidSigilArgType', line_index)
            end
            local _, changed = rep_all(line_index, ctx, args, 2)

            local fin
            
            if changed[1].value == changed[2].value then
                fin = 1 else fin = 0 end

            ctx.containers[args[1].value] = {
                type = 'scalar',
                value = fin
            }

            return ctx
        end
    },

    ['>'] = {
        min_args = 3,
        max_args = 3,
        callback = function(line_index, ctx, args)
            if args[1].type ~= 'Ident' then
                Panic('InvalidSigilArgType', line_index)
            end
            local _, changed = rep_all(line_index, ctx, args, 2)

            local fin
            
            if changed[1].value > changed[2].value then
                fin = 1 else fin = 0 end
                
            ctx.containers[args[1].value] = {
                type = 'scalar',
                value = fin
            }

            return ctx
        end
    },

    ['<'] = {
        min_args = 3,
        max_args = 3,
        callback = function(line_index, ctx, args)
            if args[1].type ~= 'Ident' then
                Panic('InvalidSigilArgType', line_index)
            end
            local _, changed = rep_all(line_index, ctx, args, 2)

            local fin
            
            if changed[1].value < changed[2].value then
                fin = 1 else fin = 0 end
                
            ctx.containers[args[1].value] = {
                type = 'scalar',
                value = fin
            }

            return ctx
        end
    },

    [':'] = {
        min_args = 3,
        callback = function (line_index, ctx, args)
            if args[1].type ~= 'Ident' then
                Panic('InvalidSigilArgType', line_index)
            end
            local _, changed = rep_all(line_index, ctx, args, 2)

            local res = false
            for _, arg in ipairs(changed) do
                if arg.value == 1 then
                    res = true
                    break
                end
            end

            if res then
                ctx.containers[args[1].value] = {
                    type = 'scalar',
                    value = 1
                }
            else
                ctx.containers[args[1].value] = {
                    type = 'scalar',
                    value = 0
                }
            end
        end
    },

    [';'] = {
        min_args = 3,
        callback = function (line_index, ctx, args)
            if args[1].type ~= 'Ident' then
                Panic('InvalidSigilArgType', line_index)
            end
            local _, changed = rep_all(line_index, ctx, args, 2)

            local res = true
            for _, arg in ipairs(changed) do
                if arg.value ~= 1 then
                    res = false
                    break
                end
            end

            if res then
                ctx.containers[args[1].value] = {
                    type = 'scalar',
                    value = 1
                }
            else
                ctx.containers[args[1].value] = {
                    type = 'scalar',
                    value = 0
                }
            end
        end
    },

    ['|'] = {
        min_args = 1,
        max_args = 1,
        callback = function (line_index, ctx, args)
            if args[1].type ~= 'Ident' then
                Panic('InvalidSigilArgType', line_index)
            end

            local inp = io.read()
            local vals = {}
            for i = 1, #inp do
                table.insert(vals, string.byte(inp:sub(i, i)))
            end

            ctx.containers[args[1].value] = {
                type = 'collection',
                values = vals
            }

            return ctx
        end
    },

    ['.'] = {
        min_args = 4,
        max_args = 4,
        callback = function (line_index, ctx, args)
            if args[1].type ~= 'Ident' or args[2].type ~= 'Ident' then
                Panic('InvalidSigilArgType', line_index)
            end

            if args[3].type == 'Ident' then
                args[3].type = 'Number'
                args[3].value = rc_s(line_index, ctx, args[3].value).value
            end

            if args[4].type == 'Ident' then
                args[4].type = 'Number'
                args[4].value = rc_s(line_index, ctx, args[3].value).value
            end

            local from = rc_c(line_index, ctx, args[2].value)
            local aind = args[3].value
            local if_pop = args[4].value

            if aind > #from.values or aind < 1 then
                ctx.containers[args[1].value] = {
                    type = 'scalar',
                    value = -1
                }
            else
                if if_pop == 1 then
                    ctx.containers[args[1].value] = {
                        type = 'scalar',
                        value = table.remove(from.values, aind)
                    }
                    ctx.containers[args[2].value] = from
                else
                    ctx.containers[args[1].value] = {
                        type = 'scalar',
                        value = from.values[aind]
                    }
                end
            end

            return ctx
        end
    }
}
