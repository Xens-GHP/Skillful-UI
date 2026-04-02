-- Skillful-UI.lua
-- A clean, modular UI library with a modern dark aesthetic.
-- Provides windows, buttons, scrolling lists, categories, notifications, and more.
-- Compatible with any executor supporting loadstring and common Roblox APIs.

local SkillfulUI = {}
SkillfulUI.__index = SkillfulUI

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local ContentProvider = game:GetService("ContentProvider")
local LocalPlayer = Players.LocalPlayer

-- Theme colors (modern dark)
local Theme = {
    Background = Color3.fromRGB(30, 30, 36),
    Secondary = Color3.fromRGB(45, 45, 52),
    Accent = Color3.fromRGB(230, 126, 34),    -- Orange accent
    Button = Color3.fromRGB(58, 58, 68),
    ButtonHover = Color3.fromRGB(72, 72, 84),
    Text = Color3.fromRGB(240, 240, 240),
    Border = Color3.fromRGB(20, 20, 24),
    Success = Color3.fromRGB(46, 204, 113),
    Error = Color3.fromRGB(231, 76, 60),
}

-- Utility: auto-fit text inside a button
local function fitText(button)
    local size = button.TextSize
    while size > 1 do
        local bounds = TextService:GetTextSize(button.Text, size, button.Font, Vector2.new(math.huge, math.huge))
        if bounds.X <= button.AbsoluteSize.X then break end
        size = size - 1
        button.TextSize = size
    end
    return size
end

