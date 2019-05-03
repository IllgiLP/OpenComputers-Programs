local event = require("event")

local timerId = nil

function start()
  if(timerId ~= nil) then
    print("Already started!")
  else
    timerId = event.timer(0.5,function()
      print("HI")
     end)
  end
end

function stop()
  if(timerId == nil) then
    print("Not running!")
  else
    event.cancel(timerId)
    timerId = nil
  end
end

function status()
    if(timerId ~= nil) then
      print("Status: running")
    else
      print("Status: stopped")
    end
end

function restart()
  if(timerId == nil) then
    print("Not running!")
  else
    stop()
    start()
  end
end
