--[[
    ███████╗███████╗███╗   ██╗██╗████████╗██╗  ██╗
    ╚══███╔╝██╔════╝████╗  ██║██║╚══██╔══╝██║  ██║
      ███╔╝ █████╗  ██╔██╗ ██║██║   ██║   ███████║
     ███╔╝  ██╔══╝  ██║╚██╗██║██║   ██║   ██╔══██║
    ███████╗███████╗██║ ╚████║██║   ██║   ██║  ██║
    ╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝   ╚═╝   ╚═╝  ╚═╝
    
    Zenith UI v3.0 – Advanced Cyberpunk UI Library
    Enhanced with advanced animations, effects & components.
    Inspired by Rayfield, CSGO UI Lib, and modern notification systems.
    Made for Roblox exploiters and developers.
]]

local Zenith = {}
Zenith.__version = "3.0.0"

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Optimized references
local cloneref = cloneref or function(obj) return obj end
local CoreGui = cloneref(CoreGui)

-- Default colors (cyberpunk theme with extended palette)
local DefaultTheme = {
    Background = Color3.fromRGB(10, 10, 20),
    Surface = Color3.fromRGB(20, 20, 35),
    SurfaceLight = Color3.fromRGB(30, 30, 50),
    Primary = Color3.fromRGB(0, 255, 255),      -- neon cyan
    Secondary = Color3.fromRGB(255, 0, 255),    -- neon magenta
    Accent = Color3.fromRGB(255, 200, 0),       -- gold
    Danger = Color3.fromRGB(255, 50, 50),
    Success = Color3.fromRGB(50, 255, 50),
    Warning = Color3.fromRGB(255, 165, 0),
    Info = Color3.fromRGB(100, 200, 255),
    Text = Color3.fromRGB(240, 240, 255),
    TextDim = Color3.fromRGB(160, 160, 200),
    Border = Color3.fromRGB(0, 255, 255),
    -- Extended gradient colors
    PrimaryGradient = Color3.fromRGB(0, 200, 255),
    SecondaryGradient = Color3.fromRGB(200, 0, 255),
    AccentGradient = Color3.fromRGB(255, 100, 0),
}

-- Theme storage (can be overridden)
Zenith.Theme = {}
for k,v in pairs(DefaultTheme) do Zenith.Theme[k] = v end

-- Animation presets for consistency
local AnimationPresets = {
    Fast = {Duration = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out},
    Normal = {Duration = 0.3, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out},
    Smooth = {Duration = 0.5, Style = Enum.EasingStyle.Sine, Direction = Enum.EasingDirection.InOut},
    Slow = {Duration = 0.8, Style = Enum.EasingStyle.Sine, Direction = Enum.EasingDirection.InOut},
    Bounce = {Duration = 0.4, Style = Enum.EasingStyle.Back, Direction = Enum.EasingDirection.Out},
}

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

local function addGradient(instance, startColor, endColor, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Parent = instance
    rotation = rotation or 45
    gradient.Rotation = rotation
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, startColor or Zenith.Theme.Primary),
        ColorSequenceKeypoint.new(1, endColor or Zenith.Theme.Secondary)
    })
    return gradient
end

local function addShadow(instance, color, size, transparency)
    local shadow = Instance.new("Frame")
    shadow.Parent = instance.Parent
    shadow.BackgroundColor3 = color or Zenith.Theme.Background
    shadow.BorderSizePixel = 0
    shadow.Size = UDim2.new(instance.Size.X.Scale, instance.Size.X.Offset + (size or 5), 
                             instance.Size.Y.Scale, instance.Size.Y.Offset + (size or 5))
    shadow.Position = UDim2.new(instance.Position.X.Scale, instance.Position.X.Offset + 2,
                                instance.Position.Y.Scale, instance.Position.Y.Offset + 2)
    shadow.ZIndex = instance.ZIndex - 1
    shadow.BackgroundTransparency = transparency or 0.7
    createCorner(shadow, 8)
    shadow.LayoutOrder = instance.LayoutOrder - 1
    return shadow
end

local function tween(obj, props, duration, style, direction)
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    duration = duration or 0.3
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

local function lerp(a, b, t)
    return a + (b - a) * t
end

-- Notification queue
local notificationQueue = {}
local activeNotifs = {}

