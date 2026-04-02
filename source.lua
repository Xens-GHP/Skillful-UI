-- Skillful-UI.lua
-- A standalone UI library for Roblox executors.
-- Forked from CSGOLib, redesigned to match the Talentless script aesthetics.
-- Provides: draggable window with toggle key, tabs, sections, buttons, labels,
-- textboxes, sliders, toggles, and built-in notifications with sound support.
-- 
-- API documentation: see separate file or comments below.

local SkillfulUI = {}
SkillfulUI.__index = SkillfulUI

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer

-- Default Theme (Talentless style)
local DefaultTheme = {
    Background = Color3.fromRGB(33, 33, 41),      -- main frame
    TitleBar = Color3.fromRGB(50, 57, 73),       -- title bar
    Button = Color3.fromRGB(76, 82, 101),        -- button background
    ButtonBorder = Color3.fromRGB(64, 68, 90),   -- button border
    ButtonHover = Color3.fromRGB(90, 96, 115),   -- hover
    Text = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(230, 126, 34),       -- orange accent (sliders, toggles)
    SliderBg = Color3.fromRGB(58, 58, 68),
    SliderFill = Color3.fromRGB(230, 126, 34),
    ToggleOff = Color3.fromRGB(64, 64, 74),
    ToggleOn = Color3.fromRGB(230, 126, 34),
    Border = Color3.fromRGB(20, 20, 24),
    Success = Color3.fromRGB(46, 204, 113),
    Error = Color3.fromRGB(231, 76, 60),
}

-- Internal: fit text to button width (auto-shrink)
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

-- Internal: play sound (if sound ID provided)
local function playSound(soundId, volume)
    if not soundId then return end
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Volume = volume or 0.3
    sound.Parent = LocalPlayer.Character or LocalPlayer
    sound:Play()
end

-- Internal: make GUI draggable
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

-- ============================================
-- Window Class
-- ============================================

local Window = {}
Window.__index = Window

