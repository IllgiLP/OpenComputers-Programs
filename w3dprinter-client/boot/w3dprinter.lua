local vcomp = require("vcomponent")
local ser = require("serialization")
local fs = require("filesystem")
local shell = require("shell")
local event = require("event")
local internet = require("internet")

if(internet == nil) then
  return;
end
local function getContent(url)
  local sContent = ""
  local result, response = pcall(internet.request, url)
  if not result then
    return nil
  end
  for chunk in response do
    sContent = sContent..chunk
  end
  return sContent
end

local function writeToFile(file,content)
  local fil = fs.open(file,"w")
  fil:write(content)
  file:close()
end

local work = function()
  local function readConfig(file)
    local done,fil = pcall(fs.open,file,"r");
    local f = io.open("file1.txt","w")
    f:write(tostring(done).." - "..tostring(fil))
    f:close()
    if(done == nil) then
      writeToFile("/etc/w3dprinter.cfg",getContent("https://raw.githubusercontent.com/IllgiLP/OpenComputers-Programs/master/w3dprinter-client/etc/w3dprinter.cfg"))
      return readConfig(file);
    end
    local content = fil:read("*a")
    local don,tbl = pcall(ser.unserialize,content)
    f = io.open("file2.txt","w")
    f:write(tostring(don).." - "..tostring(tbl))
    f:close()
    if(don == nil) then
      writeToFile("/etc/w3dprinter.cfg",getContent("https://raw.githubusercontent.com/IllgiLP/OpenComputers-Programs/master/w3dprinter-client/etc/w3dprinter.cfg"))
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
