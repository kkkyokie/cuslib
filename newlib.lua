-- ModernShaman.lua
-- Modern dark UI library
-- API:
-- Library:Window()
-- Window:Tab()
-- Tab:Section()
-- Section:Label()
-- Section:Button()
-- Section:Input()
-- Section:Toggle()
-- Section:Slider()
-- Section:Dropdown()
-- Section:RadioButton()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local library = {
    Flags = {}
}

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
    Off = Color3.fromRGB(48, 53, 61)
}

local function tween(object, duration, properties)
    local info = TweenInfo.new(
        duration or 0.16,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    )

    TweenService:Create(object, info, properties):Play()
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

local function padding(parent, left, right, top, bottom)
    local p = Instance.new("UIPadding")

    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)

    p.Parent = parent

    return p
end

local function label(parent, text, size, color, font)
    local object = Instance.new("TextLabel")

    object.BackgroundTransparency = 1
    object.Text = text or ""
    object.TextColor3 = color or THEME.Text
    object.TextSize = size or 13
    object.Font = font or Enum.Font.GothamMedium

    object.TextXAlignment = Enum.TextXAlignment.Left
    object.TextYAlignment = Enum.TextYAlignment.Center

    object.Parent = parent

    return object
end

local function makeButton(parent, name)
    local button = Instance.new("TextButton")

    button.Name = name or "Button"
    button.AutoButtonColor = false
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.Text = ""
    button.Size = UDim2.fromScale(1, 1)

    button.Parent = parent

    return button
end

local function getViewport()
    local camera = workspace.CurrentCamera

    if camera then
        return camera.ViewportSize
    end

    return Vector2.new(1280, 720)
end

local function isMobile()
    local viewport = getViewport()

    return UserInputService.TouchEnabled and viewport.X < 800
end

