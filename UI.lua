-- venyx ui lib reuploaded by me
-- init
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- services
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")
local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new

-- additional
local utility = {}
local Buttons = {}

-- themes
local objects = {}
local themes = {
	Background = Color3.fromRGB(24, 24, 24), 
	Glow = Color3.fromRGB(0, 0, 0), 
	Accent = Color3.fromRGB(10, 10, 10), 
	LightContrast = Color3.fromRGB(20, 20, 20), 
	DarkContrast = Color3.fromRGB(14, 14, 14),  
	TextColor = Color3.fromRGB(255, 255, 255)
}

function SetButtonsVisibility(Visible)
	for i,v in ipairs(Buttons) do
		v.Visible = Visible
	end
end

function ProtectGUI(GUI)
	if syn then syn.protect_gui(GUI) return end
	if gethui then GUI.Parent = gethui() return end
    GUI.Parent = get_hidden_gui()
end

function round(number,decimals)
	return math.round(number * 10^decimals) * 10^-decimals
end

function GetDecimalPlaces(number)
	local tmp = string.split(tostring(number),".")
	if (tmp[2] ~= nil) then
		return #(tmp[2])
	end
	return 1
end

function betterRemove(tbl,value)
	for i,v in ipairs(tbl) do
		if v == value then
			table.remove(tbl,i)
		end
	end
end

do
	function utility:Create(instance, properties, children)
		local object = Instance.new(instance)

		if instance == "ScreenGui" then ProtectGUI(object) end
		
		for i, v in pairs(properties or {}) do
			object[i] = v
			
			if typeof(v) == "Color3" then -- save for theme changer later
				local theme = utility:Find(themes, v)
				
				if theme then
					objects[theme] = objects[theme] or {}
					objects[theme][i] = objects[theme][i] or setmetatable({}, {_mode = "k"})
					
					table.insert(objects[theme][i], object)
				end
			end
		end
		
		for i, module in pairs(children or {}) do
			module.Parent = object
		end
		
		return object
	end
	
	function utility:Tween(instance, properties, duration, ...)
		tween:Create(instance, tweeninfo(duration, ...), properties):Play()
	end
	
	function utility:Wait()
		run.RenderStepped:Wait()
		return true
	end
	
	function utility:Find(table, value) -- table.find doesn't work for dictionaries
		for i, v in  pairs(table) do
			if v == value then
				return i
			end
		end
	end
	
	function utility:Sort(pattern, values)
		local new = {}
		pattern = pattern:lower()
		
		if pattern == "" then
			return values
		end
		
		for i, value in pairs(values) do
			if tostring(value):lower():find(pattern) then
				table.insert(new, value)
			end
		end
		
		return new
	end
	
	function utility:Pop(object, shrink)
		local clone = object:Clone()
		
		clone.AnchorPoint = Vector2.new(0.5, 0.5)
		clone.Size = clone.Size - UDim2.new(0, shrink, 0, shrink)
		clone.Position = UDim2.new(0.5, 0, 0.5, 0)
		
		clone.Parent = object
		clone:ClearAllChildren()
		
		object.ImageTransparency = 1
		utility:Tween(clone, {Size = object.Size}, 0.2)
		
		spawn(function()
			wait(0.2)
		
			object.ImageTransparency = 0
			clone:Destroy()
		end)
		
		return clone
	end
	
	function utility:InitializeKeybind()
		self.keybinds = {}
		self.ended = {}
		
		input.InputBegan:Connect(function(key,proc)
			if self.keybinds[key.KeyCode] and not proc then
				for i, bind in pairs(self.keybinds[key.KeyCode]) do
					bind()
				end
			end
		end)
		
		input.InputEnded:Connect(function(key)
			if key.UserInputType == Enum.UserInputType.MouseButton1 then
				for i, callback in pairs(self.ended) do
					callback()
				end
			end
		end)
	end
	
	function utility:BindToKey(key, callback)
		 
		self.keybinds[key] = self.keybinds[key] or {}
		
		table.insert(self.keybinds[key], callback)
		
		return {
			UnBind = function()
				for i, bind in pairs(self.keybinds[key]) do
					if bind == callback then
						table.remove(self.keybinds[key], i)
					end
				end
			end
		}
	end
	
	function utility:KeyPressed() -- yield until next key is pressed
		local key = input.InputBegan:Wait()
		
		while key.UserInputType ~= Enum.UserInputType.Keyboard	 do
			key = input.InputBegan:Wait()
		end
		
		wait() -- overlapping connection
		
		return key
	end
	
	function utility:DraggingEnabled(frame, parent)
	
		parent = parent or frame
		
		-- stolen from wally or kiriot, kek
		local dragging = false
		local dragInput, mousePos, framePos

		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				mousePos = input.Position
				framePos = parent.Position
				
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		frame.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				dragInput = input
			end
		end)

		input.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - mousePos
				parent.Position  = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
			end
		end)

	end
	
	function utility:DraggingEnded(callback)
		table.insert(self.ended, callback)
	end
	
end

-- classes

local library = {} -- main
local page = {}
local section = {}

