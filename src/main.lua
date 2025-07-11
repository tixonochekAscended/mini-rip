require('utils')
require('sigils')
require('lexer')
require('parser')
require('executor')

local function run()
    if #arg < 1 then Panic('NotEnoughArguments') end
    if arg[1] == 'license' then
        print([[mini-rip: A minimal programming language
        Copyright (C) 2025 tixonochek
    
        This program is free software: you can redistribute it and/or modify
        it under the terms of the GNU General Public License as published by
        the Free Software Foundation, either version 3 of the License, or
        (at your option) any later version.
    
        This program is distributed in the hope that it will be useful,
        but WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        GNU General Public License for more details.
    
        You should have received a copy of the GNU General Public License
        along with this program.  If not, see <https://www.gnu.org/licenses/>.]])
        os.exit(0)
    end
    local script = AttemptRead(arg[1])
    local lines = Lex(script)
    local horder_tokens = Parse(lines)

    Execute(horder_tokens)
end

run()
