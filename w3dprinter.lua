local shell = require("shell")

local args, options = shell.parse(...)

local function printUsage()
  print("Usage:")
  print("'w3dprinter' to show this message")
end
