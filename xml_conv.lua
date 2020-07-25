local lxp = require("lxp")

local final = {}
local trail = {}

local callbacks = {
   StartElement = function(parser, name, attributes)
      local t = {}
      for k, v in pairs(attributes) do
         if type(k) == "string" then
            t[k] = v
         end
      end
      if final[name] then
         if not final[name][1] then
            final[name] = { final[name] }
         end
         table.insert(final[name], t)
      else
         final[name] = t
      end
      trail[#trail+1] = final
      final = t
   end,
   EndElement = function(parser, name)
      final = trail[#trail]
      trail[#trail] = nil
   end
}

local p = lxp.new(callbacks)

local file = arg[1]
assert(file, "usage: xml_conv.lua path/to/file.xml")
local f = assert(io.open(file))

for l in f:lines() do
   p:parse(l)
   p:parse("\n")
end
f:close()

p:parse()
p:close()

local inspect = require "inspect"

local o = assert(io.open(file .. ".lua", "w"))
o:write("return " .. inspect(final))
o:close()
