# Zenith UI – API Documentation

**Version 1.0**  
*Modern, fully animated UI library for Roblox executors*  
**Source:** [https://raw.githubusercontent.com/Xens-GHP/Zenith-UI/refs/heads/main/source.lua](https://raw.githubusercontent.com/Xens-GHP/Zenith-UI/refs/heads/main/source.lua)  
**Style:** Vape V4 / Meteor Client inspired – dark theme, rounded corners, smooth tweens, accent colors.

---

## Installation

Load the library directly into your script:

```lua
local Zenith = loadstring(game:HttpGet("https://raw.githubusercontent.com/Xens-GHP/Zenith-UI/refs/heads/main/source.lua"))()
```

> **Requirements:** Your executor must support the `Drawing` API and `TweenService` (Synapse X, Krnl, ScriptWare, etc.).

---

## Quick Start

```lua
-- Create a window
local mainWin = Zenith:CreateWindow("My First UI", 200, 150, 400, 500)

-- Add a tab
local general = mainWin:AddTab("General")

-- Add a button
mainWin:AddElement(general, Zenith.ElementTypes.Button("Click me", function()
    print("Hello from Zenith!")
end))

-- Start the render loop
game:GetService("RunService").RenderStepped:Connect(function(dt)
    Zenith:Update(dt)
    Zenith:Draw()
end)
```

---

## Window API

### `Zenith:CreateWindow(title, x, y, width, height)`
Creates a new draggable, resizable window.

| Parameter | Type    | Description                        |
|-----------|---------|------------------------------------|
| `title`   | string  | Title shown in the title bar       |
| `x, y`    | number  | Initial screen position (pixels)   |
| `width`   | number  | Window width                       |
| `height`  | number  | Window height                      |

**Returns:** Window object

### Window methods

| Method                           | Description                         |
|----------------------------------|-------------------------------------|
| `window:AddTab(name)`            | Adds a new tab, returns tab object  |
| `window:AddElement(tab, element)`| Adds an element to a specific tab   |

### Window properties (read/write)

| Property           | Type     | Description                         |
|--------------------|----------|-------------------------------------|
| `window.X, window.Y` | number   | Position                            |
| `window.Width, window.Height` | number   | Dimensions                    |
| `window.Visible`   | boolean  | Show/hide the window                |
| `window.Title`     | string   | Change title dynamically            |
| `window.ActiveTab` | tab object| Currently selected tab             |
| `window.Resizable` | boolean  | Enable/disable bottom‑right resize  |
| `window.Closable`  | boolean  | (Future) Add close button           |

---

## Tab API

### `window:AddTab(name)`
Adds a tab to the window. Tabs appear horizontally below the title bar.

```lua
local settingsTab = mainWin:AddTab("Settings")
local visualsTab = mainWin:AddTab("Visuals")
```

Tabs are automatically laid out. Clicking a tab switches the displayed elements.

---

## Elements

All elements are created with `Zenith.ElementTypes.*` and must be added to a tab via `window:AddElement(tab, element)`.

### Common element properties (available after creation)

| Property         | Type     | Read‑only | Description                     |
|------------------|----------|-----------|---------------------------------|
| `element.Hover`  | boolean  | Yes       | Whether mouse is over the element |
| `element.Visible`| boolean  | No        | Show/hide individual element    |

---

### 1. Button

**`Zenith.ElementTypes.Button(label, callback)`**

| Parameter | Type     | Description                      |
|-----------|----------|----------------------------------|
| `label`   | string   | Text displayed on the button     |
| `callback`| function | Called when button is clicked    |

**Example:**
```lua
local btn = Zenith.ElementTypes.Button("Execute", function()
    Zenith:Notify("Info", "Button clicked!", 2, "success")
end)
mainWin:AddElement(tab, btn)
```

---

### 2. Checkbox

**`Zenith.ElementTypes.Checkbox(label, initialValue, callback)`**

| Parameter      | Type     | Description                               |
|----------------|----------|-------------------------------------------|
| `label`        | string   | Text next to the checkbox                 |
| `initialValue` | boolean  | Starting state (true/false)               |
| `callback`     | function | Called on toggle, receives new boolean value |

**Example:**
```lua
local chk = Zenith.ElementTypes.Checkbox("Aimbot", true, function(state)
    print("Aimbot enabled:", state)
end)
```

---

### 3. Slider

**`Zenith.ElementTypes.Slider(label, min, max, initial, callback, decimals)`**

| Parameter | Type     | Description                                      |
|-----------|----------|--------------------------------------------------|
| `label`   | string   | Text label                                       |
| `min`     | number   | Minimum value                                    |
| `max`     | number   | Maximum value                                    |
| `initial` | number   | Starting value                                   |
| `callback`| function | Called when value changes, receives current value |
| `decimals`| number   | (Optional) Number of decimal places, default 0   |

**Example:**
```lua
local sld = Zenith.ElementTypes.Slider("Volume", 0, 100, 75, function(val)
    print("Volume set to", val)
end, 0)
```

---

### 4. Dropdown

**`Zenith.ElementTypes.Dropdown(label, options, selectedIndex, callback)`**

| Parameter       | Type     | Description                                    |
|-----------------|----------|------------------------------------------------|
| `label`         | string   | Text label                                     |
| `options`       | table    | Array of strings (e.g., `{"Easy","Hard"}`)     |
| `selectedIndex` | number   | 1‑based index of initially selected option     |
| `callback`      | function | Called on selection change, receives selected string and index |

**Example:**
```lua
local drop = Zenith.ElementTypes.Dropdown("Mode", {"Aimbot", "Triggerbot", "ESP"}, 2, function(option, idx)
    print("Selected:", option, "Index:", idx)
end)
```

---

### 5. Text Input

**`Zenith.ElementTypes.TextInput(label, placeholder, callback)`**

| Parameter     | Type     | Description                                      |
|---------------|----------|--------------------------------------------------|
| `label`       | string   | Small label above the input field                |
| `placeholder` | string   | Grey hint text when the field is empty           |
| `callback`    | function | Called when the input loses focus or Enter is pressed, receives the string |

**Example:**
```lua
local input = Zenith.ElementTypes.TextInput("Username", "Enter your name", function(text)
    print("Input:", text)
end)
```

> **Note:** The library only provides the visual input box. You must implement the actual keyboard capture using `UserInputService` in your executor. The `callback` is triggered manually when you decide (e.g., after reading the input from a custom keyboard hook).

---

### 6. Keybind

**`Zenith.ElementTypes.Keybind(label, initialKey, callback)`**

| Parameter    | Type     | Description                                         |
|--------------|----------|-----------------------------------------------------|
| `label`      | string   | Text label                                          |
| `initialKey` | string   | Initial key name (e.g., `"RightControl"`, `"None"`) |
| `callback`   | function | Called when a new key is bound, receives the key name string |

**Example:**
```lua
local kb = Zenith.ElementTypes.Keybind("Open Menu", "RightControl", function(key)
    print("Bound key:", key)
end)
```

**Behavior:** Clicking the element highlights it and enters “waiting” mode. The next key press (or mouse button) is captured and stored. The callback is executed with the key name.

---

### 7. Color Picker

**`Zenith.ElementTypes.ColorPicker(label, initialColor, callback)`**

| Parameter      | Type     | Description                                          |
|----------------|----------|------------------------------------------------------|
| `label`        | string   | Text label                                           |
| `initialColor` | Color3   | Starting color (e.g., `Color3.fromRGB(0,200,200)`)   |
| `callback`     | function | Called when color changes, receives the new `Color3` |

**Example:**
```lua
local cp = Zenith.ElementTypes.ColorPicker("Accent Color", Zenith.Theme.Accent, function(color)
    Zenith.Theme.Accent = color
end)
```

The picker currently shows a hue slider. Expanding it reveals a gradient bar – clicking on it updates the hue and the preview square.

---

## Notifications

### `Zenith:Notify(title, message, duration, type)`
Shows a toast notification that auto‑fades.

| Parameter  | Type     | Description                                         |
|------------|----------|-----------------------------------------------------|
| `title`    | string   | Bold title line                                     |
| `message`  | string   | Secondary text                                      |
| `duration` | number   | Seconds to remain visible (default 3)               |
| `type`     | string   | `"info"` (cyan), `"success"` (green), `"error"` (red) |

**Example:**
```lua
Zenith:Notify("Success", "Settings saved!", 2, "success")
Zenith:Notify("Error", "Invalid value", 3, "error")
```

---

## Theme Customization

Modify the `Zenith.Theme` table to change colors globally.

| Property         | Default (RGB)               | Description                     |
|------------------|-----------------------------|---------------------------------|
| `Background`     | 18,18,24                    | Main background (rarely seen)   |
| `Surface`        | 28,28,36                    | Window background               |
| `Element`        | 38,38,48                    | Input backgrounds               |
| `Accent`         | 0,200,200                   | Cyan – highlight color          |
| `AccentDark`     | 0,150,150                   | Darker shade for hover          |
| `Text`           | 240,240,245                 | Primary text                    |
| `TextDim`        | 160,160,180                 | Dim / placeholder text          |
| `Border`         | 45,45,55                    | Border color (outlines)         |
| `Shadow`         | 0,0,0                       | Drop shadow color               |
| `ShadowAlpha`    | 0.35                        | Shadow opacity                  |
| `Success`        | 80,200,120                  | Green for success notifications |
| `Error`          | 220,60,60                   | Red for error notifications     |

**Example – change accent to pink:**
```lua
Zenith.Theme.Accent = Color3.fromRGB(255, 80, 120)
Zenith.Theme.AccentDark = Color3.fromRGB(200, 50, 90)
```

---

## Running the UI

You **must** call `Zenith:Update(dt)` and `Zenith:Draw()` every frame. The recommended way:

```lua
game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
    Zenith:Update(deltaTime)
    Zenith:Draw()
end)
```

- `Zenith:Update(dt)` handles mouse interactions, dragging, resizing, dropdowns, sliders, keybind capture, and notifications.
- `Zenith:Draw()` renders all windows, elements, and notifications.

> Make sure to call these in a loop that runs while your script is active.

---

## Full Example

```lua
local Zenith = loadstring(game:HttpGet("https://raw.githubusercontent.com/Xens-GHP/Zenith-UI/refs/heads/main/source.lua"))()

-- Create main window
local win = Zenith:CreateWindow("Zenith Demo", 100, 100, 420, 500)

-- Tabs
local mainTab = win:AddTab("Main")
local settingsTab = win:AddTab("Settings")

-- Elements
win:AddElement(mainTab, Zenith.ElementTypes.Button("Notify", function()
    Zenith:Notify("Info", "You clicked the button!", 2, "info")
end))

win:AddElement(mainTab, Zenith.ElementTypes.Checkbox("Dark Mode", true, function(state)
    if state then
        Zenith.Theme.Surface = Color3.fromRGB(28,28,36)
    else
        Zenith.Theme.Surface = Color3.fromRGB(48,48,56)
    end
end))

win:AddElement(settingsTab, Zenith.ElementTypes.Slider("Volume", 0, 100, 50, function(v)
    print("Volume:", v)
end, 0))

win:AddElement(settingsTab, Zenith.ElementTypes.Dropdown("Mode", {"Easy", "Normal", "Hard"}, 2, function(opt)
    print("Mode:", opt)
end))

-- Run
game:GetService("RunService").RenderStepped:Connect(function(dt)
    Zenith:Update(dt)
    Zenith:Draw()
end)
```
---

## License

This library is provided as‑is, free for use in any Roblox scripts. Attribution appreciated but not required.

---

**Happy scripting with Zenith UI!**  
For issues or feature requests, open an issue on the [GitHub repository](https://github.com/Xens-GHP/Zenith-UI).
