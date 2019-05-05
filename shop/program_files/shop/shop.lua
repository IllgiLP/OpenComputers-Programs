local func = {}

local timerId = nil

local ser = require("serialization")
local compo = require("component")
local event = require("event")

local itemt = nil
local fluidts = {}

local itemtSides = {hopper = -1, dispenser = -1, chest = -1}

local function parseFile(file)
  local file = io.open(file,"r")
  return ser.unserialize(file:read("*a"))
end

local config = parseFile("/etc/shop.cfg")

local count = 0

local gpu = nil

local update = function()
  local stack = itemt.getStackInSlot(itemtSides.hopper,1)
  local x,y = gpu.getResolution()
  gpu.fill(1,1,x,y," ")
  if(stack ~= nil) then
    gpu.set(1,1,stack.name.." - "..stack.size)
  else
    gpu.set(1,1,"Kein Item!")
  end
end

local task = function()
  update()
end

local function setupTransposers()
  local setup = config.shop.setup
  local transps = setup.transposers
  itemt = compo.proxy(compo.get(transps.itemTransposer))
  for k,v in pairs(transps.fluidTransposers) do
    fluidts[k] = compo.proxy(compo.get(v))
  end

  for k,v in pairs(setup.itemTransposer) do
    itemtSides[k] = v
  end

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
      cgpu.setResolution(40,20)
      gpu = cgpu
    end
  end
end

func.start = function()
  if(timerId ~= nil) then
    return false
  else
    setupGPU()
    setupTransposers()
    timerId = event.timer(0.5,task,math.huge)
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
