--[[
    Zenith UI
    A modern, fully animated UI library for Roblox executors
    Style: Vape V4 / Meteor Client inspired
    Features: Windows, Tabs, Buttons, Checkboxes, Sliders, Dropdowns, TextInputs, Keybinds, ColorPickers, Notifications, Tooltips, Resizing, Scrolling
    Dependencies: Drawing API, TweenService (standard in most executors)
--]]

local Zenith = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ========================= THEME =========================
Zenith.Theme = {
    Background    = Color3.fromRGB(18, 18, 24),  -- main background
    Surface       = Color3.fromRGB(28, 28, 36),  -- window background
    Element       = Color3.fromRGB(38, 38, 48),  -- input background
    Accent        = Color3.fromRGB(0, 200, 200), -- cyan accent
    AccentDark    = Color3.fromRGB(0, 150, 150),
    Text          = Color3.fromRGB(240, 240, 245),
    TextDim       = Color3.fromRGB(160, 160, 180),
    Border        = Color3.fromRGB(45, 45, 55),
    Shadow        = Color3.fromRGB(0, 0, 0),
    ShadowAlpha   = 0.35,
    Success       = Color3.fromRGB(80, 200, 120),
    Error         = Color3.fromRGB(220, 60, 60),
}

Zenith.Font = Drawing.Fonts.UI
Zenith.FontSize = 14
Zenith.AnimationSpeed = 0.2
Zenith.Notifications = {}
Zenith.Tooltip = nil
Zenith.TooltipTimer = 0

-- ========================= UTILITIES =========================
local function createSquare(color, pos, size, filled, thickness)
    local sq = Drawing.new("Square")
    sq.Color = color
    sq.Position = pos
    sq.Size = size
    sq.Filled = filled ~= false
    sq.Thickness = thickness or 0
    return sq
end

local function createText(text, color, pos, size, font)
    local txt = Drawing.new("Text")
    txt.Text = text
    txt.Color = color
    txt.Position = pos
    txt.Size = size or Zenith.FontSize
    txt.Font = font or Zenith.Font
    txt.Center = false
    txt.Outline = false
    return txt
end

local function drawShadow(x, y, w, h, alpha)
    for i = 1, 4 do
        local shadow = createSquare(Zenith.Theme.Shadow, Vector2.new(x - i*2, y - i), Vector2.new(w + i*4, h + i*2), true)
        shadow.Transparency = (alpha or Zenith.Theme.ShadowAlpha) * (1 - i/5)
        shadow:Draw()
        shadow:Remove()
    end
end

local function tweenObject(obj, prop, target, duration, style, direction)
    local info = TweenInfo.new(duration or Zenith.AnimationSpeed, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, info, {[prop] = target})
    tween:Play()
    return tween
end

local function clamp(v, min, max) return math.min(max, math.max(min, v)) end

-- ========================= WINDOW MANAGER =========================
Zenith.Windows = {}
Zenith.ActiveWindow = nil
Zenith.DragOffset = Vector2.new()
Zenith.ResizeEdge = nil
Zenith.HoveredElement = nil

-- ========================= WINDOW CLASS =========================
local Window = {}
Window.__index = Window

function Zenith:CreateWindow(title, x, y, w, h)
    local newWindow = setmetatable({
        Title = title,
        X = x, Y = y, Width = w, Height = h,
        MinWidth = 300, MinHeight = 200,
        Visible = true,
        Dragging = false,
        Resizing = false,
        Tabs = {},
        ActiveTab = nil,
        ScrollOffset = 0,
        Closable = true,
        Resizable = true,
        TabHeight = 28,
        TitleHeight = 30,
        Elements = {}, -- flattened for layout
    }, Window)
    table.insert(Zenith.Windows, newWindow)
    return newWindow
end

function Window:AddTab(name)
    local tab = { Name = name, Elements = {} }
    table.insert(self.Tabs, tab)
    if not self.ActiveTab then self.ActiveTab = tab end
    self:RefreshLayout()
    return tab
end

function Window:AddElement(tab, element)
    element.Window = self
    element.Tab = tab
    element.Hover = false
    element.AnimProgress = 0
    element.AnimValue = 0
    table.insert(tab.Elements, element)
    self:RefreshLayout()
    return element
end

