# Zenith UI Framework v3.0 - Complete Documentation

*Lua | 30+ Components | Cyberpunk Style | made by Xen / GHP*

---

## Quick Start

```lua
local Zenith = loadstring(game:HttpGet(https://raw.githubusercontent.com/Xens-GHP/Zenith-UI/refs/heads/main/source.lua))()

-- Set theme (Dark, Purple, or Ocean)
Zenith:CreateTheme("Dark")

-- Create a window
local window = Zenith:CreateWindow({Title = "My Game"})

-- Add a tab
local tab = window:CreateTab("Main")

-- Add components
tab:CreateButton({Text = "Click Me!", Callback = function()
    print("Button pressed!")
end})

-- Show notifications
Zenith:Notify({
    Type = "success",
    Title = "Success!",
    Content = "Everything is working"
})
```

---

## Complete Table of Contents

1. [Getting Started](#getting-started)
2. [Core Components](#-core-components)
3. [Advanced Components](#-advanced-components)
4. [Modal & Popup System](#-modal--popup-system)
5. [Theme System](#-theme-system)
6. [Animation System](#-animation-system)
7. [Windows & Tabs](#-windows--tabs)
8. [Utility Functions](#-utility-functions)
9. [Full API Reference](#-full-api-reference)
10. [Code Examples](#-complete-examples)
11. [Integration Patterns](#-integration-patterns)
12. [Performance Tips](#-performance-tips)

---

## Getting Started

### Installation

1. Get the library URL
2. Load it in your script:
```lua
local Zenith = loadstring(game:HttpGet(https://raw.githubusercontent.com/Xens-GHP/Zenith-UI/refs/heads/main/source.lua))()
```

### Setting a Theme

```lua
-- Use built-in theme
Zenith:CreateTheme("Dark")    -- Cyan/Magenta cyberpunk
Zenith:CreateTheme("Purple")  -- Purple gradient vibes
Zenith:CreateTheme("Ocean")   -- Blue professional

-- Or create custom
Zenith:SetTheme({
    Primary = Color3.fromRGB(0, 255, 255),
    Secondary = Color3.fromRGB(255, 0, 255),
    Background = Color3.fromRGB(5, 5, 10)
})
```

## Core Components

### Buttons

**CreateButton(options)**
```lua
tab:CreateButton({
    Text = "Click Me!",
    Callback = function()
        print("Button clicked!")
    end
})
```

Features: Hover effects, gradient background, smooth animations, click feedback

### Toggles

**CreateToggle(options)**
```lua
tab:CreateToggle({
    Text = "Enable Setting",
    Default = false,
    Callback = function(state)
        print("Toggle is: " .. tostring(state))
    end
})
```

Features: iOS-style switch, smooth animation, state tracking

### Sliders

**CreateSlider(options)**
```lua
tab:CreateSlider({
    Text = "Volume",
    Min = 0,
    Max = 100,
    Default = 50,
    Decimals = 0,
    Callback = function(value)
        print("Volume: " .. value)
    end
})
```

Features: Animated thumb, gradient fill, value display, smooth tweening

### Dropdowns

**CreateDropdown(options)**
```lua
tab:CreateDropdown({
    Text = "Select Option",
    Default = "Option 1",
    Values = {"Option 1", "Option 2", "Option 3"},
    Callback = function(selected)
        print("Selected: " .. selected)
    end
})
```

Features: Dropdown list, click-to-close, smooth animations

### Search Dropdowns

**CreateSearchDropdown(options)**
```lua
tab:CreateSearchDropdown({
    Text = "Search Items",
    Values = {"Sword", "Shield", "Potion", "Helmet"},
    Callback = function(selected)
        print("Found: " .. selected)
    end
})
```

Features: Real-time search filtering, dynamic results

### Color Picker

**CreateColorPicker(options)**
```lua
tab:CreateColorPicker({
    Text = "Pick a Color",
    Default = Zenith.Theme.Primary,
    Callback = function(color)
        -- Color selected
    end
})
```

Features: HSV color selection, hue slider, color preview

### Keybind

**CreateKeybind(options)**
```lua
tab:CreateKeybind({
    Text = "Interact Key",
    Default = "E",
    Callback = function(key)
        print("Keybind set to: " .. key)
    end
})
```

Features: Listen for key presses, 5-second timeout, visual feedback

### Input Fields

**CreateInput(options)**
```lua
local input = tab:CreateInput({
    Text = "Enter Name",
    Placeholder = "Type something..."
})

-- Get value
local text = input.textBox.Text
```

Features: Text input with focus animations, placeholder text

### Progress Bars

**CreateProgressBar(options)**
```lua
local bar = tab:CreateProgressBar({
    Text = "Loading"
})

bar.SetProgress(0.5)  -- 50% progress
```

Features: Smooth animations, gradient fill, value display

### Labels & Paragraphs

**CreateLabel(text)**
```lua
tab:CreateLabel("This is a small label")
```

**CreateParagraph(text)**
```lua
tab:CreateParagraph("This is a longer paragraph that can wrap to multiple lines...")
```

### Sections

**CreateSection(title)**
```lua
tab:CreateSection("Character Stats")
tab:CreateSlider({Text = "Health", Min = 0, Max = 100})
tab:CreateSlider({Text = "Mana", Min = 0, Max = 100})
```

---

## Advanced Components

### CreateContextMenu()

Right-click context menus for object interactions.

```lua
Zenith:CreateContextMenu({
    Position = UserInputService:GetMouseLocation(),
    Items = {
        {Text = "Edit", Callback = function() end},
        {Text = "Delete", Callback = function() end},
        {Text = "Copy", Callback = function() end}
    }
})
```

### CreateLeaderboard()

Professional rank-based leaderboard.

```lua
Zenith:CreateLeaderboard({
    Title = "Top Players",
    Position = UDim2.new(1, -370, 0, 20),
    Entries = {
        {Name = "Player1", Score = 5000},
        {Name = "Player2", Score = 4500},
        {Name = "Player3", Score = 4000}
    }
})
```

Features: Auto-coloring (Gold/Silver/Bronze), rank numbers, scrollable

### CreateChatBubble()

NPC and player dialogue bubbles.

```lua
-- Player message (cyan)
Zenith:CreateChatBubble({
    Message = "Hi!",
    IsPlayer = true,
    Position = UDim2.new(0.7, 0, 0.5, 0)
})

-- NPC response (with delay)
task.wait(1.5)
Zenith:CreateChatBubble({
    Message = "Welcome to my shop!",
    IsPlayer = false,
    Position = UDim2.new(0.3, 0, 0.5, 0)
})
```

Features: Pop-in animation, auto-dismiss, color coding

### CreateStatBar()

Health, mana, and stamina bars.

```lua
local health = Zenith:CreateStatBar({
    Name = "Health",
    Current = 90,
    Maximum = 100,
    Position = UDim2.new(0, 20, 0, 20)
})

-- Update value
health.SetValue(75, 100)
```

Features: Color gradients, smooth tweening, text labels, percentage display

### CreateDialogue()

Multi-line conversation system with typewriter effect.

```lua
Zenith:CreateDialogue({
    Speaker = "Quest Master",
    Lines = {
        "Welcome, adventurer!",
        "I have a task for you.",
        "Will you help?"
    },
    OnComplete = function()
        print("Dialogue finished!")
    end
})
```

Features: Typewriter effect, continue button, speaker name, gradient background

### CreateBadge()

Notification counters and badges.

```lua
local badge = Zenith:CreateBadge({
    Count = 5,
    Position = UDim2.new(1, -25, 0, 10),
    Color = Zenith.Theme.Danger
})

badge.Increment()           -- +1
badge.Decrement()           -- -1
badge.SetCount(0)           -- Hide badge
```

Features: Pulse animation, auto-hide at 0, counter methods

### CreateInventoryGrid()

RPG-style inventory with grid slots.

```lua
local inventory = Zenith:CreateInventoryGrid({
    Title = "Inventory",
    Columns = 5,
    Rows = 4,
    ItemSize = 70
})

inventory.AddItem("Iron Sword", "rbxassetid://123", function()
    print("Used sword!")
end)

inventory.AddItem("Health Potion", "rbxassetid://456")
```

Features: Click detection, item icons, grid layout, animations

### CreateHotkeys()

Hotkey display panel with keybind integration.

```lua
Zenith:CreateHotkeys({
    Position = UDim2.new(0, 20, 1, -200),
    Hotkeys = {
        {Key = "E", Text = "Interact"},
        {Key = "Q", Text = "Ability 1"},
        {Key = "R", Text = "Reload"},
        {Key = "F", Text = "Special"}
    }
})
```

Features: Auto-registers keybinds, color-coded badges, customizable position

### CreateTooltip()

Floating tooltips with auto-fade.

```lua
Zenith:CreateTooltip({
    Text = "Click to open menu",
    Position = UserInputService:GetMouseLocation()
})
```

Features: Auto-sizing, 3-second fade, smooth animations

---

## Modal & Popup System

### CreateModal()

General-purpose modal windows.

```lua
local modal = Zenith:CreateModal({
    Title = "Confirm Action",
    Content = "Are you sure you want to proceed?",
    Size = UDim2.new(0, 500, 0, 350),
    ShowConfirm = true,
    OnConfirm = function()
        print("Confirmed!")
    end,
    OnClose = function()
        print("Modal closed")
    end
})

-- Later: modal.Close()
```

Features: Customizable size, confirm/close buttons, animations, backdrop

### CreatePlayerPopup()

Music player popup with controls.

```lua
local player = Zenith:CreatePlayerPopup({
    Title = "Song Name",
    Artist = "Artist Name",
    OnPlay = function()
        -- Start playback
    end,
    OnPause = function()
        -- Pause playback
    end,
    OnNext = function()
        -- Next track
    end,
    OnPrev = function()
        -- Previous track
    end,
    OnStop = function()
        -- Stop playback
    end
})

-- Update progress
player.UpdateProgress(0.5)  -- 50% progress
player.UpdateTitle("New Song")
player.UpdateArtist("New Artist")
player.Close()
```

Features: Album art area, progress bar, time display, 4 control buttons

### CreateConfirmDialog()

Yes/No confirmation dialog.

```lua
Zenith:CreateConfirmDialog({
    Title = "Delete File?",
    Message = "This action cannot be undone.",
    OnConfirm = function()
        print("Confirmed!")
    end,
    OnCancel = function()
        print("Cancelled!")
    end
})
```

Features: Warning theme, two-button layout, backdrop

### CreateAlertPopup()

Typed alert popups.

```lua
-- Error alert
Zenith:CreateAlertPopup({
    Title = "Error",
    Message = "Something went wrong!",
    Type = "error",  -- error, warning, success, info
    OnOk = function()
        print("Alert closed")
    end
})
```

Features: Type-based coloring (red/orange/green/blue), icon symbols

### CloseAllModals()

Close all active popups.

```lua
Zenith:CloseAllModals()
```

---

## Theme System

### Available Themes

**Dark** (Cyberpunk - Default)
- Cyan primary (#00FFFF)
- Magenta secondary (#FF00FF)
- Dark background

**Purple**
- Purple-gradient themed
- Professional gaming look

**Ocean**
- Blue/cyan colors
- Professional appearance

### Creating Custom Themes

```lua
Zenith:CreateTheme("MyTheme", {
    Background = Color3.fromRGB(10, 10, 20),
    Surface = Color3.fromRGB(20, 20, 35),
    SurfaceLight = Color3.fromRGB(30, 30, 50),
    Primary = Color3.fromRGB(0, 255, 255),
    Secondary = Color3.fromRGB(255, 0, 255),
    Accent = Color3.fromRGB(255, 200, 0),
    Danger = Color3.fromRGB(255, 50, 50),
    Success = Color3.fromRGB(100, 255, 100),
    Warning = Color3.fromRGB(255, 200, 0),
    Info = Color3.fromRGB(100, 200, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 150),
    Border = Color3.fromRGB(50, 50, 50)
})
```

### Changing Themes at Runtime

```lua
Zenith:SetTheme({
    Primary = Color3.fromRGB(0, 200, 255),
    Secondary = Color3.fromRGB(200, 0, 255)
})
```

All components automatically update!

---

## Animation System

### Animation Presets

```lua
local presets = {
    Fast = {Duration = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out},
    Normal = {Duration = 0.3, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out},
    Smooth = {Duration = 0.5, Style = Enum.EasingStyle.Sine, Direction = Enum.EasingDirection.InOut},
    Slow = {Duration = 0.8, Style = Enum.EasingStyle.Sine, Direction = Enum.EasingDirection.InOut},
    Bounce = {Duration = 0.4, Style = Enum.EasingStyle.Back, Direction = Enum.EasingDirection.Out}
}
```

### Using Animations

```lua
-- Tween with preset
tween(frame, {Position = UDim2.new(0.5, 0, 0.5, 0)}, AnimationPresets.Normal.Duration)

-- Custom tween
tween(frame, {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}, 0.5, Enum.EasingStyle.Back)
```

---

## Windows & Tabs

### Creating Windows

```lua
local window = Zenith:CreateWindow({
    Title = "My Panel",
    Size = UDim2.new(0, 900, 0, 600),
    Resizable = true  -- Optional: allow resizing
})
```

Features: Draggable, closable, tabbed interface, title bar with gradient

### Creating Tabs

```lua
local combatTab = window:CreateTab("Combat")
local settingsTab = window:CreateTab("Settings")

-- Add components to tabs
combatTab:CreateButton({Text = "Attack"})
settingsTab:CreateSlider({Text = "Brightness"})
```

### Tab APIs

```lua
-- Add sections
combatTab:CreateSection("Abilities")

-- Add components
combatTab:CreateButton({Text = "Fireball"})
combatTab:CreateToggle({Text = "Auto-cast"})

-- Add labels
combatTab:CreateLabel("Advanced options:")
combatTab:CreateParagraph("These are experimental features...")
```

---

## Utility Functions

### tween()

Animate properties with easing.

```lua
tween(obj, {
    Position = UDim2.new(0, 100, 0, 100),
    BackgroundColor3 = Color3.fromRGB(255, 0, 0),
    BackgroundTransparency = 0.5
}, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
```

### addGlow()

Add glowing outline to UI.

```lua
addGlow(frame, Color3.fromRGB(0, 255, 255), 2, 0.4)
-- Arguments: object, color, thickness, transparency
```

### addGradient()

Apply color gradient.

```lua
addGradient(frame, 
    Color3.fromRGB(0, 255, 255),      -- Start color
    Color3.fromRGB(255, 0, 255),      -- End color
    45                                 -- Rotation angle
)
```

### addShadow()

Add drop shadow effect.

```lua
addShadow(frame, 
    Color3.fromRGB(0, 0, 0),  -- Color
    5,                         -- Size
    0.7                        -- Transparency
)
```

### lerp()

Linear interpolation.

```lua
local smoothValue = lerp(startValue, endValue, 0.5)
-- Returns: value halfway between start and end
```

### makeDraggable()

Make frames draggable.

```lua
makeDraggable(window.Frame, window.TitleBar)
-- Arguments: frame to drag, handle (optional)
```

### makeResizable()

Make frames resizable.

```lua
makeResizable(frame, 
    UDim2.new(0, 400, 0, 300),   -- Min size
    UDim2.new(0, 1200, 0, 800)   -- Max size
)
```

### RegisterKeybind()

Register keyboard hotkeys.

```lua
Zenith:RegisterKeybind("E", function()
    print("E key pressed!")
end)
```

---

## Full API Reference

### Notification Functions

```lua
Zenith:Notify(options)          -- Bottom-right notification
Zenith:Toast(title, msg, time)  -- Top-down notification
Zenith:ShowLoading(message)     -- Show loading spinner
Zenith:HideLoading()            -- Hide loading spinner
```

### Window Functions

```lua
Zenith:CreateWindow(options)    -- Create tabbed window
Zenith:CreateTheme(name)        -- Set theme
Zenith:SetTheme(colors)         -- Update theme colors
```

### Component Functions

Buttons, Toggles, Sliders, Dropdowns, Inputs, Color Pickers, Keybinds, etc.

All follow same pattern:
```lua
tab:CreateButton({
    Text = "...",
    Callback = function() end,
    ... other options
})
```

### Modal Functions

```lua
Zenith:CreateModal(options)           -- General modal
Zenith:CreatePlayerPopup(options)     -- Music player
Zenith:CreateConfirmDialog(options)   -- Confirmation
Zenith:CreateAlertPopup(options)      -- Alert
Zenith:CloseAllModals()               -- Close all popups
```

### Advanced Component Functions

```lua
Zenith:CreateContextMenu(options)     -- Right-click menu
Zenith:CreateLeaderboard(options)     -- Leaderboard widget
Zenith:CreateChatBubble(options)      -- Dialogue bubble
Zenith:CreateStatBar(options)         -- Stat bar
Zenith:CreateDialogue(options)        -- Conversation system
Zenith:CreateBadge(options)           -- Notification badge
Zenith:CreateInventoryGrid(options)   -- Grid inventory
Zenith:CreateHotkeys(options)         -- Hotkey panel
Zenith:CreateTooltip(options)         -- Floating tooltip
```

---

## Complete Examples

### RPG Game UI

```lua
local Zenith = loadstring(game:HttpGet("YOUR_URL"))()
Zenith:CreateTheme("Dark")

-- Create main window
local window = Zenith:CreateWindow({Title = "RPG Panel", Size = UDim2.new(0, 900, 0, 600)})

-- Character tab
local charTab = window:CreateTab("Character")
charTab:CreateSection("Stats")
charTab:CreateStatBar({Name = "Health", Current = 95, Maximum = 100, Position = UDim2.new(0, 20, 0, 60)})
charTab:CreateStatBar({Name = "Mana", Current = 70, Maximum = 100, Position = UDim2.new(0, 20, 0, 110)})

-- Inventory tab
local invTab = window:CreateTab("Inventory")
local inv = Zenith:CreateInventoryGrid({Title = "Items", Columns = 5, Rows = 4, Position = UDim2.new(0.5, 0, 0.5, 0)})
inv.AddItem("Iron Sword")
inv.AddItem("Health Potion")

-- Leaderboard
Zenith:CreateLeaderboard({
    Title = "Global Leaderboard",
    Entries = {
        {Name = "Player1", Score = 9999},
        {Name = "Player2", Score = 8500},
        {Name = "Player3", Score = 7800}
    }
})

-- Quest dialogue
Zenith:CreateDialogue({
    Speaker = "Quest Master",
    Lines = {
        "Welcome, adventurer!",
        "A dragon attacks nearby villages.",
        "Will you help us?"
    }
})
```

### Combat Game UI

```lua
local Zenith = loadstring(game:HttpGet("YOUR_URL"))()
Zenith:CreateTheme("Dark")

-- Create overlay with stats
local hp = Zenith:CreateStatBar({
    Name = "Health",
    Current = 100,
    Maximum = 100,
    Position = UDim2.new(0, 20, 0, 20)
})

local mana = Zenith:CreateStatBar({
    Name = "Mana",
    Current = 75,
    Maximum = 100,
    Position = UDim2.new(0, 20, 0, 70)
})

-- Hotkey panel
Zenith:CreateHotkeys({
    Position = UDim2.new(0, 20, 1, -200),
    Hotkeys = {
        {Key = "E", Text = "Dash"},
        {Key = "Q", Text = "Fireball"},
        {Key = "W", Text = "Ice Storm"},
        {Key = "R", Text = "Ultimate"}
    }
})

-- Combat notifications
Zenith:Notify({Type = "info", Title = "Battle Start!", Content = "Prepare for combat!"})

task.wait(2)

-- Simulate damage
hp.SetValue(80, 100)
Zenith:Notify({Type = "warning", Title = "Damaged!", Content = "You took 20 damage"})

task.wait(2)

-- Victory
Zenith:Notify({Type = "success", Title = "Victory!", Content = "You won the battle!"})
```

### Music Player UI

```lua
local Zenith = loadstring(game:HttpGet("YOUR_URL"))()
Zenith:CreateTheme("Dark")

local songs = {
    {name = "Battle Hymn", artist = "Composer", duration = 240},
    {name = "Boss Theme", artist = "Composer", duration = 180},
    {name = "Victory", artist = "Composer", duration = 120}
}

function showMusicPlayer(song)
    local player = Zenith:CreatePlayerPopup({
        Title = song.name,
        Artist = song.artist,
        OnPlay = function()
            print("Playing: " .. song.name)
        end,
        OnNext = function()
            local nextIdx = math.random(1, #songs)
            showMusicPlayer(songs[nextIdx])
        end,
        OnStop = function()
            print("Stopped")
        end
    })
end

showMusicPlayer(songs[1])
```

---

## Integration Patterns

### With Leaderstats

```lua
task.spawn(function()
    while true do
        local player = game.Players.LocalPlayer
        if player:FindFirstChild("leaderstats") then
            local health = player.leaderstats.Health.Value
            local maxHealth = 100
            healthBar.SetValue(health, maxHealth)
        end
        task.wait(0.1)
    end
end)
```

### With DataStore

```lua
Zenith:Register Keybind("S", function()
    local data = {
        health = 95,
        level = 10,
        exp = 5500
    }
    -- Save to DataStore
    dataStore:SetAsync(player.UserId, data)
end)
```

### With Animations

```lua
Zenith:RegisterKeybind("Q", function()
    -- Play animation
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://123456"
    local track = humanoid:LoadAnimation(anim)
    track:Play()
    
    -- Show UI notification
    Zenith:Notify({Type = "info", Title = "Ability", Content = "Fireball cast!"})
end)
```

---

## Performance Tips

1. **Reuse Components**: Don't recreate UI every frame
2. **Cache References**: Store component references for updates
3. **Lazy Load**: Create UI only when visible
4. **Batch Updates**: Update multiple stats at once (not per-frame)
5. **Use Threading**: Spawn long tasks to avoid blocking

```lua
-- Good
local healthBar = Zenith:CreateStatBar({Name = "Health"})
healthBar.SetValue(newHealth, maxHealth)  -- Efficient

-- Bad
for i = 1, 10 do
    Zenith:CreateStatBar({Name = "Health"})  -- Wasteful!
end
```

---

## Library Statistics

- **Total Lines**: 2,631
- **Components**: 30+
- **Themes**: 3 built-in + custom
- **Documentation**: 100+ KB
- **Examples**: 50+ code snippets
- **Dependencies**: 0 (fully standalone)

---

## Tips & Tricks

### Color Themes
All components automatically respect your theme. Change the theme once, all UIs update!

### Animations
Use the built-in `AnimationPresets` for consistent timing:
- Fast (0.15s) - Quick responses
- Normal (0.3s) - Default transitions
- Smooth (0.5s) - Comfortable viewing
- Slow (0.8s) - Cinematic feel
- Bounce (0.4s) - Playful effects

### Modals
Multiple modals layer automatically with proper Z-indexing. Use `CloseAllModals()` to reset.

### Keybinds
Register keybinds for hotkey panels, and they'll automatically be added to the panel!

---

## Common Issues

**Components not showing?**
- Check that `CoreGui` is accessible
- Verify theme colors have contrast

**Animations jerky?**
- Use animation presets instead of custom durations
- Avoid tweening every frame

**Theme not updating?**
- Use `Zenith:SetTheme()` instead of replacing table
- Check all components reference `Zenith.Theme`
---

## License & Credits

**Zenith UI Framework v3.0+**  
Built with 💜 by Xen  
All code is free to use and modify!
