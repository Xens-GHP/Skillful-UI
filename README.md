## Skillful-UI Documentation

### Overview
Skillful-UI is a lightweight UI library for Roblox
It provides draggable windows, buttons, scrolling lists, categories, notifications, and theming support
---

### **Loading the Library**
```lua
local SkillfulUI = loadstring(game:HttpGet("https://your-host.com/Skillful-UI.lua"))()
```

---

### **Creating a Window**
```lua
local window = SkillfulUI:CreateWindow(title, size, themeOverrides)
```
- `title` (string) – Title displayed in the title bar.
- `size` (Vector2) – Width and height in pixels.  
  Example: `Vector2.new(475, 300)`
- `themeOverrides` (table, optional) – Override default colors:
  - `Background`, `Secondary`, `Accent`, `Button`, `ButtonHover`, `Text`, `Border`, `Success`, `Error`

**Returns:** A window object.

---

### **Window Methods**
| Method | Description |
|--------|-------------|
| `window:Destroy()` | Closes and removes the window from CoreGui. |
| `window:SetVisible(bool)` | Shows (`true`) or hides (`false`) the window. |
| `window:Notify(title, message, duration, isError)` | Shows a toast notification. `duration` (seconds, default 3). `isError` (boolean, default false) changes color to red. |

---

### **UI Element Creation**
All element creation methods are called on the window object.  
Position and size parameters are `UDim2`.

#### **Button**
```lua
local button = window:CreateButton(text, position, size, callback)
```
- `callback` – function called when clicked.

#### **Scrolling Frame**
```lua
local scroll = window:CreateScrollingFrame(position, size, automaticCanvas)
```
- `automaticCanvas` (boolean) – if `true`, canvas height auto‑adjusts to content.

#### **List Layout** (to be placed inside a scrolling frame)
```lua
local layout = window:CreateListLayout(parent, padding, horizontalAlignment)
```
- `padding` (number, default 10) – spacing between items.
- `horizontalAlignment` – `Enum.HorizontalAlignment` value (default `Center`).

#### **Category Button** (toggleable header)
```lua
local button, arrowLabel = window:CreateCategoryButton(text, position, size, isOpen)
```
- `isOpen` (boolean) – initial expanded state (`true` = ▼, `false` = ▲).  
- Returns both the button and the arrow label (for manual state changes).

#### **Text Box**
```lua
local textBox = window:CreateTextBox(placeholder, position, size)
```

#### **Tag** (pill‑shaped label)
```lua
local tag = window:CreateTag(text, parent)
```
- Automatically sizes to fit the text.  
- `parent` – must be a GUI instance (e.g., a frame).

---

### **Example Usage**
```lua
local win = SkillfulUI:CreateWindow("My App", Vector2.new(400, 300))

-- Button
win:CreateButton("Click me", UDim2.new(0.5, -50, 0.5, -15), UDim2.new(0, 100, 0, 30), function()
    win:Notify("Info", "Button clicked!", 2)
end)

-- Scrolling list
local scroll = win:CreateScrollingFrame(UDim2.new(0, 10, 0, 50), UDim2.new(0, 200, 0, 200), true)
win:CreateListLayout(scroll, 5)

for i = 1, 10 do
    local btn = win:CreateButton("Item " .. i, UDim2.new(0,0,0,0), UDim2.new(0, 180, 0, 30), nil)
    btn.Parent = scroll
end

-- Toggle visibility
local toggle = win:CreateButton("Hide", UDim2.new(0, 220, 0, 10), UDim2.new(0, 80, 0, 30), function()
    win:SetVisible(not win.Visible)
end)
```

---

### **Notes**
- The window is draggable by its title bar.
- All buttons have hover animations.
- Notifications automatically slide in and out.
- The library does **not** require any external assets; all colors and sounds are optional (sounds not included by default).
