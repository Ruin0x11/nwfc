local nwfc = require("nwfc")

--- Returns the number of items in a dictionary-like table.
-- @tparam table tbl
-- @treturn int
function table.count(tbl)
   local count = 0
   for _, _ in pairs(tbl) do
      count = count + 1
   end
   return count
end

-- Returns the keys of a dictionary-like table.
-- @tparam table tbl
-- @treturn list
function table.keys(tbl)
   local arr = {}
   for k, _ in pairs(tbl) do
      arr[#arr + 1] = k
   end
   return arr
end

love.window.setMode(1024, 768, {borderless = true})

math.randomseed(os.time())

local imgData = love.image.newImageData("input/input_02.png")
local img = love.graphics.newImage(imgData)

local ow, oh = 100, 100

local samples = dofile("samples.xml.lua").samples

local function randomchoice(t)
   local keys = {}
   for key, value in pairs(t) do
      keys[#keys + 1] = key
   end
   local index = keys[math.random(1, #keys)]
   return t[index]
end

local name
local subset
local the_model
local imagedata

local function regen_simple_tiled()
   local s = randomchoice(samples.simpletiled)
   local path = "samples/" .. s.name
   local data = dofile(path .. "/data.xml.lua").set
   data.path = path

   name = s.name
   subset = s.subset or "(none)"
   the_model = nil

   local model = nwfc.newSimpleTiledModel(data, s.subset, s.width or 20, s.height or 20, s.periodic, s.black)
   model:run()

   imagedata = model:toImageData()
   return love.graphics.newImage(imagedata)
end

local function regen_overlapping(scale, all_at_once)
   scale = scale or 1
   local s = randomchoice(samples.overlapping)
   local path = "samples/" .. s.name .. ".png"
   local image = love.image.newImageData(path)

   name = s.name
   subset = s.subset or "(none)"

   if s.periodicInput == nil then
      s.periodicInput = true
   end

   local width = s.width or 48
   local height = s.height or 48

   local model = nwfc.newOverlappingModel(image, s.N or 2, width * scale, height * scale, s.periodicInput, s.periodic, s.symmetry or 8, s.ground or 0)
   if all_at_once then
      model:run()
   else
      the_model = model
      model:run(nil, 1, true)
   end
   imagedata = model:toImageData()
   return love.graphics.newImage(imagedata)
end

local image = regen_overlapping()

local speed = 20

love.keypressed = function(k)
   if k == "r" then
      image = regen_simple_tiled()
   elseif k == "o" then
      image = regen_overlapping()
   elseif k == "h" then
      image = regen_overlapping(5, true)
   elseif k == "=" then
      speed = math.min(speed + 5, 1000)
   elseif k == "-" then
      speed = math.max(speed - 5, speed)
   end
end

love.draw = function()
   love.graphics.setColor(1, 1, 1, 1)

   if the_model then
      the_model:run(nil, speed, true)
      imagedata = the_model:toImageData(imagedata)
      image:release()
      image = love.graphics.newImage(imagedata)
   end
   love.graphics.draw(image, 0, 0, 0)

   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.print(subset, 0, love.graphics.getHeight() - 14)
   love.graphics.print(name, 0, love.graphics.getHeight() - 14 * 2)
   love.graphics.print(("Speed: %d"):format(speed), 0, love.graphics.getHeight() - 14 * 3)
end
