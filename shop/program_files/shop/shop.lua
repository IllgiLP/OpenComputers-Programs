local func = {}

local timerId = nil

local ser = require("serialization")
local compo = require("component")
local event = require("event")

local function parseFile(file)
  local file = io.open(file,"r")
  return ser.unserialize(file:read("*a"))
end

local config = parseFile("/etc/shop.cfg")

local count = 0

local gpu = nil

local renderTask = function()
  gpu.set(1,1,"LOL: "..count)
  count = count +1
end

local function setupGPU()
  local graphics = config.graphics
  compo.setPrimary("gpu",compo.get(graphics.primaryGPU))
  local gpuScreens = graphics.gpuScreens

  for k,v in pairs(gpuScreens) do
    local cgpu = compo.proxy(compo.get(k))
    cgpu.bind(compo.get(v))
    if(k ~= graphics.primaryGPU) then
      local x,y = cgpu.getResolution()
      cgpu.fill(1,1,x,y," ")
      gpu = cgpu
    end
  end
end

func.start = function()
  if(timerId ~= nil) then
    return false
  else
    setupGPU()
    timerId = event.timer(0.5,renderTask,math.huge)
    return true
  end
end

func.stop = function()
  if(timerId == nil) then
    return false
  else
    event.cancel(timerId)
    timerId = nil
    return true
  end
end

func.isRunning = function()
  return timerId ~= nil
end

return func;
