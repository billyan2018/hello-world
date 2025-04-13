function love.load()
	 -- Define your game's base resolution
    local baseWidth, baseHeight = 800, 600

    -- Get the actual screen dimensions
    local screenWidth, screenHeight = love.graphics.getDimensions()

    -- Calculate scaling factors
    local scaleX = screenWidth / baseWidth
    local scaleY = screenHeight / baseHeight

    -- Apply scaling
    love.graphics.scale(scaleX, scaleY)
end

function love.conf(t)
    t.window.highdpi = true
end

function love.draw()
    -- Draw some text in the center of the screen
    love.graphics.print("Hello, Love2D!", 350, 280)
end