function SkillfulUI:Window(options)
    options = options or {}
    local title = options.Name or "Skillful"
    local size = options.Size or Vector2.new(500, 400)
    local toggleKey = options.ShowToggleKey
    local center = options.Center == nil and true or options.Center
    local sounds = options.Sounds or {}  -- { open, close, click, error, success }
    local theme = options.Theme or DefaultTheme
    
    local window = {}
    setmetatable(window, Window)
    window.Tabs = {}
    window.CurrentTab = nil
    window.Visible = true
    window.CloseCallbacks = {}
    window.Sounds = sounds
    window.Theme = theme
    
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
    if center then
        frame.Position = UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2)
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
    else
        frame.Position = UDim2.new(0, 100, 0, 100)
    end
    frame.Size = UDim2.new(0, size.X, 0, size.Y)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Parent = frame
    titleBar.BackgroundColor3 = theme.TitleBar
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BorderSizePixel = 0
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 6)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = titleBar
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Text = title
    titleLabel.TextColor3 = theme.Text
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = titleBar
    closeBtn.BackgroundColor3 = theme.Button
    closeBtn.BorderColor3 = theme.ButtonBorder
    closeBtn.BorderSizePixel = 2
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 2.5)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = theme.Text
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.SourceSansBold
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn
    closeBtn.MouseButton1Click:Connect(function()
        window:Destroy()
        playSound(sounds.close, 0.3)
    end)
    
    -- Toggle visibility keybind
    if toggleKey then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == toggleKey then
                window:Toggle()
            end
        end)
    end
    
    -- Make window draggable
    makeDraggable(frame, titleBar)
    
    -- Left sidebar for tabs
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Parent = frame
    tabContainer.BackgroundColor3 = theme.Button
    tabContainer.BorderSizePixel = 0
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.Size = UDim2.new(0, 120, 1, -40)
    tabContainer.ScrollBarThickness = 4
    tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = tabContainer
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.Parent = tabContainer
    tabPadding.PaddingTop = UDim.new(0, 10)
    tabPadding.PaddingBottom = UDim.new(0, 10)
    
    -- Right content area
    local contentContainer = Instance.new("Frame")
    contentContainer.Parent = frame
    contentContainer.BackgroundColor3 = theme.Background
    contentContainer.BorderSizePixel = 0
    contentContainer.Position = UDim2.new(0, 125, 0, 45)
    contentContainer.Size = UDim2.new(1, -130, 1, -50)
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 4)
    contentCorner.Parent = contentContainer
    
    -- Internal methods
    function window:Destroy()
        for _, cb in ipairs(self.CloseCallbacks) do
            pcall(cb)
        end
        screenGui:Destroy()
    end
    
    function window:SetVisible(visible)
        frame.Visible = visible
        self.Visible = visible
        if visible then
            playSound(sounds.open, 0.2)
        else
            playSound(sounds.close, 0.2)
        end
    end
    
    function window:Toggle()
        self:SetVisible(not self.Visible)
    end
    
    function window:OnClose(callback)
        table.insert(self.CloseCallbacks, callback)
    end
    
    -- Built-in notification system
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
        titleLbl.Font = Enum.Font.SourceSansBold
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local msgLbl = Instance.new("TextLabel")
        msgLbl.Parent = notif
        msgLbl.BackgroundTransparency = 1
        msgLbl.Size = UDim2.new(1, -20, 0, 25)
        msgLbl.Position = UDim2.new(0, 10, 0, 30)
        msgLbl.Text = message
        msgLbl.TextColor3 = Color3.fromRGB(255,255,255)
        msgLbl.TextSize = 12
        msgLbl.Font = Enum.Font.SourceSans
        msgLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(1, -20, 0, 10)}):Play()
        task.wait(duration or 3)
        TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(1, 10, 0, 10)}):Play()
        task.wait(0.3)
        notif:Destroy()
        if isError then
            playSound(sounds.error, 0.5)
        else
            playSound(sounds.success, 0.5)
        end
    end
    
    -- Tab creation
    function window:Tab(tabOptions)
        local tab = {}
        tab.Name = tabOptions.Name or "Tab"
        tab.Sections = {}
        tab.Container = Instance.new("ScrollingFrame")
        tab.Container.Parent = contentContainer
        tab.Container.BackgroundTransparency = 1
        tab.Container.BorderSizePixel = 0
        tab.Container.Size = UDim2.new(1, 0, 1, 0)
        tab.Container.ScrollBarThickness = 6
        tab.Container.CanvasSize = UDim2.new(0, 0, 0, 0)
        tab.Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tab.Container.Visible = false
        
        local containerLayout = Instance.new("UIListLayout")
        containerLayout.Parent = tab.Container
        containerLayout.Padding = UDim.new(0, 10)
        containerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        local containerPadding = Instance.new("UIPadding")
        containerPadding.Parent = tab.Container
        containerPadding.PaddingTop = UDim.new(0, 10)
        containerPadding.PaddingBottom = UDim.new(0, 10)
        
        -- Tab button (left sidebar)
        local tabButton = Instance.new("TextButton")
        tabButton.Parent = tabContainer
        tabButton.BackgroundColor3 = theme.Button
        tabButton.BorderColor3 = theme.ButtonBorder
        tabButton.BorderSizePixel = 2
        tabButton.Size = UDim2.new(0, 110, 0, 35)
        tabButton.Text = tab.Name
        tabButton.TextColor3 = theme.Text
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.SourceSansBold
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 4)
        tabCorner.Parent = tabButton
        fitText(tabButton)
        
        tabButton.MouseButton1Click:Connect(function()
            if window.CurrentTab then
                window.CurrentTab.Container.Visible = false
                window.CurrentTab.Button.BackgroundColor3 = theme.Button
            end
            window.CurrentTab = tab
            tab.Container.Visible = true
            tabButton.BackgroundColor3 = theme.Accent
            playSound(sounds.click, 0.2)
        end)
        
        tab.Button = tabButton
        
        -- Section creation
        function tab:Section(sectionOptions)
            local section = {}
            section.Name = sectionOptions.Name or "Section"
            section.Container = Instance.new("Frame")
            section.Container.Parent = tab.Container
            section.Container.BackgroundColor3 = theme.Button
            section.Container.BorderSizePixel = 0
            section.Container.Size = UDim2.new(0, 340, 0, 0)
            section.Container.AutomaticSize = Enum.AutomaticSize.Y
            
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 6)
            sectionCorner.Parent = section.Container
            
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Parent = section.Container
            sectionTitle.BackgroundColor3 = theme.TitleBar
            sectionTitle.Size = UDim2.new(1, 0, 0, 30)
            sectionTitle.Text = "  " .. section.Name
            sectionTitle.TextColor3 = theme.Text
            sectionTitle.TextSize = 16
            sectionTitle.Font = Enum.Font.SourceSansBold
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            local titleCorner2 = Instance.new("UICorner")
            titleCorner2.CornerRadius = UDim.new(0, 6)
            titleCorner2.Parent = sectionTitle
            
            local contentFrame = Instance.new("Frame")
            contentFrame.Parent = section.Container
            contentFrame.BackgroundTransparency = 1
            contentFrame.Position = UDim2.new(0, 0, 0, 35)
            contentFrame.Size = UDim2.new(1, 0, 0, 0)
            contentFrame.AutomaticSize = Enum.AutomaticSize.Y
            
            local contentLayout = Instance.new("UIListLayout")
            contentLayout.Parent = contentFrame
            contentLayout.Padding = UDim.new(0, 8)
            contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            
            local contentPadding = Instance.new("UIPadding")
            contentPadding.Parent = contentFrame
            contentPadding.PaddingLeft = UDim.new(0, 10)
            contentPadding.PaddingRight = UDim.new(0, 10)
            contentPadding.PaddingTop = UDim.new(0, 10)
            contentPadding.PaddingBottom = UDim.new(0, 10)
            
            section.Elements = {}
            
            local function addElement(element)
                element.Parent = contentFrame
                table.insert(section.Elements, element)
                return element
            end
            
            -- Label
            function section:Label(labelOptions)
                local label = Instance.new("TextLabel")
                label.BackgroundTransparency = 1
                label.Size = UDim2.new(1, 0, 0, 25)
                label.Text = labelOptions.Name or ""
                label.TextColor3 = theme.Text
                label.TextSize = 14
                label.Font = Enum.Font.SourceSans
                label.TextXAlignment = Enum.TextXAlignment.Left
                addElement(label)
                local obj = { Instance = label }
                function obj:Set(newText)
                    label.Text = newText
                end
                return obj
            end
            
            -- Button
            function section:Button(buttonOptions)
                local btn = Instance.new("TextButton")
                btn.BackgroundColor3 = theme.Button
                btn.BorderColor3 = theme.ButtonBorder
                btn.BorderSizePixel = 2
                btn.Size = UDim2.new(1, 0, 0, 35)
                btn.Text = buttonOptions.Name or "Button"
                btn.TextColor3 = theme.Text
                btn.TextSize = 14
                btn.Font = Enum.Font.SourceSansBold
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 4)
                btnCorner.Parent = btn
                fitText(btn)
                
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = theme.ButtonHover}):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = theme.Button}):Play()
                end)
                btn.MouseButton1Click:Connect(function()
                    playSound(sounds.click, 0.2)
                    if buttonOptions.Callback then buttonOptions.Callback() end
                end)
                addElement(btn)
                return btn
            end
            
            -- TextBox
            function section:TextBox(textBoxOptions)
                local container = Instance.new("Frame")
                container.BackgroundTransparency = 1
                container.Size = UDim2.new(1, 0, 0, 35)
                container.AutomaticSize = Enum.AutomaticSize.Y
                
                local box = Instance.new("TextBox")
                box.Parent = container
                box.BackgroundColor3 = theme.SliderBg
                box.BorderSizePixel = 0
                box.Size = UDim2.new(1, 0, 0, 35)
                box.PlaceholderText = textBoxOptions.Placeholder or ""
                box.Text = ""
                box.TextColor3 = theme.Text
                box.Font = Enum.Font.SourceSans
                box.TextSize = 14
                local boxCorner = Instance.new("UICorner")
                boxCorner.CornerRadius = UDim.new(0, 4)
                boxCorner.Parent = box
                
                local callback = textBoxOptions.Callback
                box:GetPropertyChangedSignal("Text"):Connect(function()
                    if callback then callback(box.Text) end
                end)
                addElement(container)
                return box
            end
            
            -- Slider
            function section:Slider(sliderOptions)
                local container = Instance.new("Frame")
                container.BackgroundTransparency = 1
                container.Size = UDim2.new(1, 0, 0, 50)
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Parent = container
                nameLabel.BackgroundTransparency = 1
                nameLabel.Size = UDim2.new(1, 0, 0, 20)
                nameLabel.Text = sliderOptions.Name or "Slider"
                nameLabel.TextColor3 = theme.Text
                nameLabel.TextSize = 12
                nameLabel.Font = Enum.Font.SourceSans
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local valueLabel = Instance.new("TextLabel")
                valueLabel.Parent = container
                valueLabel.BackgroundTransparency = 1
                valueLabel.Size = UDim2.new(0, 50, 0, 20)
                valueLabel.Position = UDim2.new(1, -50, 0, 0)
                valueLabel.Text = tostring(sliderOptions.Default or 0)
                valueLabel.TextColor3 = theme.Accent
                valueLabel.TextSize = 12
                valueLabel.Font = Enum.Font.SourceSansBold
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                
                local sliderBg = Instance.new("Frame")
                sliderBg.Parent = container
                sliderBg.BackgroundColor3 = theme.SliderBg
                sliderBg.BorderSizePixel = 0
                sliderBg.Position = UDim2.new(0, 0, 0, 25)
                sliderBg.Size = UDim2.new(1, 0, 0, 8)
                local sliderCorner = Instance.new("UICorner")
                sliderCorner.CornerRadius = UDim.new(0, 4)
                sliderCorner.Parent = sliderBg
                
                local sliderFill = Instance.new("Frame")
                sliderFill.Parent = sliderBg
                sliderFill.BackgroundColor3 = theme.SliderFill
                sliderFill.BorderSizePixel = 0
                sliderFill.Size = UDim2.new(0, 0, 1, 0)
                local fillCorner = Instance.new("UICorner")
                fillCorner.CornerRadius = UDim.new(0, 4)
                fillCorner.Parent = sliderFill
                
                local min = sliderOptions.Min or 0
                local max = sliderOptions.Max or 100
                local value = sliderOptions.Default or min
                
                local function updateSlider(val)
                    value = math.clamp(val, min, max)
                    local percent = (value - min) / (max - min)
                    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    valueLabel.Text = tostring(math.floor(value * 100) / 100)
                    if sliderOptions.Callback then sliderOptions.Callback(value) end
                end
                updateSlider(value)
                
                local dragging = false
                sliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                        updateSlider(min + percent * (max - min))
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                        updateSlider(min + percent * (max - min))
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                addElement(container)
                local obj = { Instance = container }
                function obj:Set(newVal)
                    updateSlider(newVal)
                end
                return obj
            end
            
            -- Toggle
            function section:Toggle(toggleOptions)
                local container = Instance.new("Frame")
                container.BackgroundTransparency = 1
                container.Size = UDim2.new(1, 0, 0, 35)
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Parent = container
                nameLabel.BackgroundTransparency = 1
                nameLabel.Size = UDim2.new(1, -60, 0, 35)
                nameLabel.Text = toggleOptions.Name or "Toggle"
                nameLabel.TextColor3 = theme.Text
                nameLabel.TextSize = 14
                nameLabel.Font = Enum.Font.SourceSans
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local toggleBg = Instance.new("Frame")
                toggleBg.Parent = container
                toggleBg.BackgroundColor3 = theme.ToggleOff
                toggleBg.BorderSizePixel = 0
                toggleBg.Position = UDim2.new(1, -50, 0, 5)
                toggleBg.Size = UDim2.new(0, 45, 0, 25)
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(1, 0)
                toggleCorner.Parent = toggleBg
                
                local toggleKnob = Instance.new("Frame")
                toggleKnob.Parent = toggleBg
                toggleKnob.BackgroundColor3 = theme.Text
                toggleKnob.BorderSizePixel = 0
                toggleKnob.Size = UDim2.new(0, 21, 0, 21)
                toggleKnob.Position = UDim2.new(0, 2, 0, 2)
                local knobCorner = Instance.new("UICorner")
                knobCorner.CornerRadius = UDim.new(1, 0)
                knobCorner.Parent = toggleKnob
                
                local state = toggleOptions.Default or false
                local callback = toggleOptions.Callback
                
                local function updateToggle()
                    if state then
                        toggleBg.BackgroundColor3 = theme.ToggleOn
                        toggleKnob.Position = UDim2.new(1, -23, 0, 2)
                    else
                        toggleBg.BackgroundColor3 = theme.ToggleOff
                        toggleKnob.Position = UDim2.new(0, 2, 0, 2)
                    end
                    if callback then callback(state) end
                end
                updateToggle()
                
                toggleBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        state = not state
                        updateToggle()
                        playSound(sounds.click, 0.2)
                    end
                end)
                
                addElement(container)
                local obj = { Instance = container }
                function obj:Set(newState)
                    state = newState
                    updateToggle()
                end
                return obj
            end
            
            table.insert(tab.Sections, section)
            return section
        end
        
        table.insert(window.Tabs, tab)
        if #window.Tabs == 1 then
            window.CurrentTab = tab
            tab.Container.Visible = true
            tabButton.BackgroundColor3 = theme.Accent
        end
        
        return tab
    end
    
    return window
end

return SkillfulUI
