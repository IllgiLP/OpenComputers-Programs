local func = {}

local timerId = nil

local ser = require("serialization")
local compo = require("component")
local event = require("event")
local sides = require("sides")

local itemt = nil
local fluidts = {}

local itemtSides = {hopper = -1, dispenser = -1, chest = -1}

local money = {}

local items = {}

local screen = {w=40,h=20}

local selectedItem = 0

local gpu = nil

local function parseFile(file)
  local file = io.open(file,"r")
  return ser.unserialize(file:read("*a"))
end

local config = parseFile("/etc/shop.cfg")

local buttons = {
  [1] = {
    name = "[Kaufen]",
    x=21,
    y=20,
    func = function()
      gpu.set(1,19,"Bitte warten...")
      local stack = itemt.getStackInSlot(itemtSides.hopper,1)
      if(stack ~= nil) then
        if(selectedItem > 0) then
          itemt.transferItem(itemtSides.hopper, itemtSides.chest, items[selectedItem].cost.amount)
          itemt.transferItem(itemtSides.hopper, itemtSides.dispenser, stack.size)
          local tpp = fluidts[items[selectedItem].tp.id]
          tpp.transferFluid(sides[items[selectedItem].tp.side],sides.top,config.shop.setup.fluid.glassSize)
        end
      end
    end
  },
  [2] = {
    name = "[Abbrechen]",
    x=30,
    y=20,
    func = function()
      gpu.set(1,19,"Bitte warten...")
      local stack = itemt.getStackInSlot(itemtSides.hopper,1)
      if(stack ~= nil) then
        itemt.transferItem(itemtSides.hopper, itemtSides.dispenser, stack.size)
      end
    end
  }
}

local update = function()
  for k,v in pairs(items) do
    local tpp = fluidts[v.tp.id]
    local level = tpp.getTankLevel(sides[v.tp.side],1)
    if(level >= config.shop.setup.fluid.glassSize) then
      v.enough = true
    else
      v.enough = false
    end
  end
end

local task = function()
  local ok, msg = xpcall(update)
  if not (ok) then
    print("Error in update: "..msg)
  end
  local stack = itemt.getStackInSlot(itemtSides.hopper,1)
  local x,y = gpu.getResolution()
  gpu.setBackground(0x000000)
  gpu.fill(1,1,x,y," ")

  if(stack == nil) then
    stack = {}
    stack.name = "minecraft:air"
    stack.size = 0
  end

  for k,v in pairs(items) do
    gpu.setBackground(0x000000)
    if (not ((stack.name == v.cost.type) and (stack.size >= v.cost.amount))) or not v.enough then
      gpu.fill(1,k,screen.w,1," ")
      v.red = true
      if(k == selectedItem) then
        selectedItem = 0
      end
    else
      v.red = false
    end
    gpu.set(1,k,string.format("[%s] %s",(selectedItem == k and "X" or " "), v.name..(v.enough and "" or " - Leer")))

    local costString = v.cost.amount.." "..money[v.cost.type].short
    if(v.red) then gpu.setBackground(0xFF0000) end
    gpu.setForeground(money[v.cost.type].color)
    gpu.set((screen.w)-(#costString-1),k,costString)
    gpu.setForeground(0xFFFFFF)
  end

  gpu.setBackground(0x000000)

  gpu.fill(1,18,40,1,"_")

  local costString = "Eingeworfen: "

  if(money[stack.name] ~= nil) then
    costString = costString..stack.size.." "..money[stack.name].short
    gpu.setForeground(money[stack.name].color)
  else
    costString = costString.."-"
    if(stack.size > 0) then
      itemt.transferItem(itemtSides.hopper, itemtSides.dispenser, stack.size)
    end
  end

  gpu.set((screen.w)-(#costString-1),19,costString)
  gpu.setForeground(0xFFFFFF)

  for k,v in pairs(buttons) do
    gpu.set(v.x,v.y,v.name)
  end
end

local onTouch = function(e,screen,x,y)
  if(screen == gpu.getScreen()) then
    if(y <= #items) then
      local i = items[y]
      if not (i.red) then
        gpu.set(1,19,"Bitte warten...")
        selectedItem = y
      end
    else
      for k,v in pairs(buttons) do
        if(y == v.y and (x >= v.x) and (x <= (v.x+#v.name))) then
          v.func()
        end
      end
    end
  end
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

local function setupMoney()
  local setup = config.shop.setup

  for k,v in pairs(setup.money) do
    money[k] = v
  end
end

local function setupItems()
  local cit = config.shop.items
  for k,v in pairs(cit) do
    items[k] = v
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
      cgpu.setResolution(screen.w,screen.h)
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
    setupMoney()
    setupItems()
    timerId = event.timer(0.5,task,math.huge)
    event.listen("touch",onTouch)
    return true
  end
end

func.stop = function()
  if(timerId == nil) then
    return false
  else
    event.cancel(timerId)
    timerId = nil
    event.ignore("touch",onTouch)
    return true
  end
end

func.isRunning = function()
  return timerId ~= nil
end

return func;
