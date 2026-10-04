-- ModernShaman.lua
-- Modern dark redesign of the Shaman UI structure.
-- Keeps the public structure: Window -> Tab -> Section -> controls.
-- Designed for PC + touch/mobile.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local library = { Flags = {} }

local THEME = {
    Background = Color3.fromRGB(10, 11, 14),
    Surface = Color3.fromRGB(15, 17, 21),
    Surface2 = Color3.fromRGB(20, 23, 28),
    Surface3 = Color3.fromRGB(25, 29, 35),
    Border = Color3.fromRGB(39, 44, 52),
    BorderHover = Color3.fromRGB(55, 63, 74),
    Text = Color3.fromRGB(238, 241, 245),
    SubText = Color3.fromRGB(145, 153, 165),
    Muted = Color3.fromRGB(95, 103, 115),
    Accent = Color3.fromRGB(0, 200, 255),
    AccentDark = Color3.fromRGB(0, 112, 145),
    Danger = Color3.fromRGB(245, 86, 95),
    Off = Color3.fromRGB(48, 53, 61),
}

local function tween(obj, duration, props)
    TweenService:Create(obj, TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or THEME.Border
    s.Transparency = transparency or 0
    s.Thickness = 1
    s.Parent = parent
    return s
end

local function padding(parent, l, r, t, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = parent
    return p
end

local function label(parent, text, size, color, font)
    local x = Instance.new("TextLabel")
    x.BackgroundTransparency = 1
    x.Text = text or ""
    x.TextColor3 = color or THEME.Text
    x.TextSize = size or 13
    x.Font = font or Enum.Font.GothamMedium
    x.TextXAlignment = Enum.TextXAlignment.Left
    x.TextYAlignment = Enum.TextYAlignment.Center
    x.Parent = parent
    return x
end

local function makeButton(parent, name)
    local b = Instance.new("TextButton")
    b.Name = name or "Button"
    b.AutoButtonColor = false
    b.BackgroundTransparency = 1
    b.BorderSizePixel = 0
    b.Text = ""
    b.Size = UDim2.fromScale(1, 1)
    b.Parent = parent
    return b
end

local function getViewport()
    local camera = workspace.CurrentCamera
    return camera and camera.ViewportSize or Vector2.new(1280, 720)
end

local function isMobile()
    local v = getViewport()
    return UserInputService.TouchEnabled and v.X < 800
end

function library:Window(Info)
    Info = Info or {}
    Info.Text = Info.Text or "Shaman"

    local old = PlayerGui:FindFirstChild("ModernShaman")
    if old then old:Destroy() end

    local window = {}
    local selectedTab
    local opened = true
    local tabs = {}

    local gui = Instance.new("ScreenGui")
    gui.Name = "ModernShaman"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui

    local scale = Instance.new("UIScale")
    scale.Parent = gui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = THEME.Background
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    corner(main, 12)
    stroke(main, THEME.Border, 0.15)

    local function resize()
        local v = getViewport()
        local mobile = isMobile()
        local width = math.clamp(v.X - (mobile and 24 or 100), 320, 720)
        local height = math.clamp(v.Y - (mobile and 90 or 140), 300, 520)
        scale.Scale = mobile and math.clamp(v.X / 430, 0.78, 1) or 1
        main.Size = UDim2.fromOffset(width, height)
        main.Position = UDim2.fromScale(0.5, 0.5)
    end

    resize()
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
    end

    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.BackgroundColor3 = THEME.Surface
    topbar.BorderSizePixel = 0
    topbar.Size = UDim2.new(1, 0, 0, 50)
    topbar.Parent = main

    local title = label(topbar, Info.Text, 14, THEME.Text, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(18, 0)
    title.Size = UDim2.new(1, -130, 1, 0)

    local accent = Instance.new("Frame")
    accent.BackgroundColor3 = THEME.Accent
    accent.BorderSizePixel = 0
    accent.Position = UDim2.fromOffset(18, 45)
    accent.Size = UDim2.fromOffset(30, 2)
    accent.Parent = topbar
    corner(accent, 2)

    local close = Instance.new("TextButton")
    close.Name = "Close"
    close.Text = "×"
    close.TextColor3 = THEME.SubText
    close.TextSize = 24
    close.Font = Enum.Font.Gotham
    close.BackgroundColor3 = THEME.Surface2
    close.AutoButtonColor = false
    close.Size = UDim2.fromOffset(34, 34)
    close.Position = UDim2.new(1, -46, 0, 8)
    close.Parent = topbar
    corner(close, 8)
    close.MouseEnter:Connect(function() tween(close, .12, {BackgroundColor3 = Color3.fromRGB(45, 28, 31), TextColor3 = THEME.Danger}) end)
    close.MouseLeave:Connect(function() tween(close, .12, {BackgroundColor3 = THEME.Surface2, TextColor3 = THEME.SubText}) end)
    close.Activated:Connect(function() gui:Destroy() end)

    local minimize = Instance.new("TextButton")
    minimize.Name = "Minimize"
    minimize.Text = "—"
    minimize.TextColor3 = THEME.SubText
    minimize.TextSize = 18
    minimize.Font = Enum.Font.GothamBold
    minimize.BackgroundColor3 = THEME.Surface2
    minimize.AutoButtonColor = false
    minimize.Size = UDim2.fromOffset(34, 34)
    minimize.Position = UDim2.new(1, -86, 0, 8)
    minimize.Parent = topbar
    corner(minimize, 8)

    local body = Instance.new("Frame")
    body.Name = "Body"
    body.BackgroundTransparency = 1
    body.Position = UDim2.fromOffset(0, 50)
    body.Size = UDim2.new(1, 0, 1, -50)
    body.Parent = main

    local sidebar = Instance.new("Frame")
    sidebar.Name = "TabContainer"
    sidebar.BackgroundColor3 = THEME.Surface
    sidebar.BorderSizePixel = 0
    sidebar.Size = UDim2.fromOffset(138, 0)
    sidebar.Parent = body
    corner(sidebar, 10)

    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Name = "ScrollingContainer"
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.Size = UDim2.fromScale(1, 1)
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabScroll.ScrollBarThickness = 2
    tabScroll.ScrollBarImageColor3 = THEME.BorderHover
    tabScroll.Parent = sidebar
    padding(tabScroll, 9, 9, 12, 12)

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabScroll

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.BackgroundColor3 = THEME.Background
    content.BorderSizePixel = 0
    content.Position = UDim2.fromOffset(138, 0)
    content.Size = UDim2.new(1, -138, 1, 0)
    content.Parent = body

    local function selectTab(tab)
        selectedTab = tab
        for _, t in ipairs(tabs) do
            local active = t == tab
            tween(t.Button, .14, {
                BackgroundColor3 = active and THEME.Surface3 or THEME.Surface,
                TextColor3 = active and THEME.Text or THEME.SubText,
            })
            tween(t.Indicator, .14, {BackgroundTransparency = active and 0 or 1})
            t.Page.Visible = active
        end
    end

    local function setCollapsed(value)
        opened = value
        body.Visible = opened
        if opened then
            tween(main, .2, {Size = main.Size})
        end
    end

    minimize.Activated:Connect(function()
        setCollapsed(not opened)
    end)

    -- Touch + mouse dragging.
    local dragging = false
    local dragStart, startPos
    local function beginDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end
    topbar.InputBegan:Connect(beginDrag)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end)

    function window:Tab(TabInfo)
        TabInfo = TabInfo or {}
        TabInfo.Text = TabInfo.Text or "Tab"

        local tab = {}
        local page = Instance.new("ScrollingFrame")
        page.Name = "Page"
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Size = UDim2.fromScale(1, 1)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.CanvasSize = UDim2.new()
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = THEME.BorderHover
        page.Visible = false
        page.Parent = content
        padding(page, 16, 16, 16, 20)

        local columns = Instance.new("Frame")
        columns.Name = "Columns"
        columns.BackgroundTransparency = 1
        columns.Size = UDim2.new(1, 0, 0, 0)
        columns.AutomaticSize = Enum.AutomaticSize.Y
        columns.Parent = page

        local left = Instance.new("Frame")
        left.Name = "LeftContainer"
        left.BackgroundTransparency = 1
        left.Size = UDim2.new(0.5, -6, 0, 0)
        left.AutomaticSize = Enum.AutomaticSize.Y
        left.Parent = columns

        local right = Instance.new("Frame")
        right.Name = "RightContainer"
        right.BackgroundTransparency = 1
        right.Position = UDim2.new(0.5, 6, 0, 0)
        right.Size = UDim2.new(0.5, -6, 0, 0)
        right.AutomaticSize = Enum.AutomaticSize.Y
        right.Parent = columns

        local leftLayout = Instance.new("UIListLayout")
        leftLayout.Padding = UDim.new(0, 10)
        leftLayout.Parent = left
        local rightLayout = leftLayout:Clone()
        rightLayout.Parent = right

        local tabButton = Instance.new("TextButton")
        tabButton.Name = "TabButton"
        tabButton.Text = TabInfo.Text
        tabButton.Font = Enum.Font.GothamMedium
        tabButton.TextSize = 12
        tabButton.TextColor3 = THEME.SubText
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        tabButton.AutoButtonColor = false
        tabButton.BackgroundColor3 = THEME.Surface
        tabButton.Size = UDim2.new(1, 0, 0, 38)
        tabButton.Parent = tabScroll
        corner(tabButton, 8)

        local indicator = Instance.new("Frame")
        indicator.Name = "Selected"
        indicator.BackgroundColor3 = THEME.Accent
        indicator.BackgroundTransparency = 1
        indicator.BorderSizePixel = 0
        indicator.Position = UDim2.fromOffset(0, 8)
        indicator.Size = UDim2.fromOffset(3, 22)
        indicator.Parent = tabButton
        corner(indicator, 2)

        padding(tabButton, 15, 8, 0, 0)
        tab.Page = page
        tab.Button = tabButton
        tab.Indicator = indicator
        tab.Left = left
        tab.Right = right
        table.insert(tabs, tab)

        tabButton.Activated:Connect(function() selectTab(tab) end)

        function tab:Select()
            selectTab(tab)
        end

        function tab:Section(SectionInfo)
            SectionInfo = SectionInfo or {}
            SectionInfo.Text = SectionInfo.Text or "Section"
            SectionInfo.Side = SectionInfo.Side or "Left"

            local section = {}
            local parent = SectionInfo.Side == "Right" and right or left

            local frame = Instance.new("Frame")
            frame.Name = "Section"
            frame.BackgroundColor3 = THEME.Surface
            frame.BorderSizePixel = 0
            frame.Size = UDim2.new(1, 0, 0, 0)
            frame.AutomaticSize = Enum.AutomaticSize.Y
            frame.Parent = parent
            corner(frame, 9)
            stroke(frame, THEME.Border, 0.2)
            padding(frame, 10, 10, 8, 10)

            local sectionHeader = Instance.new("TextButton")
            sectionHeader.Name = "SectionHeader"
            sectionHeader.BackgroundTransparency = 1
            sectionHeader.Text = ""
            sectionHeader.AutoButtonColor = false
            sectionHeader.Size = UDim2.new(1, 0, 0, 30)
            sectionHeader.Parent = frame

            local sectionTitle = label(sectionHeader, SectionInfo.Text, 12, THEME.Text, Enum.Font.GothamBold)
            sectionTitle.Size = UDim2.new(1, -28, 1, 0)

            local arrow = label(sectionHeader, "⌄", 16, THEME.Muted, Enum.Font.GothamBold)
            arrow.TextXAlignment = Enum.TextXAlignment.Center
            arrow.Position = UDim2.new(1, -24, 0, 0)
            arrow.Size = UDim2.fromOffset(24, 30)

            local controls = Instance.new("Frame")
            controls.Name = "SectionFrame"
            controls.BackgroundTransparency = 1
            controls.Position = UDim2.fromOffset(0, 30)
            controls.Size = UDim2.new(1, 0, 0, 0)
            controls.AutomaticSize = Enum.AutomaticSize.Y
            controls.Parent = frame

            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 5)
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Parent = controls

            local collapsed = false
            sectionHeader.Activated:Connect(function()
                collapsed = not collapsed
                controls.Visible = not collapsed
                arrow.Text = collapsed and "›" or "⌄"
            end)

            local function controlRow(height)
                local row = Instance.new("Frame")
                row.BackgroundColor3 = THEME.Surface2
                row.BorderSizePixel = 0
                row.Size = UDim2.new(1, 0, 0, height or 38)
                row.Parent = controls
                corner(row, 7)
                return row
            end

            function section:Label(ControlInfo)
                ControlInfo = ControlInfo or {}
                local row = controlRow(34)
                local txt = label(row, ControlInfo.Text or "Label", 12, ControlInfo.Color or THEME.SubText)
                txt.Position = UDim2.fromOffset(11, 0)
                txt.Size = UDim2.new(1, -22, 1, 0)
                return {Set = function(_, SetInfo)
                    SetInfo = SetInfo or {}
                    txt.Text = SetInfo.Text or txt.Text
                    txt.TextColor3 = SetInfo.Color or txt.TextColor3
                end}
            end

            function section:Button(ControlInfo)
                ControlInfo = ControlInfo or {}
                local row = controlRow(40)
                local txt = label(row, ControlInfo.Text or "Button", 12, THEME.Text, Enum.Font.GothamMedium)
                txt.Position = UDim2.fromOffset(11, 0)
                txt.Size = UDim2.new(1, -22, 1, 0)
                local btn = makeButton(row, "Button")
                btn.Activated:Connect(function() pcall(ControlInfo.Callback or function() end) end)
                btn.MouseEnter:Connect(function() tween(row, .1, {BackgroundColor3 = THEME.Surface3}) end)
                btn.MouseLeave:Connect(function() tween(row, .1, {BackgroundColor3 = THEME.Surface2}) end)
            end

            function section:Input(ControlInfo)
                ControlInfo = ControlInfo or {}
                local row = controlRow(44)
                local box = Instance.new("TextBox")
                box.Name = "Input"
                box.PlaceholderText = ControlInfo.Placeholder or "Input"
                box.PlaceholderColor3 = THEME.Muted
                box.Text = ""
                box.TextColor3 = THEME.Text
                box.TextSize = 12
                box.Font = Enum.Font.Gotham
                box.TextXAlignment = Enum.TextXAlignment.Left
                box.BackgroundColor3 = THEME.Surface3
                box.BorderSizePixel = 0
                box.Position = UDim2.fromOffset(7, 6)
                box.Size = UDim2.new(1, -14, 1, -12)
                box.Parent = row
                corner(box, 6)
                stroke(box, THEME.Border, 0.2)
                padding(box, 10, 10, 0, 0)
                box.FocusLost:Connect(function()
                    local value = box.Text
                    if ControlInfo.Flag then library.Flags[ControlInfo.Flag] = value end
                    pcall(ControlInfo.Callback or function() end, value)
                end)
            end

            function section:Toggle(ControlInfo)
                ControlInfo = ControlInfo or {}
                local row = controlRow(42)
                local txt = label(row, ControlInfo.Text or "Toggle", 12, THEME.Text)
                txt.Position = UDim2.fromOffset(11, 0)
                txt.Size = UDim2.new(1, -65, 1, 0)

                local switch = Instance.new("Frame")
                switch.BackgroundColor3 = THEME.Off
                switch.Position = UDim2.new(1, -49, 0.5, -9)
                switch.Size = UDim2.fromOffset(38, 18)
                switch.Parent = row
                corner(switch, 100)

                local knob = Instance.new("Frame")
                knob.BackgroundColor3 = THEME.SubText
                knob.Position = UDim2.fromOffset(3, 3)
                knob.Size = UDim2.fromOffset(12, 12)
                knob.Parent = switch
                corner(knob, 100)

                local state = ControlInfo.Default == true
                local api = {}
                local button = makeButton(row, "ToggleButton")

                local function set(v, callback)
                    state = v == true
                    if ControlInfo.Flag then library.Flags[ControlInfo.Flag] = state end
                    tween(switch, .15, {BackgroundColor3 = state and THEME.AccentDark or THEME.Off})
                    tween(knob, .15, {Position = state and UDim2.new(1, -15, 0, 3) or UDim2.fromOffset(3, 3), BackgroundColor3 = state and THEME.Accent or THEME.SubText})
                    if callback then pcall(ControlInfo.Callback or function() end, state) end
                end
                function api:Set(v) set(v, true) end
                button.Activated:Connect(function() set(not state, true) end)
                set(state, false)
                if ControlInfo.Flag then library.Flags[ControlInfo.Flag] = state end
                return api
            end

            function section:Slider(ControlInfo)
                ControlInfo = ControlInfo or {}
                local min = ControlInfo.Minimum or 1
                local max = ControlInfo.Maximum or 100
                if min > max then min, max = max, min end
                local value = math.clamp(ControlInfo.Default or min, min, max)

                local row = controlRow(54)
                local txt = label(row, ControlInfo.Text or "Slider", 12, THEME.Text)
                txt.Position = UDim2.fromOffset(11, 3)
                txt.Size = UDim2.new(0.65, 0, 0, 22)
                local valueLabel = label(row, tostring(value) .. (ControlInfo.Postfix or ""), 11, THEME.SubText)
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Position = UDim2.new(0.65, 0, 3, 0)
                valueLabel.Size = UDim2.new(0.35, -11, 0, 22)

                local track = Instance.new("Frame")
                track.BackgroundColor3 = THEME.Off
                track.BorderSizePixel = 0
                track.Position = UDim2.new(0, 11, 1, -17)
                track.Size = UDim2.new(1, -22, 0, 5)
                track.Parent = row
                corner(track, 100)

                local fill = Instance.new("Frame")
                fill.BackgroundColor3 = THEME.Accent
                fill.BorderSizePixel = 0
                fill.Size = UDim2.fromScale((value - min) / math.max(max - min, 1), 1)
                fill.Parent = track
                corner(fill, 100)

                local hit = makeButton(track, "SliderButton")
                hit.ZIndex = 3
                local draggingSlider = false

                local function update(input)
                    local x = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                    local ratio = track.AbsoluteSize.X > 0 and x / track.AbsoluteSize.X or 0
                    value = math.floor(min + (max - min) * ratio + 0.5)
                    fill.Size = UDim2.fromScale(ratio, 1)
                    valueLabel.Text = tostring(value) .. (ControlInfo.Postfix or "")
                    if ControlInfo.Flag then library.Flags[ControlInfo.Flag] = value end
                    pcall(ControlInfo.Callback or function() end, value)
                end
                hit.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = true
                        update(input)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSlider = false end
                end)
                if ControlInfo.Flag then library.Flags[ControlInfo.Flag] = value end
                pcall(ControlInfo.Callback or function() end, value)
            end

            function section:Dropdown(ControlInfo)
                ControlInfo = ControlInfo or {}
                local list = ControlInfo.List or {}
                local current = ControlInfo.Default
                local expanded = false
                local api = {}

                local holder = Instance.new("Frame")
                holder.Name = "Dropdown"
                holder.BackgroundTransparency = 1
                holder.Size = UDim2.new(1, 0, 0, 42)
                holder.Parent = controls

                local head = controlRow(42)
                head.Parent = holder
                local title = label(head, ControlInfo.Text or "Dropdown", 12, THEME.Text)
                title.Position = UDim2.fromOffset(11, 0)
                title.Size = UDim2.new(0.52, 0, 1, 0)
                local currentLabel = label(head, current and tostring(current) or "Select...", 11, THEME.SubText)
                currentLabel.TextXAlignment = Enum.TextXAlignment.Right
                currentLabel.Position = UDim2.new(0.52, 0, 0, 0)
                currentLabel.Size = UDim2.new(0.48, -28, 1, 0)
                local chevron = label(head, "›", 18, THEME.Muted, Enum.Font.GothamBold)
                chevron.TextXAlignment = Enum.TextXAlignment.Center
                chevron.Position = UDim2.new(1, -25, 0, 0)
                chevron.Size = UDim2.fromOffset(20, 42)

                local menu = Instance.new("Frame")
                menu.BackgroundColor3 = THEME.Surface3
                menu.BorderSizePixel = 0
                menu.Size = UDim2.new(1, 0, 0, 0)
                menu.AutomaticSize = Enum.AutomaticSize.Y
                menu.Visible = false
                menu.Parent = holder
                corner(menu, 7)
                stroke(menu, THEME.Border, 0.15)
                padding(menu, 5, 5, 5, 5)
                local menuLayout = Instance.new("UIListLayout")
                menuLayout.Padding = UDim.new(0, 3)
                menuLayout.Parent = menu

                local function choose(option)
                    current = option
                    currentLabel.Text = tostring(option)
                    if ControlInfo.Flag then library.Flags[ControlInfo.Flag] = option end
                    pcall(ControlInfo.Callback or function() end, option)
                    expanded = false
                    menu.Visible = false
                    chevron.Text = "›"
                end

                for _, option in ipairs(list) do
                    local b = Instance.new("TextButton")
                    b.Text = tostring(option)
                    b.TextColor3 = THEME.SubText
                    b.TextSize = 11
                    b.Font = Enum.Font.GothamMedium
                    b.TextXAlignment = Enum.TextXAlignment.Left
                    b.AutoButtonColor = false
                    b.BackgroundColor3 = THEME.Surface2
                    b.Size = UDim2.new(1, 0, 0, 34)
                    b.Parent = menu
                    corner(b, 6)
                    padding(b, 9, 5, 0, 0)
                    b.Activated:Connect(function() choose(option) end)
                    b.MouseEnter:Connect(function() tween(b, .1, {BackgroundColor3 = THEME.Border}) end)
                    b.MouseLeave:Connect(function() tween(b, .1, {BackgroundColor3 = THEME.Surface2}) end)
                end

                local headButton = makeButton(head, "DropdownButton")
                headButton.Activated:Connect(function()
                    expanded = not expanded
                    menu.Visible = expanded
                    chevron.Text = expanded and "⌄" or "›"
                    holder.Size = expanded and UDim2.new(1, 0, 0, 42 + math.min(#list * 37 + 10, 190)) or UDim2.new(1, 0, 0, 42)
                end)

                function api:Set(option) choose(option) end
                if current ~= nil then
                    if ControlInfo.Flag then library.Flags[ControlInfo.Flag] = current end
                    pcall(ControlInfo.Callback or function() end, current)
                end
                return api
            end

            function section:RadioButton(ControlInfo)
                ControlInfo = ControlInfo or {}
                local options = ControlInfo.Options or {}
                local selected = ControlInfo.Default
                local api = {}
                local row = controlRow(42 + #options * 34)
                local title = label(row, ControlInfo.Text or "Radio Button", 12, THEME.Text)
                title.Position = UDim2.fromOffset(11, 5)
                title.Size = UDim2.new(1, -22, 0, 28)

                local list = Instance.new("Frame")
                list.BackgroundTransparency = 1
                list.Position = UDim2.fromOffset(7, 36)
                list.Size = UDim2.new(1, -14, 0, #options * 34)
                list.Parent = row
                local layout = Instance.new("UIListLayout")
                layout.Padding = UDim.new(0, 2)
                layout.Parent = list

                local buttons = {}
                local function select(option)
                    selected = option
                    if ControlInfo.Flag then library.Flags[ControlInfo.Flag] = option end
                    for value, ui in pairs(buttons) do
                        local active = value == selected
                        tween(ui.Dot, .12, {BackgroundColor3 = active and THEME.Accent or THEME.Off})
                        ui.Text.TextColor3 = active and THEME.Text or THEME.SubText
                    end
                    pcall(ControlInfo.Callback or function() end, option)
                end

                for _, option in ipairs(options) do
                    local b = Instance.new("TextButton")
                    b.Text = ""
                    b.AutoButtonColor = false
                    b.BackgroundTransparency = 1
                    b.Size = UDim2.new(1, 0, 0, 32)
                    b.Parent = list
                    local dot = Instance.new("Frame")
                    dot.BackgroundColor3 = THEME.Off
                    dot.Position = UDim2.fromOffset(6, 8)
                    dot.Size = UDim2.fromOffset(14, 14)
                    dot.Parent = b
                    corner(dot, 100)
                    stroke(dot, THEME.BorderHover, 0)
                    local t = label(b, tostring(option), 11, THEME.SubText)
                    t.Position = UDim2.fromOffset(28, 0)
                    t.Size = UDim2.new(1, -28, 1, 0)
                    buttons[option] = {Dot = dot, Text = t}
                    b.Activated:Connect(function() select(option) end)
                end
                function api:Set(option) select(option) end
                if selected ~= nil then select(selected) end
                return api
            end

            return section
        end

        if #tabs == 1 then selectTab(tab) end
        return tab
    end

    function window:Destroy()
        if gui then gui:Destroy() end
    end

    return window
end