function library:Window(info)
    info = info or {}

    local titleText = info.Text or "Shaman"

    local existing = PlayerGui:FindFirstChild("ModernShaman")

    if existing then
        existing:Destroy()
    end

    local window = {}

    local tabs = {}
    local selectedTab = nil

    local opened = true
    local destroyed = false

    --------------------------------------------------
    -- SCREEN GUI
    --------------------------------------------------

    local gui = Instance.new("ScreenGui")

    gui.Name = "ModernShaman"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    gui.Parent = PlayerGui

    --------------------------------------------------
    -- MAIN
    --------------------------------------------------

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
        if destroyed then
            return
        end

        local viewport = getViewport()
        local mobile = isMobile()

        local width
        local height

        if mobile then
            width = math.clamp(viewport.X - 20, 300, 460)
            height = math.clamp(viewport.Y - 50, 320, 700)
        else
            width = math.clamp(viewport.X - 100, 500, 760)
            height = math.clamp(viewport.Y - 120, 350, 560)
        end

        main.Size = UDim2.fromOffset(width, height)
        main.Position = UDim2.fromScale(0.5, 0.5)
    end

    resize()

    local cameraConnection

    if workspace.CurrentCamera then
        cameraConnection = workspace.CurrentCamera:GetPropertyChangedSignal(
            "ViewportSize"
        ):Connect(resize)
    end

    --------------------------------------------------
    -- TOPBAR
    --------------------------------------------------

    local topbar = Instance.new("Frame")

    topbar.Name = "Topbar"
    topbar.BackgroundColor3 = THEME.Surface
    topbar.BorderSizePixel = 0
    topbar.Size = UDim2.new(1, 0, 0, 50)

    topbar.Parent = main

    local title = label(
        topbar,
        titleText,
        14,
        THEME.Text,
        Enum.Font.GothamBold
    )

    title.Position = UDim2.fromOffset(18, 0)
    title.Size = UDim2.new(1, -130, 1, 0)

    --------------------------------------------------
    -- ACCENT
    --------------------------------------------------

    local accent = Instance.new("Frame")

    accent.BackgroundColor3 = THEME.Accent
    accent.BorderSizePixel = 0

    accent.Position = UDim2.fromOffset(18, 45)
    accent.Size = UDim2.fromOffset(30, 2)

    accent.Parent = topbar

    corner(accent, 2)

    --------------------------------------------------
    -- CLOSE
    --------------------------------------------------

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

    close.MouseEnter:Connect(function()
        tween(close, 0.12, {
            BackgroundColor3 = Color3.fromRGB(45, 28, 31),
            TextColor3 = THEME.Danger
        })
    end)

    close.MouseLeave:Connect(function()
        tween(close, 0.12, {
            BackgroundColor3 = THEME.Surface2,
            TextColor3 = THEME.SubText
        })
    end)

    close.Activated:Connect(function()
        window:Destroy()
    end)

    --------------------------------------------------
    -- MINIMIZE
    --------------------------------------------------

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

    minimize.MouseEnter:Connect(function()
        tween(minimize, 0.12, {
            BackgroundColor3 = THEME.Surface3,
            TextColor3 = THEME.Text
        })
    end)

    minimize.MouseLeave:Connect(function()
        tween(minimize, 0.12, {
            BackgroundColor3 = THEME.Surface2,
            TextColor3 = THEME.SubText
        })
    end)

    --------------------------------------------------
    -- BODY
    --------------------------------------------------

    local body = Instance.new("Frame")

    body.Name = "Body"
    body.BackgroundTransparency = 1

    body.Position = UDim2.fromOffset(0, 50)
    body.Size = UDim2.new(1, 0, 1, -50)

    body.Parent = main

    --------------------------------------------------
    -- SIDEBAR
    --------------------------------------------------

    local sidebar = Instance.new("Frame")

    sidebar.Name = "TabContainer"
    sidebar.BackgroundColor3 = THEME.Surface
    sidebar.BorderSizePixel = 0

    sidebar.Size = UDim2.fromOffset(138, 0)

    sidebar.Parent = body

    corner(sidebar, 10)

    --------------------------------------------------
    -- TAB SCROLL
    --------------------------------------------------

    local tabScroll = Instance.new("ScrollingFrame")

    tabScroll.Name = "ScrollingContainer"

    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0

    tabScroll.Size = UDim2.fromScale(1, 1)

    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabScroll.CanvasSize = UDim2.new()

    tabScroll.ScrollBarThickness = 2
    tabScroll.ScrollBarImageColor3 = THEME.BorderHover

    tabScroll.Parent = sidebar

    padding(tabScroll, 9, 9, 12, 12)

    local tabLayout = Instance.new("UIListLayout")

    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    tabLayout.Parent = tabScroll

    --------------------------------------------------
    -- CONTENT
    --------------------------------------------------

    local content = Instance.new("Frame")

    content.Name = "Content"

    content.BackgroundColor3 = THEME.Background
    content.BorderSizePixel = 0

    content.Position = UDim2.fromOffset(138, 0)
    content.Size = UDim2.new(1, -138, 1, 0)

    content.Parent = body

    --------------------------------------------------
    -- MOBILE LAYOUT
    --------------------------------------------------

    local function updateLayout()
        local mobile = isMobile()

        if mobile then
            sidebar.Size = UDim2.new(1, 0, 0, 48)

            content.Position = UDim2.fromOffset(0, 48)
            content.Size = UDim2.new(1, 0, 1, -48)

            tabScroll.ScrollingDirection = Enum.ScrollingDirection.X
            tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
            tabScroll.CanvasSize = UDim2.new()

            tabLayout.FillDirection = Enum.FillDirection.Horizontal
            tabLayout.Padding = UDim.new(0, 6)

            padding(tabScroll, 8, 8, 5, 5)

            for _, tab in ipairs(tabs) do
                tab.Button.Size = UDim2.fromOffset(105, 38)
            end
        else
            sidebar.Size = UDim2.new(0, 138, 1, 0)

            content.Position = UDim2.fromOffset(138, 0)
            content.Size = UDim2.new(1, -138, 1, 0)

            tabScroll.ScrollingDirection = Enum.ScrollingDirection.Y
            tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

            tabLayout.FillDirection = Enum.FillDirection.Vertical
            tabLayout.Padding = UDim.new(0, 6)

            padding(tabScroll, 9, 9, 12, 12)

            for _, tab in ipairs(tabs) do
                tab.Button.Size = UDim2.new(1, 0, 0, 38)
            end
        end

        for _, tab in ipairs(tabs) do
            tab:updateColumns()
        end
    end

    --------------------------------------------------
    -- TAB SELECTION
    --------------------------------------------------

    local function selectTab(tab)
        selectedTab = tab

        for _, current in ipairs(tabs) do
            local active = current == tab

            tween(current.Button, 0.14, {
                BackgroundColor3 = active
                    and THEME.Surface3
                    or THEME.Surface,

                TextColor3 = active
                    and THEME.Text
                    or THEME.SubText
            })

            tween(current.Indicator, 0.14, {
                BackgroundTransparency = active and 0 or 1
            })

            current.Page.Visible = active
        end
    end

    --------------------------------------------------
    -- MINIMIZE
    --------------------------------------------------

    local function setCollapsed(value)
        opened = not value

        body.Visible = opened

        minimize.Text = opened and "—" or "+"

        if opened then
            resize()
        end
    end

    minimize.Activated:Connect(function()
        setCollapsed(opened)
    end)

    --------------------------------------------------
    -- DRAGGING
    --------------------------------------------------

    local dragging = false
    local dragStart
    local startPosition

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        dragging = true
        dragStart = input.Position
        startPosition = main.Position

        local connection

        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false

                if connection then
                    connection:Disconnect()
                end
            end
        end)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end)

    --------------------------------------------------
    -- WINDOW TAB
    --------------------------------------------------

    function window:Tab(tabInfo)
        tabInfo = tabInfo or {}

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

        --------------------------------------------------
        -- COLUMNS
        --------------------------------------------------

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
        leftLayout.SortOrder = Enum.SortOrder.LayoutOrder

        leftLayout.Parent = left

        local rightLayout = leftLayout:Clone()
        rightLayout.Parent = right

        --------------------------------------------------
        -- RESPONSIVE COLUMNS
        --------------------------------------------------

        function tab:updateColumns()
            if isMobile() then
                left.Size = UDim2.new(1, 0, 0, 0)
                right.Size = UDim2.new(1, 0, 0, 0)

                right.Position = UDim2.new(0, 0, 0, 0)

                leftLayout.FillDirection = Enum.FillDirection.Vertical
                rightLayout.FillDirection = Enum.FillDirection.Vertical
            else
                left.Size = UDim2.new(0.5, -6, 0, 0)
                right.Size = UDim2.new(0.5, -6, 0, 0)

                right.Position = UDim2.new(0.5, 6, 0, 0)
            end
        end

        --------------------------------------------------
        -- TAB BUTTON
        --------------------------------------------------

        local tabButton = Instance.new("TextButton")

        tabButton.Name = "TabButton"

        tabButton.Text = tabInfo.Text or "Tab"

        tabButton.Font = Enum.Font.GothamMedium
        tabButton.TextSize = 12

        tabButton.TextColor3 = THEME.SubText
        tabButton.TextXAlignment = Enum.TextXAlignment.Left

        tabButton.AutoButtonColor = false

        tabButton.BackgroundColor3 = THEME.Surface

        tabButton.Size = UDim2.new(1, 0, 0, 38)

        tabButton.Parent = tabScroll

        corner(tabButton, 8)

        padding(tabButton, 15, 8, 0, 0)

        --------------------------------------------------
        -- TAB INDICATOR
        --------------------------------------------------

        local indicator = Instance.new("Frame")

        indicator.Name = "Selected"

        indicator.BackgroundColor3 = THEME.Accent
        indicator.BackgroundTransparency = 1
        indicator.BorderSizePixel = 0

        indicator.Position = UDim2.fromOffset(0, 8)
        indicator.Size = UDim2.fromOffset(3, 22)

        indicator.Parent = tabButton

        corner(indicator, 2)

        --------------------------------------------------
        -- SAVE TAB
        --------------------------------------------------

        tab.Page = page
        tab.Button = tabButton
        tab.Indicator = indicator

        tab.Left = left
        tab.Right = right

        table.insert(tabs, tab)

        tabButton.Activated:Connect(function()
            selectTab(tab)
        end)

        function tab:Select()
            selectTab(tab)
        end

        --------------------------------------------------
        -- SECTION
        --------------------------------------------------

        function tab:Section(sectionInfo)
            sectionInfo = sectionInfo or {}

            local section = {}

            local side = sectionInfo.Side or "Left"

            local parent

            if isMobile() then
                parent = left
            else
                parent = side == "Right" and right or left
            end

            --------------------------------------------------
            -- SECTION FRAME
            --------------------------------------------------

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

            --------------------------------------------------
            -- HEADER
            --------------------------------------------------

            local header = Instance.new("TextButton")

            header.Name = "SectionHeader"

            header.BackgroundTransparency = 1
            header.Text = ""

            header.AutoButtonColor = false

            header.Size = UDim2.new(1, 0, 0, 30)

            header.Parent = frame

            local sectionTitle = label(
                header,
                sectionInfo.Text or "Section",
                12,
                THEME.Text,
                Enum.Font.GothamBold
            )

            sectionTitle.Size = UDim2.new(1, -28, 1, 0)

            local arrow = label(
                header,
                "⌄",
                16,
                THEME.Muted,
                Enum.Font.GothamBold
            )

            arrow.TextXAlignment = Enum.TextXAlignment.Center

            arrow.Position = UDim2.new(1, -24, 0, 0)
            arrow.Size = UDim2.fromOffset(24, 30)

            --------------------------------------------------
            -- CONTROLS
            --------------------------------------------------

            local controls = Instance.new("Frame")

            controls.Name = "SectionFrame"

            controls.BackgroundTransparency = 1

            controls.Position = UDim2.fromOffset(0, 30)

            controls.Size = UDim2.new(1, 0, 0, 0)
            controls.AutomaticSize = Enum.AutomaticSize.Y

            controls.Parent = frame

            local controlsLayout = Instance.new("UIListLayout")

            controlsLayout.Padding = UDim.new(0, 5)
            controlsLayout.SortOrder = Enum.SortOrder.LayoutOrder

            controlsLayout.Parent = controls

            --------------------------------------------------
            -- COLLAPSE
            --------------------------------------------------

            local collapsed = false

            header.Activated:Connect(function()
                collapsed = not collapsed

                controls.Visible = not collapsed

                arrow.Text = collapsed and "›" or "⌄"
            end)

            --------------------------------------------------
            -- CONTROL ROW
            --------------------------------------------------

            local function controlRow(height)
                local row = Instance.new("Frame")

                row.BackgroundColor3 = THEME.Surface2
                row.BorderSizePixel = 0

                row.Size = UDim2.new(1, 0, 0, height or 38)

                row.Parent = controls

                corner(row, 7)

                return row
            end

            --------------------------------------------------
            -- LABEL
            --------------------------------------------------

            function section:Label(controlInfo)
                controlInfo = controlInfo or {}

                local row = controlRow(34)

                local text = label(
                    row,
                    controlInfo.Text or "Label",
                    12,
                    controlInfo.Color or THEME.SubText
                )

                text.Position = UDim2.fromOffset(11, 0)
                text.Size = UDim2.new(1, -22, 1, 0)

                local api = {}

                function api:Set(setInfo)
                    setInfo = setInfo or {}

                    if setInfo.Text ~= nil then
                        text.Text = setInfo.Text
                    end

                    if setInfo.Color ~= nil then
                        text.TextColor3 = setInfo.Color
                    end
                end

                return api
            end

            --------------------------------------------------
            -- BUTTON
            --------------------------------------------------

            function section:Button(controlInfo)
                controlInfo = controlInfo or {}

                local row = controlRow(40)

                local text = label(
                    row,
                    controlInfo.Text or "Button",
                    12,
                    THEME.Text,
                    Enum.Font.GothamMedium
                )

                text.Position = UDim2.fromOffset(11, 0)
                text.Size = UDim2.new(1, -22, 1, 0)

                local button = makeButton(row, "Button")

                button.Activated:Connect(function()
                    pcall(
                        controlInfo.Callback or function() end
                    )
                end)

                button.MouseEnter:Connect(function()
                    tween(row, 0.1, {
                        BackgroundColor3 = THEME.Surface3
                    })
                end)

                button.MouseLeave:Connect(function()
                    tween(row, 0.1, {
                        BackgroundColor3 = THEME.Surface2
                    })
                end)

                return {
                    Set = function()
                    end
                }
            end

            --------------------------------------------------
            -- INPUT
            --------------------------------------------------

            function section:Input(controlInfo)
                controlInfo = controlInfo or {}

                local row = controlRow(44)

                local box = Instance.new("TextBox")

                box.Name = "Input"

                box.PlaceholderText =
                    controlInfo.Placeholder or "Input"

                box.PlaceholderColor3 = THEME.Muted

                box.Text = ""

                box.TextColor3 = THEME.Text
                box.TextSize = 12
                box.Font = Enum.Font.Gotham

                box.TextXAlignment = Enum.TextXAlignment.Left

                box.ClearTextOnFocus = false

                box.BackgroundColor3 = THEME.Surface3
                box.BorderSizePixel = 0

                box.Position = UDim2.fromOffset(7, 6)
                box.Size = UDim2.new(1, -14, 1, -12)

                box.Parent = row

                corner(box, 6)
                stroke(box, THEME.Border, 0.2)

                padding(box, 10, 10, 0, 0)

                if controlInfo.Default ~= nil then
                    box.Text = tostring(controlInfo.Default)
                end

                box.FocusLost:Connect(function()
                    local value = box.Text

                    if controlInfo.Flag then
                        library.Flags[controlInfo.Flag] = value
                    end

                    pcall(
                        controlInfo.Callback or function() end,
                        value
                    )
                end)

                local api = {}

                function api:Set(value)
                    box.Text = tostring(value)

                    if controlInfo.Flag then
                        library.Flags[controlInfo.Flag] = value
                    end
                end

                function api:Get()
                    return box.Text
                end

                return api
            end

            --------------------------------------------------
            -- TOGGLE
            --------------------------------------------------

            function section:Toggle(controlInfo)
                controlInfo = controlInfo or {}

                local row = controlRow(42)

                local text = label(
                    row,
                    controlInfo.Text or "Toggle",
                    12,
                    THEME.Text
                )

                text.Position = UDim2.fromOffset(11, 0)
                text.Size = UDim2.new(1, -65, 1, 0)

                --------------------------------------------------
                -- SWITCH
                --------------------------------------------------

                local switch = Instance.new("Frame")

                switch.BackgroundColor3 = THEME.Off

                switch.Position = UDim2.new(
                    1,
                    -49,
                    0.5,
                    -9
                )

                switch.Size = UDim2.fromOffset(38, 18)

                switch.Parent = row

                corner(switch, 100)

                local knob = Instance.new("Frame")

                knob.BackgroundColor3 = THEME.SubText

                knob.Position = UDim2.fromOffset(3, 3)
                knob.Size = UDim2.fromOffset(12, 12)

                knob.Parent = switch

                corner(knob, 100)

                --------------------------------------------------
                -- STATE
                --------------------------------------------------

                local state = controlInfo.Default == true

                local api = {}

                local button = makeButton(
                    row,
                    "ToggleButton"
                )

                local function set(value, callback)
                    state = value == true

                    if controlInfo.Flag then
                        library.Flags[controlInfo.Flag] = state
                    end

                    tween(switch, 0.15, {
                        BackgroundColor3 =
                            state
                            and THEME.AccentDark
                            or THEME.Off
                    })

                    tween(knob, 0.15, {
                        Position =
                            state
                            and UDim2.new(1, -15, 0, 3)
                            or UDim2.fromOffset(3, 3),

                        BackgroundColor3 =
                            state
                            and THEME.Accent
                            or THEME.SubText
                    })

                    if callback then
                        pcall(
                            controlInfo.Callback
                                or function() end,
                            state
                        )
                    end
                end

                function api:Set(value)
                    set(value, true)
                end

                function api:Get()
                    return state
                end

                button.Activated:Connect(function()
                    set(not state, true)
                end)

                set(state, false)

                return api
            end

            --------------------------------------------------
            -- SLIDER
            --------------------------------------------------

            function section:Slider(controlInfo)
                controlInfo = controlInfo or {}

                local minimum = controlInfo.Minimum or 1
                local maximum = controlInfo.Maximum or 100

                if minimum > maximum then
                    minimum, maximum = maximum, minimum
                end

                local value = math.clamp(
                    controlInfo.Default or minimum,
                    minimum,
                    maximum
                )

                local row = controlRow(54)

                local text = label(
                    row,
                    controlInfo.Text or "Slider",
                    12,
                    THEME.Text
                )

                text.Position = UDim2.fromOffset(11, 3)
                text.Size = UDim2.new(0.65, 0, 0, 22)

                local valueLabel = label(
                    row,
                    tostring(value) .. (controlInfo.Postfix or ""),
                    11,
                    THEME.SubText
                )

                valueLabel.TextXAlignment = Enum.TextXAlignment.Right

                valueLabel.Position = UDim2.new(
                    0.65,
                    0,
                    3,
                    0
                )

                valueLabel.Size = UDim2.new(
                    0.35,
                    -11,
                    0,
                    22
                )

                --------------------------------------------------
                -- TRACK
                --------------------------------------------------

                local track = Instance.new("Frame")

                track.BackgroundColor3 = THEME.Off
                track.BorderSizePixel = 0

                track.Position = UDim2.new(
                    0,
                    11,
                    1,
                    -17
                )

                track.Size = UDim2.new(
                    1,
                    -22,
                    0,
                    5
                )

                track.Parent = row

                corner(track, 100)

                local fill = Instance.new("Frame")

                fill.BackgroundColor3 = THEME.Accent
                fill.BorderSizePixel = 0

                fill.Size = UDim2.fromScale(
                    (value - minimum)
                        / math.max(maximum - minimum, 1),
                    1
                )

                fill.Parent = track

                corner(fill, 100)

                local hit = makeButton(
                    track,
                    "SliderButton"
                )

                hit.ZIndex = 3

                local draggingSlider = false

                local function setValue(newValue, callback)
                    value = math.clamp(
                        newValue,
                        minimum,
                        maximum
                    )

                    local ratio =
                        (value - minimum)
                        / math.max(maximum - minimum, 1)

                    fill.Size = UDim2.fromScale(
                        ratio,
                        1
                    )

                    valueLabel.Text =
                        tostring(value)
                        .. (controlInfo.Postfix or "")

                    if controlInfo.Flag then
                        library.Flags[controlInfo.Flag] = value
                    end

                    if callback then
                        pcall(
                            controlInfo.Callback
                                or function() end,
                            value
                        )
                    end
                end

                local function updateFromInput(input)
                    if track.AbsoluteSize.X <= 0 then
                        return
                    end

                    local x =
                        input.Position.X
                        - track.AbsolutePosition.X

                    x = math.clamp(
                        x,
                        0,
                        track.AbsoluteSize.X
                    )

                    local ratio =
                        x / track.AbsoluteSize.X

                    local newValue =
                        minimum
                        + (maximum - minimum)
                        * ratio

                    newValue = math.floor(
                        newValue + 0.5
                    )

                    setValue(newValue, true)
                end

                hit.InputBegan:Connect(function(input)
                    if input.UserInputType
                        == Enum.UserInputType.MouseButton1
                        or input.UserInputType
                        == Enum.UserInputType.Touch then

                        draggingSlider = true

                        updateFromInput(input)
                    end
                end)

                local changedConnection

                changedConnection =
                    UserInputService.InputChanged:Connect(function(input)
                        if not draggingSlider then
                            return
                        end

                        if input.UserInputType
                            == Enum.UserInputType.MouseMovement
                            or input.UserInputType
                            == Enum.UserInputType.Touch then

                            updateFromInput(input)
                        end
                    end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType
                        == Enum.UserInputType.MouseButton1
                        or input.UserInputType
                        == Enum.UserInputType.Touch then

                        draggingSlider = false
                    end
                end)

                setValue(value, false)

                local api = {}

                function api:Set(newValue)
                    setValue(
                        tonumber(newValue)
                            or minimum,
                        true
                    )
                end

                function api:Get()
                    return value
                end

                return api
            end

            --------------------------------------------------
            -- DROPDOWN
            --------------------------------------------------

            function section:Dropdown(controlInfo)
                controlInfo = controlInfo or {}

                local list = controlInfo.List or {}

                local current = controlInfo.Default
                local expanded = false

                local api = {}

                --------------------------------------------------
                -- HOLDER
                --------------------------------------------------

                local holder = Instance.new("Frame")

                holder.Name = "Dropdown"

                holder.BackgroundTransparency = 1

                holder.Size = UDim2.new(
                    1,
                    0,
                    0,
                    42
                )

                holder.AutomaticSize =
                    Enum.AutomaticSize.Y

                holder.Parent = controls

                --------------------------------------------------
                -- HEADER
                --------------------------------------------------

                local head = Instance.new("Frame")

                head.Name = "Header"

                head.BackgroundColor3 = THEME.Surface2
                head.BorderSizePixel = 0

                head.Size = UDim2.new(
                    1,
                    0,
                    0,
                    42
                )

                head.Parent = holder

                corner(head, 7)

                local title = label(
                    head,
                    controlInfo.Text or "Dropdown",
                    12,
                    THEME.Text
                )

                title.Position = UDim2.fromOffset(
                    11,
                    0
                )

                title.Size = UDim2.new(
                    0.52,
                    0,
                    1,
                    0
                )

                local currentLabel = label(
                    head,
                    current ~= nil
                        and tostring(current)
                        or "Select...",
                    11,
                    THEME.SubText
                )

                currentLabel.TextXAlignment =
                    Enum.TextXAlignment.Right

                currentLabel.Position =
                    UDim2.new(
                        0.52,
                        0,
                        0,
                        0
                    )

                currentLabel.Size =
                    UDim2.new(
                        0.48,
                        -28,
                        1,
                        0
                    )

                local chevron = label(
                    head,
                    "›",
                    18,
                    THEME.Muted,
                    Enum.Font.GothamBold
                )

                chevron.TextXAlignment =
                    Enum.TextXAlignment.Center

                chevron.Position =
                    UDim2.new(
                        1,
                        -25,
                        0,
                        0
                    )

                chevron.Size =
                    UDim2.fromOffset(
                        20,
                        42
                    )

                --------------------------------------------------
                -- MENU
                --------------------------------------------------

                local menu = Instance.new("Frame")

                menu.Name = "Menu"

                menu.BackgroundColor3 =
                    THEME.Surface3

                menu.BorderSizePixel = 0

                menu.Size = UDim2.new(
                    1,
                    0,
                    0,
                    0
                )

                menu.AutomaticSize =
                    Enum.AutomaticSize.Y

                menu.Visible = false

                menu.Parent = holder

                corner(menu, 7)

                stroke(menu, THEME.Border, 0.15)

                padding(menu, 5, 5, 5, 5)

                local menuLayout =
                    Instance.new("UIListLayout")

                menuLayout.Padding =
                    UDim.new(0, 3)

                menuLayout.SortOrder =
                    Enum.SortOrder.LayoutOrder

                menuLayout.Parent = menu

                --------------------------------------------------
                -- CHOOSE
                --------------------------------------------------

                local function choose(option)
                    current = option

                    currentLabel.Text =
                        tostring(option)

                    if controlInfo.Flag then
                        library.Flags[
                            controlInfo.Flag
                        ] = option
                    end

                    pcall(
                        controlInfo.Callback
                            or function() end,
                        option
                    )

                    expanded = false

                    menu.Visible = false

                    chevron.Text = "›"

                    holder.Size =
                        UDim2.new(
                            1,
                            0,
                            0,
                            42
                        )
                end

                --------------------------------------------------
                -- OPTIONS
                --------------------------------------------------

                for index, option in ipairs(list) do
                    local optionButton =
                        Instance.new("TextButton")

                    optionButton.Name =
                        "Option_" .. index

                    optionButton.Text =
                        tostring(option)

                    optionButton.TextColor3 =
                        THEME.SubText

                    optionButton.TextSize = 11

                    optionButton.Font =
                        Enum.Font.GothamMedium

                    optionButton.TextXAlignment =
                        Enum.TextXAlignment.Left

                    optionButton.AutoButtonColor =
                        false

                    optionButton.BackgroundColor3 =
                        THEME.Surface2

                    optionButton.Size =
                        UDim2.new(
                            1,
                            0,
                            0,
                            34
                        )

                    optionButton.Parent = menu

                    corner(optionButton, 6)

                    padding(
                        optionButton,
                        9,
                        5,
                        0,
                        0
                    )

                    optionButton.Activated:Connect(
                        function()
                            choose(option)
                        end
                    )

                    optionButton.MouseEnter:Connect(
                        function()
                            tween(
                                optionButton,
                                0.1,
                                {
                                    BackgroundColor3 =
                                        THEME.Border
                                }
                            )
                        end
                    )

                    optionButton.MouseLeave:Connect(
                        function()
                            tween(
                                optionButton,
                                0.1,
                                {
                                    BackgroundColor3 =
                                        THEME.Surface2
                                }
                            )
                        end
                    )
                end

                --------------------------------------------------
                -- HEADER BUTTON
                --------------------------------------------------

                local headButton =
                    makeButton(
                        head,
                        "DropdownButton"
                    )

                headButton.ZIndex = 5

                headButton.Activated:Connect(
                    function()
                        expanded = not expanded

                        menu.Visible = expanded

                        chevron.Text =
                            expanded
                            and "⌄"
                            or "›"

                        if expanded then
                            local menuHeight =
                                math.min(
                                    (#list * 37) + 10,
                                    190
                                )

                            holder.Size =
                                UDim2.new(
                                    1,
                                    0,
                                    0,
                                    42 + menuHeight
                                )
                        else
                            holder.Size =
                                UDim2.new(
                                    1,
                                    0,
                                    0,
                                    42
                                )
                        end
                    end
                )

                function api:Set(option)
                    for _, value in ipairs(list) do
                        if value == option then
                            choose(option)
                            return
                        end
                    end
                end

                function api:Get()
                    return current
                end

                if current ~= nil then
                    if controlInfo.Flag then
                        library.Flags[
                            controlInfo.Flag
                        ] = current
                    end
                end

                return api
            end

            --------------------------------------------------
            -- RADIO BUTTON
            --------------------------------------------------

            function section:RadioButton(controlInfo)
                controlInfo = controlInfo or {}

                local options =
                    controlInfo.Options or {}

                local selected =
                    controlInfo.Default

                local api = {}

                local rowHeight =
                    42 + (#options * 34)

                local row =
                    controlRow(rowHeight)

                local title = label(
                    row,
                    controlInfo.Text
                        or "Radio Button",
                    12,
                    THEME.Text
                )

                title.Position =
                    UDim2.fromOffset(
                        11,
                        5
                    )

                title.Size =
                    UDim2.new(
                        1,
                        -22,
                        0,
                        28
                    )

                local list =
                    Instance.new("Frame")

                list.BackgroundTransparency = 1

                list.Position =
                    UDim2.fromOffset(
                        7,
                        36
                    )

                list.Size =
                    UDim2.new(
                        1,
                        -14,
                        0,
                        #options * 34
                    )

                list.Parent = row

                local listLayout =
                    Instance.new("UIListLayout")

                listLayout.Padding =
                    UDim.new(0, 2)

                listLayout.Parent = list

                local buttons = {}

                local function select(option, callback)
                    selected = option

                    if controlInfo.Flag then
                        library.Flags[
                            controlInfo.Flag
                        ] = option
                    end

                    for value, ui in pairs(buttons) do
                        local active =
                            value == selected

                        tween(
                            ui.Dot,
                            0.12,
                            {
                                BackgroundColor3 =
                                    active
                                    and THEME.Accent
                                    or THEME.Off
                            }
                        )

                        ui.Text.TextColor3 =
                            active
                            and THEME.Text
                            or THEME.SubText
                    end

                    if callback then
                        pcall(
                            controlInfo.Callback
                                or function() end,
                            option
                        )
                    end
                end

                for _, option in ipairs(options) do
                    local button =
                        Instance.new("TextButton")

                    button.Text = ""

                    button.AutoButtonColor = false

                    button.BackgroundTransparency = 1

                    button.Size =
                        UDim2.new(
                            1,
                            0,
                            0,
                            32
                        )

                    button.Parent = list

                    local dot =
                        Instance.new("Frame")

                    dot.BackgroundColor3 =
                        THEME.Off

                    dot.Position =
                        UDim2.fromOffset(
                            6,
                            8
                        )

                    dot.Size =
                        UDim2.fromOffset(
                            14,
                            14
                        )

                    dot.Parent = button

                    corner(dot, 100)

                    stroke(
                        dot,
                        THEME.BorderHover,
                        0
                    )

                    local text =
                        label(
                            button,
                            tostring(option),
                            11,
                            THEME.SubText
                        )

                    text.Position =
                        UDim2.fromOffset(
                            28,
                            0
                        )

                    text.Size =
                        UDim2.new(
                            1,
                            -28,
                            1,
                            0
                        )

                    buttons[option] = {
                        Dot = dot,
                        Text = text
                    }

                    button.Activated:Connect(
                        function()
                            select(
                                option,
                                true
                            )
                        end
                    )
                end

                function api:Set(option)
                    for _, value in ipairs(options) do
                        if value == option then
                            select(
                                option,
                                true
                            )
                            return
                        end
                    end
                end

                function api:Get()
                    return selected
                end

                if selected ~= nil then
                    select(
                        selected,
                        false
                    )
                end

                return api
            end

            return section
        end

        tab:updateColumns()

        if #tabs == 1 then
            selectTab(tab)
        end

        updateLayout()

        return tab
    end

    --------------------------------------------------
    -- DESTROY
    --------------------------------------------------

    function window:Destroy()
        if destroyed then
            return
        end

        destroyed = true

        if cameraConnection then
            cameraConnection:Disconnect()
            cameraConnection = nil
        end

        gui:Destroy()
    end

    --------------------------------------------------
    -- INITIAL LAYOUT
    --------------------------------------------------

    updateLayout()

    return window
end

return library