local function showNextNotification()
    if #notificationQueue == 0 then return end
    local notif = table.remove(notificationQueue, 1)
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZenithNotif"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.BackgroundColor3 = notif.Type == "error" and Zenith.Theme.Danger or 
                             notif.Type == "success" and Zenith.Theme.Success or
                             notif.Type == "warning" and Zenith.Theme.Warning or Zenith.Theme.Primary
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(0, 320, 0, 100)
    frame.Position = UDim2.new(1, -340, 0, #activeNotifs * 110 + 20)
    frame.AnchorPoint = Vector2.new(1, 0)
    createCorner(frame, 12)
    
    -- Glow effect based on notification type
    local glowColor = notif.Type == "error" and Zenith.Theme.Danger or Zenith.Theme.Primary
    addGlow(frame, glowColor, 2, 0.3)
    
    -- Add gradient background for enhancement
    addGradient(frame, Color3.fromRGB(25, 25, 40), Color3.fromRGB(35, 35, 50), 135)
    
    -- Icon
    if notif.Icon then
        local icon = Instance.new("ImageLabel")
        icon.Parent = frame
        icon.BackgroundTransparency = 1
        icon.Position = UDim2.new(0, 12, 0, 12)
        icon.Size = UDim2.new(0, 24, 0, 24)
        icon.Image = notif.Icon
        icon.ImageColor3 = glowColor
    end
    
    local title = Instance.new("TextLabel")
    title.Parent = frame
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 50, 0, 8)
    title.Size = UDim2.new(1, -72, 0, 25)
    title.Font = Enum.Font.GothamBold
    title.Text = notif.Title or "Notification"
    title.TextColor3 = glowColor
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local content = Instance.new("TextLabel")
    content.Parent = frame
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 50, 0, 35)
    content.Size = UDim2.new(1, -72, 0, 55)
    content.Font = Enum.Font.Gotham
    content.Text = notif.Content or ""
    content.TextColor3 = Zenith.Theme.Text
    content.TextSize = 12
    content.TextWrapped = true
    content.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Progressive accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Parent = frame
    accentBar.BackgroundColor3 = glowColor
    accentBar.BorderSizePixel = 0
    accentBar.Position = UDim2.new(0, 0, 1, -4)
    accentBar.Size = UDim2.new(0, 0, 0, 4)
    
    table.insert(activeNotifs, gui)
    
    -- Smooth slide-in animation
    tween(frame, {Position = UDim2.new(1, -340, 0, #activeNotifs * 110 + 20)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Animated progress bar
    tween(accentBar, {Size = UDim2.new(1, 0, 0, 4)}, notif.Duration or 3, Enum.EasingStyle.Linear)
    
    task.wait(notif.Duration or 3)
    
    -- Smooth exit animation
    tween(frame, {Position = UDim2.new(1, 0, 0, #activeNotifs * 110 + 20)}, 0.3, Enum.EasingStyle.Back):OnComplete(function()
        gui:Destroy()
        local index = table.find(activeNotifs, gui)
        if index then table.remove(activeNotifs, index) end
        showNextNotification()
    end)
end

function Zenith:Notify(options)
    options = options or {}
    options.Type = options.Type or "info"
    options.Duration = options.Duration or 3
    table.insert(notificationQueue, options)
    showNextNotification()
end

-- Toast notification (alternative style - slide from top)
function Zenith:Toast(title, message, duration)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZenithToast"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.BackgroundColor3 = Zenith.Theme.Surface
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(0, 400, 0, 60)
    frame.Position = UDim2.new(0.5, -200, 0, -80)
    frame.AnchorPoint = Vector2.new(0.5, 0)
    createCorner(frame, 10)
    addGlow(frame, Zenith.Theme.Primary, 2)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = frame
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 15, 0, 5)
    titleLabel.Size = UDim2.new(1, -30, 0, 20)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Zenith.Theme.Primary
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Parent = frame
    msgLabel.BackgroundTransparency = 1
    msgLabel.Position = UDim2.new(0, 15, 0, 30)
    msgLabel.Size = UDim2.new(1, -30, 0, 25)
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.Text = message or ""
    msgLabel.TextColor3 = Zenith.Theme.Text
    msgLabel.TextSize = 12
    msgLabel.TextWrapped = true
    
    -- Slide down animation
    tween(frame, {Position = UDim2.new(0.5, -200, 0, 20)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    task.wait(duration or 3)
    
    -- Slide up animation and fade
    tween(frame, {Position = UDim2.new(0.5, -200, 0, -80)}, 0.3, Enum.EasingStyle.Back):OnComplete(function()
        gui:Destroy()
    end)
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
    bg.BackgroundTransparency = 0.7
    bg.Size = UDim2.new(1, 0, 1, 0)
    
    local frame = Instance.new("Frame")
    frame.Parent = loadingGui
    frame.BackgroundColor3 = Zenith.Theme.Surface
    frame.Size = UDim2.new(0, 300, 0, 140)
    frame.Position = UDim2.new(0.5, -150, 0.5, -70)
    frame.AnchorPoint = Vector2.new(0, 0)
    createCorner(frame, 12)
    addGlow(frame, Zenith.Theme.Primary, 2.5)
    addGradient(frame, Color3.fromRGB(20, 20, 35), Color3.fromRGB(30, 30, 50), 90)
    
    local text = Instance.new("TextLabel")
    text.Parent = frame
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, 0, 0, 35)
    text.Position = UDim2.new(0, 0, 0, 15)
    text.Font = Enum.Font.GothamBold
    text.Text = message or "Loading..."
    text.TextColor3 = Zenith.Theme.Text
    text.TextSize = 18
    
    -- Animated loading spinner (rotating dots)
    local spinnerFrame = Instance.new("Frame")
    spinnerFrame.Parent = frame
    spinnerFrame.BackgroundTransparency = 1
    spinnerFrame.Size = UDim2.new(1, 0, 0, 50)
    spinnerFrame.Position = UDim2.new(0, 0, 0.5, 5)
    
    local dots = {}
    for i = 1, 3 do
        local dot = Instance.new("Frame")
        dot.Parent = spinnerFrame
        dot.BackgroundColor3 = Zenith.Theme.Primary
        dot.BorderSizePixel = 0
        dot.Size = UDim2.new(0, 8, 0, 8)
        dot.Position = UDim2.new(0.5, -12 + (i-1) * 8, 0.5, -4)
        createCorner(dot, 4)
        table.insert(dots, dot)
    end
    
    task.spawn(function()
        while loadingGui do
            for i, dot in ipairs(dots) do
                task.spawn(function()
                    for _ = 1, 2 do
                        tween(dot, {BackgroundTransparency = 0.5}, 0.3, Enum.EasingStyle.Quad)
                        task.wait(0.3)
                        tween(dot, {BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Quad)
                        task.wait(0.3)
                    end
                end)
                task.wait(0.2)
            end
        end
    end)
end

function Zenith:HideLoading()
    if loadingGui then 
        tween(loadingGui.Frame, {BackgroundTransparency = 1}, 0.3):OnComplete(function()
            loadingGui:Destroy()
            loadingGui = nil
        end)
    end
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
    tabContent.ScrollBarThickness = 8
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.ScrollBarImageColor3 = Zenith.Theme.Primary
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = tabContent
    layout.Padding = UDim.new(0, 15)
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
                tween(btn, {BackgroundColor3 = Zenith.Theme.SurfaceLight}, 0.2)
                tween(btn, {TextColor3 = Zenith.Theme.Text}, 0.2)
            end
        end
        tween(tabBtn, {BackgroundColor3 = Zenith.Theme.Primary}, 0.2)
        tween(tabBtn, {TextColor3 = Color3.fromRGB(0, 0, 0)}, 0.2)
        
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
        btn.Size = UDim2.new(1, 0, 0, 45)
        btn.Font = Enum.Font.GothamBold
        btn.Text = options.Text or "Button"
        btn.TextColor3 = Zenith.Theme.Text
        btn.TextSize = 16
        createCorner(btn, 10)
        addGlow(btn, Zenith.Theme.Primary, 1.5)
        
        -- Add gradient background
        addGradient(btn, Color3.fromRGB(30, 30, 50), Color3.fromRGB(40, 40, 60), 135)
        
        -- Hover effect
        local function onMouseEnter()
            tween(btn, {BackgroundColor3 = Zenith.Theme.Primary}, 0.2)
            tween(btn, {TextColor3 = Color3.fromRGB(0, 0, 0)}, 0.2)
            btn.Size = UDim2.new(1, 0, 0, 48)
        end
        
        local function onMouseLeave()
            tween(btn, {BackgroundColor3 = Zenith.Theme.Surface}, 0.2)
            tween(btn, {TextColor3 = Zenith.Theme.Text}, 0.2)
            btn.Size = UDim2.new(1, 0, 0, 45)
        end
        
        btn.MouseEnter:Connect(onMouseEnter)
        btn.MouseLeave:Connect(onMouseLeave)
        
        btn.MouseButton1Click:Connect(function()
            tween(btn, {BackgroundColor3 = Zenith.Theme.Accent}, 0.1)
            task.wait(0.1)
            tween(btn, {BackgroundColor3 = Zenith.Theme.Primary}, 0.1)
            if options.Callback then options.Callback() end
        end)
        return btn
    end
    
    function api:CreateToggle(options)
        local frame = Instance.new("Frame")
        frame.Parent = tabContent
        frame.BackgroundColor3 = Zenith.Theme.Surface
        frame.BorderSizePixel = 0
        frame.Size = UDim2.new(1, 0, 0, 50)
        createCorner(frame, 10)
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -100, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.Font = Enum.Font.Gotham
        label.Text = options.Text or "Toggle"
        label.TextColor3 = Zenith.Theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Toggle switch background
        local switchBg = Instance.new("Frame")
        switchBg.Parent = frame
        switchBg.BackgroundColor3 = Zenith.Theme.SurfaceLight
        switchBg.BorderSizePixel = 0
        switchBg.Size = UDim2.new(0, 56, 0, 30)
        switchBg.Position = UDim2.new(1, -68, 0.5, -15)
        createCorner(switchBg, 15)
        
        -- Toggle switch button
        local switchBtn = Instance.new("Frame")
        switchBtn.Parent = switchBg
        switchBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
        switchBtn.BorderSizePixel = 0
        switchBtn.Size = UDim2.new(0, 24, 0, 24)
        switchBtn.Position = UDim2.new(0, 3, 0.5, -12)
        createCorner(switchBtn, 12)
        
        local state = options.Default or false
        
        if state then
            switchBg.BackgroundColor3 = Zenith.Theme.Success
            switchBtn.Position = UDim2.new(0, 29, 0.5, -12)
        end
        
        local toggleClickArea = Instance.new("TextButton")
        toggleClickArea.Parent = frame
        toggleClickArea.BackgroundTransparency = 1
        toggleClickArea.Size = UDim2.new(0, 80, 1, 0)
        toggleClickArea.Position = UDim2.new(1, -80, 0, 0)
        toggleClickArea.Text = ""
        
        toggleClickArea.MouseButton1Click:Connect(function()
            state = not state
            
            if state then
                tween(switchBg, {BackgroundColor3 = Zenith.Theme.Success}, 0.3)
                tween(switchBtn, {Position = UDim2.new(0, 29, 0.5, -12)}, 0.3, Enum.EasingStyle.Quad)
            else
                tween(switchBg, {BackgroundColor3 = Zenith.Theme.SurfaceLight}, 0.3)
                tween(switchBtn, {Position = UDim2.new(0, 3, 0.5, -12)}, 0.3, Enum.EasingStyle.Quad)
            end
            
            if options.Callback then options.Callback(state) end
        end)
        
        return frame
    end
    
    function api:CreateSlider(options)
        local frame = Instance.new("Frame")
        frame.Parent = tabContent
        frame.BackgroundColor3 = Zenith.Theme.Surface
        frame.BorderSizePixel = 0
        frame.Size = UDim2.new(1, 0, 0, 85)
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
        valueLabel.Size = UDim2.new(0, 80, 0, 20)
        valueLabel.Position = UDim2.new(1, -92, 0, 8)
        valueLabel.Font = Enum.Font.Gotham
        valueLabel.Text = tostring(options.Default or options.Min or 0)
        valueLabel.TextColor3 = Zenith.Theme.Primary
        valueLabel.TextSize = 12
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Parent = frame
        sliderBg.BackgroundColor3 = Zenith.Theme.SurfaceLight
        sliderBg.BorderSizePixel = 0
        sliderBg.Size = UDim2.new(1, -24, 0, 6)
        sliderBg.Position = UDim2.new(0, 12, 0, 45)
        createCorner(sliderBg, 3)
        
        local fill = Instance.new("Frame")
        fill.Parent = sliderBg
        fill.BackgroundColor3 = Zenith.Theme.Primary
        fill.BorderSizePixel = 0
        fill.Size = UDim2.new(0, 0, 1, 0)
        createCorner(fill, 3)
        
        -- Add gradient to fill for better visuals
        addGradient(fill, Zenith.Theme.Primary, Zenith.Theme.PrimaryGradient, 0)
        
        -- Animated slider thumb
        local thumb = Instance.new("Frame")
        thumb.Parent = sliderBg
        thumb.BackgroundColor3 = Zenith.Theme.Primary
        thumb.BorderSizePixel = 0
        thumb.Size = UDim2.new(0, 14, 0, 14)
        thumb.Position = UDim2.new(0, 0, 0.5, -7)
        createCorner(thumb, 7)
        addGlow(thumb, Zenith.Theme.Primary, 1.5)
        
        local min = options.Min or 0
        local max = options.Max or 100
        local value = options.Default or min
        local decimals = options.Decimals or 0
        
        local function updateSlider(val)
            val = math.clamp(val, min, max)
            value = val
            local percent = (val - min) / (max - min)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            thumb.Position = UDim2.new(percent, -7, 0.5, -7)
            valueLabel.Text = string.format("%." .. decimals .. "f", val)
            if options.Callback then options.Callback(val) end
            
            -- Smooth scale animation on thumb
            tween(thumb, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(percent, -8, 0.5, -8)}, 0.1)
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
                tween(thumb, {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7)}, 0.15)
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
    
    function api:CreateProgressBar(options)
        local frame = Instance.new("Frame")
        frame.Parent = tabContent
        frame.BackgroundColor3 = Zenith.Theme.Surface
        frame.BorderSizePixel = 0
        frame.Size = UDim2.new(1, 0, 0, 50)
        createCorner(frame, 8)
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -20, 0, 15)
        label.Position = UDim2.new(0, 12, 0, 5)
        label.Font = Enum.Font.Gotham
        label.Text = options.Text or "Progress"
        label.TextColor3 = Zenith.Theme.Text
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local progressBg = Instance.new("Frame")
        progressBg.Parent = frame
        progressBg.BackgroundColor3 = Zenith.Theme.SurfaceLight
        progressBg.BorderSizePixel = 0
        progressBg.Size = UDim2.new(1, -24, 0, 8)
        progressBg.Position = UDim2.new(0, 12, 0, 28)
        createCorner(progressBg, 4)
        
        local progressFill = Instance.new("Frame")
        progressFill.Parent = progressBg
        progressFill.BackgroundColor3 = Zenith.Theme.Primary
        progressFill.BorderSizePixel = 0
        progressFill.Size = UDim2.new(0, 0, 1, 0)
        createCorner(progressFill, 4)
        addGradient(progressFill, Zenith.Theme.Primary, Zenith.Theme.PrimaryGradient)
        
        local function SetProgress(percent)
            percent = math.clamp(percent, 0, 1)
            tween(progressFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.3, Enum.EasingStyle.Quad)
        end
        
        return {frame = frame, SetProgress = SetProgress}
    end
    
    function api:CreateInput(options)
        local frame = Instance.new("Frame")
        frame.Parent = tabContent
        frame.BackgroundColor3 = Zenith.Theme.Surface
        frame.BorderSizePixel = 0
        frame.Size = UDim2.new(1, 0, 0, 50)
        createCorner(frame, 8)
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -20, 0, 15)
        label.Position = UDim2.new(0, 12, 0, 5)
        label.Font = Enum.Font.Gotham
        label.Text = options.Text or "Input"
        label.TextColor3 = Zenith.Theme.Text
        label.TextSize = 12
        
        local inputBg = Instance.new("Frame")
        inputBg.Parent = frame
        inputBg.BackgroundColor3 = Zenith.Theme.SurfaceLight
        inputBg.BorderSizePixel = 0
        inputBg.Size = UDim2.new(1, -24, 0, 22)
        inputBg.Position = UDim2.new(0, 12, 0, 23)
        createCorner(inputBg, 6)
        
        local textBox = Instance.new("TextBox")
        textBox.Parent = inputBg
        textBox.BackgroundTransparency = 1
        textBox.Size = UDim2.new(1, -12, 1, 0)
        textBox.Position = UDim2.new(0, 6, 0, 0)
        textBox.Font = Enum.Font.Gotham
        textBox.TextColor3 = Zenith.Theme.Text
        textBox.PlaceholderColor3 = Zenith.Theme.TextDim
        textBox.PlaceholderText = options.Placeholder or "Enter text..."
        textBox.TextSize = 12
        
        -- Focus animation
        textBox.FocusLost:Connect(function()
            tween(inputBg, {BackgroundColor3 = Zenith.Theme.SurfaceLight}, 0.2)
        end)
        textBox.Focused:Connect(function()
            tween(inputBg, {BackgroundColor3 = Color3.fromRGB(40, 40, 60)}, 0.2)
            addGlow(inputBg, Zenith.Theme.Primary, 1, 0.2)
        end)
        
        return {frame = frame, textBox = textBox, GetText = function() return textBox.Text end}
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
    addGlow(frame, Zenith.Theme.Primary, 2.5)
    addGradient(frame, Color3.fromRGB(5, 5, 15), Color3.fromRGB(20, 20, 35), 180)
    
    -- Title bar with gradient
    local titleBar = Instance.new("Frame")
    titleBar.Parent = frame
    titleBar.BackgroundColor3 = Zenith.Theme.Surface
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BorderSizePixel = 0
    createCorner(titleBar, 12)
    addGradient(titleBar, Zenith.Theme.Surface, Color3.fromRGB(30, 30, 50), 90)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = titleBar
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -120, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = options.Title or "Zenith UI"
    titleLabel.TextColor3 = Zenith.Theme.Primary
    titleLabel.TextSize = 20
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = titleBar
    closeBtn.BackgroundColor3 = Zenith.Theme.Danger
    closeBtn.Size = UDim2.new(0, 40, 0, 35)
    closeBtn.Position = UDim2.new(1, -50, 0.5, -17)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Zenith.Theme.Text
    closeBtn.TextSize = 18
    closeBtn.BorderSizePixel = 0
    createCorner(closeBtn, 8)
    
    closeBtn.MouseButton1Click:Connect(function()
        -- Close animation
        tween(frame, {Position = UDim2.new(0.5, 0, 0.5 + 0.3, 0)}, 0.3, Enum.EasingStyle.Back):OnComplete(function()
            gui:Destroy()
        end)
    end)
    
    -- Hover effects on close button
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}, 0.2)
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, {BackgroundColor3 = Zenith.Theme.Danger}, 0.2)
    end)
    
    -- Tab bar
    local tabBar = Instance.new("Frame")
    tabBar.Parent = frame
    tabBar.BackgroundColor3 = Zenith.Theme.Surface
    tabBar.BorderSizePixel = 0
    tabBar.Size = UDim2.new(1, 0, 0, 45)
    tabBar.Position = UDim2.new(0, 0, 0, 50)
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = tabBar
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.Parent = tabBar
    tabPadding.PaddingLeft = UDim.new(0, 15)
    tabPadding.PaddingTop = UDim.new(0, 5)
    tabPadding.PaddingRight = UDim.new(0, 15)
    
    -- Content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Parent = frame
    contentContainer.BackgroundTransparency = 1
    contentContainer.Size = UDim2.new(1, 0, 1, -95)
    contentContainer.Position = UDim2.new(0, 0, 0, 95)
    
    -- Make draggable
    makeDraggable(frame, titleBar)
    
    -- Optional resizing
    if options.Resizable then
        makeResizable(frame, UDim2.new(0, 600, 0, 400), UDim2.new(0, 1400, 0, 900))
    end
    
    -- Open animation
    frame.Position = UDim2.new(0.5, 0, 0.5 - 0.3, 0)
    tween(frame, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
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

-- Utility to create themed presets
function Zenith:CreateTheme(name, colors)
    local themes = {
        Dark = {
            Background = Color3.fromRGB(10, 10, 20),
            Surface = Color3.fromRGB(20, 20, 35),
            SurfaceLight = Color3.fromRGB(30, 30, 50),
            Primary = Color3.fromRGB(0, 255, 255),
            Secondary = Color3.fromRGB(255, 0, 255),
            Accent = Color3.fromRGB(255, 200, 0),
        },
        Purple = {
            Background = Color3.fromRGB(15, 10, 25),
            Surface = Color3.fromRGB(30, 20, 50),
            SurfaceLight = Color3.fromRGB(40, 30, 65),
            Primary = Color3.fromRGB(150, 100, 255),
            Secondary = Color3.fromRGB(200, 50, 200),
            Accent = Color3.fromRGB(100, 255, 255),
        },
        Ocean = {
            Background = Color3.fromRGB(5, 20, 40),
            Surface = Color3.fromRGB(10, 40, 70),
            SurfaceLight = Color3.fromRGB(20, 60, 100),
            Primary = Color3.fromRGB(0, 180, 255),
            Secondary = Color3.fromRGB(100, 200, 255),
            Accent = Color3.fromRGB(50, 220, 200),
        }
    }
    
    if themes[name] then
        self:SetTheme(themes[name])
        return themes[name]
    elseif colors then
        return colors
    end
end

-- ============================================================
-- MODAL & POPUP SYSTEM v2.0 - Cyberpunk Popup UI Framework
-- ============================================================

local activeModals = {}
local modalManager = {}

local function createCorner(obj, radius)
    local corner = Instance.new("UICorner")
    corner.Parent = obj
    corner.CornerRadius = UDim.new(0, radius or 8)
    return corner
end

-- Advanced popup background
local function createModalBackground()
    local bgGui = Instance.new("ScreenGui")
    bgGui.Name = "ModalBg"
    bgGui.Parent = CoreGui
    bgGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local backdrop = Instance.new("Frame")
    backdrop.Parent = bgGui
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BorderSizePixel = 0
    backdrop.BackgroundTransparency = 0.4
    backdrop.ZIndex = 100
    
    return {gui = bgGui, backdrop = backdrop}
end

-- Glitch effect for cyberpunk aesthetic
local function applyGlitchEffect(frame)
    local original = frame.Position
    local function glitch()
        for _ = 1, 3 do
            frame.Position = UDim2.new(original.X.Scale, original.X.Offset + math.random(-2, 2), 
                                       original.Y.Scale, original.Y.Offset + math.random(-2, 2))
            task.wait(0.05)
        end
        frame.Position = original
    end
    return glitch
end

-- Create a basic modal window
function Zenith:CreateModal(options)
    options = options or {}
    
    local title = options.Title or "Modal"
    local content = options.Content or ""
    local size = options.Size or UDim2.new(0, 500, 0, 350)
    local onClose = options.OnClose or function() end
    local onConfirm = options.OnConfirm or function() end
    local showConfirm = options.ShowConfirm ~= false
    
    local bg = createModalBackground()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ModalWindow"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = gui
    mainFrame.BackgroundColor3 = Zenith.Theme.Background
    mainFrame.Size = size
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, -0.5, 0)
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 101
    createCorner(mainFrame, 15)
    addGlow(mainFrame, Zenith.Theme.Primary, 3)
    addGradient(mainFrame, Color3.fromRGB(15, 15, 30), Color3.fromRGB(25, 25, 45), 135)
    
    -- Animate in
    tween(mainFrame, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Parent = mainFrame
    titleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
    titleBar.BorderSizePixel = 0
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.ZIndex = 102
    createCorner(titleBar, 15)
    addGlow(titleBar, Zenith.Theme.Secondary, 1.5, 0.4)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = titleBar
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Zenith.Theme.Primary
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = titleBar
    closeBtn.BackgroundColor3 = Zenith.Theme.Danger
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -17)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Zenith.Theme.Text
    closeBtn.TextSize = 16
    closeBtn.BorderSizePixel = 0
    closeBtn.ZIndex = 103
    createCorner(closeBtn, 6)
    
    -- Content area
    local contentArea = Instance.new("TextLabel")
    contentArea.Parent = mainFrame
    contentArea.BackgroundTransparency = 1
    contentArea.Position = UDim2.new(0, 20, 0, 60)
    contentArea.Size = UDim2.new(1, -40, 1, showConfirm and -130 or -80)
    contentArea.Font = Enum.Font.Gotham
    contentArea.Text = content
    contentArea.TextColor3 = Zenith.Theme.Text
    contentArea.TextSize = 14
    contentArea.TextWrapped = true
    contentArea.TextYAlignment = Enum.TextYAlignment.Top
    contentArea.ZIndex = 102
    
    -- Button container
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Parent = mainFrame
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Position = UDim2.new(0, 20, 1, -60)
    buttonContainer.Size = UDim2.new(1, -40, 0, 50)
    buttonContainer.ZIndex = 102
    
    local closeClicked = false
    local function closeModal()
        if closeClicked then return end
        closeClicked = true
        tween(mainFrame, {Position = UDim2.new(0.5, 0, 1.5, 0)}, 0.3, Enum.EasingStyle.Back):OnComplete(function()
            gui:Destroy()
            bg.gui:Destroy()
        end)
        onClose()
    end
    
    closeBtn.MouseButton1Click:Connect(closeModal)
    closeBtn.MouseEnter:Connect(function() tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}, 0.2) end)
    closeBtn.MouseLeave:Connect(function() tween(closeBtn, {BackgroundColor3 = Zenith.Theme.Danger}, 0.2) end)
    
    if showConfirm then
        local confirmBtn = Instance.new("TextButton")
        confirmBtn.Parent = buttonContainer
        confirmBtn.BackgroundColor3 = Zenith.Theme.Success
        confirmBtn.Size = UDim2.new(0, 150, 0, 35)
        confirmBtn.Position = UDim2.new(1, -160, 0, 8)
        confirmBtn.Font = Enum.Font.GothamBold
        confirmBtn.Text = "Confirm"
        confirmBtn.TextColor3 = Zenith.Theme.Text
        confirmBtn.TextSize = 14
        confirmBtn.BorderSizePixel = 0
        confirmBtn.ZIndex = 103
        createCorner(confirmBtn, 6)
        
        confirmBtn.MouseButton1Click:Connect(function()
            onConfirm()
            closeModal()
        end)
        confirmBtn.MouseEnter:Connect(function() tween(confirmBtn, {BackgroundColor3 = Color3.fromRGB(100, 255, 100)}, 0.2) end)
        confirmBtn.MouseLeave:Connect(function() tween(confirmBtn, {BackgroundColor3 = Zenith.Theme.Success}, 0.2) end)
    end
    
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Parent = buttonContainer
    cancelBtn.BackgroundColor3 = Zenith.Theme.Danger
    cancelBtn.Size = UDim2.new(0, 150, 0, 35)
    cancelBtn.Position = showConfirm and UDim2.new(0, 0, 0, 8) or UDim2.new(1, -160, 0, 8)
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.Text = "Close"
    cancelBtn.TextColor3 = Zenith.Theme.Text
    cancelBtn.TextSize = 14
    cancelBtn.BorderSizePixel = 0
    cancelBtn.ZIndex = 103
    createCorner(cancelBtn, 6)
    
    cancelBtn.MouseButton1Click:Connect(closeModal)
    cancelBtn.MouseEnter:Connect(function() tween(cancelBtn, {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}, 0.2) end)
    cancelBtn.MouseLeave:Connect(function() tween(cancelBtn, {BackgroundColor3 = Zenith.Theme.Danger}, 0.2) end)
    
    table.insert(activeModals, {gui = gui, bg = bg, mainFrame = mainFrame})
    
    return {
        gui = gui,
        mainFrame = mainFrame,
        titleLabel = titleLabel,
        contentArea = contentArea,
        Close = closeModal
    }
