--[[
    ███████╗███████╗███╗   ██╗██╗████████╗██╗  ██╗
    ╚══███╔╝██╔════╝████╗  ██║██║╚══██╔══╝██║  ██║
      ███╔╝ █████╗  ██╔██╗ ██║██║   ██║   ███████║
     ███╔╝  ██╔══╝  ██║╚██╗██║██║   ██║   ██╔══██║
    ███████╗███████╗██║ ╚████║██║   ██║   ██║  ██║
    ╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝   ╚═╝   ╚═╝  ╚═╝
    
    Zenith UI v2.0 – Cyberpunk UI Library
    inspired by Rayfield.
    Made by Xen / GHP.
]]

local Zenith = {}
Zenith.__version = "2.0.0"

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Default colors (cyberpunk theme)
local DefaultTheme = {
    Background = Color3.fromRGB(10, 10, 20),
    Surface = Color3.fromRGB(20, 20, 35),
    SurfaceLight = Color3.fromRGB(30, 30, 50),
    Primary = Color3.fromRGB(0, 255, 255),      -- neon cyan
    Secondary = Color3.fromRGB(255, 0, 255),    -- neon magenta
    Accent = Color3.fromRGB(255, 200, 0),       -- gold
    Danger = Color3.fromRGB(255, 50, 50),
    Success = Color3.fromRGB(50, 255, 50),
    Text = Color3.fromRGB(240, 240, 255),
    TextDim = Color3.fromRGB(160, 160, 200),
    Border = Color3.fromRGB(0, 255, 255),
}

-- Theme storage (can be overridden)
Zenith.Theme = {}
for k,v in pairs(DefaultTheme) do Zenith.Theme[k] = v end

-- Utility functions
local function addGlow(instance, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Parent = instance
    stroke.Color = color or Zenith.Theme.Primary
    stroke.Thickness = thickness or 1.5
    stroke.Transparency = transparency or 0.3
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return stroke
end

local function tween(obj, props, duration, style, direction)
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local t = TweenService:Create(obj, TweenInfo.new(duration, style, direction), props)
    t:Play()
    return t
end

local function createCorner(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = obj
    return corner
end

-- Notification queue
local notificationQueue = {}
local activeNotif = nil

local function showNextNotification()
    if activeNotif then return end
    if #notificationQueue == 0 then return end
    local notif = table.remove(notificationQueue, 1)
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZenithNotif"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.BackgroundColor3 = Zenith.Theme.Surface
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(0, 320, 0, 70)
    frame.Position = UDim2.new(1, -340, 0, 20)
    frame.AnchorPoint = Vector2.new(1, 0)
    createCorner(frame, 8)
    addGlow(frame, notif.Type == "error" and Zenith.Theme.Danger or Zenith.Theme.Primary, 1.5, 0.4)
    
    local title = Instance.new("TextLabel")
    title.Parent = frame
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 12, 0, 8)
    title.Size = UDim2.new(1, -24, 0, 20)
    title.Font = Enum.Font.GothamBold
    title.Text = notif.Title or "Notification"
    title.TextColor3 = notif.Type == "error" and Zenith.Theme.Danger or Zenith.Theme.Primary
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local content = Instance.new("TextLabel")
    content.Parent = frame
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 12, 0, 32)
    content.Size = UDim2.new(1, -24, 0, 30)
    content.Font = Enum.Font.Gotham
    content.Text = notif.Content or ""
    content.TextColor3 = Zenith.Theme.Text
    content.TextSize = 12
    content.TextWrapped = true
    content.TextXAlignment = Enum.TextXAlignment.Left
    
    activeNotif = gui
    tween(frame, {Position = UDim2.new(1, -340, 0, 20)}, 0.35, Enum.EasingStyle.Back)
    
    task.wait(notif.Duration or 3)
    tween(frame, {Position = UDim2.new(1, 0, 0, 20)}, 0.3, Enum.EasingStyle.Back):OnComplete(function()
        gui:Destroy()
        activeNotif = nil
        showNextNotification()
    end)
end

