-- SkyHub Dex++ - Advanced Game Explorer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============== TẠO GIAO DIỆN DEX++ STYLE ==============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DexPlusPlus"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Main Container (Dex Style)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainContainer"
mainFrame.Size = UDim2.new(0, 800, 0, 500)
mainFrame.Position = UDim2.new(0.5, -400, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -100, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.Text = "🎮 DEX++ Game Explorer"
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.TextColor3 = Color3.fromRGB(0, 255, 255)
titleText.BackgroundTransparency = 1
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 80, 1, 0)
closeBtn.Position = UDim2.new(1, -85, 0, 0)
closeBtn.Text = "Close"
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 12
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
closeBtn.AutoButtonColor = true
closeBtn.Parent = titleBar

-- ============== TAB SYSTEM ==============
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 30)
tabContainer.Position = UDim2.new(0, 10, 0, 40)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local tabs = {
    {name = "📁 Explorer", color = Color3.fromRGB(0, 150, 200)},
    {name = "📜 Scripts", color = Color3.fromRGB(0, 180, 120)},
    {name = "🏗️ Models", color = Color3.fromRGB(200, 100, 0)},
    {name = "💾 Save", color = Color3.fromRGB(180, 0, 180)}
}

local tabButtons = {}
local tabPages = {}

-- Tạo tab buttons
for i, tabInfo in ipairs(tabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 100, 1, 0)
    tabBtn.Position = UDim2.new(0, (i-1)*105, 0, 0)
    tabBtn.Text = tabInfo.name
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.TextSize = 12
    tabBtn.TextColor3 = Color3.new(1, 1, 1)
    tabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    tabBtn.AutoButtonColor = true
    tabBtn.Parent = tabContainer
    
    local tabPage = Instance.new("Frame")
    tabPage.Size = UDim2.new(1, -20, 1, -80)
    tabPage.Position = UDim2.new(0, 10, 0, 80)
    tabPage.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    tabPage.Visible = i == 1
    tabPage.Parent = mainFrame
    
    table.insert(tabButtons, tabBtn)
    table.insert(tabPages, tabPage)
    
    tabBtn.MouseButton1Click:Connect(function()
        for j, page in ipairs(tabPages) do
            page.Visible = j == i
            tabButtons[j].BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        end
        tabBtn.BackgroundColor3 = tabInfo.color
    end)
    
    if i == 1 then
        tabBtn.BackgroundColor3 = tabInfo.color
    end
end

-- ============== EXPLORER TAB (Dex Style) ==============
local explorerPage = tabPages[1]

-- Tree View Container
local treeContainer = Instance.new("ScrollingFrame")
treeContainer.Size = UDim2.new(0.3, -10, 1, -10)
treeContainer.Position = UDim2.new(0, 10, 0, 10)
treeContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
treeContainer.ScrollBarThickness = 5
treeContainer.Parent = explorerPage

-- Properties Panel
local propsContainer = Instance.new("Frame")
propsContainer.Size = UDim2.new(0.7, -20, 1, -10)
propsContainer.Position = UDim2.new(0.3, 10, 0, 10)
propsContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
propsContainer.Parent = explorerPage

-- ============== GAME EXPLORER ENGINE ==============
local Explorer = {
    SelectedObject = nil,
    ObjectCache = {},
    TreeNodes = {}
}

-- Hàm tạo tree node
function Explorer:CreateTreeNode(parent, obj, depth)
    if not obj then return end
    
    local nodeFrame = Instance.new("Frame")
    nodeFrame.Size = UDim2.new(1, -depth*20, 0, 25)
    nodeFrame.Position = UDim2.new(0, depth*20, 0, #self.TreeNodes * 25)
    nodeFrame.BackgroundTransparency = 1
    nodeFrame.Parent = parent
    
    local expandBtn = Instance.new("TextButton")
    expandBtn.Size = UDim2.new(0, 20, 0, 20)
    expandBtn.Position = UDim2.new(0, 0, 0, 2)
    expandBtn.Text = "+"
    expandBtn.Font = Enum.Font.GothamBold
    expandBtn.TextSize = 12
    expandBtn.TextColor3 = Color3.new(1, 1, 1)
    expandBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    expandBtn.AutoButtonColor = true
    expandBtn.Parent = nodeFrame
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 20, 0, 20)
    iconLabel.Position = UDim2.new(0, 25, 0, 2)
    iconLabel.Text = self:GetIconForClass(obj.ClassName)
    iconLabel.Font = Enum.Font.Gotham
    iconLabel.TextSize = 12
    iconLabel.TextColor3 = Color3.new(1, 1, 1)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Parent = nodeFrame
    
    local nameLabel = Instance.new("TextButton")
    nameLabel.Size = UDim2.new(1, -50, 0, 20)
    nameLabel.Position = UDim2.new(0, 50, 0, 2)
    nameLabel.Text = obj.Name
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 12
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.BackgroundTransparency = 1
    nameLabel.AutoButtonColor = false
    nameLabel.Parent = nodeFrame
    
    -- Click để chọn object
    nameLabel.MouseButton1Click:Connect(function()
        self:SelectObject(obj)
    end)
    
    table.insert(self.TreeNodes, nodeFrame)
    return nodeFrame
