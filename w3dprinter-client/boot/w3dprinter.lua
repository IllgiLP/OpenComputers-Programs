local vcomp = require("vcomponent")
local ser = require("serialization")
local fs = require("filesystem")
local shell = require("shell")
local event = require("event")

local work = function()
  local function readConfig(file)
    local done,fil = pcall(fs.open,file,"r");
    if not (done) then
      shell.execute("wget -f https://raw.githubusercontent.com/IllgiLP/OpenComputers-Programs/master/w3dprinter-client/etc/w3dprinter.cfg /etc/w3dprinter.cfg")
      return readConfig(file);
    end
    local content = fil:read("*a")
    local don,tbl = pcall(ser.unserialize,content)
    print("HIIIIIIII")
    if not (don) then
      shell.execute("wget -f https://raw.githubusercontent.com/IllgiLP/OpenComputers-Programs/master/w3dprinter-client/etc/w3dprinter.cfg /etc/w3dprinter.cfg")
      return readConfig(file);
    end
    return tbl;
  end

  --[[local proxy = {
  	test = function(something) return type(something) end
  }
  local docs = {
  	test = "function(value:something):string -- I do stuff."
  }
  vcomp.register("LALWZADDR","testcomp",proxy,docs)]]--

end

event.listen("init",work)