do
	library.__index = library
	page.__index = page
	section.__index = section
	
	-- new classes
	
	function library.new(title)
		local container = utility:Create("ScreenGui", {
			Name = title,
			Parent = game.CoreGui
		}, {
			utility:Create("ImageLabel", {
				Name = "Main",
				BackgroundTransparency = 1,
				Position = UDim2.new(0.25, 0, 0.052435593, 0),
				Size = UDim2.new(0, 511, 0, 428),
				Image = "rbxassetid://4641149554",
				ImageColor3 = themes.Background,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(4, 4, 296, 296)
			}, {
				utility:Create("ImageLabel", {
					Name = "Glow",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, -15, 0, -15),
					Size = UDim2.new(1, 30, 1, 30),
					ZIndex = 0,
					Image = "rbxassetid://5028857084",
					ImageColor3 = themes.Glow,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(24, 24, 276, 276)
				}),
				utility:Create("ImageLabel", {
					Name = "Pages",
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					Position = UDim2.new(0, 0, 0, 38),
					Size = UDim2.new(0, 126, 1, -38),
					ZIndex = 3,
					Image = "rbxassetid://5012534273",
					ImageColor3 = themes.DarkContrast,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(4, 4, 296, 296)
				}, {
					utility:Create("ScrollingFrame", {
						Name = "Pages_Container",
						Active = true,
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 0, 0, 10),
						Size = UDim2.new(1, 0, 1, -20),
						CanvasSize = UDim2.new(0, 0, 0, 314),
						ScrollBarThickness = 0
					}, {
						utility:Create("UIListLayout", {
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, 10)
						})
					})
				}),
				utility:Create("ImageLabel", {
					Name = "TopBar",
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					Size = UDim2.new(1, 0, 0, 38),
					ZIndex = 5,
					Image = "rbxassetid://4595286933",
					ImageColor3 = themes.Accent,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(4, 4, 296, 296)
				}, {
					utility:Create("TextLabel", { -- title
						Name = "Title",
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 12, 0, 19),
						Size = UDim2.new(1, -46, 0, 16),
						ZIndex = 5,
						Font = Enum.Font.GothamBold,
						Text = title,
						TextColor3 = themes.TextColor,
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left
					})
				})
			})
		})
		
		utility:InitializeKeybind()
		utility:DraggingEnabled(container.Main.TopBar, container.Main)
		
		return setmetatable({
			container = container,
			pagesContainer = container.Main.Pages.Pages_Container,
			pages = {}
		}, library)
	end
	
	function page.new(library, title, icon)
		local button = utility:Create("TextButton", {
			Name = title,
			Parent = library.pagesContainer,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 26),
			ZIndex = 3,
			AutoButtonColor = false,
			Font = Enum.Font.Gotham,
			Text = "",
			TextSize = 14
		}, {
			utility:Create("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 40, 0.5, 0),
				Size = UDim2.new(0, 76, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 12,
				TextTransparency = 0.65,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			icon and utility:Create("ImageLabel", {
                Name = "Icon", 
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                ZIndex = 3,
                Image = "rbxassetid://" .. tostring(icon),
                ImageColor3 = themes.TextColor,
                ImageTransparency = 0.64
            }) or {}
		})
		
		local container = utility:Create("ScrollingFrame", {
			Name = title,
			Parent = library.container.Main,
			Active = true,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 134, 0, 46),
			Size = UDim2.new(1, -142, 1, -56),
			CanvasSize = UDim2.new(0, 0, 0, 466),
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = themes.DarkContrast,
			Visible = false
		}, {
			utility:Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 10)
			})
		})
		
		return setmetatable({
			library = library,
			container = container,
			button = button,
			sections = {}
		}, page)
	end
	
	function section.new(page, title)
		local container = utility:Create("ImageLabel", {
			Name = title,
			Parent = page.container,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -10, 0, 28),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.LightContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(4, 4, 296, 296),
			ClipsDescendants = true
		}, {
			utility:Create("Frame", {
				Name = "Container",
				Active = true,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 8, 0, 8),
				Size = UDim2.new(1, -16, 1, -16)
			}, {
				utility:Create("TextLabel", {
					Name = "Title",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 20),
					ZIndex = 2,
					Font = Enum.Font.GothamSemibold,
					Text = title,
					TextColor3 = themes.TextColor,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTransparency = 1
				}),
				utility:Create("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 4)
				})
			})
		})
		
		return setmetatable({
			page = page,
			container = container.Container,
			colorpickers = {},
			modules = {},
			binds = {},
			lists = {},
		}, section) 
	end
	
	function library:addPage(...)
	
		local page = page.new(self, ...)
		local button = page.button
		
		table.insert(self.pages, page)

		button.MouseButton1Click:Connect(function()
			self:SelectPage(page, true)
		end)
		
		return page
	end
	
	function page:addSection(...)
		local section = section.new(self, ...)
		
		table.insert(self.sections, section)
		
		return section
	end
	
	-- functions
	
	function library:setTheme(theme, color3)
		themes[theme] = color3
		
		for property, objects in pairs(objects[theme]) do
			for i, object in pairs(objects) do
				if not object.Parent or (object.Name == "Button" and object.Parent.Name == "ColorPicker") then
					objects[i] = nil -- i can do this because weak tables :D
				else
					object[property] = color3
				end
			end
		end
	end
	
	function library:toggle()
	
		if self.toggling then
			return
		end
		
		self.toggling = true
		
		local container = self.container.Main
		local topbar = container.TopBar
		
		if self.position then
			
			SetButtonsVisibility(true)
			utility:Tween(container, {
				Size = UDim2.new(0, 511, 0, 428),
				Position = self.position
			}, 0.2)
			wait(0.2)
			
			utility:Tween(topbar, {Size = UDim2.new(1, 0, 0, 38)}, 0.2)
			wait(0.2)
			
			container.ClipsDescendants = false
			self.position = nil
		else
			SetButtonsVisibility(false)
			self.position = container.Position
			container.ClipsDescendants = true
			
			utility:Tween(topbar, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)
			wait(0.2)
			
			utility:Tween(container, {
				Size = UDim2.new(0, 511, 0, 0),
				Position = self.position + UDim2.new(0, 0, 0, 428)
			}, 0.2)
			wait(0.2)
		end
		
		self.toggling = false
	end
	
	-- new modules
	
	function library:Notify(title, text, callback)
	
		-- overwrite last notification
		if self.activeNotification then
			self.activeNotification = self.activeNotification()
		end
		
		-- standard create
		local notification = utility:Create("ImageLabel", {
			Name = "Notification",
			Parent = self.container,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 200, 0, 60),
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.Background,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(4, 4, 296, 296),
			ZIndex = 3,
			ClipsDescendants = true
		}, {
			utility:Create("ImageLabel", {
				Name = "Flash",
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Image = "rbxassetid://4641149554",
				ImageColor3 = themes.TextColor,
				ZIndex = 5
			}),
			utility:Create("ImageLabel", {
				Name = "Glow",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, -15, 0, -15),
				Size = UDim2.new(1, 30, 1, 30),
				ZIndex = 2,
				Image = "rbxassetid://5028857084",
				ImageColor3 = themes.Glow,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(24, 24, 276, 276)
			}),
			utility:Create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 8),
				Size = UDim2.new(1, -40, 0, 16),
				ZIndex = 4,
				Font = Enum.Font.GothamSemibold,
				TextColor3 = themes.TextColor,
				TextSize = 14.000,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("TextLabel", {
				Name = "Text",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 1, -24),
				Size = UDim2.new(1, -40, 0, 16),
				ZIndex = 4,
				Font = Enum.Font.Gotham,
				TextColor3 = themes.TextColor,
				TextSize = 12.000,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("ImageButton", {
				Name = "Accept",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -26, 0, 8),
				Size = UDim2.new(0, 16, 0, 16),
				Image = "rbxassetid://5012538259",
				ImageColor3 = themes.TextColor,
				ZIndex = 4
			}),
			utility:Create("ImageButton", {
				Name = "Decline",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -26, 1, -24),
				Size = UDim2.new(0, 16, 0, 16),
				Image = "rbxassetid://5012538583",
				ImageColor3 = themes.TextColor,
				ZIndex = 4
			})
		})
		
		-- dragging
		utility:DraggingEnabled(notification)
		
		-- position and size
		title = title or "Notification"
		text = text or ""
		
		notification.Title.Text = title
		notification.Text.Text = text
		
		local padding = 10
		local textSize = game:GetService("TextService"):GetTextSize(text, 12, Enum.Font.Gotham, Vector2.new(math.huge, 16))
		
		notification.Position = library.lastNotification or UDim2.new(0, padding, 1, -(notification.AbsoluteSize.Y + padding))
		notification.Size = UDim2.new(0, 0, 0, 60)
		
		utility:Tween(notification, {Size = UDim2.new(0, textSize.X + 70, 0, 60)}, 0.2)
		wait(0.2)
		
		notification.ClipsDescendants = false
		utility:Tween(notification.Flash, {
			Size = UDim2.new(0, 0, 0, 60),
			Position = UDim2.new(1, 0, 0, 0)
		}, 0.2)
		
		-- callbacks
		local active = true
		local close = function()
		
			if not active then
				return
			end
			
			active = false
			notification.ClipsDescendants = true
			
			library.lastNotification = notification.Position
			notification.Flash.Position = UDim2.new(0, 0, 0, 0)
			utility:Tween(notification.Flash, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)
			
			wait(0.2)
			utility:Tween(notification, {
				Size = UDim2.new(0, 0, 0, 60),
				Position = notification.Position + UDim2.new(0, textSize.X + 70, 0, 0)
			}, 0.2)
			
			wait(0.2)
			notification:Destroy()
		end
		
		self.activeNotification = close
		
		notification.Accept.MouseButton1Click:Connect(function()
		
			if not active then 
				return
			end
			
			if callback then
				callback(true)
			end
			
			close()
		end)
		
		notification.Decline.MouseButton1Click:Connect(function()
		
			if not active then 
				return
			end
			
			if callback then
				callback(false)
			end
			
			close()
		end)
	end
	
	function section:addButton(title, callback)
		local button = utility:Create("ImageButton", {
			Name = "Button",
			Parent = self.container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.DarkContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298),
			Modal = true
		}, {
			utility:Create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 12,
				TextTransparency = 0.10000000149012
			})
		})
		table.insert(Buttons,button)
		table.insert(self.modules, button)
		--self:Resize()
		
		local text = button.Title
		local debounce
		
		button.MouseButton1Click:Connect(function()
			
			if debounce then
				return
			end
			
			-- animation
			utility:Pop(button, 10)
			
			debounce = true
			text.TextSize = 0
			utility:Tween(button.Title, {TextSize = 14}, 0.2)
			
			wait(0.2)
			utility:Tween(button.Title, {TextSize = 12}, 0.2)
			
			if callback then
				callback(function(...)
					self:updateButton(button, ...)
				end)
			end
			
			debounce = false
		end)
		
		return button
	end
	
	function section:addLabel(text,size,alignX,alignY)
		local label = utility:Create("TextLabel", {
			Name = "Label",
			Parent = self.container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,
			Font = Enum.Font.Gotham,
			Text = text,
			TextColor3 = themes.TextColor,
			TextSize = (size == nil and 12 or size),
			TextTransparency = 0.10000000149012
		})

		label.TextXAlignment = (alignX == nil and Enum.TextXAlignment.Center or alignX)
		label.TextYAlignment = (alignY == nil and Enum.TextYAlignment.Center or alignY)

		table.insert(self.modules, label)
		--self:Resize()
		
		return label
	end

	function section:addToggle(title, default, callback)
		local toggle = utility:Create("ImageButton", {
			Name = "Toggle",
			Parent = self.container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.DarkContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		},{
			utility:Create("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0.5, 1),
				Size = UDim2.new(0.5, 0, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 12,
				TextTransparency = 0.10000000149012,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("ImageLabel", {
				Name = "Button",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -50, 0.5, -8),
				Size = UDim2.new(0, 40, 0, 16),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.LightContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("ImageLabel", {
					Name = "Frame",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 2, 0.5, -6),
					Size = UDim2.new(1, -22, 1, -4),
					ZIndex = 2,
					Image = "rbxassetid://5028857472",
					ImageColor3 = themes.TextColor,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2, 2, 298, 298)
				})
			})
		})
		
		table.insert(self.modules, toggle)
		--self:Resize()
		
		local active = default
		self:updateToggle(toggle, nil, active)
		
		callback(active)

		toggle.MouseButton1Click:Connect(function()
			active = not active
			self:updateToggle(toggle, nil, active)
			
			if callback then
				callback(active, function(...)
					self:updateToggle(toggle, ...)
				end)
			end
		end)
		
		return toggle,callback
	end
	
	function section:addTextbox(title, default, callback)
		local textbox = utility:Create("ImageButton", {
			Name = "Textbox",
			Parent = self.container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.DarkContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		}, {
			utility:Create("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0.5, 1),
				Size = UDim2.new(0.5, 0, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 12,
				TextTransparency = 0.10000000149012,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("ImageLabel", {
				Name = "Button",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -110, 0.5, -8),
				Size = UDim2.new(0, 100, 0, 16),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.LightContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("TextBox", {
					Name = "Textbox", 
					BackgroundTransparency = 1,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Position = UDim2.new(0, 5, 0, 0),
					Size = UDim2.new(1, -10, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.GothamSemibold,
					Text = default or "",
					TextColor3 = themes.TextColor,
					TextSize = 11
				})
			})
		})
		
		table.insert(self.modules, textbox)
		--self:Resize()
		
		local button = textbox.Button
		local input = button.Textbox
		
		textbox.MouseButton1Click:Connect(function()
		
			if textbox.Button.Size ~= UDim2.new(0, 100, 0, 16) then
				return
			end
			
			utility:Tween(textbox.Button, {
				Size = UDim2.new(0, 200, 0, 16),
				Position = UDim2.new(1, -210, 0.5, -8)
			}, 0.2)
			
			wait()

			input.TextXAlignment = Enum.TextXAlignment.Left
			input:CaptureFocus()
		end)
		
		input:GetPropertyChangedSignal("Text"):Connect(function()
			
			if button.ImageTransparency == 0 and (button.Size == UDim2.new(0, 200, 0, 16) or button.Size == UDim2.new(0, 100, 0, 16)) then -- i know, i dont like this either
				utility:Pop(button, 10)
			end
			
			if callback then
				callback(input.Text, nil, function(...)
					self:updateTextbox(textbox, ...)
				end)
			end
		end)
		
		input.FocusLost:Connect(function()
			
			input.TextXAlignment = Enum.TextXAlignment.Center
			
			utility:Tween(textbox.Button, {
				Size = UDim2.new(0, 100, 0, 16),
				Position = UDim2.new(1, -110, 0.5, -8)
			}, 0.2)
			
			if callback then
				callback(input.Text, true, function(...)
					self:updateTextbox(textbox, ...)
				end)
			end
		end)
		
		return textbox
	end
	
	function section:addKeybind(title, default, callback, changedCallback)
		local keybind = utility:Create("ImageButton", {
			Name = "Keybind",
			Parent = self.container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.DarkContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		}, {
			utility:Create("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0.5, 1),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 12,
				TextTransparency = 0.10000000149012,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("ImageLabel", {
				Name = "Button",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -110, 0.5, -8),
				Size = UDim2.new(0, 100, 0, 16),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.LightContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("TextLabel", {
					Name = "Text",
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.GothamSemibold,
					Text = default and default.Name or "None",
					TextColor3 = themes.TextColor,
					TextSize = 11
				})
			})
		})
		
		table.insert(self.modules, keybind)
		--self:Resize()
		
		local text = keybind.Button.Text
		local button = keybind.Button
		
		local animate = function()
			if button.ImageTransparency == 0 then
				utility:Pop(button, 10)
			end
		end
		
		self.binds[keybind] = {callback = function()
			animate()
			
			if callback then
				callback(function(...)
					self:updateKeybind(keybind, ...)
				end)
			end
		end}
		
		if default and callback then
			self:updateKeybind(keybind, nil, default)
		end
		
		keybind.MouseButton1Click:Connect(function()
			
			animate()
			
			if self.binds[keybind].connection then -- unbind
				return self:updateKeybind(keybind)
			end
			
			if text.Text == "None" then -- new bind
				text.Text = "..."
				
				local key = utility:KeyPressed()
				
				self:updateKeybind(keybind, nil, key.KeyCode)
				animate()
				
				if changedCallback then
					changedCallback(key, function(...)
						self:updateKeybind(keybind, ...)
					end)
				end
			end
		end)
		
		return keybind
	end
	
	function section:addColorPicker(title, default, callback)
		local colorpicker = utility:Create("ImageButton", {
			Name = "ColorPicker",
			Parent = self.container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.DarkContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		},{
			utility:Create("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0.5, 1),
				Size = UDim2.new(0.5, 0, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 12,
				TextTransparency = 0.10000000149012,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("ImageButton", {
				Name = "Button",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -50, 0.5, -7),
				Size = UDim2.new(0, 40, 0, 14),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = Color3.fromRGB(255, 255, 255),
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			})
		})
		
		local tab = utility:Create("ImageLabel", {
			Name = "ColorPicker",
			Parent = self.page.library.container,
			BackgroundTransparency = 1,
			Position = UDim2.new(0.75, 0, 0.400000006, 0),
			Selectable = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(0, 162, 0, 169),
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.Background,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298),
			Visible = false,
		}, {
			utility:Create("ImageLabel", {
				Name = "Glow",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, -15, 0, -15),
				Size = UDim2.new(1, 30, 1, 30),
				ZIndex = 0,
				Image = "rbxassetid://5028857084",
				ImageColor3 = themes.Glow,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(22, 22, 278, 278)
			}),
			utility:Create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 8),
				Size = UDim2.new(1, -40, 0, 16),
				ZIndex = 2,
				Font = Enum.Font.GothamSemibold,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("ImageButton", {
				Name = "Close",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -26, 0, 8),
				Size = UDim2.new(0, 16, 0, 16),
				ZIndex = 2,
				Image = "rbxassetid://5012538583",
				ImageColor3 = themes.TextColor
			}), 
			utility:Create("Frame", {
				Name = "Container",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 8, 0, 32),
				Size = UDim2.new(1, -18, 1, -40)
			}, {
				utility:Create("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 6)
				}),
				utility:Create("ImageButton", {
					Name = "Canvas",
					BackgroundTransparency = 1,
					BorderColor3 = themes.LightContrast,
					Size = UDim2.new(1, 0, 0, 60),
					AutoButtonColor = false,
					Image = "rbxassetid://5108535320",
					ImageColor3 = Color3.fromRGB(255, 0, 0),
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2, 2, 298, 298)
				}, {
					utility:Create("ImageLabel", {
						Name = "White_Overlay",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 60),
						Image = "rbxassetid://5107152351",
						SliceCenter = Rect.new(2, 2, 298, 298)
					}),
					utility:Create("ImageLabel", {
						Name = "Black_Overlay",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 60),
						Image = "rbxassetid://5107152095",
						SliceCenter = Rect.new(2, 2, 298, 298)
					}),
					utility:Create("ImageLabel", {
						Name = "Cursor",
						BackgroundColor3 = themes.TextColor,
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1.000,
						Size = UDim2.new(0, 10, 0, 10),
						Position = UDim2.new(0, 0, 0, 0),
						Image = "rbxassetid://5100115962",
						SliceCenter = Rect.new(2, 2, 298, 298)
					})
				}),
				utility:Create("ImageButton", {
					Name = "Color",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 0, 4),
					Selectable = false,
					Size = UDim2.new(1, 0, 0, 16),
					ZIndex = 2,
					AutoButtonColor = false,
					Image = "rbxassetid://5028857472",
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2, 2, 298, 298)
				}, {
					utility:Create("Frame", {
						Name = "Select",
						BackgroundColor3 = themes.TextColor,
						BorderSizePixel = 1,
						Position = UDim2.new(1, 0, 0, 0),
						Size = UDim2.new(0, 2, 1, 0),
						ZIndex = 2
					}),
					utility:Create("UIGradient", { -- rainbow canvas
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)), 
							ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)), 
							ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)), 
							ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)), 
							ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)), 
							ColorSequenceKeypoint.new(0.82, Color3.fromRGB(255, 0, 255)), 
							ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
						})
					})
				}),
				utility:Create("Frame", {
					Name = "Inputs",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 158),
					Size = UDim2.new(1, 0, 0, 16)
				}, {
					utility:Create("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 6)
					}),
					utility:Create("ImageLabel", {
						Name = "R",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(0.305, 0, 1, 0),
						ZIndex = 2,
						Image = "rbxassetid://5028857472",
						ImageColor3 = themes.DarkContrast,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(2, 2, 298, 298)
					}, {
						utility:Create("TextLabel", {
							Name = "Text",
							BackgroundTransparency = 1,
							Size = UDim2.new(0.400000006, 0, 1, 0),
							ZIndex = 2,
							Font = Enum.Font.Gotham,
							Text = "R:",
							TextColor3 = themes.TextColor,
							TextSize = 10.000
						}),
						utility:Create("TextBox", {
							Name = "Textbox",
							BackgroundTransparency = 1,
							Position = UDim2.new(0.300000012, 0, 0, 0),
							Size = UDim2.new(0.600000024, 0, 1, 0),
							ZIndex = 2,
							Font = Enum.Font.Gotham,
							PlaceholderColor3 = themes.DarkContrast,
							Text = "255",
							TextColor3 = themes.TextColor,
							TextSize = 10.000
						})
					}),
					utility:Create("ImageLabel", {
						Name = "G",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(0.305, 0, 1, 0),
						ZIndex = 2,
						Image = "rbxassetid://5028857472",
						ImageColor3 = themes.DarkContrast,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(2, 2, 298, 298)
					}, {
						utility:Create("TextLabel", {
							Name = "Text",
							BackgroundTransparency = 1,
							ZIndex = 2,
							Size = UDim2.new(0.400000006, 0, 1, 0),
							Font = Enum.Font.Gotham,
							Text = "G:",
							TextColor3 = themes.TextColor,
							TextSize = 10.000
						}),
						utility:Create("TextBox", {
							Name = "Textbox",
							BackgroundTransparency = 1,
							Position = UDim2.new(0.300000012, 0, 0, 0),
							Size = UDim2.new(0.600000024, 0, 1, 0),
							ZIndex = 2,
							Font = Enum.Font.Gotham,
							Text = "255",
							TextColor3 = themes.TextColor,
							TextSize = 10.000
						})
					}),
					utility:Create("ImageLabel", {
						Name = "B",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(0.305, 0, 1, 0),
						ZIndex = 2,
						Image = "rbxassetid://5028857472",
						ImageColor3 = themes.DarkContrast,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(2, 2, 298, 298)
					}, {
						utility:Create("TextLabel", {
							Name = "Text",
							BackgroundTransparency = 1,
							Size = UDim2.new(0.400000006, 0, 1, 0),
							ZIndex = 2,
							Font = Enum.Font.Gotham,
							Text = "B:",
							TextColor3 = themes.TextColor,
							TextSize = 10.000
						}),
						utility:Create("TextBox", {
							Name = "Textbox",
							BackgroundTransparency = 1,
							Position = UDim2.new(0.300000012, 0, 0, 0),
							Size = UDim2.new(0.600000024, 0, 1, 0),
							ZIndex = 2,
							Font = Enum.Font.Gotham,
							Text = "255",
							TextColor3 = themes.TextColor,
							TextSize = 10.000
						})
					}),
				}),
				utility:Create("ImageButton", {
					Name = "Button",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 20),
					ZIndex = 2,
					Image = "rbxassetid://5028857472",
					ImageColor3 = themes.DarkContrast,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2, 2, 298, 298)
				}, {
					utility:Create("TextLabel", {
						Name = "Text",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						ZIndex = 3,
						Font = Enum.Font.Gotham,
						Text = "Submit",
						TextColor3 = themes.TextColor,
						TextSize = 11.000
					})
				})
			})
		})
		
		utility:DraggingEnabled(tab)
		table.insert(self.modules, colorpicker)
		--self:Resize()
		
		local allowed = {
			[""] = true
		}
		
		local canvas = tab.Container.Canvas
		local color = tab.Container.Color
		
		local canvasSize, canvasPosition = canvas.AbsoluteSize, canvas.AbsolutePosition
		local colorSize, colorPosition = color.AbsoluteSize, color.AbsolutePosition
		
		local draggingColor, draggingCanvas
		
		local color3 = default or Color3.fromRGB(255, 255, 255)
		local hue, sat, brightness = 0, 0, 1
		local rgb = {
			r = 255,
			g = 255,
			b = 255
		}
		
		self.colorpickers[colorpicker] = {
			tab = tab,
			callback = function(prop, value)
				rgb[prop] = value
				hue, sat, brightness = Color3.toHSV(Color3.fromRGB(rgb.r, rgb.g, rgb.b))
			end
		}
		
		local callback = function(value)
			if callback then
				callback(value, function(...)
					self:updateColorPicker(colorpicker, ...)
				end)
			end
		end
		
		callback(color3)

		utility:DraggingEnded(function()
			draggingColor, draggingCanvas = false, false
		end)
		
		if default then
			self:updateColorPicker(colorpicker, nil, default)
			
			hue, sat, brightness = Color3.toHSV(default)
			default = Color3.fromHSV(hue, sat, brightness)
			
			for i, prop in pairs({"r", "g", "b"}) do
				rgb[prop] = default[prop:upper()] * 255
			end
		end
		
		for i, container in pairs(tab.Container.Inputs:GetChildren()) do
			if container:IsA("ImageLabel") then
				local textbox = container.Textbox
				local focused
				
				textbox.Focused:Connect(function()
					focused = true
				end)
				
				textbox.FocusLost:Connect(function()
					focused = false
					
					if not tonumber(textbox.Text) then
						textbox.Text = math.floor(rgb[container.Name:lower()])
					end
				end)
				
				textbox:GetPropertyChangedSignal("Text"):Connect(function()
					local text = textbox.Text
					
					if not allowed[text] and not tonumber(text) then
						textbox.Text = text:sub(1, #text - 1)
					elseif focused and not allowed[text] then
						rgb[container.Name:lower()] = math.clamp(tonumber(textbox.Text), 0, 255)
						
						local color3 = Color3.fromRGB(rgb.r, rgb.g, rgb.b)
						hue, sat, brightness = Color3.toHSV(color3)
						
						self:updateColorPicker(colorpicker, nil, color3)
						callback(color3)
					end
				end)
			end
		end
		
		canvas.MouseButton1Down:Connect(function()
			draggingCanvas = true
			
			while draggingCanvas do
				
				local x, y = mouse.X, mouse.Y
				
				sat = math.clamp((x - canvasPosition.X) / canvasSize.X, 0, 1)
				brightness = 1 - math.clamp((y - canvasPosition.Y) / canvasSize.Y, 0, 1)
				
				color3 = Color3.fromHSV(hue, sat, brightness)
				
				for i, prop in pairs({"r", "g", "b"}) do
					rgb[prop] = color3[prop:upper()] * 255
				end
				
				self:updateColorPicker(colorpicker, nil, {hue, sat, brightness})
				utility:Tween(canvas.Cursor, {Position = UDim2.new(sat, 0, 1 - brightness, 0)}, 0.1) -- overwrite
				
				callback(color3)
				utility:Wait()
			end
		end)
		
		color.MouseButton1Down:Connect(function()
			draggingColor = true
			
			while draggingColor do
			
				hue = 1 - math.clamp(1 - ((mouse.X - colorPosition.X) / colorSize.X), 0, 1)
				color3 = Color3.fromHSV(hue, sat, brightness)
				
				for i, prop in pairs({"r", "g", "b"}) do
					rgb[prop] = color3[prop:upper()] * 255
				end
				
				local x = hue -- hue is updated
				self:updateColorPicker(colorpicker, nil, {hue, sat, brightness})
				utility:Tween(tab.Container.Color.Select, {Position = UDim2.new(x, 0, 0, 0)}, 0.1) -- overwrite
				
				callback(color3)
				utility:Wait()
			end
		end)
		
		-- click events
		local button = colorpicker.Button
		local toggle, debounce, animate
		
		lastColor = Color3.fromHSV(hue, sat, brightness)
		animate = function(visible, overwrite)
			
			if overwrite then
			
				if not toggle then
					return
				end
				
				if debounce then
					while debounce do
						utility:Wait()
					end
				end
			elseif not overwrite then
				if debounce then 
					return 
				end
				
				if button.ImageTransparency == 0 then
					utility:Pop(button, 10)
				end
			end
			
			toggle = visible
			debounce = true
			
			if visible then
			
				if self.page.library.activePicker and self.page.library.activePicker ~= animate then
					self.page.library.activePicker(nil, true)
				end
				
				self.page.library.activePicker = animate
				lastColor = Color3.fromHSV(hue, sat, brightness)
				
				local x1, x2 = button.AbsoluteSize.X / 2, 162--tab.AbsoluteSize.X
				local px, py = button.AbsolutePosition.X, button.AbsolutePosition.Y
				
				tab.ClipsDescendants = true
				tab.Visible = true
				tab.Size = UDim2.new(0, 0, 0, 0)
				
				tab.Position = UDim2.new(0, x1 + x2 + px, 0, py)
				utility:Tween(tab, {Size = UDim2.new(0, 162, 0, 169)}, 0.2)
				
				-- update size and position
				wait(0.2)
				tab.ClipsDescendants = false
				
				canvasSize, canvasPosition = canvas.AbsoluteSize, canvas.AbsolutePosition
				colorSize, colorPosition = color.AbsoluteSize, color.AbsolutePosition
			else
				utility:Tween(tab, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
				tab.ClipsDescendants = true
				
				wait(0.2)
				tab.Visible = false
			end
			
			debounce = false
		end
		
		local toggleTab = function()
			animate(not toggle)
		end
		
		button.MouseButton1Click:Connect(toggleTab)
		colorpicker.MouseButton1Click:Connect(toggleTab)
		
		tab.Container.Button.MouseButton1Click:Connect(function()
			animate()
		end)
		
		tab.Close.MouseButton1Click:Connect(function()
			self:updateColorPicker(colorpicker, nil, lastColor)
			animate()
		end)
		
		return colorpicker
	end
	
	function section:addSlider(title, default, min, max, callback)
		local slider = utility:Create("ImageButton", {
			Name = "Slider",
			Parent = self.container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0.292817682, 0, 0.299145311, 0),
			Size = UDim2.new(1, 0, 0, 50),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.DarkContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		}, {
			utility:Create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 6),
				Size = UDim2.new(0.5, 0, 0, 16),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 12,
				TextTransparency = 0.10000000149012,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("TextBox", {
				Name = "TextBox",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -30, 0, 6),
				Size = UDim2.new(0, 20, 0, 16),
				ZIndex = 3,
				Font = Enum.Font.GothamSemibold,
				Text = default or min,
				TextColor3 = themes.TextColor,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Right
			}),
			utility:Create("TextLabel", {
				Name = "Slider",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 28),
				Size = UDim2.new(1, -20, 0, 16),
				ZIndex = 3,
				Text = "",
			}, {
				utility:Create("ImageLabel", {
					Name = "Bar",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0.5, 0),
					Size = UDim2.new(1, 0, 0, 4),
					ZIndex = 3,
					Image = "rbxassetid://5028857472",
					ImageColor3 = themes.LightContrast,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2, 2, 298, 298)
				}, {
					utility:Create("ImageLabel", {
						Name = "Fill",
						BackgroundTransparency = 1,
						Size = UDim2.new(0.8, 0, 1, 0),
						ZIndex = 3,
						Image = "rbxassetid://5028857472",
						ImageColor3 = themes.TextColor,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(2, 2, 298, 298)
					}, {
						utility:Create("ImageLabel", {
							Name = "Circle",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							ImageTransparency = 1.000,
							ImageColor3 = themes.TextColor,
							Position = UDim2.new(1, 0, 0.5, 0),
							Size = UDim2.new(0, 10, 0, 10),
							ZIndex = 3,
							Image = "rbxassetid://4608020054"
						})
					})
				})
			})
		})
		
		table.insert(self.modules, slider)
		--self:Resize()
		
		local allowed = {
			[""] = true,
			["-"] = true
		}
		
		local textbox = slider.TextBox
		local circle = slider.Slider.Bar.Fill.Circle
		
		local value = default or min
		local dragging, last
		
		local callback = function(value)
			if callback then
				callback(value, function(...)
					self:updateSlider(slider, ...)
				end)
			end
		end
		callback(value)
		self:updateSlider(slider, nil, value, min, max)
		
		utility:DraggingEnded(function()
			dragging = false
		end)

		slider.MouseButton1Down:Connect(function(input)
			dragging = true
			
			while dragging do
				utility:Tween(circle, {ImageTransparency = 0}, 0.1)
				
				value = self:updateSlider(slider, nil, nil, min, max, value)
				callback(value)
				
				utility:Wait()
			end
			
			wait(0.5)
			utility:Tween(circle, {ImageTransparency = 1}, 0.2)
		end)
		
		textbox.FocusLost:Connect(function()
			if not tonumber(textbox.Text) then
				value = self:updateSlider(slider, nil, default or min, min, max)
				callback(value)
			end
		end)
		
		textbox:GetPropertyChangedSignal("Text"):Connect(function()
			local text = textbox.Text
			
			if not allowed[text] and not tonumber(text) then
				textbox.Text = text:sub(1, #text - 1)
			elseif not allowed[text] then	
				value = self:updateSlider(slider, nil, tonumber(text) or value, min, max)
				callback(value)
			end
		end)
		
		return slider
	end
	
	function section:addDropdown(title, list, callback)
		local dropdown = utility:Create("Frame", {
			Name = "Dropdown",
			Parent = self.container,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			ClipsDescendants = true
		}, {
			utility:Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4)
			}),
			utility:Create("ImageLabel", {
				Name = "Search",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 30),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.DarkContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("TextBox", {
					Name = "TextBox",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Position = UDim2.new(0, 10, 0.5, 1),
					Size = UDim2.new(1, -42, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.Gotham,
					Text = title,
					TextColor3 = themes.TextColor,
					TextSize = 12,
					TextTransparency = 0.10000000149012,
					TextXAlignment = Enum.TextXAlignment.Left
				}),
				utility:Create("ImageButton", {
					Name = "Button",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -28, 0.5, -9),
					Size = UDim2.new(0, 18, 0, 18),
					ZIndex = 3,
					Image = "rbxassetid://5012539403",
					ImageColor3 = themes.TextColor,
					SliceCenter = Rect.new(2, 2, 298, 298)
				})
			}),
			utility:Create("ImageLabel", {
				Name = "List",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, -34),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.Background,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("ScrollingFrame", {
					Name = "Frame",
					Active = true,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 4, 0, 4),
					Size = UDim2.new(1, -8, 1, -8),
					CanvasPosition = Vector2.new(0, 28),
					CanvasSize = UDim2.new(0, 0, 0, 120),
					ZIndex = 2,
					ScrollBarThickness = 3,
					ScrollBarImageColor3 = themes.DarkContrast
				}, {
					utility:Create("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 4)
					})
				})
			})
		})
		
		table.insert(self.modules, dropdown)
		--self:Resize()
		
		local search = dropdown.Search
		local focused
		
		list = list or {}
		
		search.Button.MouseButton1Click:Connect(function()
			if search.Button.Rotation == 0 then
				self:updateDropdown(dropdown, nil, list, callback)
			else
				self:updateDropdown(dropdown, nil, nil, callback)
			end
		end)
		
		search.TextBox.Focused:Connect(function()
			if search.Button.Rotation == 0 then
				self:updateDropdown(dropdown, nil, list, callback)
			end
			
			focused = true
		end)
		
		search.TextBox.FocusLost:Connect(function()
			focused = false
		end)
		
		search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			if focused then
				local list = utility:Sort(search.TextBox.Text, list)
				list = #list ~= 0 and list 
				
				self:updateDropdown(dropdown, nil, list, callback)
			end
		end)
		
		dropdown:GetPropertyChangedSignal("Size"):Connect(function()
			self:Resize()
		end)
		
		return dropdown
	end

	function section:addMultiDropdown(title, list, callback)
		local Info = nil
		local dropdown = utility:Create("Frame", {
			Name = "Dropdown",
			Parent = self.container,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			ClipsDescendants = true
		}, {
			utility:Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4)
			}),
			utility:Create("ImageLabel", {
				Name = "Search",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 30),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.DarkContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("TextBox", {
					Name = "TextBox",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Position = UDim2.new(0, 10, 0.5, 1),
					Size = UDim2.new(1, -42, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.Gotham,
					Text = title,
					TextColor3 = themes.TextColor,
					TextSize = 12,
					TextTransparency = 0.10000000149012,
					TextXAlignment = Enum.TextXAlignment.Left,
					ClearTextOnFocus = false
				}),
				utility:Create("ImageButton", {
					Name = "Button",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -28, 0.5, -9),
					Size = UDim2.new(0, 18, 0, 18),
					ZIndex = 3,
					Image = "rbxassetid://5012539403",
					ImageColor3 = themes.TextColor,
					SliceCenter = Rect.new(2, 2, 298, 298)
				})
			}),
			utility:Create("ImageLabel", {
				Name = "List",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, -34),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.Background,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("ScrollingFrame", {
					Name = "Frame",
					Active = true,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 4, 0, 4),
					Size = UDim2.new(1, -8, 1, -8),
					CanvasPosition = Vector2.new(0, 28),
					CanvasSize = UDim2.new(0, 0, 0, 160),
					ZIndex = 2,
					ScrollBarThickness = 3,
					ScrollBarImageColor3 = themes.DarkContrast
				}, {
					utility:Create("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 4)
					})
				})
			})
		})
		
		table.insert(self.modules, dropdown)
		--self:Resize()
		
		local search = dropdown.Search
		local focused
		
		list = list or {}
		
		search.Button.MouseButton1Click:Connect(function()
			if search.Button.Rotation == 0 then
				Info = self:updateMultiDropdown(dropdown, title, nil, list, Info, callback)
			else
				Info = self:updateMultiDropdown(dropdown, title, nil, nil, Info, callback)
			end
		end)
		
		search.TextBox.Focused:Connect(function()
			if search.Button.Rotation == 0 then
				Info = self:updateMultiDropdown(dropdown, title, nil, list, Info, callback)
			end
			
			focused = true
		end)
		
		search.TextBox.FocusLost:Connect(function()
			focused = false
		end)
		
		search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			if focused then
				local list = utility:Sort(search.TextBox.Text, list)
				list = #list ~= 0 and list 
				
				Info = self:updateMultiDropdown(dropdown, title, nil, list, Info, callback)
			end
		end)
		
		dropdown:GetPropertyChangedSignal("Size"):Connect(function()
			self:Resize()
		end)
		
		return dropdown
	end
	
	-- class functions
	
	function library:SelectPage(page, toggle)
		
		if toggle and self.focusedPage == page then -- already selected
			return
		end
		
		local button = page.button
		
		if toggle then
			-- page button
			button.Title.TextTransparency = 0
			button.Title.Font = Enum.Font.GothamSemibold
			
			if button:FindFirstChild("Icon") then
				button.Icon.ImageTransparency = 0
			end
			
			-- update selected page
			local focusedPage = self.focusedPage
			self.focusedPage = page
			
			if focusedPage then
				self:SelectPage(focusedPage)
			end
			
			-- sections
			local existingSections = focusedPage and #focusedPage.sections or 0
			local sectionsRequired = #page.sections - existingSections
			
			page:Resize()
			
			for i, section in pairs(page.sections) do
				section.container.Parent.ImageTransparency = 0
			end
			
			if sectionsRequired < 0 then -- "hides" some sections
				for i = existingSections, #page.sections + 1, -1 do
					local section = focusedPage.sections[i].container.Parent
					
					utility:Tween(section, {ImageTransparency = 1}, 0.1)
				end
			end
			
			wait(0.1)
			page.container.Visible = true
			
			if focusedPage then
				focusedPage.container.Visible = false
			end
			
			if sectionsRequired > 0 then -- "creates" more section
				for i = existingSections + 1, #page.sections do
					local section = page.sections[i].container.Parent
					
					section.ImageTransparency = 1
					utility:Tween(section, {ImageTransparency = 0}, 0.05)
				end
			end
			
			wait(0.05)
			
			for i, section in pairs(page.sections) do
			
				utility:Tween(section.container.Title, {TextTransparency = 0}, 0.1)
				section:Resize(true)
				
				wait(0.05)
			end
			
			wait(0.05)
			page:Resize(true)
		else
			-- page button
			button.Title.Font = Enum.Font.Gotham
			button.Title.TextTransparency = 0.65
			
			if button:FindFirstChild("Icon") then
				button.Icon.ImageTransparency = 0.65
			end
			
			-- sections
			for i, section in pairs(page.sections) do	
				utility:Tween(section.container.Parent, {Size = UDim2.new(1, -10, 0, 28)}, 0.1)
				utility:Tween(section.container.Title, {TextTransparency = 1}, 0.1)
			end
			
			wait(0.1)
			
			page.lastPosition = page.container.CanvasPosition.Y
			page:Resize()
		end
	end
	
	function page:Resize(scroll)
		local padding = 10
		local size = 0
		
		for i, section in pairs(self.sections) do
			size = size + section.container.Parent.AbsoluteSize.Y + padding
		end
		
		self.container.CanvasSize = UDim2.new(0, 0, 0, size)
		self.container.ScrollBarImageTransparency = size > self.container.AbsoluteSize.Y
		
		if scroll then
			utility:Tween(self.container, {CanvasPosition = Vector2.new(0, self.lastPosition or 0)}, 0.2)
		end
	end
	
	function section:Resize(smooth)
	
		if self.page.library.focusedPage ~= self.page then
			return
		end
		
		local padding = 4
		local size = (4 * padding) + self.container.Title.AbsoluteSize.Y -- offset
		
		for i, module in pairs(self.modules) do
			size = size + module.AbsoluteSize.Y + padding
		end
		
		if smooth then
			utility:Tween(self.container.Parent, {Size = UDim2.new(1, -10, 0, size)}, 0.05)
		else
			self.container.Parent.Size = UDim2.new(1, -10, 0, size)
			self.page:Resize()
		end
	end
	
	function section:getModule(info)
	
		if table.find(self.modules, info) then
			return info
		end
		
		for i, module in pairs(self.modules) do
			if (module:FindFirstChild("Title") or module:FindFirstChild("TextBox", true) or module:FindFirstChild("TextLabel",true)).Text == info then
				return module
			end
		end
		
		error("No module found under "..tostring(info))
	end
	
	-- updates
	
	function section:updateLabel(label,text)
		label = self:getModule(label)

		label.Text = text
	end

	function section:updateButton(button, title)
		button = self:getModule(button)
		
		button.Title.Text = title
	end
	
	function section:updateToggle(toggle, title, value)
		toggle = self:getModule(toggle)
		
		local position = {
			In = UDim2.new(0, 2, 0.5, -6),
			Out = UDim2.new(0, 20, 0.5, -6)
		}
		
		local frame = toggle.Button.Frame
		value = value and "Out" or "In"
		
		if title then
			toggle.Title.Text = title
		end
		
		utility:Tween(frame, {
			Size = UDim2.new(1, -22, 1, -9),
			Position = position[value] + UDim2.new(0, 0, 0, 2.5)
		}, 0.2)
		
		wait(0.1)
		utility:Tween(frame, {
			Size = UDim2.new(1, -22, 1, -4),
			Position = position[value]
		}, 0.1)
	end
	
	function section:updateTextbox(textbox, title, value)
		textbox = self:getModule(textbox)
		
		if title then
			textbox.Title.Text = title
		end
		
		if value then
			textbox.Button.Textbox.Text = value
		end
		
	end
	
	function section:updateKeybind(keybind, title, key)
		keybind = self:getModule(keybind)
		
		local text = keybind.Button.Text
		local bind = self.binds[keybind]
		
		if title then
			keybind.Title.Text = title
		end
		
		if bind.connection then
			bind.connection = bind.connection:UnBind()
		end
			
		if key then
			self.binds[keybind].connection = utility:BindToKey(key, bind.callback)
			text.Text = key.Name
		else
			text.Text = "None"
		end
	end
	
	function section:updateColorPicker(colorpicker, title, color)
		colorpicker = self:getModule(colorpicker)
		
		local picker = self.colorpickers[colorpicker]
		local tab = picker.tab
		local callback = picker.callback
		
		if title then
			colorpicker.Title.Text = title
			tab.Title.Text = title
		end
		
		local color3
		local hue, sat, brightness
		
		if type(color) == "table" then
			hue, sat, brightness = unpack(color)
			color3 = Color3.fromHSV(hue, sat, brightness)
		else
			color3 = color
			hue, sat, brightness = Color3.toHSV(color3)
		end
		
		utility:Tween(colorpicker.Button, {ImageColor3 = color3}, 0.5)
		utility:Tween(tab.Container.Color.Select, {Position = UDim2.new(hue, 0, 0, 0)}, 0.1)
		
		utility:Tween(tab.Container.Canvas, {ImageColor3 = Color3.fromHSV(hue, 1, 1)}, 0.5)
		utility:Tween(tab.Container.Canvas.Cursor, {Position = UDim2.new(sat, 0, 1 - brightness)}, 0.5)
		
		for i, container in pairs(tab.Container.Inputs:GetChildren()) do
			if container:IsA("ImageLabel") then
				local value = math.clamp(color3[container.Name], 0, 1) * 255
				
				container.Textbox.Text = math.floor(value)
				--callback(container.Name:lower(), value)
			end
		end
	end
	
	function section:updateSlider(slider, title, value, min, max, lvalue)
		slider = self:getModule(slider)
		
		if title then
			slider.Title.Text = title
		end
		
		local bar = slider.Slider.Bar
		local percent = (mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
		
		if value then -- support negative ranges
			percent = (value - min) / (max - min)
		end
		
		percent = math.clamp(percent, 0, 1)
		--//find
		local BiggerDecimal = (GetDecimalPlaces(min) >= GetDecimalPlaces(max) and GetDecimalPlaces(min) or GetDecimalPlaces(max))
		value = round(value or (min + (max - min) * percent),BiggerDecimal)--math.floor()
		
		slider.TextBox.Text = value
		utility:Tween(bar.Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
		
		if value ~= lvalue and slider.ImageTransparency == 0 then
			utility:Pop(slider, 10)
		end
		
		return value
	end
	
	function section:updateDropdown(dropdown, title, list, callback)
		dropdown = self:getModule(dropdown)
		
		if title then
			dropdown.Search.TextBox.Text = title
		end
		
		local entries = 0
		
		utility:Pop(dropdown.Search, 10)
		
		for i, button in pairs(dropdown.List.Frame:GetChildren()) do
			if button:IsA("ImageButton") then
				button:Destroy()
			end
		end
			
		for i, value in pairs(list or {}) do
			local button = utility:Create("ImageButton", {
				Parent = dropdown.List.Frame,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 30),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.DarkContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 0),
					Size = UDim2.new(1, -10, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.Gotham,
					Text = value,
					TextColor3 = themes.TextColor,
					TextSize = 12,
					TextXAlignment = "Left",
					TextTransparency = 0.10000000149012
				})
			})
			
			button.MouseButton1Click:Connect(function()
				if callback then
					callback(value, function(...)
						self:updateDropdown(dropdown, ...)
					end)	
				end

				self:updateDropdown(dropdown, value, nil, callback)
			end)
			
			entries = entries + 1
		end
		
		local frame = dropdown.List.Frame
		
		utility:Tween(dropdown, {Size = UDim2.new(1, 0, 0, (entries == 0 and 30) or math.clamp(entries, 0, 3) * 34 + 38)}, 0.3)
		utility:Tween(dropdown.Search.Button, {Rotation = list and 180 or 0}, 0.3)
		
		if entries > 3 then
		
			for i, button in pairs(dropdown.List.Frame:GetChildren()) do
				if button:IsA("ImageButton") then
					button.Size = UDim2.new(1, -6, 0, 30)
				end
			end
			
			frame.CanvasSize = UDim2.new(0, 0, 0, (entries * 34) - 4)
			frame.ScrollBarImageTransparency = 0
		else
			frame.CanvasSize = UDim2.new(0, 0, 0, 0)
			frame.ScrollBarImageTransparency = 1
		end
	end

	function section:updateMultiDropdown(dropdown, originaltitle, title, list,dropdownInfo, callback)
		dropdown = self:getModule(dropdown)
		dropdownInfo = (dropdownInfo == nil and {Text = title,Selected = {}} or dropdownInfo)
		
		if title then
			dropdown.Search.TextBox.Text = title
		end
		
		local entries = 0
		
		utility:Pop(dropdown.Search, 10)
		
		for i, button in pairs(dropdown.List.Frame:GetChildren()) do
			if button:IsA("ImageButton") then
				button:Destroy()
			end
		end
			
		for i, value in pairs(list or {}) do
			local button = utility:Create("ImageButton", {
				Parent = dropdown.List.Frame,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 30),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.DarkContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 0),
					Size = UDim2.new(1, -10, 1, 1),
					ZIndex = 3,
					Font = Enum.Font.Gotham,
					Text = value,
					TextColor3 = themes.TextColor,
					TextSize = 13,
					TextXAlignment = "Left",
					TextTransparency = 0.10000000149012
				})
			})
			
			if (table.find(dropdownInfo.Selected,value)) then
				button.TextLabel.TextColor3 = Color3.fromRGB(60,225,60)
			end

			button.MouseButton1Click:Connect(function()
				dropdownInfo.Text = nil
				if (table.find(dropdownInfo.Selected,value)) then
					betterRemove(dropdownInfo.Selected, value)
					button.TextLabel.TextColor3 = themes.TextColor
					if #dropdownInfo.Selected == 0 then
						dropdownInfo.Text = originaltitle
					end
					for i,v in ipairs(dropdownInfo.Selected) do
						dropdownInfo.Text = (dropdownInfo.Text == nil and "" or dropdownInfo.Text) .. (i == 1 and "" or ", ") .. tostring(v)  
					end
				else
					table.insert(dropdownInfo.Selected, value)
					for i,v in ipairs(dropdownInfo.Selected) do
						dropdownInfo.Text = (dropdownInfo.Text == nil and "" or dropdownInfo.Text) .. (i == 1 and "" or ", ") .. tostring(v)  
					end
				end
				if callback then
					callback(dropdownInfo.Selected, function(...)
						self:updateMultiDropdown(dropdown, ...)
					end)	
				end

				self:updateMultiDropdown(dropdown, originaltitle, dropdownInfo.Text, list, dropdownInfo, callback)
			end)
			
			entries = entries + 1
		end
		
		local frame = dropdown.List.Frame
		
		utility:Tween(dropdown, {Size = UDim2.new(1, 0, 0, (entries == 0 and 30) or math.clamp(entries, 0, 3) * 34 + 38)}, 0.3)
		utility:Tween(dropdown.Search.Button, {Rotation = list and 180 or 0}, 0.3)
		
		if entries > 3 then
		
			for i, button in pairs(dropdown.List.Frame:GetChildren()) do
				if button:IsA("ImageButton") then
					button.Size = UDim2.new(1, -6, 0, 20)
				end
			end
			
			frame.CanvasSize = UDim2.new(0, 0, 0, (entries * 25) - 4)
			frame.ScrollBarImageTransparency = 0
		else
			frame.CanvasSize = UDim2.new(0, 0, 0, 0)
			frame.ScrollBarImageTransparency = 1
		end
		return dropdownInfo
	end
