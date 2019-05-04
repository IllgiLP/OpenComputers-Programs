local event = require("event")

local shop = loadfile("/program_files/shop/shop.lua")()

function start()
  if(shop.isRunning()) then
    print("Already started!")
  else
    shop.start()
  end
end

function stop()
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