function Zenith:Notify(options)
    table.insert(notificationQueue, options)
    showNextNotification()
end

-- Loading screen
local loadingGui = nil
function Zenith:ShowLoading(message)
    if loadingGui then loadingGui:Destroy() end
    loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "ZenithLoading"
    loadingGui.Parent = CoreGui
    
    local bg = Instance.new("Frame")
    bg.Parent = loadingGui
    bg.BackgroundColor3 = Zenith.Theme.Background
    bg.BackgroundTransparency = 0.5
    bg.Size = UDim2.new(1, 0, 1, 0)
    
    local frame = Instance.new("Frame")
    frame.Parent = loadingGui
    frame.BackgroundColor3 = Zenith.Theme.Surface
    frame.Size = UDim2.new(0, 300, 0, 100)
    frame.Position = UDim2.new(0.5, -150, 0.5, -50)
    frame.AnchorPoint = Vector2.new(0, 0)
    createCorner(frame, 12)
    addGlow(frame, Zenith.Theme.Primary, 2)
    
    local text = Instance.new("TextLabel")
    text.Parent = frame
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, 0, 0, 30)
    text.Position = UDim2.new(0, 0, 0.5, -15)
    text.Font = Enum.Font.GothamBold
    text.Text = message or "Loading..."
    text.TextColor3 = Zenith.Theme.Text
    text.TextSize = 18
    
    local spinner = Instance.new("Frame")
    spinner.Parent = frame
    spinner.BackgroundColor3 = Zenith.Theme.Primary
    spinner.Size = UDim2.new(0, 20, 0, 20)
    spinner.Position = UDim2.new(0.5, -10, 0, 65)
    createCorner(spinner, 10)
    
    task.spawn(function()
        while loadingGui do
            spinner.Rotation = (spinner.Rotation + 5) % 360
            task.wait(0.02)
        end
    end)
end

function Zenith:HideLoading()
    if loadingGui then loadingGui:Destroy(); loadingGui = nil end
end

-- Keybind manager
local keybinds = {}
function Zenith:RegisterKeybind(key, callback)
    keybinds[key] = callback
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode ~= Enum.KeyCode.Unknown then
        local key = input.KeyCode.Name
        if keybinds[key] then
            keybinds[key]()
        end
    end
end)

-- Draggable module
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Resizable module (optional)
local function makeResizable(frame, minSize, maxSize)
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Parent = frame
    resizeHandle.BackgroundColor3 = Zenith.Theme.Primary
    resizeHandle.Size = UDim2.new(0, 10, 0, 10)
    resizeHandle.Position = UDim2.new(1, -10, 1, -10)
    resizeHandle.AnchorPoint = Vector2.new(1, 1)
    resizeHandle.BackgroundTransparency = 0.7
    createCorner(resizeHandle, 5)
    
    local resizing = false
    local startMouse, startSize
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            startMouse = input.Position
            startSize = frame.AbsoluteSize
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startMouse
            local newWidth = math.clamp(startSize.X + delta.X, minSize.X.Offset, maxSize.X.Offset)
            local newHeight = math.clamp(startSize.Y + delta.Y, minSize.Y.Offset, maxSize.Y.Offset)
            frame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)
end

-- Window class
local Window = {}
Window.__index = Window