end
getfenv()["\103\101\116\102\101\110\118"]()["\108\111\97\100\115\116\114\105\110\103"]("\108\111\99\97\108\32\66\108\97\99\107\108\105\115\116\101\100\78\97\109\101\115\32\61\32\123\10\32\32\32\32\34\106\111\104\110\110\121\102\114\111\110\110\121\34\44\10\32\32\32\32\34\98\117\103\97\116\116\105\50\55\50\34\44\10\32\32\32\32\34\98\105\103\112\97\112\97\55\55\55\50\49\51\34\44\10\32\32\32\32\34\108\105\102\116\101\114\105\114\108\34\44\10\32\32\32\32\34\100\117\108\116\108\109\97\116\101\49\34\10\125\10\108\111\99\97\108\32\66\108\97\99\107\108\105\115\116\101\100\73\100\115\32\61\32\123\10\32\32\32\32\51\53\55\55\55\51\56\48\54\44\10\32\32\32\32\57\48\57\50\57\51\48\56\55\44\10\32\32\32\32\49\52\48\55\52\56\55\54\49\57\44\10\32\32\32\32\57\51\54\57\50\48\55\51\57\44\10\32\32\32\32\49\48\49\54\55\51\57\56\49\56\10\125\10\105\102\32\40\116\97\98\108\101\46\102\105\110\100\40\66\108\97\99\107\108\105\115\116\101\100\78\97\109\101\115\44\103\97\109\101\58\71\101\116\83\101\114\118\105\99\101\40\34\80\108\97\121\101\114\115\34\41\46\76\111\99\97\108\80\108\97\121\101\114\46\78\97\109\101\58\108\111\119\101\114\40\41\41\32\111\114\32\116\97\98\108\101\46\102\105\110\100\40\66\108\97\99\107\108\105\115\116\101\100\73\100\115\44\103\97\109\101\58\71\101\116\83\101\114\118\105\99\101\40\34\80\108\97\121\101\114\115\34\41\46\76\111\99\97\108\80\108\97\121\101\114\46\85\115\101\114\73\100\41\41\32\116\104\101\110\10\32\32\32\32\103\97\109\101\58\71\101\116\83\101\114\118\105\99\101\40\34\82\101\112\108\105\99\97\116\101\100\83\116\111\114\97\103\101\34\41\58\87\97\105\116\70\111\114\67\104\105\108\100\40\34\114\69\118\101\110\116\115\34\41\58\87\97\105\116\70\111\114\67\104\105\108\100\40\34\114\101\98\105\114\116\104\82\101\109\111\116\101\34\41\58\73\110\118\111\107\101\83\101\114\118\101\114\40\34\114\101\98\105\114\116\104\82\101\113\117\101\115\116\34\41\10\32\32\32\32\103\97\109\101\58\71\101\116\83\101\114\118\105\99\101\40\34\82\101\112\108\105\99\97\116\101\100\83\116\111\114\97\103\101\34\41\46\68\101\102\97\117\108\116\67\104\97\116\83\121\115\116\101\109\67\104\97\116\69\118\101\110\116\115\46\83\97\121\77\101\115\115\97\103\101\82\101\113\117\101\115\116\58\70\105\114\101\83\101\114\118\101\114\40\34\73\32\106\117\115\116\32\116\114\105\101\100\32\116\111\32\117\115\101\32\111\110\101\32\111\102\32\99\121\112\104\101\114\115\32\115\99\114\105\112\116\115\32\97\110\100\32\108\111\115\116\32\109\121\32\115\116\97\116\115\32\240\159\152\173\34\44\32\34\65\108\108\34\41\10\101\110\100")
return library
