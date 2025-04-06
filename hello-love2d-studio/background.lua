local background = {}
local apiG = love.graphics

function background.draw() 
   local w, h = apiG.getDimensions()
   local r,g,b  = 100, 0, 185
	for y = 0, h do
      local t = y/h
      local red = r*(1-t) +255 * t
      local green = g*(1-t) + 255 *t
      local blue = b*(1-t)+ 255*t
      apiG.setColor(red/255, green/255, blue/255)
      apiG.line(0, y ,w, y)
 
	end
end

return background