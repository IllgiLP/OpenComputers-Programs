local event = require("event")

local shop = loadfile("/program_files/shop/shop.lua")()

function start()
  if(timerId ~= nil) then
    print("Already started!")
  else
    timerId = event.timer(0.5,function()
      print("HI")
    end,math.huge)
  end
  if(shop.isRunning()) then
    print("Already started!")
  else
    shop.start()
  end
end

function stop()
  if(timerId == nil) then
    print("Not running!")
  else
    event.cancel(timerId)
    timerId = nil
  end
  if not (shop.isRunning()) then
    print("Not running!")
  else
    shop.stop()
  end
end

function status()
    if(shop.isRunning()) then
      print("Status: running")
    else
      print("Status: stopped")
    end
end

function restart()
  if not (shop.isRunning()) then
    print("Not running!")
  else
    stop()
    start()
  end
end