end

-- Hàm lấy icon cho class
function Explorer:GetIconForClass(className)
    local icons = {
        Workspace = "🏢",
        Model = "🏗️",
        Part = "🧱",
        Script = "📜",
        LocalScript = "📱",
        ModuleScript = "📦",
        Folder = "📁",
        Sound = "🎵",
        Light = "💡",
        Camera = "📷",
        Humanoid = "👤",
        MeshPart = "🔷",
        UnionOperation = "🔶",
        Motor6D = "🔗",
        Motor = "⚙️"
    }
    return icons[className] or "📄"
end

-- Hàm chọn object
function Explorer:SelectObject(obj)
    self.SelectedObject = obj
    self:UpdatePropertiesPanel()
end

-- Hàm cập nhật properties panel
function Explorer:UpdatePropertiesPanel()
    local propsPanel = propsContainer
    propsPanel:ClearAllChildren()
    
    if not self.SelectedObject then
        local noSelect = Instance.new("TextLabel")
        noSelect.Size = UDim2.new(1, -20, 1, -20)
        noSelect.Position = UDim2.new(0, 10, 0, 10)
        noSelect.Text = "Select an object to view properties"
        noSelect.Font = Enum.Font.Gotham
        noSelect.TextSize = 14
        noSelect.TextColor3 = Color3.fromRGB(200, 200, 200)
        noSelect.BackgroundTransparency = 1
        noSelect.Parent = propsPanel
        return
    end
    
    local obj = self.SelectedObject
    
    -- Object header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    header.Parent = propsPanel
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 10, 0, 5)
    icon.Text = self:GetIconForClass(obj.ClassName)
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 16
    icon.TextColor3 = Color3.new(1, 1, 1)
    icon.BackgroundTransparency = 1
    icon.Parent = header
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.5, -50, 0, 30)
    nameLabel.Position = UDim2.new(0, 50, 0, 5)
    nameLabel.Text = obj.Name
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.BackgroundTransparency = 1
    nameLabel.Parent = header
    
    local classLabel = Instance.new("TextLabel")
    classLabel.Size = UDim2.new(0.5, -10, 0, 30)
    classLabel.Position = UDim2.new(0.5, 10, 0, 5)
    classLabel.Text = "Class: "..obj.ClassName
    classLabel.Font = Enum.Font.Gotham
    classLabel.TextSize = 12
    classLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    classLabel.TextXAlignment = Enum.TextXAlignment.Right
    classLabel.BackgroundTransparency = 1
    classLabel.Parent = header
    
    -- Properties scroll
    local propsScroll = Instance.new("ScrollingFrame")
    propsScroll.Size = UDim2.new(1, -20, 1, -60)
    propsScroll.Position = UDim2.new(0, 10, 0, 50)
    propsScroll.BackgroundTransparency = 1
    propsScroll.ScrollBarThickness = 5
    propsScroll.Parent = propsPanel
    
    local yPos = 0
    
    -- Hiển thị properties
    local function addProperty(name, value, color)
        local propFrame = Instance.new("Frame")
        propFrame.Size = UDim2.new(1, -10, 0, 25)
        propFrame.Position = UDim2.new(0, 5, 0, yPos)
        propFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        propFrame.Parent = propsScroll
        
        local propName = Instance.new("TextLabel")
        propName.Size = UDim2.new(0.4, -5, 1, 0)
        propName.Position = UDim2.new(0, 5, 0, 0)
        propName.Text = name
        propName.Font = Enum.Font.Gotham
        propName.TextSize = 12
        propName.TextColor3 = color or Color3.fromRGB(0, 200, 255)
        propName.TextXAlignment = Enum.TextXAlignment.Left
        propName.BackgroundTransparency = 1
        propName.Parent = propFrame
        
        local propValue = Instance.new("TextLabel")
        propValue.Size = UDim2.new(0.6, -10, 1, 0)
        propValue.Position = UDim2.new(0.4, 5, 0, 0)
        propValue.Text = tostring(value)
        propValue.Font = Enum.Font.Gotham
        propValue.TextSize = 11
        propValue.TextColor3 = Color3.fromRGB(200, 200, 200)
        propValue.TextXAlignment = Enum.TextXAlignment.Left
        propValue.BackgroundTransparency = 1
        propValue.Parent = propFrame
        
        yPos = yPos + 30
    end
    
    -- Basic properties
    addProperty("Name", obj.Name)
    addProperty("ClassName", obj.ClassName)
    
    -- Object specific properties
    if obj:IsA("BasePart") then
        addProperty("Position", string.format("(%.2f, %.2f, %.2f)", 
            obj.Position.X, obj.Position.Y, obj.Position.Z))
        addProperty("Size", string.format("(%.2f, %.2f, %.2f)", 
            obj.Size.X, obj.Size.Y, obj.Size.Z))
        addProperty("Color", string.format("RGB(%.0f, %.0f, %.0f)", 
            obj.Color.R*255, obj.Color.G*255, obj.Color.B*255))
        addProperty("Material", tostring(obj.Material))
        addProperty("Transparency", obj.Transparency)
        addProperty("CanCollide", tostring(obj.CanCollide))
        addProperty("Anchored", tostring(obj.Anchored))
    elseif obj:IsA("Model") then
        addProperty("PrimaryPart", obj.PrimaryPart and obj.PrimaryPart.Name or "None")
        addProperty("Children", #obj:GetChildren())
    elseif obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
        addProperty("Enabled", tostring(obj.Enabled))
        addProperty("Disabled", tostring(obj.Disabled))
        
        -- View source button
        local viewBtn = Instance.new("TextButton")
        viewBtn.Size = UDim2.new(1, -20, 0, 25)
        viewBtn.Position = UDim2.new(0, 10, 0, yPos)
        viewBtn.Text = "📜 View Source"
        viewBtn.Font = Enum.Font.Gotham
        viewBtn.TextSize = 12
        viewBtn.TextColor3 = Color3.new(1, 1, 1)
        viewBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        viewBtn.AutoButtonColor = true
        viewBtn.Parent = propsScroll
        
        viewBtn.MouseButton1Click:Connect(function()
            local success, source = pcall(function()
                return obj.Source
            end)
            
            if success and source then
                -- Tạo script viewer
                local viewer = Instance.new("ScreenGui")
                viewer.Name = "ScriptViewer"
                viewer.Parent = playerGui
                
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(0, 700, 0, 500)
                frame.Position = UDim2.new(0.5, -350, 0.5, -250)
                frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                frame.Parent = viewer
                
                local title = Instance.new("TextLabel")
                title.Size = UDim2.new(1, -20, 0, 40)
                title.Position = UDim2.new(0, 10, 0, 10)
                title.Text = obj.Name .. " (" .. obj.ClassName .. ")"
                title.Font = Enum.Font.GothamBold
                title.TextSize = 16
                title.TextColor3 = Color3.fromRGB(0, 255, 255)
                title.BackgroundTransparency = 1
                title.Parent = frame
                
                local closeBtn2 = Instance.new("TextButton")
                closeBtn2.Size = UDim2.new(0, 30, 0, 30)
                closeBtn2.Position = UDim2.new(1, -35, 0, 10)
                closeBtn2.Text = "X"
                closeBtn2.Font = Enum.Font.GothamBold
                closeBtn2.TextSize = 16
                closeBtn2.TextColor3 = Color3.fromRGB(255, 50, 50)
                closeBtn2.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                closeBtn2.AutoButtonColor = true
                closeBtn2.Parent = frame
                closeBtn2.MouseButton1Click:Connect(function()
                    viewer:Destroy()
                end)
                
                local textBox = Instance.new("TextBox")
                textBox.Size = UDim2.new(1, -20, 1, -60)
                textBox.Position = UDim2.new(0, 10, 0, 50)
                textBox.Text = source
                textBox.Font = Enum.Font.Code
                textBox.TextSize = 12
                textBox.TextColor3 = Color3.new(1, 1, 1)
                textBox.BackgroundTransparency = 1
                textBox.TextXAlignment = Enum.TextXAlignment.Left
                textBox.TextYAlignment = Enum.TextYAlignment.Top
                textBox.TextWrapped = false
                textBox.MultiLine = true
                textBox.TextEditable = false
                textBox.Parent = frame
                
                local lineCount = #string.split(source, "\n")
                local infoLabel = Instance.new("TextLabel")
                infoLabel.Size = UDim2.new(1, -20, 0, 20)
                infoLabel.Position = UDim2.new(0, 10, 1, -30)
                infoLabel.Text = "Lines: " .. lineCount .. " | Path: " .. obj:GetFullName()
                infoLabel.Font = Enum.Font.Gotham
                infoLabel.TextSize = 11
                infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                infoLabel.BackgroundTransparency = 1
                infoLabel.Parent = frame
            end
        end)
        
        yPos = yPos + 30
    end
    
    propsScroll.CanvasSize = UDim2.new(0, 0, 0, yPos + 10)
end

-- Khởi tạo explorer với Workspace
spawn(function()
    wait(1)
    
    -- Tạo root nodes cho các services quan trọng
    local services = {
        Workspace,
        ReplicatedStorage,
        ServerScriptService,
        ServerStorage,
        game:GetService("Lighting"),
        game:GetService("StarterPack"),
        game:GetService("StarterGui")
    }
    
    for _, service in ipairs(services) do
        local node = Explorer:CreateTreeNode(treeContainer, service, 0)
        
        -- Add children
        for _, child in ipairs(service:GetChildren()) do
            Explorer:CreateTreeNode(treeContainer, child, 1)
        end
    end
    
    treeContainer.CanvasSize = UDim2.new(0, 0, 0, #Explorer.TreeNodes * 30)
end)

-- ============== SCRIPTS TAB ==============
local scriptsPage = tabPages[2]

local scriptsContainer = Instance.new("ScrollingFrame")
scriptsContainer.Size = UDim2.new(1, -20, 1, -10)
scriptsContainer.Position = UDim2.new(0, 10, 0, 10)
scriptsContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
scriptsContainer.ScrollBarThickness = 5
scriptsContainer.Parent = scriptsPage

local function loadScriptsTab()
    scriptsContainer:ClearAllChildren()
    
    local servicesToCheck = {
        {name = "Workspace", service = Workspace},
        {name = "ReplicatedStorage", service = ReplicatedStorage},
        {name = "ServerScriptService", service = ServerScriptService},
        {name = "ServerStorage", service = ServerStorage}
    }
    
    local yPos = 0
    
    for _, serviceInfo in ipairs(servicesToCheck) do
        -- Service header
        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, -10, 0, 30)
        header.Position = UDim2.new(0, 5, 0, yPos)
        header.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        header.Parent = scriptsContainer
        
        local headerText = Instance.new("TextLabel")
        headerText.Size = UDim2.new(1, -10, 1, 0)
        headerText.Position = UDim2.new(0, 10, 0, 0)
        headerText.Text = "📁 " .. serviceInfo.name
        headerText.Font = Enum.Font.GothamBold
        headerText.TextSize = 14
        headerText.TextColor3 = Color3.fromRGB(0, 255, 255)
        headerText.TextXAlignment = Enum.TextXAlignment.Left
        headerText.BackgroundTransparency = 1
        headerText.Parent = header
        
        yPos = yPos + 35
        
        -- Scripts in service
        local scriptCount = 0
        for _, obj in ipairs(serviceInfo.service:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                scriptCount = scriptCount + 1
                
                local scriptFrame = Instance.new("Frame")
                scriptFrame.Size = UDim2.new(1, -20, 0, 40)
                scriptFrame.Position = UDim2.new(0, 10, 0, yPos)
                scriptFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                scriptFrame.Parent = scriptsContainer
                
                local icon = Instance.new("TextLabel")
                icon.Size = UDim2.new(0, 30, 0, 30)
                icon.Position = UDim2.new(0, 10, 0, 5)
                icon.Text = Explorer:GetIconForClass(obj.ClassName)
                icon.Font = Enum.Font.GothamBold
                icon.TextSize = 14
                icon.TextColor3 = Color3.new(1, 1, 1)
                icon.BackgroundTransparency = 1
                icon.Parent = scriptFrame
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(0.4, -50, 0, 30)
                nameLabel.Position = UDim2.new(0, 50, 0, 5)
                nameLabel.Text = obj.Name
                nameLabel.Font = Enum.Font.Gotham
                nameLabel.TextSize = 12
                nameLabel.TextColor3 = Color3.new(1, 1, 1)
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.BackgroundTransparency = 1
                nameLabel.Parent = scriptFrame
                
                local pathLabel = Instance.new("TextLabel")
                pathLabel.Size = UDim2.new(0.4, -10, 0, 30)
                pathLabel.Position = UDim2.new(0.4, 10, 0, 5)
                pathLabel.Text = obj:GetFullName()
                pathLabel.Font = Enum.Font.Gotham
                pathLabel.TextSize = 10
                pathLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                pathLabel.TextXAlignment = Enum.TextXAlignment.Left
                pathLabel.BackgroundTransparency = 1
                pathLabel.Parent = scriptFrame
                
                local viewBtn = Instance.new("TextButton")
                viewBtn.Size = UDim2.new(0, 80, 0, 25)
                viewBtn.Position = UDim2.new(1, -90, 0, 7)
                viewBtn.Text = "👁️ View"
                viewBtn.Font = Enum.Font.Gotham
                viewBtn.TextSize = 11
                viewBtn.TextColor3 = Color3.new(1, 1, 1)
                viewBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
                viewBtn.AutoButtonColor = true
                viewBtn.Parent = scriptFrame
                
                viewBtn.MouseButton1Click:Connect(function()
                    local success, source = pcall(function()
                        return obj.Source
                    end)
                    
                    if success and source then
                        -- Tạo script viewer
                        local viewer = Instance.new("ScreenGui")
                        viewer.Name = "ScriptViewer"
                        viewer.Parent = playerGui
                        
                        local frame = Instance.new("Frame")
                        frame.Size = UDim2.new(0, 700, 0, 500)
                        frame.Position = UDim2.new(0.5, -350, 0.5, -250)
                        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                        frame.Parent = viewer
                        
                        local title = Instance.new("TextLabel")
                        title.Size = UDim2.new(1, -20, 0, 40)
                        title.Position = UDim2.new(0, 10, 0, 10)
                        title.Text = obj.Name .. " (" .. obj.ClassName .. ")"
                        title.Font = Enum.Font.GothamBold
                        title.TextSize = 16
                        title.TextColor3 = Color3.fromRGB(0, 255, 255)
                        title.BackgroundTransparency = 1
                        title.Parent = frame
                        
                        local closeBtn2 = Instance.new("TextButton")
                        closeBtn2.Size = UDim2.new(0, 30, 0, 30)
                        closeBtn2.Position = UDim2.new(1, -35, 0, 10)
                        closeBtn2.Text = "X"
                        closeBtn2.Font = Enum.Font.GothamBold
                        closeBtn2.TextSize = 16
                        closeBtn2.TextColor3 = Color3.fromRGB(255, 50, 50)
                        closeBtn2.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                        closeBtn2.AutoButtonColor = true
                        closeBtn2.Parent = frame
                        closeBtn2.MouseButton1Click:Connect(function()
                            viewer:Destroy()
                        end)
                        
                        local textBox = Instance.new("TextBox")
                        textBox.Size = UDim2.new(1, -20, 1, -60)
                        textBox.Position = UDim2.new(0, 10, 0, 50)
                        textBox.Text = source
                        textBox.Font = Enum.Font.Code
                        textBox.TextSize = 12
                        textBox.TextColor3 = Color3.new(1, 1, 1)
                        textBox.BackgroundTransparency = 1
                        textBox.TextXAlignment = Enum.TextXAlignment.Left
                        textBox.TextYAlignment = Enum.TextYAlignment.Top
                        textBox.TextWrapped = false
                        textBox.MultiLine = true
                        textBox.TextEditable = false
                        textBox.Parent = frame
                    end
                end)
                
                yPos = yPos + 45
            end
        end
        
        if scriptCount == 0 then
            local noScripts = Instance.new("TextLabel")
            noScripts.Size = UDim2.new(1, -20, 0, 25)
            noScripts.Position = UDim2.new(0, 10, 0, yPos)
            noScripts.Text = "No scripts found"
            noScripts.Font = Enum.Font.Gotham
            noScripts.TextSize = 12
            noScripts.TextColor3 = Color3.fromRGB(150, 150, 150)
            noScripts.BackgroundTransparency = 1
            noScripts.Parent = scriptsContainer
            yPos = yPos + 30
        end
    end
    
    scriptsContainer.CanvasSize = UDim2.new(0, 0, 0, yPos + 10)
end

-- ============== MODELS TAB ==============
local modelsPage = tabPages[3]

local modelsContainer = Instance.new("ScrollingFrame")
modelsContainer.Size = UDim2.new(1, -20, 1, -10)
modelsContainer.Position = UDim2.new(0, 10, 0, 10)
modelsContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
modelsContainer.ScrollBarThickness = 5
modelsContainer.Parent = modelsPage

local function loadModelsTab()
    modelsContainer:ClearAllChildren()
    
    local models = {}
    
    -- Tìm tất cả models trong Workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and #obj:GetChildren() > 0 then
            local partCount = 0
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("BasePart") then
                    partCount = partCount + 1
                end
            end
            
            if partCount > 0 then
                table.insert(models, {
                    model = obj,
                    name = obj.Name,
                    partCount = partCount
                })
            end
        end
    end
    
    local yPos = 0
    
    -- Models header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, -10, 0, 30)
    header.Position = UDim2.new(0, 5, 0, yPos)
    header.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    header.Parent = modelsContainer
    
    local headerText = Instance.new("TextLabel")
    headerText.Size = UDim2.new(1, -10, 1, 0)
    headerText.Position = UDim2.new(0, 10, 0, 0)
    headerText.Text = "🏗️ Models in Workspace (" .. #models .. " found)"
    headerText.Font = Enum.Font.GothamBold
    headerText.TextSize = 14
    headerText.TextColor3 = Color3.fromRGB(0, 255, 255)
    headerText.TextXAlignment = Enum.TextXAlignment.Left
    headerText.BackgroundTransparency = 1
    headerText.Parent = header
    
    yPos = yPos + 35
    
    -- Hiển thị models
    for i, modelData in ipairs(models) do
        local modelFrame = Instance.new("Frame")
        modelFrame.Size = UDim2.new(1, -20, 0, 60)
        modelFrame.Position = UDim2.new(0, 10, 0, yPos)
        modelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        modelFrame.Parent = modelsContainer
        
        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(0, 40, 0, 40)
        icon.Position = UDim2.new(0, 10, 0, 10)
        icon.Text = "🏗️"
        icon.Font = Enum.Font.GothamBold
        icon.TextSize = 20
        icon.TextColor3 = Color3.new(1, 1, 1)
        icon.BackgroundTransparency = 1
        icon.Parent = modelFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.5, -60, 0, 20)
        nameLabel.Position = UDim2.new(0, 60, 0, 10)
        nameLabel.Text = modelData.name
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.BackgroundTransparency = 1
        nameLabel.Parent = modelFrame
        
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(0.5, -60, 0, 20)
        infoLabel.Position = UDim2.new(0, 60, 0, 30)
        infoLabel.Text = "Parts: " .. modelData.partCount
        infoLabel.Font = Enum.Font.Gotham
        infoLabel.TextSize = 12
        infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        infoLabel.TextXAlignment = Enum.TextXAlignment.Left
        infoLabel.BackgroundTransparency = 1
        infoLabel.Parent = modelFrame
        
        -- Buttons
        local viewBtn = Instance.new("TextButton")
        viewBtn.Size = UDim2.new(0, 70, 0, 25)
        viewBtn.Position = UDim2.new(1, -150, 0, 7)
        viewBtn.Text = "👁️ View"
        viewBtn.Font = Enum.Font.Gotham
        viewBtn.TextSize = 11
        viewBtn.TextColor3 = Color3.new(1, 1, 1)
        viewBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        viewBtn.AutoButtonColor = true
        viewBtn.Parent = modelFrame
        
        viewBtn.MouseButton1Click:Connect(function()
            -- Highlight model
            for _, part in ipairs(modelData.model:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0.3
                    part.Color = Color3.fromRGB(0, 255, 255)
                end
            end
        end)
        
        local cloneBtn = Instance.new("TextButton")
        cloneBtn.Size = UDim2.new(0, 70, 0, 25)
        cloneBtn.Position = UDim2.new(1, -75, 0, 7)
        cloneBtn.Text = "📋 Clone"
        cloneBtn.Font = Enum.Font.Gotham
        cloneBtn.TextSize = 11
        cloneBtn.TextColor3 = Color3.new(1, 1, 1)
        cloneBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        cloneBtn.AutoButtonColor = true
        cloneBtn.Parent = modelFrame
        
        cloneBtn.MouseButton1Click:Connect(function()
            local clone = modelData.model:Clone()
            clone.Parent = Workspace
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                clone:MoveTo(player.Character.HumanoidRootPart.Position + Vector3.new(10, 0, 0))
            end
        end)
        
        yPos = yPos + 65
    end
    
    if #models == 0 then
        local noModels = Instance.new("TextLabel")
        noModels.Size = UDim2.new(1, -20, 0, 50)
        noModels.Position = UDim2.new(0, 10, 0, yPos)
        noModels.Text = "No models found in Workspace"
        noModels.Font = Enum.Font.Gotham
        noModels.TextSize = 14
        noModels.TextColor3 = Color3.fromRGB(150, 150, 150)
        noModels.BackgroundTransparency = 1
        noModels.Parent = modelsContainer
        yPos = yPos + 60
    end
    
    modelsContainer.CanvasSize = UDim2.new(0, 0, 0, yPos + 10)
end

-- ============== SAVE TAB ==============
local savePage = tabPages[4]

local saveContainer = Instance.new("ScrollingFrame")
saveContainer.Size = UDim2.new(1, -20, 1, -10)
saveContainer.Position = UDim2.new(0, 10, 0, 10)
saveContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
saveContainer.ScrollBarThickness = 5
saveContainer.Parent = savePage

local function createSaveButton(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.AutoButtonColor = true
    btn.Parent = saveContainer
    
    btn.MouseButton1Click:Connect(callback)
    
    return btn
end

-- Hàm tạo RBXM file (Model file)
local function saveAsRBXM(model, filename)
    -- Đơn giản hóa: Lưu thông tin model
    local modelData = {
        Type = "Model",
        Name = model.Name,
        Children = {}
    }
    
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("BasePart") then
            table.insert(modelData.Children, {
                Type = "Part",
                Name = child.Name,
                Position = {child.Position.X, child.Position.Y, child.Position.Z},
                Size = {child.Size.X, child.Size.Y, child.Size.Z},
                Color = {child.Color.R, child.Color.G, child.Color.B}
            })
        end
    end
    
    local jsonData = HttpService:JSONEncode(modelData)
    
    -- Kiểm tra writefile
    if type(writefile) == "function" then
        writefile(filename .. ".json", jsonData)
        
        -- Tạo file .rbxm đơn giản
        local rbxmContent = string.format([[
<roblox version="4">
    <External>null</External>
    <External>nil</External>
    <Item class="Model" referent="RBX0">
        <Properties>
            <string name="Name">%s</string>
        </Properties>
]], model.Name)
        
        for i, child in ipairs(modelData.Children) do
            rbxmContent = rbxmContent .. string.format([[
        <Item class="Part" referent="RBX%d">
            <Properties>
                <string name="Name">%s</string>
                <CoordinateFrame name="CFrame">
                    <X>%f</X>
                    <Y>%f</Y>
                    <Z>%f</Z>
                    <R00>1</R00><R01>0</R01><R02>0</R02>
                    <R10>0</R10><R11>1</R11><R12>0</R12>
                    <R20>0</R20><R21>0</R21><R22>1</R22>
                </CoordinateFrame>
                <Vector3 name="Size">
                    <X>%f</X>
                    <Y>%f</Y>
                    <Z>%f</Z>
                </Vector3>
            </Properties>
        </Item>
]], i, child.Name, 
   child.Position[1], child.Position[2], child.Position[3],
   child.Size[1], child.Size[2], child.Size[3])
        end
        
        rbxmContent = rbxmContent .. "    </Item>\n</roblox>"
        
        writefile(filename .. ".rbxm", rbxmContent)
        return true
    end
    
    return false
end

-- Hàm save script
local function saveScriptAsLua(scriptObj, filename)
    if type(writefile) ~= "function" then return false end
    
    local success, source = pcall(function()
        return scriptObj.Source
    end)
    
    if success and source then
        writefile(filename .. ".lua", source)
        return true
    end
    
    return false
end

-- Tạo các nút save
local yPos = 10

createSaveButton("💾 Save Selected Object", yPos, function()
    if Explorer.SelectedObject then
        local obj = Explorer.SelectedObject
        
        if obj:IsA("Model") then
            local success = saveAsRBXM(obj, "SavedModel_" .. obj.Name)
            if success then
                game.StarterGui:SetCore("SendNotification", {
                    Title = "✅ Model Saved",
                    Text = "Saved as SavedModel_" .. obj.Name .. ".rbxm",
                    Duration = 5
                })
            end
        elseif obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local success = saveScriptAsLua(obj, "SavedScript_" .. obj.Name)
            if success then
                game.StarterGui:SetCore("SendNotification", {
                    Title = "✅ Script Saved",
                    Text = "Saved as SavedScript_" .. obj.Name .. ".lua",
                    Duration = 5
                })
            end
        end
    end
end)

yPos = yPos + 50

createSaveButton("🗺️ Save Map (Workspace)", yPos, function()
    local mapData = {
        Name = game.Name,
        PlaceId = game.PlaceId,
        Objects = {}
    }
    
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            table.insert(mapData.Objects, {
                Name = obj.Name,
                Class = obj.ClassName
            })
        end
    end
    
    if type(writefile) == "function" then
        writefile("MapData_" .. game.PlaceId .. ".json", HttpService:JSONEncode(mapData))
        
        game.StarterGui:SetCore("SendNotification", {
            Title = "✅ Map Saved",
            Text = "Saved map data",
            Duration = 5
        })
    end
end)

yPos = yPos + 50

createSaveButton("📜 Save All Scripts", yPos, function()
    if type(writefile) ~= "function" then return end
    
    local scriptCount = 0
    local services = {Workspace, ReplicatedStorage, ServerScriptService, ServerStorage}
    
    for _, service in ipairs(services) do
        for _, obj in ipairs(service:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                local success, source = pcall(function()
                    return obj.Source
                end)
                
                if success and source then
                    scriptCount = scriptCount + 1
                    local safeName = string.gsub(obj.Name, "[^%w_]", "_")
                    writefile("Script_" .. safeName .. "_" .. scriptCount .. ".lua", source)
                end
            end
        end
    end
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "✅ Scripts Saved",
        Text = "Saved " .. scriptCount .. " scripts",
        Duration = 5
    })
end)

yPos = yPos + 50

createSaveButton("🏗️ Save All Models", yPos, function()
    if type(writefile) ~= "function" then return end
    
    local modelCount = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            modelCount = modelCount + 1
            saveAsRBXM(obj, "Model_" .. obj.Name .. "_" .. modelCount)
        end
    end
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "✅ Models Saved",
        Text = "Saved " .. modelCount .. " models",
        Duration = 5
    })
end)

saveContainer.CanvasSize = UDim2.new(0, 0, 0, yPos + 60)

-- ============== INITIALIZE ==============
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Load data khi tab được chọn
for i, tabBtn in ipairs(tabButtons) do
    tabBtn.MouseButton1Click:Connect(function()
        if i == 2 then -- Scripts tab
            loadScriptsTab()
        elseif i == 3 then -- Models tab
            loadModelsTab()
        end
    end)
end

-- Auto-load scripts tab
spawn(function()
    wait(2)
    loadScriptsTab()
    loadModelsTab()
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "🎮 DEX++ Loaded",
    Text = "Game Explorer ready!",
    Duration = 5
})

print("=== DEX++ GAME EXPLORER LOADED ===")
print("Features:")
print("- 📁 Object Explorer (Dex Style)")
print("- 📜 Script Viewer & Decompiler")
print("- 🏗️ Model Viewer & Cloner")
print("- 💾 Save to RBXM/LUA files")
