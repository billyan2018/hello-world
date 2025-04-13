local console = require "console"
-- added helpful nativefs library to be able to utilize folders outside of save folder
nativefs = require "nativefs"
-- Slab is Gui for texteditor
Slab = require "Slab"

function love.run()
	if love.load then
		love.load(love.arg.parseGameArguments(arg), arg)
	end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then
		love.timer.step()
	end

	local dt = 0

	-- Main loop time.
	return function()
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				xpcall(function() love.handlers[name](a,b,c,d,e,f) end, handle_error)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then
			dt = love.timer.step()
		end

		-- Call update and draw
		if love.update then
			xpcall(function() love.update(dt) end, handle_error)
		end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())
			if love.draw then
				xpcall(love.draw, handle_error)
			end
			love.graphics.present()
		end

		if love.timer then
			love.timer.sleep(0.001)
		end
	end
end

function love.load()
	love.keyboard.setKeyRepeat(true)
	love.keyboard.setTextInput(true)

	-- global directory to save and read files from (iOS = sourceBaseDirectory = "Documents")
	SourceBaseDir = love.filesystem.getSourceBaseDirectory()

	-- global variables for Slab
	ButtonPressed = false
	InputText = "Write Code Here"
	SaveText = ""

	-- Slab.Initialize does many things to include changing Love Keyboard handler to reference its own OnKeyPressed() & Love textinput handler to reference its own callback TextInput() and calls LoadState() [saved Slab State];
	-- In addition, uses function (not callback) Keyboard.isPressed(key) instead of Love keyboard.isDown(key)
	-- Slab.IsKeyPressed(key) calls Keyboard.isPressed(key)
	Slab.Initialize(--[[args]] nil, --[[dontInterceptEventHandlers]] true)
	LineHeight = Slab.GetTextHeight()
	SyntaxHighlight = {["and"]={0,0,1},["end"]={0,0,1},["in"]={0,0,1},["repeat"]={0,0,1},["break"]={0,0,1},["false"]={0,0,1},["local"]={0,0,1},["return"]={0,0,1},["do"]={0,0,1},["for"]={0,0,1},["nil"]={0,0,1},["then"]={0,0,1},["else"]={0,0,1},["function"]={0,0,1},["not"]={0,0,1},["true"]={0,0,1},["elseif"]={0,0,1},["if"]={0,0,1},["or"]={0,0,1},["until"]={0,0,1},["while"]={0,0,1}}

	-- define a variable that will store graphics functions
	graphics = ""

	-- note: if want to run shaders in IDE: don't use callback function love.load; can use callbacks love.draw & love.update
	-- & setup shaders not all in one command but in parts e.g:
	-- glslScript = [[glslcode]]; myShader = love.graphics.newShader(glslScript);
	-- then in callback love.draw: love.graphics.setShader(myShader) love.graphics..[drawSomething] love.graphics.setShader()
	-- resets to standard Love shader

	-- save all MiniIDE handlers
	MiniIDE = {}
	MiniIDE.draw = love.draw
	MiniIDE.update = love.update
	MiniIDE_handlers = {}
	for name,_ in pairs(love.handlers) do
		MiniIDE_handlers[name] = love[name]
	end
end

function handle_error(err)
	Error_message = debug.traceback('Error: ' .. tostring(err), --[[stack frame]]2):gsub('\n[^\n]+$', '')
	print(Error_message)  -- save error to console
	-- reset MiniIDE state
	graphics = ""
	Slab.ResetFrame()
	-- restore all MiniIDE handlers
	love.draw = MiniIDE.draw
	love.update = MiniIDE.update
	for name,def in pairs(MiniIDE_handlers) do
		love[name] = def
	end
end

function love.keypressed(key, scancode, isrepeat)
	Slab.OnKeyPressed(key, scancode, isrepeat)
	if not(Slab.IsAnyInputFocused()) then console.keypressed(key, scancode, isrepeat) end
end