end

-- Music/Media player popup (like your music script!)
function Zenith:CreatePlayerPopup(options)
    options = options or {}
    
    local title = options.Title or "Now Playing"
    local artist = options.Artist or "Unknown Artist"
    local onPlay = options.OnPlay or function() end
    local onPause = options.OnPause or function() end
    local onStop = options.OnStop or function() end
    local onNext = options.OnNext or function() end
    local onPrev = options.OnPrev or function() end
    
    local bg = createModalBackground()
    local gui = Instance.new("ScreenGui")
    gui.Name = "PlayerPopup"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local playerFrame = Instance.new("Frame")
    playerFrame.Parent = gui
    playerFrame.BackgroundColor3 = Zenith.Theme.Background
    playerFrame.Size = UDim2.new(0, 450, 0, 520)
    playerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    playerFrame.Position = UDim2.new(0.5, 0, -0.5, 0)
    playerFrame.BorderSizePixel = 0
    playerFrame.ZIndex = 101
    createCorner(playerFrame, 20)
    addGlow(playerFrame, Zenith.Theme.Primary, 4)
    addGradient(playerFrame, Color3.fromRGB(8, 8, 18), Color3.fromRGB(20, 20, 40), 180)
    
    -- Animate in
    tween(playerFrame, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Album art area
    local albumArea = Instance.new("Frame")
    albumArea.Parent = playerFrame
    albumArea.BackgroundColor3 = Zenith.Theme.SurfaceLight
    albumArea.BorderSizePixel = 0
    albumArea.Size = UDim2.new(1, -40, 0, 250)
    albumArea.Position = UDim2.new(0, 20, 0, 20)
    albumArea.ZIndex = 102
    createCorner(albumArea, 15)
    addGradient(albumArea, Zenith.Theme.Primary, Zenith.Theme.Secondary, 45)
    
    local albumLabel = Instance.new("TextLabel")
    albumLabel.Parent = albumArea
    albumLabel.BackgroundTransparency = 1
    albumLabel.Size = UDim2.new(1, 0, 1, 0)
    albumLabel.Font = Enum.Font.GothamBold
    albumLabel.Text = "♫"
    albumLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    albumLabel.TextSize = 120
    
    -- Song info
    local songTitle = Instance.new("TextLabel")
    songTitle.Parent = playerFrame
    songTitle.BackgroundTransparency = 1
    songTitle.Position = UDim2.new(0, 20, 0, 280)
    songTitle.Size = UDim2.new(1, -40, 0, 35)
    songTitle.Font = Enum.Font.GothamBold
    songTitle.Text = title
    songTitle.TextColor3 = Zenith.Theme.Primary
    songTitle.TextSize = 16
    songTitle.TextWrapped = true
    songTitle.ZIndex = 102
    
    local artistLabel = Instance.new("TextLabel")
    artistLabel.Parent = playerFrame
    artistLabel.BackgroundTransparency = 1
    artistLabel.Position = UDim2.new(0, 20, 0, 318)
    artistLabel.Size = UDim2.new(1, -40, 0, 25)
    artistLabel.Font = Enum.Font.Gotham
    artistLabel.Text = artist
    artistLabel.TextColor3 = Zenith.Theme.TextDim
    artistLabel.TextSize = 12
    artistLabel.ZIndex = 102
    
    -- Progress bar
    local progressBg = Instance.new("Frame")
    progressBg.Parent = playerFrame
    progressBg.BackgroundColor3 = Zenith.Theme.SurfaceLight
    progressBg.BorderSizePixel = 0
    progressBg.Size = UDim2.new(1, -40, 0, 6)
    progressBg.Position = UDim2.new(0, 20, 0, 360)
    progressBg.ZIndex = 102
    createCorner(progressBg, 3)
    
    local progressFill = Instance.new("Frame")
    progressFill.Parent = progressBg
    progressFill.BackgroundColor3 = Zenith.Theme.Primary
    progressFill.BorderSizePixel = 0
    progressFill.Size = UDim2.new(0.3, 0, 1, 0)
    progressFill.ZIndex = 103
    createCorner(progressFill, 3)
    addGradient(progressFill, Zenith.Theme.Primary, Zenith.Theme.Accent, 90)
    
    -- Time labels
    local timeStart = Instance.new("TextLabel")
    timeStart.Parent = playerFrame
    timeStart.BackgroundTransparency = 1
    timeStart.Position = UDim2.new(0, 20, 0, 372)
    timeStart.Size = UDim2.new(0, 40, 0, 20)
    timeStart.Font = Enum.Font.Gotham
    timeStart.Text = "0:00"
    timeStart.TextColor3 = Zenith.Theme.TextDim
    timeStart.TextSize = 11
    timeStart.ZIndex = 102
    
    local timeEnd = Instance.new("TextLabel")
    timeEnd.Parent = playerFrame
    timeEnd.BackgroundTransparency = 1
    timeEnd.Position = UDim2.new(1, -60, 0, 372)
    timeEnd.Size = UDim2.new(0, 40, 0, 20)
    timeEnd.Font = Enum.Font.Gotham
    timeEnd.Text = "3:45"
    timeEnd.TextColor3 = Zenith.Theme.TextDim
    timeEnd.TextSize = 11
    timeEnd.ZIndex = 102
    
    -- Control buttons
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Parent = playerFrame
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Position = UDim2.new(0, 20, 0, 410)
    buttonContainer.Size = UDim2.new(1, -40, 0, 60)
    buttonContainer.ZIndex = 102
    
    local function createControlBtn(text, position, callback)
        local btn = Instance.new("TextButton")
        btn.Parent = buttonContainer
        btn.BackgroundColor3 = Zenith.Theme.Surface
        btn.BorderSizePixel = 0
        btn.Size = UDim2.new(0, 70, 0, 50)
        btn.Position = position
        btn.Font = Enum.Font.GothamBold
        btn.Text = text
        btn.TextColor3 = Zenith.Theme.Primary
        btn.TextSize = 20
        btn.ZIndex = 103
        createCorner(btn, 10)
        addGlow(btn, Zenith.Theme.Primary, 1.5, 0.3)
        
        btn.MouseButton1Click:Connect(callback)
        btn.MouseEnter:Connect(function()
            tween(btn, {BackgroundColor3 = Zenith.Theme.Primary}, 0.15)
            tween(btn, {TextColor3 = Zenith.Theme.Background}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, {BackgroundColor3 = Zenith.Theme.Surface}, 0.15)
            tween(btn, {TextColor3 = Zenith.Theme.Primary}, 0.15)
        end)
        
        return btn
    end
    
    createControlBtn("⏮", UDim2.new(0, 0, 0, 0), onPrev)
    createControlBtn("⏸", UDim2.new(0, 85, 0, 0), onPause)
    createControlBtn("▶", UDim2.new(0, 170, 0, 0), onPlay)
    createControlBtn("⏭", UDim2.new(0, 344, 0, 0), onNext)
    
    -- Close button
    local closePlayerBtn = Instance.new("TextButton")
    closePlayerBtn.Parent = playerFrame
    closePlayerBtn.BackgroundTransparency = 1
    closePlayerBtn.Position = UDim2.new(0, 20, 0, 485)
    closePlayerBtn.Size = UDim2.new(1, -40, 0, 30)
    closePlayerBtn.Font = Enum.Font.GothamBold
    closePlayerBtn.Text = "Close Player"
    closePlayerBtn.TextColor3 = Zenith.Theme.Danger
    closePlayerBtn.TextSize = 13
    closePlayerBtn.ZIndex = 102
    
    closePlayerBtn.MouseButton1Click:Connect(function()
        tween(playerFrame, {Position = UDim2.new(0.5, 0, 1.5, 0)}, 0.4, Enum.EasingStyle.Back):OnComplete(function()
            gui:Destroy()
            bg.gui:Destroy()
        end)
        onStop()
    end)
    
    table.insert(activeModals, {gui = gui, bg = bg, mainFrame = playerFrame})
    
    return {
        gui = gui,
        playerFrame = playerFrame,
        UpdateProgress = function(percent) tween(progressFill, {Size = UDim2.new(math.clamp(percent, 0, 1), 0, 1, 0)}, 0.2) end,
        UpdateTitle = function(newTitle) songTitle.Text = newTitle end,
        UpdateArtist = function(newArtist) artistLabel.Text = newArtist end,
        Close = function() closePlayerBtn:Emit("MouseButton1Click") end
    }
end

-- Confirmation dialog
function Zenith:CreateConfirmDialog(options)
    options = options or {}
    
    local title = options.Title or "Confirm"
    local message = options.Message or "Are you sure?"
    local onConfirm = options.OnConfirm or function() end
    local onCancel = options.OnCancel or function() end
    
    local bg = createModalBackground()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ConfirmDialog"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local dialog = Instance.new("Frame")
    dialog.Parent = gui
    dialog.BackgroundColor3 = Zenith.Theme.Background
    dialog.Size = UDim2.new(0, 400, 0, 220)
    dialog.AnchorPoint = Vector2.new(0.5, 0.5)
    dialog.Position = UDim2.new(0.5, 0, -0.5, 0)
    dialog.BorderSizePixel = 0
    dialog.ZIndex = 101
    createCorner(dialog, 12)
    addGlow(dialog, Zenith.Theme.Warning, 2.5)
    addGradient(dialog, Color3.fromRGB(30, 20, 10), Color3.fromRGB(40, 25, 15), 135)
    
    tween(dialog, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Parent = dialog
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.new(0, 15, 0, 10)
    titleLbl.Size = UDim2.new(1, -30, 0, 30)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Text = title
    titleLbl.TextColor3 = Zenith.Theme.Warning
    titleLbl.TextSize = 16
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 102
    
    local msgLbl = Instance.new("TextLabel")
    msgLbl.Parent = dialog
    msgLbl.BackgroundTransparency = 1
    msgLbl.Position = UDim2.new(0, 15, 0, 45)
    msgLbl.Size = UDim2.new(1, -30, 0, 100)
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.Text = message
    msgLbl.TextColor3 = Zenith.Theme.Text
    msgLbl.TextSize = 13
    msgLbl.TextWrapped = true
    msgLbl.ZIndex = 102
    
    local yesBtn = Instance.new("TextButton")
    yesBtn.Parent = dialog
    yesBtn.BackgroundColor3 = Zenith.Theme.Success
    yesBtn.Size = UDim2.new(0, 85, 0, 30)
    yesBtn.Position = UDim2.new(0, 15, 1, -40)
    yesBtn.Font = Enum.Font.GothamBold
    yesBtn.Text = "Yes"
    yesBtn.TextColor3 = Zenith.Theme.Text
    yesBtn.TextSize = 12
    yesBtn.BorderSizePixel = 0
    yesBtn.ZIndex = 103
    createCorner(yesBtn, 6)
    
    yesBtn.MouseButton1Click:Connect(function()
        tween(dialog, {Position = UDim2.new(0.5, 0, 1.5, 0)}, 0.3, Enum.EasingStyle.Back):OnComplete(function()
            gui:Destroy()
            bg.gui:Destroy()
        end)
        onConfirm()
    end)
    
    local noBtn = Instance.new("TextButton")
    noBtn.Parent = dialog
    noBtn.BackgroundColor3 = Zenith.Theme.Danger
    noBtn.Size = UDim2.new(0, 85, 0, 30)
    noBtn.Position = UDim2.new(1, -100, 1, -40)
    noBtn.Font = Enum.Font.GothamBold
    noBtn.Text = "No"
    noBtn.TextColor3 = Zenith.Theme.Text
    noBtn.TextSize = 12
    noBtn.BorderSizePixel = 0
    noBtn.ZIndex = 103
    createCorner(noBtn, 6)
    
    noBtn.MouseButton1Click:Connect(function()
        tween(dialog, {Position = UDim2.new(0.5, 0, 1.5, 0)}, 0.3, Enum.EasingStyle.Back):OnComplete(function()
            gui:Destroy()
            bg.gui:Destroy()
        end)
        onCancel()
    end)
    
    table.insert(activeModals, {gui = gui, bg = bg, mainFrame = dialog})
    
    return {gui = gui, dialog = dialog}
end

-- Alert popup
function Zenith:CreateAlertPopup(options)
    options = options or {}
    
    local title = options.Title or "Alert"
    local message = options.Message or "Message"
    local alertType = options.Type or "info" -- "error", "warning", "success", "info"
    local onOk = options.OnOk or function() end
    
    local colorMap = {
        error = Zenith.Theme.Danger,
        warning = Zenith.Theme.Warning,
        success = Zenith.Theme.Success,
        info = Zenith.Theme.Info
    }
    
    local accentColor = colorMap[alertType] or Zenith.Theme.Info
    
    local bg = createModalBackground()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AlertPopup"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local alert = Instance.new("Frame")
    alert.Parent = gui
    alert.BackgroundColor3 = Zenith.Theme.Background
    alert.Size = UDim2.new(0, 380, 0, 200)
    alert.AnchorPoint = Vector2.new(0.5, 0.5)
    alert.Position = UDim2.new(0.5, 0, -0.5, 0)
    alert.BorderSizePixel = 0
    alert.ZIndex = 101
    createCorner(alert, 12)
    addGlow(alert, accentColor, 2, 0.3)
    
    tween(alert, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    local icon = Instance.new("TextLabel")
    icon.Parent = alert
    icon.BackgroundTransparency = 1
    icon.Position = UDim2.new(0, 15, 0, 15)
    icon.Size = UDim2.new(0, 35, 0, 35)
    icon.Font = Enum.Font.GothamBold
    icon.TextColor3 = accentColor
    icon.TextSize = 28
    icon.ZIndex = 102
    
    if alertType == "error" then icon.Text = "✕" 
    elseif alertType == "warning" then icon.Text = "⚠"
    elseif alertType == "success" then icon.Text = "✓"
    else icon.Text = "ℹ" end
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Parent = alert
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.new(0, 60, 0, 10)
    titleLbl.Size = UDim2.new(1, -75, 0, 25)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Text = title
    titleLbl.TextColor3 = accentColor
    titleLbl.TextSize = 14
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 102
    
    local msgLbl = Instance.new("TextLabel")
    msgLbl.Parent = alert
    msgLbl.BackgroundTransparency = 1
    msgLbl.Position = UDim2.new(0, 15, 0, 50)
    msgLbl.Size = UDim2.new(1, -30, 0, 80)
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.Text = message
    msgLbl.TextColor3 = Zenith.Theme.Text
    msgLbl.TextSize = 12
    msgLbl.TextWrapped = true
    msgLbl.ZIndex = 102
    
    local okBtn = Instance.new("TextButton")
    okBtn.Parent = alert
    okBtn.BackgroundColor3 = accentColor
    okBtn.Size = UDim2.new(0, 100, 0, 28)
    okBtn.Position = UDim2.new(0.5, -50, 1, -35)
    okBtn.Font = Enum.Font.GothamBold
    okBtn.Text = "OK"
    okBtn.TextColor3 = Zenith.Theme.Background
    okBtn.TextSize = 12
    okBtn.BorderSizePixel = 0
    okBtn.ZIndex = 103
    createCorner(okBtn, 6)
    
    okBtn.MouseButton1Click:Connect(function()
        tween(alert, {Position = UDim2.new(0.5, 0, 1.5, 0)}, 0.3, Enum.EasingStyle.Back):OnComplete(function()
            gui:Destroy()
            bg.gui:Destroy()
        end)
        onOk()
    end)
    
    table.insert(activeModals, {gui = gui, bg = bg, mainFrame = alert})
    
    return {gui = gui, alert = alert}
end

-- Close all active modals
function Zenith:CloseAllModals()
    for _, modal in ipairs(activeModals) do
        pcall(function()
            modal.gui:Destroy()
            modal.bg.gui:Destroy()
        end)
    end
    activeModals = {}
end

-- ============================================================
-- ADVANCED COMPONENTS - Context Menu, Leaderboard, Chat, etc
-- ============================================================

-- Context menu system (right-click menu)
function Zenith:CreateContextMenu(options)
    options = options or {}
    local items = options.Items or {}
    local position = options.Position or UserInputService:GetMouseLocation()
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "ContextMenu"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local menuFrame = Instance.new("Frame")
    menuFrame.Parent = gui
    menuFrame.BackgroundColor3 = Zenith.Theme.Surface
    menuFrame.BorderSizePixel = 0
    menuFrame.Size = UDim2.new(0, 200, 0, #items * 35 + 10)
    menuFrame.Position = UDim2.new(0, position.X, 0, position.Y)
    menuFrame.ZIndex = 200
    createCorner(menuFrame, 8)
    addGlow(menuFrame, Zenith.Theme.Primary, 1.5, 0.4)
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = menuFrame
    layout.Padding = UDim.new(0, 3)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local padding = Instance.new("UIPadding")
    padding.Parent = menuFrame
    padding.PaddingLeft = UDim.new(0, 5)
    padding.PaddingRight = UDim.new(0, 5)
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 5)
    
    for _, item in ipairs(items) do
        local itemBtn = Instance.new("TextButton")
        itemBtn.Parent = menuFrame
        itemBtn.BackgroundColor3 = Zenith.Theme.SurfaceLight
        itemBtn.Size = UDim2.new(1, 0, 0, 30)
        itemBtn.Font = Enum.Font.Gotham
        itemBtn.Text = item.Text or "Option"
        itemBtn.TextColor3 = Zenith.Theme.Text
        itemBtn.TextSize = 12
        itemBtn.BorderSizePixel = 0
        createCorner(itemBtn, 5)
        
        itemBtn.MouseButton1Click:Connect(function()
            if item.Callback then item.Callback() end
            gui:Destroy()
        end)
        
        itemBtn.MouseEnter:Connect(function()
            tween(itemBtn, {BackgroundColor3 = Zenith.Theme.Primary}, 0.1)
            tween(itemBtn, {TextColor3 = Zenith.Theme.Background}, 0.1)
        end)
        
        itemBtn.MouseLeave:Connect(function()
            tween(itemBtn, {BackgroundColor3 = Zenith.Theme.SurfaceLight}, 0.1)
            tween(itemBtn, {TextColor3 = Zenith.Theme.Text}, 0.1)
        end)
    end
    
    -- Close when clicking outside
    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            gui:Destroy()
            connection:Disconnect()
        end
    end)
    
    task.wait(0.1)
    tween(menuFrame, {Size = UDim2.new(0, 200, 0, #items * 35 + 10)}, 0.2)
    
    return gui
end

-- Leaderboard widget
function Zenith:CreateLeaderboard(options)
    options = options or {}
    local title = options.Title or "Leaderboard"
    local maxSize = options.MaxSize or UDim2.new(0, 350, 0, 400)
    local entries = options.Entries or {} -- {Name, Score, Icon/Color}
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "Leaderboard"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local lbFrame = Instance.new("Frame")
    lbFrame.Parent = gui
    lbFrame.BackgroundColor3 = Zenith.Theme.Background
    lbFrame.BorderSizePixel = 0
    lbFrame.Size = maxSize
    lbFrame.Position = options.Position or UDim2.new(1, -370, 0, 20)
    createCorner(lbFrame, 12)
    addGlow(lbFrame, Zenith.Theme.Primary, 2)
    
    local header = Instance.new("Frame")
    header.Parent = lbFrame
    header.BackgroundColor3 = Zenith.Theme.Surface
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, 45)
    createCorner(header, 12)
    addGradient(header, Zenith.Theme.Primary, Zenith.Theme.Secondary, 90)
    
    local headerLabel = Instance.new("TextLabel")
    headerLabel.Parent = header
    headerLabel.BackgroundTransparency = 1
    headerLabel.Size = UDim2.new(1, 0, 1, 0)
    headerLabel.Font = Enum.Font.GothamBold
    headerLabel.Text = "🏆 " .. title
    headerLabel.TextColor3 = Zenith.Theme.Background
    headerLabel.TextSize = 16
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Parent = lbFrame
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.Position = UDim2.new(0, 0, 0, 45)
    scrollFrame.Size = UDim2.new(1, 0, 1, -50)
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = scrollFrame
    listLayout.Padding = UDim.new(0, 5)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    for rank, entry in ipairs(entries) do
        local entryFrame = Instance.new("Frame")
        entryFrame.Parent = scrollFrame
        entryFrame.BackgroundColor3 = rank == 1 and Color3.fromRGB(255, 215, 0) or 
                                     rank == 2 and Color3.fromRGB(192, 192, 192) or
                                     rank == 3 and Color3.fromRGB(205, 127, 50) or
                                     Zenith.Theme.SurfaceLight
        entryFrame.BorderSizePixel = 0
        entryFrame.Size = UDim2.new(1, -12, 0, 35)
        createCorner(entryFrame, 6)
        
        local rankLabel = Instance.new("TextLabel")
        rankLabel.Parent = entryFrame
        rankLabel.BackgroundTransparency = 1
        rankLabel.Position = UDim2.new(0, 8, 0, 0)
        rankLabel.Size = UDim2.new(0, 25, 1, 0)
        rankLabel.Font = Enum.Font.GothamBold
        rankLabel.Text = tostring(rank)
        rankLabel.TextColor3 = Zenith.Theme.Text
        rankLabel.TextSize = 14
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = entryFrame
        nameLabel.BackgroundTransparency = 1
        nameLabel.Position = UDim2.new(0, 40, 0, 0)
        nameLabel.Size = UDim2.new(1, -90, 1, 0)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.Text = entry.Name or "Player"
        nameLabel.TextColor3 = Zenith.Theme.Text
        nameLabel.TextSize = 12
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local scoreLabel = Instance.new("TextLabel")
        scoreLabel.Parent = entryFrame
        scoreLabel.BackgroundTransparency = 1
        scoreLabel.Position = UDim2.new(1, -45, 0, 0)
        scoreLabel.Size = UDim2.new(0, 40, 1, 0)
        scoreLabel.Font = Enum.Font.GothamBold
        scoreLabel.Text = tostring(entry.Score or 0)
        scoreLabel.TextColor3 = Zenith.Theme.Primary
        scoreLabel.TextSize = 12
        scoreLabel.TextXAlignment = Enum.TextXAlignment.Right
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    
    return {gui = gui, frame = lbFrame}
end

-- Chat bubble system
function Zenith:CreateChatBubble(options)
    options = options or {}
    local message = options.Message or "Hello!"
    local isPlayer = options.IsPlayer ~= false
    local position = options.Position or UDim2.new(0.5, -150, 0, 100)
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "ChatBubble"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local bubbleFrame = Instance.new("Frame")
    bubbleFrame.Parent = gui
    bubbleFrame.BackgroundColor3 = isPlayer and Zenith.Theme.Primary or Zenith.Theme.Surface
    bubbleFrame.BorderSizePixel = 0
    bubbleFrame.Size = UDim2.new(0, 300, 0, 80)
    bubbleFrame.Position = position
    createCorner(bubbleFrame, 15)
    addGlow(bubbleFrame, isPlayer and Zenith.Theme.Primary or Zenith.Theme.Secondary, 1.5)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = bubbleFrame
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, -20, 1, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 0)
    textLabel.Font = Enum.Font.Gotham
    textLabel.Text = message
    textLabel.TextColor3 = isPlayer and Zenith.Theme.Background or Zenith.Theme.Text
    textLabel.TextSize = 13
    textLabel.TextWrapped = true
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    
    -- Animate in
    bubbleFrame.Size = UDim2.new(0, 0, 0, 0)
    tween(bubbleFrame, {Size = UDim2.new(0, 300, 0, 80)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    task.wait(3)
    tween(bubbleFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back):OnComplete(function()
        gui:Destroy()
    end)
    
    return gui
end

-- Stat bar system (health, mana, stamina, etc)
function Zenith:CreateStatBar(options)
    options = options or {}
    local statName = options.Name or "Health"
    local current = options.Current or 100
    local maximum = options.Maximum or 100
    local colorStart = options.ColorStart or Zenith.Theme.Success
    local colorEnd = options.ColorEnd or Zenith.Theme.Danger
    local position = options.Position or UDim2.new(0, 20, 0, 20)
    local size = options.Size or UDim2.new(0, 300, 0, 40)
    
    local guiContainer = options.Container or CoreGui
    
    local frame = Instance.new("Frame")
    frame.Parent = guiContainer
    frame.BackgroundColor3 = Zenith.Theme.Surface
    frame.BorderSizePixel = 0
    frame.Size = size
    frame.Position = position
    createCorner(frame, 10)
    addGlow(frame, colorStart, 1.5)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(0, 100, 0.3, 0)
    label.Font = Enum.Font.GothamBold
    label.Text = statName
    label.TextColor3 = Zenith.Theme.Primary
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local barBg = Instance.new("Frame")
    barBg.Parent = frame
    barBg.BackgroundColor3 = Zenith.Theme.SurfaceLight
    barBg.BorderSizePixel = 0
    barBg.Size = UDim2.new(1, -20, 0, 12)
    barBg.Position = UDim2.new(0, 10, 0.45, 0)
    createCorner(barBg, 6)
    
    local barFill = Instance.new("Frame")
    barFill.Parent = barBg
    barFill.BackgroundColor3 = colorStart
    barFill.BorderSizePixel = 0
    barFill.Size = UDim2.new((current / maximum), 0, 1, 0)
    createCorner(barFill, 6)
    addGradient(barFill, colorStart, colorEnd)
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = frame
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(1, -60, 0, 5)
    valueLabel.Size = UDim2.new(0, 50, 0.3, 0)
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.Text = current .. "/" .. maximum
    valueLabel.TextColor3 = Zenith.Theme.TextDim
    valueLabel.TextSize = 10
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local api = {}
    
    function api:SetValue(newCur, newMax)
        current = math.clamp(newCur, 0, newMax or maximum)
        maximum = newMax or maximum
        local percent = current / maximum
        tween(barFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.3, Enum.EasingStyle.Quad)
        valueLabel.Text = current .. "/" .. maximum
    end
    
    return {frame = frame, SetValue = api.SetValue}
end

-- Dialogue/conversation system
function Zenith:CreateDialogue(options)
    options = options or {}
    local speaker = options.Speaker or "NPC"
    local lines = options.Lines or {"Hello!", "How are you?"}
    local onComplete = options.OnComplete or function() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "Dialogue"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local dialogFrame = Instance.new("Frame")
    dialogFrame.Parent = gui
    dialogFrame.BackgroundColor3 = Zenith.Theme.Background
    dialogFrame.BorderSizePixel = 0
    dialogFrame.Size = UDim2.new(0, 600, 0, 200)
    dialogFrame.Position = UDim2.new(0.5, -300, 1, -220)
    dialogFrame.AnchorPoint = Vector2.new(0.5, 1)
    createCorner(dialogFrame, 15)
    addGlow(dialogFrame, Zenith.Theme.Secondary, 2)
    addGradient(dialogFrame, Color3.fromRGB(20, 20, 40), Color3.fromRGB(30, 25, 50), 135)
    
    local speakerLabel = Instance.new("TextLabel")
    speakerLabel.Parent = dialogFrame
    speakerLabel.BackgroundTransparency = 1
    speakerLabel.Position = UDim2.new(0, 15, 0, 10)
    speakerLabel.Size = UDim2.new(1, -30, 0, 25)
    speakerLabel.Font = Enum.Font.GothamBold
    speakerLabel.Text = speaker
    speakerLabel.TextColor3 = Zenith.Theme.Secondary
    speakerLabel.TextSize = 16
    speakerLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = dialogFrame
    textLabel.BackgroundTransparency = 1
    textLabel.Position = UDim2.new(0, 15, 0, 40)
    textLabel.Size = UDim2.new(1, -30, 0, 120)
    textLabel.Font = Enum.Font.Gotham
    textLabel.Text = ""
    textLabel.TextColor3 = Zenith.Theme.Text
    textLabel.TextSize = 13
    textLabel.TextWrapped = true
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    local continueBtn = Instance.new("TextButton")
    continueBtn.Parent = dialogFrame
    continueBtn.BackgroundColor3 = Zenith.Theme.Primary
    continueBtn.Size = UDim2.new(0, 150, 0, 30)
    continueBtn.Position = UDim2.new(1, -165, 1, -40)
    continueBtn.Font = Enum.Font.GothamBold
    continueBtn.Text = "Continue ▶"
    continueBtn.TextColor3 = Zenith.Theme.Background
    continueBtn.TextSize = 12
    continueBtn.BorderSizePixel = 0
    createCorner(continueBtn, 6)
    
    local currentLine = 1
    
    local function displayLine()
        textLabel.Text = ""
        local line = lines[currentLine]
        if line then
            -- Type out effect
            for i = 1, #line do
                textLabel.Text = string.sub(line, 1, i)
                task.wait(0.03)
            end
        else
            gui:Destroy()
            onComplete()
        end
    end
    
    continueBtn.MouseButton1Click:Connect(function()
        currentLine = currentLine + 1
        if currentLine > #lines then
            gui:Destroy()
            onComplete()
        else
            displayLine()
        end
    end)
    
    continueBtn.MouseEnter:Connect(function()
        tween(continueBtn, {BackgroundColor3 = Zenith.Theme.Accent}, 0.2)
    end)
    continueBtn.MouseLeave:Connect(function()
        tween(continueBtn, {BackgroundColor3 = Zenith.Theme.Primary}, 0.2)
    end)
    
    displayLine()
    
    return gui
end

-- Badge/notification counter
function Zenith:CreateBadge(options)
    options = options or {}
    local count = options.Count or 1
    local position = options.Position or UDim2.new(1, -25, 0, 10)
    local container = options.Container
    local color = options.Color or Zenith.Theme.Danger
    
    local badge = Instance.new("Frame")
    badge.Parent = container or CoreGui
    badge.BackgroundColor3 = color
    badge.BorderSizePixel = 0
    badge.Size = UDim2.new(0, 25, 0, 25)
    badge.Position = position
    createCorner(badge, 12)
    addGlow(badge, color, 1.5)
    
    local countLabel = Instance.new("TextLabel")
    countLabel.Parent = badge
    countLabel.BackgroundTransparency = 1
    countLabel.Size = UDim2.new(1, 0, 1, 0)
    countLabel.Font = Enum.Font.GothamBold
    countLabel.Text = tostring(count)
    countLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    countLabel.TextSize = 12
    
    local api = {}
    
    function api:SetCount(newCount)
        count = newCount
        if count <= 0 then
            badge.Visible = false
        else
            badge.Visible = true
            countLabel.Text = tostring(count)
            tween(badge, {Size = UDim2.new(0, 28, 0, 28)}, 0.1)
            task.wait(0.1)
            tween(badge, {Size = UDim2.new(0, 25, 0, 25)}, 0.1)
        end
    end
    
    function api:Increment()
        api:SetCount(count + 1)
    end
    
    function api:Decrement()
        api:SetCount(math.max(0, count - 1))
    end
    
    return {badge = badge, SetCount = api.SetCount, Increment = api.Increment, Decrement = api.Decrement}
end

-- Inventory/Grid system
function Zenith:CreateInventoryGrid(options)
    options = options or {}
    local cols = options.Columns or 4
    local rows = options.Rows or 4
    local itemSize = options.ItemSize or 60
    local onItemSelect = options.OnItemSelect or function() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "Inventory"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local gridFrame = Instance.new("Frame")
    gridFrame.Parent = gui
    gridFrame.BackgroundColor3 = Zenith.Theme.Background
    gridFrame.BorderSizePixel = 0
    gridFrame.Size = UDim2.new(0, cols * itemSize + 40, 0, rows * itemSize + 60)
    gridFrame.Position = options.Position or UDim2.new(0.5, -(cols * itemSize + 40) / 2, 0.5, -(rows * itemSize + 60) / 2)
    gridFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    createCorner(gridFrame, 12)
    addGlow(gridFrame, Zenith.Theme.Primary, 2)
    
    local title = Instance.new("TextLabel")
    title.Parent = gridFrame
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 15, 0, 10)
    title.Size = UDim2.new(1, -30, 0, 25)
    title.Font = Enum.Font.GothamBold
    title.Text = options.Title or "Inventory"
    title.TextColor3 = Zenith.Theme.Primary
    title.TextSize = 16
    
    local gridContainer = Instance.new("Frame")
    gridContainer.Parent = gridFrame
    gridContainer.BackgroundTransparency = 1
    gridContainer.Position = UDim2.new(0, 20, 0, 45)
    gridContainer.Size = UDim2.new(1, -40, 1, -55)
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.Parent = gridContainer
    gridLayout.CellSize = UDim2.new(0, itemSize, 0, itemSize)
    gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- API
    local api = {}
    
    function api:AddItem(itemName, icon, callback)
        local slot = Instance.new("Frame")
        slot.Parent = gridContainer
        slot.BackgroundColor3 = Zenith.Theme.Surface
        slot.BorderSizePixel = 0
        slot.Size = UDim2.new(0, itemSize, 0, itemSize)
        createCorner(slot, 8)
        addGlow(slot, Zenith.Theme.Primary, 1, 0.5)
        
        if icon then
            local iconImg = Instance.new("ImageLabel")
            iconImg.Parent = slot
            iconImg.BackgroundTransparency = 1
            iconImg.Size = UDim2.new(1, -6, 1, -6)
            iconImg.Position = UDim2.new(0, 3, 0, 3)
            iconImg.Image = icon
            iconImg.ImageColor3 = Zenith.Theme.Primary
        end
        
        local label = Instance.new("TextLabel")
        label.Parent = slot
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 0, 1, -16)
        label.Size = UDim2.new(1, 0, 0, 14)
        label.Font = Enum.Font.Gotham
        label.Text = itemName
        label.TextColor3 = Zenith.Theme.Text
        label.TextSize = 10
        label.TextScaled = true
        
        local clickDetector = Instance.new("TextButton")
        clickDetector.Parent = slot
        clickDetector.BackgroundTransparency = 1
        clickDetector.Size = UDim2.new(1, 0, 1, 0)
        clickDetector.Text = ""
        
        clickDetector.MouseButton1Click:Connect(function()
            tween(slot, {BackgroundColor3 = Zenith.Theme.Primary}, 0.2)
            task.wait(0.2)
            tween(slot, {BackgroundColor3 = Zenith.Theme.Surface}, 0.2)
            if callback then callback() end
            onItemSelect(itemName)
        end)
        
        clickDetector.MouseEnter:Connect(function()
            tween(slot, {BackgroundColor3 = Zenith.Theme.SurfaceLight}, 0.1)
        end)
        
        clickDetector.MouseLeave:Connect(function()
            tween(slot, {BackgroundColor3 = Zenith.Theme.Surface}, 0.1)
        end)
        
        return slot
    end
    
    return {gui = gui, frame = gridFrame, container = gridContainer, AddItem = api.AddItem}
end

-- Hotkey/command panel
function Zenith:CreateHotkeys(options)
    options = options or {}
    local hotkeys = options.Hotkeys or {}
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "Hotkeys"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local hotkeyFrame = Instance.new("Frame")
    hotkeyFrame.Parent = gui
    hotkeyFrame.BackgroundColor3 = Zenith.Theme.Background
    hotkeyFrame.BorderSizePixel = 0
    hotkeyFrame.Size = UDim2.new(0, 300, 0, #hotkeys * 40 + 50)
    hotkeyFrame.Position = options.Position or UDim2.new(0, 20, 1, 0)
    hotkeyFrame.AnchorPoint = Vector2.new(0, 1)
    createCorner(hotkeyFrame, 12)
    addGlow(hotkeyFrame, Zenith.Theme.Primary, 1.5)
    
    local headerLabel = Instance.new("TextLabel")
    headerLabel.Parent = hotkeyFrame
    headerLabel.BackgroundTransparency = 1
    headerLabel.Position = UDim2.new(0, 15, 0, 8)
    headerLabel.Size = UDim2.new(1, -30, 0, 25)
    headerLabel.Font = Enum.Font.GothamBold
    headerLabel.Text = "Hotkeys"
    headerLabel.TextColor3 = Zenith.Theme.Primary
    headerLabel.TextSize = 14
    
    local listFrame = Instance.new("Frame")
    listFrame.Parent = hotkeyFrame
    listFrame.BackgroundTransparency = 1
    listFrame.Position = UDim2.new(0, 10, 0, 35)
    listFrame.Size = UDim2.new(1, -20, 1, -45)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = listFrame
    listLayout.Padding = UDim.new(0, 5)
    
    for _, hotkey in ipairs(hotkeys) do
        local hotkeyItem = Instance.new("Frame")
        hotkeyItem.Parent = listFrame
        hotkeyItem.BackgroundColor3 = Zenith.Theme.Surface
        hotkeyItem.BorderSizePixel = 0
        hotkeyItem.Size = UDim2.new(1, 0, 0, 30)
        createCorner(hotkeyItem, 6)
        
        local keyLabel = Instance.new("TextLabel")
        keyLabel.Parent = hotkeyItem
        keyLabel.BackgroundColor3 = Zenith.Theme.Primary
        keyLabel.BorderSizePixel = 0
        keyLabel.Position = UDim2.new(0, 5, 0.5, -12)
        keyLabel.Size = UDim2.new(0, 40, 0, 24)
        keyLabel.Font = Enum.Font.GothamBold
        keyLabel.Text = hotkey.Key
        keyLabel.TextColor3 = Zenith.Theme.Background
        keyLabel.TextSize = 11
        createCorner(keyLabel, 4)
        
        local actionLabel = Instance.new("TextLabel")
        actionLabel.Parent = hotkeyItem
        actionLabel.BackgroundTransparency = 1
        actionLabel.Position = UDim2.new(0, 50, 0, 0)
        actionLabel.Size = UDim2.new(1, -55, 1, 0)
        actionLabel.Font = Enum.Font.Gotham
        actionLabel.Text = hotkey.Text
        actionLabel.TextColor3 = Zenith.Theme.Text
        actionLabel.TextSize = 11
        actionLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        if hotkey.Key then
            Zenith:RegisterKeybind(hotkey.Key, hotkey.Callback or function() end)
        end
    end
    
    return {gui = gui, frame = hotkeyFrame}
end

-- Floating tooltip system
function Zenith:CreateTooltip(options)
    options = options or {}
    local text = options.Text or "Tooltip"
    local targetPosition = options.Position or UserInputService:GetMouseLocation()
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "Tooltip"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local tooltipFrame = Instance.new("Frame")
    tooltipFrame.Parent = gui
    tooltipFrame.BackgroundColor3 = Zenith.Theme.Surface
    tooltipFrame.BorderSizePixel = 0
    tooltipFrame.Size = UDim2.new(0, 1, 0, 1)
    tooltipFrame.Position = UDim2.new(0, targetPosition.X + 10, 0, targetPosition.Y + 10)
    createCorner(tooltipFrame, 6)
    addGlow(tooltipFrame, Zenith.Theme.Primary, 1, 0.5)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = tooltipFrame
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Font = Enum.Font.Gotham
    textLabel.Text = text
    textLabel.TextColor3 = Zenith.Theme.Text
    textLabel.TextSize = 11
    textLabel.TextWrapped = true
    textLabel.Padding = UDim.new(0, 5)
    
    -- Auto-size
    local textSizeX = textLabel.TextBounds.X + 10
    local textSizeY = textLabel.TextBounds.Y + 6
    tooltipFrame.Size = UDim2.new(0, math.max(60, textSizeX), 0, math.max(20, textSizeY))
    
    -- Fade out after time
    task.wait(3)
    tween(tooltipFrame, {BackgroundTransparency = 1}, 0.3):OnComplete(function()
        gui:Destroy()
    end)
    
    return gui
end

return Zenith
