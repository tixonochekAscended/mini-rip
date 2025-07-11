function Execute(hots)
    local context = { -- Program State, Context (Ctx)
        labels = {},
        containers = {},
        jump_prop = -1, -- for jumping to labels
        runif_prop = 0 -- for runifs
    }

    local j = 1
    while j <= #hots do -- Handling labels
        local hot = hots[j]

        if hot.sigil == '&' then
            if #hot.args == 1 and hot.args[1].type == 'Ident' then
                context.labels[hot.args[1].value] = j
            else
                Panic('InvalidLabelDefinition', j)
            end
        end

        j = j + 1
    end

    j = 1
    while j <= #hots do -- Handling execution
        local hot = hots[j]
        if context.runif_prop > 0 then
            context.runif_prop = context.runif_prop - 1
            j = j + 1
            goto uber_continue
        end
        if not next(hot) then goto continue end

        if Sigils[hot.sigil].min_args and #hot.args < Sigils[hot.sigil].min_args then
            Panic('NotEnoughSigilArguments', j)
        end

        if Sigils[hot.sigil].max_args and #hot.args > Sigils[hot.sigil].max_args then
            Panic('TooManySigilArguments', j)
        end

        context = Sigils[hot.sigil].callback(j, context, hot.args) or context

        ::continue::
        if context.jump_prop ~= -1 then
            j = context.jump_prop
            context.jump_prop = -1
        else
            j = j + 1
        end
        ::uber_continue::
    end
end