function love.update(dt)
	Slab.Update(dt)

	Slab.BeginWindow("EditorWindow",{Title = "TextEditor", AutoSizeWindow = false, X= ((love.graphics.getWidth()/2)-200), Y = 20, W= 400, H = 400, IsOpen = true})
	local W,H = Slab.GetWindowActiveSize()

	Slab.DisableDocks({"Left","Right","Bottom"})

	Slab.BeginLayout('ExpandableControls', {ExpandW = true})

	Slab.Text("Clipboard: Copy to (Control-c);     Paste from (Control-v)")

	if Slab.Button("Clear Editor") then
		ClearEditorButtonPressed = true
	end
	if ClearEditorButtonPressed then
		InputText = ""
		ClearEditorButtonPressed = false
	end

	Slab.SameLine()

	if Slab.Button("Clear Terminal") then
		ClearTerminalButtonPressed = true
	end
	if ClearTerminalButtonPressed then
		addText("clear")
		ClearTerminalButtonPressed = false
	end

	xpcall(function()

		--  Complicated Edit Box Setup: size in refernce to whole Window; Scale down height to
		--  Account for below edit box controls; have multiline wrap -10 from right edge
		if Slab.Input('EditBox',{Text = InputText, MultiLine = true, MultiLineW = W-10, W=W, H=H-(6*LineHeight), Highlight = SyntaxHighlight}) then
			InputText = Slab.GetInputText()
		end

	end,
	function(err)  -- on error
		print('could not load '..Selected..': '..err)
		InputText = ''  -- eliminate any confusion regarding which file we're editing
	end)

	if Slab.Button("Load") then
		LoadButtonPressed = true
	end
	if LoadButtonPressed and Selected then
		InputText = nativefs.read(SourceBaseDir.."/"..Selected)
		LoadButtonPressed = false
	end

	Slab.SameLine()

	if Slab.Button("Save") then
		SaveButtonPressed = true
	end
	if SaveButtonPressed and SaveText then
		nativefs.write(SourceBaseDir.."/"..SaveText,InputText)
		SaveButtonPressed = false
		message = "print('file: "..SaveText.." written')"
		addText(message)
	end

	Slab.SameLine()

	if Slab.Button("Run") then
		RunButtonPressed = true
	end
	if RunButtonPressed then
		graphics = ""
		addText(InputText)
		RunButtonPressed = false
	end

	Slab.SameLine()
	if Slab.Button("Stop Code") then
		StopCodeButtonPressed = true
	end
	if StopCodeButtonPressed then
		InputText = InputText.."\n".."function escape()".."\n\t".."error('StopScript')".."\n".."end"
		StopCodeButtonPressed = false
	end

	Slab.Text("Load Filename: ")

	Slab.SameLine()

	if Slab.BeginComboBox('filePicker',{Selected = Selected}) then
		for index,info in ipairs(nativefs.getDirectoryItemsInfo(SourceBaseDir)) do
			if info.type == 'file' then
				if Slab.TextSelectable(info.name) then
					Selected = info.name
				end
			end
		end
		Slab.EndComboBox()
	end

	Slab.SameLine()

	Slab.Text("Save Filename: ")

	Slab.SameLine()

	if Slab.Input("writeFileName",{Text=SaveText}) then
		SaveText = Slab.GetInputText()
	end

	Slab.EndLayout()

	Slab.EndWindow()
end

function love.draw()
  console.draw()
  Slab.Draw()
  love.graphics.setColor(1,1,1)
  graphicsFxn = load(graphics)
-- next line changes the environment that graphicsFxn runs in so can access variables
-- from that were created in the console.ENV
  setfenv(graphicsFxn,console.ENV)
  graphicsFxn()
end

function addText(text)
	console.addHistory(text)
	console.execute(text)
end

function love.quit()
	Slab.OnQuit()
end

function love.keyreleased(key, scancode)
	Slab.OnKeyReleased(key, scancode)
end

function love.textinput(text)
	Slab.OnTextInput(text)
end

function love.wheelmoved(x, y)
	Slab.OnWheelMoved(x, y)
end

function love.mousemoved(x, y, dx, dy, istouch)
	Slab.OnMouseMoved(x, y, dx, dy, istouch)
end

function love.mousepressed( x, y, button, istouch, presses)
	Slab.OnMousePressed( x, y, button, istouch, presses)
end

function love.mousereleased( x, y, button, istouch, presses)
	Slab.OnMouseReleased( x, y, button, istouch, presses)
end