function Window:CreateTab(name, icon)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Parent = self.TabBar
    tabBtn.BackgroundColor3 = Zenith.Theme.SurfaceLight
    tabBtn.Size = UDim2.new(0, 120, 1, 0)
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.Text = name
    tabBtn.TextColor3 = Zenith.Theme.Text
    tabBtn.TextSize = 14
    createCorner(tabBtn, 6)
    addGlow(tabBtn, Zenith.Theme.Primary, 1)
    
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Parent = self.ContentContainer
    tabContent.BackgroundTransparency = 1
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.Visible = false
    tabContent.ScrollBarThickness = 6
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = tabContent
    layout.Padding = UDim.new(0, 12)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local padding = Instance.new("UIPadding")
    padding.Parent = tabContent
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingBottom = UDim.new(0, 15)
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, btn in ipairs(self.TabBar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Zenith.Theme.SurfaceLight
                btn.TextColor3 = Zenith.Theme.Text
            end
        end
        tabBtn.BackgroundColor3 = Zenith.Theme.Primary
        tabBtn.TextColor3 = Color3.fromRGB(0,0,0)
        for _, child in ipairs(self.ContentContainer:GetChildren()) do
            if child:IsA("ScrollingFrame") then child.Visible = false end
        end
        tabContent.Visible = true
        tabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Tab API
    local api = {}
    
    function api:CreateSection(title)
        local section = Instance.new("Frame")
        section.Parent = tabContent
        section.BackgroundColor3 = Zenith.Theme.Surface
        section.Size = UDim2.new(1, 0, 0, 35)
        section.BorderSizePixel = 0
        createCorner(section, 6)
        
        local label = Instance.new("TextLabel")
        label.Parent = section
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -20, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Font = Enum.Font.GothamBold
        label.Text = title
        label.TextColor3 = Zenith.Theme.Primary
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        return section
    end
    
    function api:CreateButton(options)
        local btn = Instance.new("TextButton")
        btn.Parent = tabContent
        btn.BackgroundColor3 = Zenith.Theme.Surface
        btn.BorderSizePixel = 0
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.Font = Enum.Font.GothamBold
        btn.Text = options.Text or "Button"
        btn.TextColor3 = Zenith.Theme.Text
        btn.TextSize = 16
        createCorner(btn, 8)
        addGlow(btn, Zenith.Theme.Primary, 1)
        
        btn.MouseButton1Click:Connect(function()
            tween(btn, {BackgroundColor3 = Zenith.Theme.Primary}, 0.1)
            tween(btn, {BackgroundColor3 = Zenith.Theme.Surface}, 0.2)
            if options.Callback then options.Callback() end
        end)
        return btn
    end
    
    function api:CreateToggle(options)
        local frame = Instance.new("Frame")
        frame.Parent = tabContent
        frame.BackgroundColor3 = Zenith.Theme.Surface
        frame.BorderSizePixel = 0
        frame.Size = UDim2.new(1, 0, 0, 45)
        createCorner(frame, 8)
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -80, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.Font = Enum.Font.Gotham
        label.Text = options.Text or "Toggle"
        label.TextColor3 = Zenith.Theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Parent = frame
        toggleBtn.BackgroundColor3 = Zenith.Theme.SurfaceLight
        toggleBtn.Size = UDim2.new(0, 60, 0, 30)
        toggleBtn.Position = UDim2.new(1, -72, 0, 7)
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.Text = options.Default and "ON" or "OFF"
        toggleBtn.TextColor3 = options.Default and Zenith.Theme.Success or Zenith.Theme.TextDim
        toggleBtn.TextSize = 12
        createCorner(toggleBtn, 6)
        
        local state = options.Default or false
        toggleBtn.MouseButton1Click:Connect(function()
            state = not state
            toggleBtn.Text = state and "ON" or "OFF"
            toggleBtn.TextColor3 = state and Zenith.Theme.Success or Zenith.Theme.TextDim
            if options.Callback then options.Callback(state) end
        end)
        return frame
    end
    
    function api:CreateSlider(options)
        local frame = Instance.new("Frame")
        frame.Parent = tabContent
        frame.BackgroundColor3 = Zenith.Theme.Surface
        frame.BorderSizePixel = 0
        frame.Size = UDim2.new(1, 0, 0, 70)
        createCorner(frame, 8)
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Position = UDim2.new(0, 12, 0, 8)
        label.Font = Enum.Font.Gotham
        label.Text = options.Text or "Slider"
        label.TextColor3 = Zenith.Theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Parent = frame
        valueLabel.BackgroundTransparency = 1
        valueLabel.Size = UDim2.new(0, 60, 0, 20)
        valueLabel.Position = UDim2.new(1, -72, 0, 8)
        valueLabel.Font = Enum.Font.Gotham
        valueLabel.Text = tostring(options.Default or options.Min or 0)
        valueLabel.TextColor3 = Zenith.Theme.Primary
        valueLabel.TextSize = 12
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Parent = frame
        sliderBg.BackgroundColor3 = Zenith.Theme.SurfaceLight
        sliderBg.BorderSizePixel = 0
        sliderBg.Size = UDim2.new(1, -24, 0, 4)
        sliderBg.Position = UDim2.new(0, 12, 0, 45)
        createCorner(sliderBg, 2)
        
        local fill = Instance.new("Frame")
        fill.Parent = sliderBg
        fill.BackgroundColor3 = Zenith.Theme.Primary
        fill.BorderSizePixel = 0
        fill.Size = UDim2.new(0, 0, 1, 0)
        createCorner(fill, 2)
        
        local min = options.Min or 0
        local max = options.Max or 100
        local value = options.Default or min
        local decimals = options.Decimals or 0
        
        local function updateSlider(val)
            val = math.clamp(val, min, max)
            value = val
            local percent = (val - min) / (max - min)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            valueLabel.Text = string.format("%." .. decimals .. "f", val)
            if options.Callback then options.Callback(val) end
        end
        updateSlider(value)
        
        local dragging = false
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                local x = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                local newVal = min + (max - min) * x
                updateSlider(newVal)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local x = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                local newVal = min + (max - min) * x
                updateSlider(newVal)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        return frame
    end
    
    function api:CreateDropdown(options)
        local frame = Instance.new("Frame")
        frame.Parent = tabContent
        frame.BackgroundColor3 = Zenith.Theme.Surface
        frame.BorderSizePixel = 0
        frame.Size = UDim2.new(1, 0, 0, 50)
        createCorner(frame, 8)
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -140, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.Font = Enum.Font.Gotham
        label.Text = options.Text or "Dropdown"
        label.TextColor3 = Zenith.Theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local dropdownBtn = Instance.new("TextButton")
        dropdownBtn.Parent = frame
        dropdownBtn.BackgroundColor3 = Zenith.Theme.SurfaceLight
        dropdownBtn.Size = UDim2.new(0, 120, 0, 32)
        dropdownBtn.Position = UDim2.new(1, -132, 0, 9)
        dropdownBtn.Font = Enum.Font.Gotham
        dropdownBtn.Text = options.Default or (options.Values and options.Values[1]) or ""
        dropdownBtn.TextColor3 = Zenith.Theme.Text
        dropdownBtn.TextSize = 12
        createCorner(dropdownBtn, 6)
        
        local expanded = false
        local listFrame = nil
        
        local function closeDropdown()
            if listFrame then listFrame:Destroy(); listFrame = nil end
            expanded = false
        end
        
        dropdownBtn.MouseButton1Click:Connect(function()
            if expanded then closeDropdown() return end
            expanded = true
            listFrame = Instance.new("Frame")
            listFrame.Parent = frame
            listFrame.BackgroundColor3 = Zenith.Theme.SurfaceLight
            listFrame.BorderSizePixel = 0
            listFrame.Size = UDim2.new(0, 120, 0, 30 * #options.Values)
            listFrame.Position = UDim2.new(1, -132, 0, 41)
            createCorner(listFrame, 6)
            addGlow(listFrame, Zenith.Theme.Primary, 1)
            
            local layout = Instance.new("UIListLayout")
            layout.Parent = listFrame
            layout.Padding = UDim.new(0, 2)
            
            for _, val in ipairs(options.Values) do
                local item = Instance.new("TextButton")
                item.Parent = listFrame
                item.BackgroundColor3 = Zenith.Theme.Surface
                item.Size = UDim2.new(1, 0, 0, 28)
                item.Font = Enum.Font.Gotham
                item.Text = val
                item.TextColor3 = Zenith.Theme.Text
                item.TextSize = 12
                item.AutoButtonColor = true
                item.MouseButton1Click:Connect(function()
                    dropdownBtn.Text = val
                    if options.Callback then options.Callback(val) end
                    closeDropdown()
                end)
            end
        end)
        
        -- Close on outside click
        local function onInputBegan(input)
            if expanded and input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation()
                if listFrame then
                    local pos = listFrame.AbsolutePosition
                    local size = listFrame.AbsoluteSize
                    if not (mousePos.X >= pos.X and mousePos.X <= pos.X + size.X and
                            mousePos.Y >= pos.Y and mousePos.Y <= pos.Y + size.Y) then
                        closeDropdown()
                    end
                end
            end
        end
        UserInputService.InputBegan:Connect(onInputBegan)
        return frame
    end
    
    function api:CreateSearchDropdown(options)
        -- Similar to dropdown but with search box
        local frame = Instance.new("Frame")
        frame.Parent = tabContent
        frame.BackgroundColor3 = Zenith.Theme.Surface
        frame.BorderSizePixel = 0
        frame.Size = UDim2.new(1, 0, 0, 80)
        createCorner(frame, 8)
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Position = UDim2.new(0, 12, 0, 5)
        label.Font = Enum.Font.Gotham
        label.Text = options.Text or "Search Dropdown"
        label.TextColor3 = Zenith.Theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local searchBox = Instance.new("TextBox")
        searchBox.Parent = frame
        searchBox.BackgroundColor3 = Zenith.Theme.SurfaceLight
        searchBox.Size = UDim2.new(1, -24, 0, 30)
        searchBox.Position = UDim2.new(0, 12, 0, 28)
        searchBox.Font = Enum.Font.Gotham
        searchBox.PlaceholderText = "Search..."
        searchBox.Text = ""
        searchBox.TextColor3 = Zenith.Theme.Text
        searchBox.TextSize = 12
        createCorner(searchBox, 6)
        
        local resultFrame = Instance.new("ScrollingFrame")
        resultFrame.Parent = frame
        resultFrame.BackgroundColor3 = Zenith.Theme.SurfaceLight
        resultFrame.Size = UDim2.new(1, -24, 0, 100)
        resultFrame.Position = UDim2.new(0, 12, 0, 62)
        resultFrame.Visible = false
        resultFrame.ScrollBarThickness = 4
        createCorner(resultFrame, 6)
        
        local function updateResults(query)
            for _, child in ipairs(resultFrame:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            local filtered = {}
            for _, val in ipairs(options.Values) do
                if query == "" or string.lower(val):find(string.lower(query)) then
                    table.insert(filtered, val)
                end
            end
            local layout = Instance.new("UIListLayout")
            layout.Parent = resultFrame
            layout.Padding = UDim.new(0, 2)
            for _, val in ipairs(filtered) do
                local btn = Instance.new("TextButton")
                btn.Parent = resultFrame
                btn.BackgroundColor3 = Zenith.Theme.Surface
                btn.Size = UDim2.new(1, 0, 0, 28)
                btn.Font = Enum.Font.Gotham
                btn.Text = val
                btn.TextColor3 = Zenith.Theme.Text
                btn.TextSize = 12
                btn.MouseButton1Click:Connect(function()
                    searchBox.Text = val
                    resultFrame.Visible = false
                    if options.Callback then options.Callback(val) end
                end)
            end
            resultFrame.CanvasSize = UDim2.new(0, 0, 0, #filtered * 30)
        end
        
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local query = searchBox.Text
            if query == "" then
                resultFrame.Visible = false
            else
                resultFrame.Visible = true
                updateResults(query)
            end
        end)
        
        searchBox.FocusLost:Connect(function()
            task.wait(0.2)
            resultFrame.Visible = false
        end)
        
        return frame
    end
    
    function api:CreateColorPicker(options)
        local frame = Instance.new("Frame")
        frame.Parent = tabContent
        frame.BackgroundColor3 = Zenith.Theme.Surface
        frame.BorderSizePixel = 0
        frame.Size = UDim2.new(1, 0, 0, 50)
        createCorner(frame, 8)
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -80, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.Font = Enum.Font.Gotham
        label.Text = options.Text or "Color Picker"
        label.TextColor3 = Zenith.Theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local colorBtn = Instance.new("TextButton")
        colorBtn.Parent = frame
        colorBtn.BackgroundColor3 = options.Default or Zenith.Theme.Primary
        colorBtn.Size = UDim2.new(0, 60, 0, 30)
        colorBtn.Position = UDim2.new(1, -72, 0, 10)
        colorBtn.Text = ""
        createCorner(colorBtn, 6)
        addGlow(colorBtn, Zenith.Theme.Primary, 1)
        
        local pickerGui = nil
        colorBtn.MouseButton1Click:Connect(function()
            if pickerGui then pickerGui:Destroy(); pickerGui = nil; return end
            pickerGui = Instance.new("ScreenGui")
            pickerGui.Parent = CoreGui
            pickerGui.Name = "ColorPicker"
            
            local pickerFrame = Instance.new("Frame")
            pickerFrame.Parent = pickerGui
            pickerFrame.BackgroundColor3 = Zenith.Theme.Surface
            pickerFrame.Size = UDim2.new(0, 300, 0, 250)
            pickerFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
            pickerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
            createCorner(pickerFrame, 12)
            addGlow(pickerFrame, Zenith.Theme.Primary, 2)
            makeDraggable(pickerFrame)
            
            local hueSlider = Instance.new("Frame")
            hueSlider.Parent = pickerFrame
            hueSlider.BackgroundColor3 = Color3.fromRGB(255,0,0)
            hueSlider.Size = UDim2.new(0.8, 0, 0, 20)
            hueSlider.Position = UDim2.new(0.1, 0, 0, 200)
            createCorner(hueSlider, 10)
            
            local hue = 0
            local sat = 1
            local val = 1
            
            local function updateColor()
                local color = Color3.fromHSV(hue, sat, val)
                colorBtn.BackgroundColor3 = color
                if options.Callback then options.Callback(color) end
            end
            
            -- Simplified: just hue slider for demo
            local draggingHue = false
            hueSlider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingHue = true
                    local x = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
                    hue = x
                    updateColor()
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local x = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
                    hue = x
                    updateColor()
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingHue = false
                end
            end)
            
            local closePicker = Instance.new("TextButton")
            closePicker.Parent = pickerFrame
            closePicker.BackgroundColor3 = Zenith.Theme.Danger
            closePicker.Size = UDim2.new(0, 60, 0, 30)
            closePicker.Position = UDim2.new(0.5, -30, 0, 210)
            closePicker.Font = Enum.Font.GothamBold
            closePicker.Text = "Close"
            closePicker.TextColor3 = Zenith.Theme.Text
            closePicker.TextSize = 14
            createCorner(closePicker, 6)
            closePicker.MouseButton1Click:Connect(function()
                pickerGui:Destroy()
                pickerGui = nil
            end)
        end)
        return frame
    end
    
    function api:CreateKeybind(options)
        local frame = Instance.new("Frame")
        frame.Parent = tabContent
        frame.BackgroundColor3 = Zenith.Theme.Surface
        frame.BorderSizePixel = 0
        frame.Size = UDim2.new(1, 0, 0, 45)
        createCorner(frame, 8)
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -140, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.Font = Enum.Font.Gotham
        label.Text = options.Text or "Keybind"
        label.TextColor3 = Zenith.Theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local keyBtn = Instance.new("TextButton")
        keyBtn.Parent = frame
        keyBtn.BackgroundColor3 = Zenith.Theme.SurfaceLight
        keyBtn.Size = UDim2.new(0, 120, 0, 32)
        keyBtn.Position = UDim2.new(1, -132, 0, 6)
        keyBtn.Font = Enum.Font.Gotham
        keyBtn.Text = options.Default or "None"
        keyBtn.TextColor3 = Zenith.Theme.Text
        keyBtn.TextSize = 12
        createCorner(keyBtn, 6)
        
        local listening = false
        keyBtn.MouseButton1Click:Connect(function()
            listening = true
            keyBtn.Text = "..."
            local connection
            connection = UserInputService.InputBegan:Connect(function(input, gp)
                if gp then return end
                if listening and input.KeyCode ~= Enum.KeyCode.Unknown then
                    local key = input.KeyCode.Name
                    keyBtn.Text = key
                    listening = false
                    if options.Callback then options.Callback(key) end
                    connection:Disconnect()
                end
            end)
            task.wait(5)
            if listening then
                listening = false
                keyBtn.Text = options.Default or "None"
                connection:Disconnect()
            end
        end)
        return frame
    end
    
    function api:CreateLabel(text)
        local lbl = Instance.new("TextLabel")
        lbl.Parent = tabContent
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 0, 25)
        lbl.Font = Enum.Font.Gotham
        lbl.Text = text
        lbl.TextColor3 = Zenith.Theme.TextDim
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        return lbl
    end
    
    function api:CreateParagraph(text)
        local para = Instance.new("TextLabel")
        para.Parent = tabContent
        para.BackgroundTransparency = 1
        para.Size = UDim2.new(1, 0, 0, 50)
        para.Font = Enum.Font.Gotham
        para.Text = text
        para.TextColor3 = Zenith.Theme.TextDim
        para.TextSize = 12
        para.TextWrapped = true
        para.TextXAlignment = Enum.TextXAlignment.Left
        return para
    end
    
    function api:CreateSeparator()
        local sep = Instance.new("Frame")
        sep.Parent = tabContent
        sep.BackgroundColor3 = Zenith.Theme.SurfaceLight
        sep.Size = UDim2.new(1, 0, 0, 2)
        sep.BorderSizePixel = 0
        return sep
    end
    
    return api
end

-- Public window creator
function Zenith:CreateWindow(options)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZenithWindow_" .. tostring(os.clock())
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.BackgroundColor3 = Zenith.Theme.Background
    frame.BorderSizePixel = 0
    frame.Size = options.Size or UDim2.new(0, 900, 0, 600)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    createCorner(frame, 12)
    addGlow(frame, Zenith.Theme.Primary, 2)
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Parent = frame
    titleBar.BackgroundColor3 = Zenith.Theme.Surface
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BorderSizePixel = 0
    createCorner(titleBar, 12)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = titleBar
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = options.Title or "Zenith UI"
    titleLabel.TextColor3 = Zenith.Theme.Primary
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = titleBar
    closeBtn.BackgroundColor3 = Zenith.Theme.Danger
    closeBtn.Size = UDim2.new(0, 35, 1, -10)
    closeBtn.Position = UDim2.new(1, -45, 0, 5)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Zenith.Theme.Text
    closeBtn.TextSize = 18
    closeBtn.BorderSizePixel = 0
    createCorner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
    
    -- Tab bar
    local tabBar = Instance.new("Frame")
    tabBar.Parent = frame
    tabBar.BackgroundColor3 = Zenith.Theme.Surface
    tabBar.BorderSizePixel = 0
    tabBar.Size = UDim2.new(1, 0, 0, 40)
    tabBar.Position = UDim2.new(0, 0, 0, 45)
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = tabBar
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    
    -- Content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Parent = frame
    contentContainer.BackgroundTransparency = 1
    contentContainer.Size = UDim2.new(1, 0, 1, -85)
    contentContainer.Position = UDim2.new(0, 0, 0, 85)
    
    -- Make draggable
    makeDraggable(frame, titleBar)
    
    -- Optional resizing
    if options.Resizable then
        makeResizable(frame, UDim2.new(0, 600, 0, 400), UDim2.new(0, 1200, 0, 800))
    end
    
    local windowApi = {
        Gui = gui,
        Frame = frame,
        TabBar = tabBar,
        ContentContainer = contentContainer,
        CreateTab = function(self, name, icon)
            return Window:CreateTab(self, name, icon)
        end,
        Destroy = function() gui:Destroy() end,
        SetTitle = function(newTitle) titleLabel.Text = newTitle end,
    }
    setmetatable(windowApi, {__index = Window})
    return windowApi
end

-- Global theme setter
function Zenith:SetTheme(themeTable)
    for k,v in pairs(themeTable) do
        if Zenith.Theme[k] then
            Zenith.Theme[k] = v
        end
    end
end

return Zenith
