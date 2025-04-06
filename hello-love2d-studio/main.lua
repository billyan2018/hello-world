local bg = require('background')
local path = "unknown"
function love.load()
		local data = "Hello, this is some data written to a file!"
    love.filesystem.write("myfile.txt", data)
    path = love.filesystem.getRealDirectory("myfile.txt")
    print()
end

function love.draw()
  bg.draw()
 
  love.graphics.print(path, 20, 20)
  myLowercasedVariable
  -- test
end