function Window:RefreshLayout()
    if not self.ActiveTab then return end
    local y = self.Y + self.TitleHeight + self.TabHeight + 8
    local padding = 8
    local contentX = self.X + padding
    local contentW = self.Width - padding * 2
    self.Elements = {}
    for _, elem in ipairs(self.ActiveTab.Elements) do
        elem.X = contentX
        elem.Y = y - self.ScrollOffset
        elem.Width = contentW
        elem.Height = 32
        if elem.Type == "Dropdown" and elem.Expanded then
            elem.Height = 32 + (#elem.Options * 28) * elem.AnimHeight
        elseif elem.Type == "ColorPicker" and elem.Open then
            elem.Height = 180
        elseif elem.Type == "Slider" then
            elem.Height = 38
        elseif elem.Type == "TextInput" then
            elem.Height = 42
        elseif elem.Type == "Keybind" then
            elem.Height = 38
        end
        table.insert(self.Elements, elem)
        y = y + elem.Height + 6
    end
    self.ContentHeight = y - self.Y - self.TitleHeight - self.TabHeight
end

-- ========================= ELEMENT TYPES =========================
local ElementTypes = {}

function ElementTypes.Button(label, callback)
    return {
        Type = "Button",
        Label = label,
        Callback = callback,
    }
end

function ElementTypes.Checkbox(label, initial, callback)
    return {
        Type = "Checkbox",
        Label = label,
        Value = initial or false,
        Callback = callback,
        AnimValue = initial and 1 or 0,
    }
end

function ElementTypes.Slider(label, min, max, initial, callback, decimals)
    return {
        Type = "Slider",
        Label = label,
        Min = min or 0,
        Max = max or 100,
        Value = initial or 0,
        Decimals = decimals or 0,
        Callback = callback,
        Dragging = false,
        AnimValue = (initial - min)/(max - min) or 0,
    }
end

function ElementTypes.Dropdown(label, options, selected, callback)
    return {
        Type = "Dropdown",
        Label = label,
        Options = options,
        Selected = selected or 1,
        Callback = callback,
        Expanded = false,
        AnimHeight = 0,
    }
end

function ElementTypes.TextInput(label, placeholder, callback)
    return {
        Type = "TextInput",
        Label = label,
        Placeholder = placeholder or "",
        Value = "",
        Callback = callback,
        Focused = false,
    }
end

function ElementTypes.Keybind(label, initialKey, callback)
    return {
        Type = "Keybind",
        Label = label,
        Key = initialKey or "None",
        Callback = callback,
        Waiting = false,
    }
end

function ElementTypes.ColorPicker(label, initialColor, callback)
    return {
        Type = "ColorPicker",
        Label = label,
        Color = initialColor or Zenith.Theme.Accent,
        Callback = callback,
        Hue = 0, Sat = 1, Val = 1,
        Open = false,
    }
end

-- ========================= DRAWING FUNCTIONS =========================
local function drawRoundedRect(x, y, w, h, radius, color, transparency)
    local sq = createSquare(color, Vector2.new(x, y), Vector2.new(w, h), true)
    sq.Transparency = transparency or 0
    sq:Draw()
    sq:Remove()
    -- simple corner circles for roundness
    local circle = Drawing.new("Circle")
    circle.Filled = true
    circle.Color = color
    circle.Transparency = transparency or 0
    circle.Radius = radius
    circle.Position = Vector2.new(x + radius, y + radius)
    circle:Draw()
    circle.Position = Vector2.new(x + w - radius, y + radius)
    circle:Draw()
    circle.Position = Vector2.new(x + radius, y + h - radius)
    circle:Draw()
    circle.Position = Vector2.new(x + w - radius, y + h - radius)
    circle:Draw()
    circle:Remove()
end

local function drawButton(elem, dt)
    local target = elem.Hover and 1 or 0
    elem.AnimProgress = elem.AnimProgress + (target - elem.AnimProgress) * dt * 12
    local color = Zenith.Theme.Accent:Lerp(Zenith.Theme.AccentDark, elem.AnimProgress)
    drawRoundedRect(elem.X, elem.Y, elem.Width, elem.Height, 6, color)
    local text = createText(elem.Label, Zenith.Theme.Text, Vector2.new(elem.X + 12, elem.Y + elem.Height/2 - 8))
    text:Draw()
    text:Remove()
end

local function drawCheckbox(elem, dt)
    drawRoundedRect(elem.X, elem.Y, elem.Width, elem.Height, 6, Zenith.Theme.Element)
    local box = createSquare(Zenith.Theme.Accent, Vector2.new(elem.X + 8, elem.Y + 6), Vector2.new(20, 20), true)
    box:Draw()
    box:Remove()
    local target = elem.Value and 1 or 0
    elem.AnimValue = elem.AnimValue + (target - elem.AnimValue) * dt * 15
    if elem.AnimValue > 0.05 then
        local check = createText("✔", Zenith.Theme.Text, Vector2.new(elem.X + 12, elem.Y + 4), 16)
        check.Transparency = elem.AnimValue
        check:Draw()
        check:Remove()
    end
    local label = createText(elem.Label, Zenith.Theme.Text, Vector2.new(elem.X + 36, elem.Y + elem.Height/2 - 8))
    label:Draw()
    label:Remove()
end

local function drawSlider(elem, dt)
    drawRoundedRect(elem.X, elem.Y, elem.Width, elem.Height, 6, Zenith.Theme.Element)
    local label = createText(elem.Label .. ": " .. string.format("%."..(elem.Decimals or 0).."f", elem.Value), Zenith.Theme.Text, Vector2.new(elem.X + 8, elem.Y + 6))
    label:Draw()
    label:Remove()
    local barX = elem.X + elem.Width - 120
    local barW = 100
    drawRoundedRect(barX, elem.Y + elem.Height - 12, barW, 6, 3, Zenith.Theme.Background)
    local target = (elem.Value - elem.Min) / (elem.Max - elem.Min)
    elem.AnimValue = elem.AnimValue + (target - elem.AnimValue) * dt * 12
    drawRoundedRect(barX, elem.Y + elem.Height - 12, barW * elem.AnimValue, 6, 3, Zenith.Theme.Accent)
end

local function drawDropdown(elem, dt)
    local bgColor = elem.Expanded and Zenith.Theme.Accent or Zenith.Theme.Element
    drawRoundedRect(elem.X, elem.Y, elem.Width, 32, 6, bgColor)
    local label = createText(elem.Label, Zenith.Theme.Text, Vector2.new(elem.X + 8, elem.Y + 8))
    label:Draw()
    label:Remove()
    local current = elem.Options[elem.Selected] or ""
    local valueText = createText(current, Zenith.Theme.TextDim, Vector2.new(elem.X + elem.Width - 80, elem.Y + 8))
    valueText:Draw()
    valueText:Remove()
    local arrow = createText(elem.Expanded and "▲" or "▼", Zenith.Theme.Text, Vector2.new(elem.X + elem.Width - 20, elem.Y + 6), 12)
    arrow:Draw()
    arrow:Remove()
    if elem.Expanded then
        local optY = elem.Y + 32
        for i, opt in ipairs(elem.Options) do
            drawRoundedRect(elem.X, optY, elem.Width, 28, 4, Zenith.Theme.Surface)
            local optColor = (i == elem.Selected) and Zenith.Theme.Accent or Zenith.Theme.Text
            local optText = createText(opt, optColor, Vector2.new(elem.X + 12, optY + 6))
            optText:Draw()
            optText:Remove()
            optY = optY + 28
        end
    end
    local targetHeight = elem.Expanded and 1 or 0
    elem.AnimHeight = elem.AnimHeight + (targetHeight - elem.AnimHeight) * dt * 10
end

local function drawTextInput(elem, dt)
    drawRoundedRect(elem.X, elem.Y, elem.Width, elem.Height, 6, elem.Focused and Zenith.Theme.Accent or Zenith.Theme.Element)
    local label = createText(elem.Label, Zenith.Theme.TextDim, Vector2.new(elem.X + 8, elem.Y + 4), 11)
    label:Draw()
    label:Remove()
    local displayText = (elem.Value == "" and elem.Placeholder) or elem.Value
    local textColor = (elem.Value == "" and elem.Placeholder ~= "") and Zenith.Theme.TextDim or Zenith.Theme.Text
    local inputText = createText(displayText, textColor, Vector2.new(elem.X + 8, elem.Y + 20), 13)
    inputText:Draw()
    inputText:Remove()
    if elem.Focused then
        local cursor = createText("|", Zenith.Theme.Accent, Vector2.new(elem.X + 8 + (#displayText * 6), elem.Y + 18), 14)
        cursor:Draw()
        cursor:Remove()
    end
end

local function drawKeybind(elem, dt)
    drawRoundedRect(elem.X, elem.Y, elem.Width, elem.Height, 6, elem.Waiting and Zenith.Theme.Accent or Zenith.Theme.Element)
    local label = createText(elem.Label, Zenith.Theme.Text, Vector2.new(elem.X + 8, elem.Y + 6))
    label:Draw()
    label:Remove()
    local keyText = elem.Waiting and "Press any key..." or tostring(elem.Key)
    local keyColor = elem.Waiting and Zenith.Theme.Accent or Zenith.Theme.TextDim
    local keyLabel = createText(keyText, keyColor, Vector2.new(elem.X + elem.Width - 100, elem.Y + 8))
    keyLabel:Draw()
    keyLabel:Remove()
end

local function drawColorPicker(elem, dt)
    drawRoundedRect(elem.X, elem.Y, elem.Width, 32, 6, Zenith.Theme.Element)
    local label = createText(elem.Label, Zenith.Theme.Text, Vector2.new(elem.X + 8, elem.Y + 8))
    label:Draw()
    label:Remove()
    local preview = createSquare(elem.Color, Vector2.new(elem.X + elem.Width - 30, elem.Y + 6), Vector2.new(20, 20), true)
    preview:Draw()
    preview:Remove()
    if elem.Open then
        drawRoundedRect(elem.X, elem.Y + 32, elem.Width, 148, 6, Zenith.Theme.Surface)
        -- simplified color wheel representation (just a gradient bar for hue)
        for i = 0, elem.Width - 20 do
            local hue = i / (elem.Width - 20)
            local color = Color3.fromHSV(hue, 1, 1)
            local bar = createSquare(color, Vector2.new(elem.X + 10 + i, elem.Y + 40), Vector2.new(1, 12), true)
            bar:Draw()
            bar:Remove()
        end
        local indicator = createSquare(Color3.fromRGB(255,255,255), Vector2.new(elem.X + 10 + (elem.Hue * (elem.Width - 20)), elem.Y + 38), Vector2.new(2, 16), true)
        indicator:Draw()
        indicator:Remove()
    end
end

-- ========================= NOTIFICATIONS =========================
function Zenith:Notify(title, message, duration, type)
    local notif = {
        Title = title,
        Message = message,
        Duration = duration or 3,
        Type = type or "info",
        StartTime = tick(),
        Y = 50,
        AnimY = -100,
    }
    table.insert(self.Notifications, notif)
    tweenObject(notif, "AnimY", 50, 0.3, Enum.EasingStyle.Bounce)
end

local function drawNotifications()
    local y = 50
    for i, n in ipairs(Zenith.Notifications) do
        local alpha = 1 - (tick() - n.StartTime) / n.Duration
        if alpha <= 0 then table.remove(Zenith.Notifications, i) break end
        local bgColor = (n.Type == "error") and Zenith.Theme.Error or (n.Type == "success") and Zenith.Theme.Success or Zenith.Theme.Accent
        local yPos = n.Y + (n.AnimY - n.Y) * (1 - alpha) -- smooth slide
        drawRoundedRect(10, yPos, 260, 50, 8, bgColor, 1 - alpha)
        local title = createText(n.Title, Zenith.Theme.Text, Vector2.new(20, yPos + 6), 12)
        title.Transparency = 1 - alpha
        title:Draw()
        title:Remove()
        local msg = createText(n.Message, Zenith.Theme.TextDim, Vector2.new(20, yPos + 24), 11)
        msg.Transparency = 1 - alpha
        msg:Draw()
        msg:Remove()
        y = y + 60
    end
end

-- ========================= TOOLTIP =========================
function Zenith:ShowTooltip(text, x, y)
    if self.Tooltip then self.Tooltip:Remove() end
    self.Tooltip = createText(text, Zenith.Theme.Text, Vector2.new(x + 10, y + 10), 12)
    self.Tooltip.Outline = true
    self.Tooltip.OutlineColor = Color3.fromRGB(0,0,0)
    self.TooltipTimer = tick()
end

-- ========================= INPUT HANDLING =========================
function Zenith:Update(dt)
    local mx, my = UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y
    local clicked = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    local anyHover = false
    self.HoveredElement = nil

    -- Update windows
    for _, win in ipairs(self.Windows) do
        if win.Visible then
            win:RefreshLayout()
            -- Title bar drag
            local inTitle = mx > win.X and mx < win.X + win.Width and my > win.Y and my < win.Y + win.TitleHeight
            if inTitle and clicked and not win.Dragging then
                win.Dragging = true
                self.ActiveWindow = win
                self.DragOffset = Vector2.new(mx - win.X, my - win.Y)
            end
            if win.Dragging and not clicked then win.Dragging = false end
            if win.Dragging then
                win.X = mx - self.DragOffset.X
                win.Y = my - self.DragOffset.Y
            end
            -- Resize edges (bottom-right)
            if win.Resizable then
                local inResize = mx > win.X + win.Width - 10 and my > win.Y + win.Height - 10
                if inResize and clicked and not win.Resizing then
                    win.Resizing = true
                end
                if win.Resizing and not clicked then win.Resizing = false end
                if win.Resizing then
                    win.Width = math.max(win.MinWidth, mx - win.X)
                    win.Height = math.max(win.MinHeight, my - win.Y)
                end
            end
            -- Tabs
            local tabX = win.X + 10
            for i, tab in ipairs(win.Tabs) do
                if mx > tabX and mx < tabX + 80 and my > win.Y + win.TitleHeight and my < win.Y + win.TitleHeight + win.TabHeight then
                    anyHover = true
                    if clicked then
                        win.ActiveTab = tab
                        win.ScrollOffset = 0
                        win:RefreshLayout()
                    end
                end
                tabX = tabX + 85
            end
            -- Elements
            for _, elem in ipairs(win.Elements) do
                if mx > elem.X and mx < elem.X + elem.Width and my > elem.Y and my < elem.Y + elem.Height then
                    anyHover = true
                    self.HoveredElement = elem
                    elem.Hover = true
                    if clicked then
                        if elem.Type == "Button" then
                            elem.Callback()
                            tweenObject(elem, "AnimProgress", 0.2, 0.1)
                        elseif elem.Type == "Checkbox" then
                            elem.Value = not elem.Value
                            elem.Callback(elem.Value)
                        elseif elem.Type == "Slider" then
                            elem.Dragging = true
                        elseif elem.Type == "Dropdown" then
                            elem.Expanded = not elem.Expanded
                            tweenObject(elem, "AnimHeight", elem.Expanded and 1 or 0, 0.15)
                        elseif elem.Type == "TextInput" then
                            elem.Focused = true
                        elseif elem.Type == "Keybind" then
                            elem.Waiting = true
                        elseif elem.Type == "ColorPicker" then
                            elem.Open = not elem.Open
                        end
                    end
                    if elem.Type == "Slider" and elem.Dragging then
                        local barX = elem.X + elem.Width - 120
                        local t = clamp((mx - barX) / 100, 0, 1)
                        local newVal = elem.Min + t * (elem.Max - elem.Min)
                        if elem.Decimals == 0 then newVal = math.floor(newVal) end
                        elem.Value = newVal
                        elem.Callback(elem.Value)
                    end
                else
                    elem.Hover = false
                    if elem.Type == "Slider" then elem.Dragging = false end
                end
            end
            -- Scrolling
            local scrollDelta = UserInputService:GetMouseDelta().Y
            if my > win.Y + win.TitleHeight + win.TabHeight and my < win.Y + win.Height then
                win.ScrollOffset = clamp(win.ScrollOffset - scrollDelta * 0.5, 0, math.max(0, win.ContentHeight - (win.Height - win.TitleHeight - win.TabHeight)))
            end
        end
    end

    -- Handle keybind waiting
    if self.HoveredElement and self.HoveredElement.Type == "Keybind" and self.HoveredElement.Waiting then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if self.HoveredElement and self.HoveredElement.Waiting then
                local key = input.KeyCode.Name
                if key == "Unknown" then key = input.UserInputType.Name end
                self.HoveredElement.Key = key
                self.HoveredElement.Waiting = false
                self.HoveredElement.Callback(key)
            end
        end):Disconnect() -- one-shot
    end

    -- Tooltip
    if self.Tooltip and tick() - self.TooltipTimer > 2 then
        self.Tooltip:Remove()
        self.Tooltip = nil
    end
    if self.HoveredElement and not self.Tooltip then
        local tip = (self.HoveredElement.Type == "Button" and "Click to execute") or
                    (self.HoveredElement.Type == "Slider" and "Drag to adjust") or
                    (self.HoveredElement.Type == "Dropdown" and "Click to expand") or
                    nil
        if tip then self:ShowTooltip(tip, mx, my) end
    end
end

-- ========================= MAIN DRAW =========================
function Zenith:Draw()
    for _, win in ipairs(self.Windows) do
        if win.Visible then
            drawShadow(win.X, win.Y, win.Width, win.Height)
            drawRoundedRect(win.X, win.Y, win.Width, win.Height, 10, Zenith.Theme.Surface)
            -- Title bar
            drawRoundedRect(win.X, win.Y, win.Width, win.TitleHeight, 10, Zenith.Theme.Background)
            local title = createText(win.Title, Zenith.Theme.Text, Vector2.new(win.X + 10, win.Y + 6), 16)
            title:Draw()
            title:Remove()
            -- Tabs
            local tabX = win.X + 10
            for i, tab in ipairs(win.Tabs) do
                local active = (tab == win.ActiveTab)
                local tabColor = active and Zenith.Theme.Accent or Zenith.Theme.Element
                drawRoundedRect(tabX, win.Y + win.TitleHeight, 80, win.TabHeight, 6, tabColor)
                local tabText = createText(tab.Name, active and Zenith.Theme.Text or Zenith.Theme.TextDim, Vector2.new(tabX + 5, win.Y + win.TitleHeight + 6), 12)
                tabText:Draw()
                tabText:Remove()
                tabX = tabX + 85
            end
            -- Elements (clipped)
            local clipRegion = {
                X = win.X, Y = win.Y + win.TitleHeight + win.TabHeight,
                Width = win.Width, Height = win.Height - win.TitleHeight - win.TabHeight
            }
            -- Simulate clipping by checking Y bounds (draw only visible)
            for _, elem in ipairs(win.Elements) do
                if elem.Y + elem.Height > clipRegion.Y and elem.Y < clipRegion.Y + clipRegion.Height then
                    if elem.Type == "Button" then drawButton(elem, RunService.RenderStepTime) end
                    if elem.Type == "Checkbox" then drawCheckbox(elem, RunService.RenderStepTime) end
                    if elem.Type == "Slider" then drawSlider(elem, RunService.RenderStepTime) end
                    if elem.Type == "Dropdown" then drawDropdown(elem, RunService.RenderStepTime) end
                    if elem.Type == "TextInput" then drawTextInput(elem, RunService.RenderStepTime) end
                    if elem.Type == "Keybind" then drawKeybind(elem, RunService.RenderStepTime) end
                    if elem.Type == "ColorPicker" then drawColorPicker(elem, RunService.RenderStepTime) end
                end
            end
        end
    end
    drawNotifications()
end

-- ========================= EXAMPLE DEMO (run this script alone) =========================
local function startDemo()
    local ui = Zenith
    local mainWin = ui:CreateWindow("Zenith UI - Demo", 200, 150, 420, 500)
    local general = mainWin:AddTab("General")
    local visuals = mainWin:AddTab("Visuals")
    local misc = mainWin:AddTab("Misc")

    mainWin:AddElement(general, ElementTypes.Button("Click Me", function() ui:Notify("Button", "You clicked the button!", 2, "success") end))
    mainWin:AddElement(general, ElementTypes.Checkbox("Enable Feature", true, function(v) print("Checkbox:", v) end))
    mainWin:AddElement(general, ElementTypes.Slider("Volume", 0, 100, 50, function(v) print("Volume:", v) end, 0))
    mainWin:AddElement(general, ElementTypes.Dropdown("Mode", {"Aimbot", "Triggerbot", "ESP"}, 1, function(v) print("Mode:", v) end))
    mainWin:AddElement(general, ElementTypes.TextInput("Username", "Enter name", function(v) print("Name:", v) end))
    mainWin:AddElement(general, ElementTypes.Keybind("Open Menu", "RightControl", function(k) print("Keybind:", k) end))
    mainWin:AddElement(general, ElementTypes.ColorPicker("Accent Color", ui.Theme.Accent, function(c) ui.Theme.Accent = c end))

    -- Run loop
    local heartbeat
    heartbeat = RunService.RenderStepped:Connect(function(dt)
        ui:Update(dt)
        ui:Draw()
    end)
    return heartbeat
end

if game:GetService("RunService"):IsStudio() then
    -- In Roblox Studio, demo runs automatically
    startDemo()
end

return Zenith
