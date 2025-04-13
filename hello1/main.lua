-- just a demo app
local textToPrint  = 'love2d studio\nCode, debug and test great games \nAll from you mobile devices'
local printedText  = ""
local bg = require('background')
local interval = 0.2
local typeTimer = interval
local typePosition = 0
local waitCycles = 20
local lg = love.graphics
local bG =

function love.load() 
  love.filesystem.createDirectory("a")
  love.filesystem.write("a/a.txt","hello")
  local content,size = love.filesystem.read("a/a.txt")
  print("content read from file:")
  print(content)
  local textFont = lg.newFont(32) 
  lg.setFont(textFont)
end

function love.update(dt)
	typeTimer = typeTimer - dt
	if typeTimer <= 0 then
		typeTimer = interval
		typePosition = typePosition + 1
      if typePosition >#textToPrint + waitCycles then
          typePosition = 0
      end

		printedText = string.sub(textToPrint,0,typePosition)
	end
end

function love.draw()
  bg.draw()
  lg.print(printedText,40,200)
end        