-- Utility: play a sound
local function playSound(soundId, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Volume = volume or 0.3
    sound.Parent = LocalPlayer.Character or LocalPlayer
    sound:Play()
end

-- Dragging logic (internal)
local function makeDraggable(gui, dragHandle)
    dragHandle = dragHandle or gui
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- ** Public API **

-- Create a new main window
function SkillfulUI:CreateWindow(title, size, themeOverrides)
    local window = {}
    setmetatable(window, self)
    window.Elements = {}
    window.Visible = true

    -- Merge theme
    local theme = Theme
    if themeOverrides then
        for k,v in pairs(themeOverrides) do theme[k] = v end
    end

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SkillfulUI_Window"
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main frame
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Parent = screenGui
    frame.BackgroundColor3 = theme.Background
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2)
    frame.Size = UDim2.new(0, size.X, 0, size.Y)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Parent = frame
    titleBar.BackgroundColor3 = theme.Secondary
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BorderSizePixel = 0
    Instance.new("UICorner").Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = titleBar
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Text = title
    titleLabel.TextColor3 = theme.Text
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = titleBar
    closeBtn.BackgroundTransparency = 1
    closeBtn.Size = UDim2.new(0, 40, 1, 0)
    closeBtn.Position = UDim2.new(1, -40, 0, 0)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = theme.Text
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.MouseButton1Click:Connect(function()
        window:Destroy()
    end)

    -- Make window draggable
    makeDraggable(frame, titleBar)

    -- Internal methods
    function window:Destroy()
        screenGui:Destroy()
    end

    function window:SetVisible(visible)
        frame.Visible = visible
        self.Visible = visible
    end

    -- Helper to add a child element
    function window:AddElement(element)
        table.insert(self.Elements, element)
        return element
    end

    -- Create a button
    function window:CreateButton(text, position, size, callback)
        local btn = Instance.new("TextButton")
        btn.Parent = frame
        btn.BackgroundColor3 = theme.Button
        btn.BorderSizePixel = 0
        btn.Position = position
        btn.Size = size
        btn.Text = text
        btn.TextColor3 = theme.Text
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamSemibold
        local cornerBtn = Instance.new("UICorner")
        cornerBtn.CornerRadius = UDim.new(0, 4)
        cornerBtn.Parent = btn

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = theme.ButtonHover}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = theme.Button}):Play()
        end)
        btn.MouseButton1Click:Connect(callback)
        fitText(btn)
        return btn
    end

    -- Create a scrolling frame (for lists)
    function window:CreateScrollingFrame(position, size, automaticCanvas)
        local scroll = Instance.new("ScrollingFrame")
        scroll.Parent = frame
        scroll.Position = position
        scroll.Size = size
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 6
        scroll.AutomaticCanvasSize = automaticCanvas and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
        scroll.CanvasSize = automaticCanvas and UDim2.new(0,0,0,0) or UDim2.new(0,0,0,0)
        return scroll
    end

    -- Create a list layout inside a scrolling frame
    function window:CreateListLayout(parent, padding, horizontalAlignment)
        local layout = Instance.new("UIListLayout")
        layout.Parent = parent
        layout.Padding = UDim.new(0, padding or 10)
        layout.HorizontalAlignment = horizontalAlignment or Enum.HorizontalAlignment.Center
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        return layout
    end

    -- Create a category button (toggle style)
    function window:CreateCategoryButton(text, position, size, isOpen)
        local btn = self:CreateButton(text, position, size, nil)
        btn.BackgroundColor3 = theme.Secondary
        btn.TextXAlignment = Enum.TextXAlignment.Left
        local arrow = Instance.new("TextLabel")
        arrow.Parent = btn
        arrow.BackgroundTransparency = 1
        arrow.Size = UDim2.new(0, 20, 1, 0)
        arrow.Position = UDim2.new(1, -25, 0, 0)
        arrow.Text = isOpen and "▼" or "▲"
        arrow.TextColor3 = theme.Text
        arrow.TextSize = 14
        arrow.Font = Enum.Font.GothamBold
        return btn, arrow
    end

    -- Create a simple text input
    function window:CreateTextBox(placeholder, position, size)
        local box = Instance.new("TextBox")
        box.Parent = frame
        box.BackgroundColor3 = theme.Secondary
        box.BorderSizePixel = 0
        box.Position = position
        box.Size = size
        box.PlaceholderText = placeholder
        box.Text = ""
        box.TextColor3 = theme.Text
        box.Font = Enum.Font.Gotham
        box.TextSize = 14
        Instance.new("UICorner").Parent = box
        return box
    end

    -- Create a tag (label with background)
    function window:CreateTag(text, parent)
        local tag = Instance.new("TextLabel")
        tag.Parent = parent
        tag.BackgroundColor3 = theme.Button
        tag.BorderSizePixel = 0
        tag.Size = UDim2.new(0, 0, 0, 24)
        tag.Text = text
        tag.TextColor3 = theme.Text
        tag.TextSize = 12
        tag.Font = Enum.Font.Gotham
        tag.TextXAlignment = Enum.TextXAlignment.Center
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = tag
        local bounds = TextService:GetTextSize(text, 12, tag.Font, Vector2.new(1000, 24))
        tag.Size = UDim2.new(0, bounds.X + 16, 0, 24)
        return tag
    end

    -- Show a simple notification (toast)
    function window:Notify(title, message, duration, isError)
        local notif = Instance.new("Frame")
        notif.Parent = screenGui
        notif.BackgroundColor3 = isError and theme.Error or theme.Success
        notif.BorderSizePixel = 0
        notif.Size = UDim2.new(0, 250, 0, 60)
        notif.Position = UDim2.new(1, -270, 0, 10)
        notif.AnchorPoint = Vector2.new(1, 0)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = notif

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Parent = notif
        titleLbl.BackgroundTransparency = 1
        titleLbl.Size = UDim2.new(1, -20, 0, 25)
        titleLbl.Position = UDim2.new(0, 10, 0, 5)
        titleLbl.Text = title
        titleLbl.TextColor3 = Color3.fromRGB(255,255,255)
        titleLbl.TextSize = 14
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left

        local msgLbl = Instance.new("TextLabel")
        msgLbl.Parent = notif
        msgLbl.BackgroundTransparency = 1
        msgLbl.Size = UDim2.new(1, -20, 0, 25)
        msgLbl.Position = UDim2.new(0, 10, 0, 30)
        msgLbl.Text = message
        msgLbl.TextColor3 = Color3.fromRGB(255,255,255)
        msgLbl.TextSize = 12
        msgLbl.Font = Enum.Font.Gotham
        msgLbl.TextXAlignment = Enum.TextXAlignment.Left

        TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(1, -20, 0, 10)}):Play()
        task.wait(duration or 3)
        TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(1, 10, 0, 10)}):Play()
        task.wait(0.3)
        notif:Destroy()
    end

    return window
end

return SkillfulUI
