local threadapi = require("thread")

local thread = nil

function start()
  if(thread ~= nil) then
    print("Already started!")
  else
    thread = threadapi.create(function()
        while true do
          os.sleep(2)
        end
     end)
  end
end

function stop()
  if(thread == nil) then
    print("Not running!")
  else
    thread:kill()
    thread = nil
  end
end

function status()
    if(thread ~= nil) then
      print("Status: "..thread:status())
    else
      print("Status: stopped")
    end
end

function restart()
  if(thread == nil) then
    print("Not running!")
  else
    stop()
    start()
  end
end
