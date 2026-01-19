-- SkyHub Ultimate - Deep Game Saver v3.0
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local StarterPack = game:GetService("StarterPack")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterGui = game:GetService("StarterGui")
local ContentProvider = game:GetService("ContentProvider")
local InsertService = game:GetService("InsertService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============== TẠO GIAO DIỆN ==============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SkyHubDeepSaver"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Menu Icon
local menuIcon = Instance.new("TextButton")
menuIcon.Name = "MenuIcon"
menuIcon.Size = UDim2.new(0, 60, 0, 60)
menuIcon.Position = UDim2.new(0, 20, 0.5, -30)
menuIcon.Text = "💾"
menuIcon.Font = Enum.Font.GothamBlack
menuIcon.TextSize = 30
menuIcon.TextColor3 = Color3.fromRGB(0, 255, 255)
menuIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
menuIcon.AutoButtonColor = true
menuIcon.Visible = true
menuIcon.Parent = screenGui

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 15)
iconCorner.Parent = menuIcon

local iconStroke = Instance.new("UIStroke")
iconStroke.Color = Color3.fromRGB(0, 255, 255)
iconStroke.Thickness = 3
iconStroke.Parent = menuIcon

-- Main Menu
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainMenu"
mainFrame.Size = UDim2.new(0, 500, 0, 650)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -325)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0, 255, 255)
mainStroke.Thickness = 3
mainStroke.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 70)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Text = "🔥 DEEP GAME SAVER v3.0\n💾 Save Everything - Model, Script, Data"
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.TextStrokeTransparency = 0
title.TextYAlignment = Enum.TextYAlignment.Center
title.Parent = mainFrame

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 10)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
closeBtn.AutoButtonColor = true
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- ============== DEEP SAVE ENGINE ==============
local DeepSave = {
    Cache = {},
    Settings = {
        SaveModels = true,
        SaveScripts = true,
        SaveData = true,
        SaveRemoteEvents = true,
        SaveGUIs = true,
        SaveSounds = true,
        SaveParticles = true,
        MaxDepth = 100
    }
}

-- Hàm serialize object deep
function DeepSave:SerializeObject(obj, depth)
    if depth > self.Settings.MaxDepth then
        return {Name = obj.Name, ClassName = obj.ClassName, Error = "Max depth reached"}
    end
    
    local serialized = {
        Name = obj.Name,
        ClassName = obj.ClassName,
        FullName = obj:GetFullName(),
        Depth = depth
    }
    
    -- Serialize properties based on class
    if obj:IsA("BasePart") then
        serialized.Position = {X = obj.Position.X, Y = obj.Position.Y, Z = obj.Position.Z}
        serialized.Size = {X = obj.Size.X, Y = obj.Size.Y, Z = obj.Size.Z}
        serialized.CFrame = {
            X = obj.CFrame.X, Y = obj.CFrame.Y, Z = obj.CFrame.Z,
            R00 = obj.CFrame:components()[1], R01 = obj.CFrame:components()[2], R02 = obj.CFrame:components()[3],
            R10 = obj.CFrame:components()[4], R11 = obj.CFrame:components()[5], R12 = obj.CFrame:components()[6],
            R20 = obj.CFrame:components()[7], R21 = obj.CFrame:components()[8], R22 = obj.CFrame:components()[9]
        }
        serialized.Color = {R = obj.Color.R, G = obj.Color.G, B = obj.Color.B}
        serialized.Transparency = obj.Transparency
        serialized.Material = tostring(obj.Material)
        serialized.Reflectance = obj.Reflectance
        serialized.CanCollide = obj.CanCollide
        serialized.Anchored = obj.Anchored
        serialized.Locked = obj.Locked
        serialized.CastShadow = obj.CastShadow
        
    elseif obj:IsA("Model") then
        serialized.PrimaryPart = obj.PrimaryPart and obj.PrimaryPart.Name
        serialized.WorldPivot = obj:GetPivot() and {
            X = obj:GetPivot().Position.X,
            Y = obj:GetPivot().Position.Y,
            Z = obj:GetPivot().Position.Z
        }
        
    elseif obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
        if self.Settings.SaveScripts then
            local success, source = pcall(function()
                return obj.Source
            end)
            if success and source then
                serialized.Source = source
                serialized.Enabled = obj.Enabled
                serialized.Disabled = obj.Disabled
            end
        end
        
    elseif obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        if self.Settings.SaveRemoteEvents then
            serialized.EventType = obj.ClassName
        end
        
    elseif obj:IsA("Sound") then
        if self.Settings.SaveSounds then
            serialized.SoundId = obj.SoundId
            serialized.Volume = obj.Volume
            serialized.PlaybackSpeed = obj.PlaybackSpeed
            serialized.Looped = obj.Looped
            serialized.Playing = obj.Playing
        end
        
    elseif obj:IsA("ParticleEmitter") then
        if self.Settings.SaveParticles then
            serialized.Rate = obj.Rate
            serialized.Lifetime = obj.Lifetime.Min
            serialized.Size = obj.Size.Min
            serialized.Speed = obj.Speed.Min
            serialized.Texture = obj.Texture
        end
        
    elseif obj:IsA("GuiObject") then
        if self.Settings.SaveGUIs then
            serialized.Size = {X = obj.Size.X.Scale, Y = obj.Size.Y.Scale, OffsetX = obj.Size.X.Offset, OffsetY = obj.Size.Y.Offset}
            serialized.Position = {X = obj.Position.X.Scale, Y = obj.Position.Y.Scale, OffsetX = obj.Position.X.Offset, OffsetY = obj.Position.Y.Offset}
            serialized.BackgroundColor3 = {R = obj.BackgroundColor3.R, G = obj.BackgroundColor3.G, B = obj.BackgroundColor3.B}
            serialized.Transparency = obj.BackgroundTransparency
        end
        
    elseif obj:IsA("ValueBase") then
        if self.Settings.SaveData then
            if obj:IsA("StringValue") then
                serialized.Value = obj.Value
            elseif obj:IsA("NumberValue") then
                serialized.Value = obj.Value
            elseif obj:IsA("BoolValue") then
                serialized.Value = obj.Value
            elseif obj:IsA("ObjectValue") then
                serialized.Value = obj.Value and obj.Value.Name
            end
        end
    end
    
    -- Serialize children recursively
    serialized.Children = {}
    for _, child in ipairs(obj:GetChildren()) do
        table.insert(serialized.Children, self:SerializeObject(child, depth + 1))
    end
    
    -- Cache for performance
    self.Cache[obj] = serialized
    return serialized
end

-- Hàm save toàn bộ game
function DeepSave:SaveFullGame()
    local gameData = {
        metadata = {
            name = game.Name,
            placeId = game.PlaceId,
            creatorId = game.CreatorId,
            description = game.Description,
            savedAt = os.date("%Y-%m-%d %H:%M:%S"),
            version = "3.0",
            gameId = game.GameId,
            jobId = game.JobId
        },
        services = {},
        statistics = {
            parts = 0,
            scripts = 0,
            models = 0,
            players = #Players:GetPlayers(),
            objects = 0
        }
    }
    
    -- Save all services
    local servicesToSave = {
        "Workspace",
        "ReplicatedStorage", 
        "ServerScriptService",
        "ServerStorage",
        "Lighting",
        "SoundService",
        "StarterPack",
        "StarterGui",
        "StarterPlayer",
        "Teams"
    }
    
    for _, serviceName in ipairs(servicesToSave) do
        local service = game:GetService(serviceName)
        if service then
            gameData.services[serviceName] = self:SerializeObject(service, 0)
            
            -- Count objects
            local function countObjects(obj)
                gameData.statistics.objects = gameData.statistics.objects + 1
                if obj:IsA("BasePart") then
                    gameData.statistics.parts = gameData.statistics.parts + 1
                elseif obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                    gameData.statistics.scripts = gameData.statistics.scripts + 1
                elseif obj:IsA("Model") then
                    gameData.statistics.models = gameData.statistics.models + 1
                end
                
                for _, child in ipairs(obj:GetChildren()) do
                    countObjects(child)
                end
            end
            
            countObjects(service)
        end
    end
    
    -- Save player data
    gameData.players = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        local playerData = {
            name = plr.Name,
            userId = plr.UserId,
            displayName = plr.DisplayName,
            accountAge = plr.AccountAge,
            membershipType = tostring(plr.MembershipType)
        }
        
        if plr.Character then
            playerData.character = {
                position = plr.Character:FindFirstChild("HumanoidRootPart") and {
                    x = plr.Character.HumanoidRootPart.Position.X,
                    y = plr.Character.HumanoidRootPart.Position.Y,
                    z = plr.Character.HumanoidRootPart.Position.Z
                },
                health = plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health
            }
        end
        
        table.insert(gameData.players, playerData)
    end
    
    return gameData
end

-- Hàm tạo file .rbxl (Roblox Place File)
function DeepSave:CreateRBXLFile(gameData)
    -- Tạo XML content cho RBXLX format
    local xmlContent = '<?xml version="1.0" encoding="utf-8"?>\n'
    xmlContent = xmlContent .. '<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n'
    
    -- Add metadata
    xmlContent = xmlContent .. '  <Meta name="ExplicitAutoJoints">true</Meta>\n'
    
    -- Helper function to create item
    local function createItem(obj, refId)
        local item = '  <Item class="'..obj.ClassName..'" referent="RBX'..refId..'">\n'
        item = item .. '    <Properties>\n'
        item = item .. '      <string name="Name">'..obj.Name..'</string>\n'
        
        if obj:IsA("BasePart") then
            item = item .. '      <CoordinateFrame name="CFrame">\n'
            item = item .. '        <X>'..obj.Position.X..'</X>\n'
            item = item .. '        <Y>'..obj.Position.Y..'</Y>\n'
            item = item .. '        <Z>'..obj.Position.Z..'</Z>\n'
            item = item .. '        <R00>1</R00><R01>0</R01><R02>0</R02>\n'
            item = item .. '        <R10>0</R10><R11>1</R11><R12>0</R12>\n'
            item = item .. '        <R20>0</R20><R21>0</R21><R22>1</R22>\n'
            item = item .. '      </CoordinateFrame>\n'
            
            item = item .. '      <Vector3 name="Size">\n'
            item = item .. '        <X>'..obj.Size.X..'</X>\n'
            item = item .. '        <Y>'..obj.Size.Y..'</Y>\n'
            item = item .. '        <Z>'..obj.Size.Z..'</Z>\n'
            item = item .. '      </Vector3>\n'
            
            item = item .. '      <bool name="Anchored">'..tostring(obj.Anchored)..'</bool>\n'
            item = item .. '      <bool name="CanCollide">'..tostring(obj.CanCollide)..'</bool>\n'
        end
        
        item = item .. '    </Properties>\n'
        return item
    end
    
    -- Add Workspace
    xmlContent = xmlContent .. createItem(Workspace, 0)
    
    -- Add all parts in Workspace
    local refCounter = 1
    local function addParts(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("BasePart") then
                xmlContent = xmlContent .. createItem(child, refCounter)
                refCounter = refCounter + 1
            end
            addParts(child)
        end
    end
    
    addParts(Workspace)
    
    xmlContent = xmlContent .. '  </Item>\n'  -- Close Workspace
    
    -- Close roblox tag
    xmlContent = xmlContent .. '</roblox>'
    
    return xmlContent
end

-- Hàm tạo Lua Module từ object
function DeepSave:CreateLuaModule(obj)
    local moduleCode = "-- Generated by DeepSave v3.0\n"
    moduleCode = moduleCode .. "-- Object: "..obj.Name.." ("..obj.ClassName..")\n"
    moduleCode = moduleCode .. "-- Path: "..obj:GetFullName().."\n"
    moduleCode = moduleCode .. "-- Time: "..os.date().."\n\n"
    
    if obj:IsA("ModuleScript") then
        local success, source = pcall(function()
            return obj.Source
        end)
        if success then
            moduleCode = moduleCode .. source
        end
    elseif obj:IsA("Script") or obj:IsA("LocalScript") then
        local success, source = pcall(function()
            return obj.Source
        end)
        if success then
            moduleCode = moduleCode .. "-- Script Source:\n"
            moduleCode = moduleCode .. source
        end
    else
        moduleCode = moduleCode .. "-- Properties:\n"
        moduleCode = moduleCode .. "local "..obj.Name.." = {\n"
        moduleCode = moduleCode .. "  ClassName = \""..obj.ClassName.."\",\n"
        moduleCode = moduleCode .. "  Name = \""..obj.Name.."\",\n"
        
        if obj:IsA("BasePart") then
            moduleCode = moduleCode .. "  Position = Vector3.new("..obj.Position.X..", "..obj.Position.Y..", "..obj.Position.Z.."),\n"
            moduleCode = moduleCode .. "  Size = Vector3.new("..obj.Size.X..", "..obj.Size.Y..", "..obj.Size.Z.."),\n"
            moduleCode = moduleCode .. "  Color = Color3.new("..obj.Color.R..", "..obj.Color.G..", "..obj.Color.B.."),\n"
            moduleCode = moduleCode .. "  Material = \""..tostring(obj.Material).."\",\n"
        end
        
        moduleCode = moduleCode .. "}\n\n"
        moduleCode = moduleCode .. "return "..obj.Name
    end
    
    return moduleCode
end

-- ============== TAB SYSTEM ==============
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 40)
tabContainer.Position = UDim2.new(0, 10, 0, 90)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 5)
tabLayout.Parent = tabContainer

-- Pages container
local pagesContainer = Instance.new("Frame")
pagesContainer.Size = UDim2.new(1, -20, 1, -150)
pagesContainer.Position = UDim2.new(0, 10, 0, 140)
pagesContainer.BackgroundTransparency = 1
pagesContainer.Parent = mainFrame

-- Hàm tạo tab
local function createTabButton(name)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 90, 1, 0)
    button.Text = name
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 12
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    button.AutoButtonColor = true
    button.Parent = tabContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    return button
end

-- Hàm tạo page
local function createPage(name)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = name.."Page"
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.Visible = false
    scroll.ScrollBarThickness = 5
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    scroll.Parent = pagesContainer
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = scroll
    
    return scroll
end

-- Hàm tạo nút feature
local function createFeatureButton(parent, text, yPos)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 45)
    button.Position = UDim2.new(0, 10, 0, yPos)
    button.Text = text
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    button.AutoButtonColor = true
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 200, 255)
    stroke.Thickness = 2
    stroke.Parent = button
    
    return button
end

-- ============== TẠO CÁC TAB ==============
local deepSaveTab = createTabButton("💾 DEEP SAVE")
local exportTab = createTabButton("📤 EXPORT")
local scriptTab = createTabButton("📜 SCRIPTS")
local modelTab = createTabButton("🏗️ MODELS")
local toolsTab = createTabButton("🔧 TOOLS")

local deepSavePage = createPage("DeepSave")
local exportPage = createPage("Export")
local scriptPage = createPage("Script")
local modelPage = createPage("Model")
local toolsPage = createPage("Tools")

-- Kích hoạt tab đầu
deepSavePage.Visible = true
deepSaveTab.BackgroundColor3 = Color3.fromRGB(0, 100, 200)

-- Tab switching
local function switchTab(tabName)
    deepSavePage.Visible = false
    exportPage.Visible = false
    scriptPage.Visible = false
    modelPage.Visible = false
    toolsPage.Visible = false
    
    deepSaveTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    exportTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    scriptTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    modelTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    toolsTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    
    if tabName == "DeepSave" then
        deepSavePage.Visible = true
        deepSaveTab.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    elseif tabName == "Export" then
        exportPage.Visible = true
        exportTab.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    elseif tabName == "Script" then
        scriptPage.Visible = true
        scriptTab.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    elseif tabName == "Model" then
        modelPage.Visible = true
        modelTab.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    elseif tabName == "Tools" then
        toolsPage.Visible = true
        toolsTab.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    end
end

deepSaveTab.MouseButton1Click:Connect(function() switchTab("DeepSave") end)
exportTab.MouseButton1Click:Connect(function() switchTab("Export") end)
scriptTab.MouseButton1Click:Connect(function() switchTab("Script") end)
modelTab.MouseButton1Click:Connect(function() switchTab("Model") end)
toolsTab.MouseButton1Click:Connect(function() switchTab("Tools") end)

-- ============== CÁC NÚT TÍNH NĂNG ==============

-- Deep Save Tab
local saveFullGameBtn = createFeatureButton(deepSavePage, "🔥 Save Full Game (Deep)", 10)
local saveModelsBtn = createFeatureButton(deepSavePage, "🏗️ Save All Models", 65)
local saveScriptsBtn = createFeatureButton(deepSavePage, "📜 Save All Scripts", 120)
local saveMapBtn = createFeatureButton(deepSavePage, "🗺️ Save Map Data", 175)
local saveRemotesBtn = createFeatureButton(deepSavePage, "📡 Save Remote Events", 230)
local saveGUIsBtn = createFeatureButton(deepSavePage, "🎨 Save GUIs", 285)
local saveSoundsBtn = createFeatureButton(deepSavePage, "🎵 Save Sounds", 340)

-- Export Tab
local exportRBXLBtn = createFeatureButton(exportPage, "📁 Export as .rbxl", 10)
local exportJSONBtn = createFeatureButton(exportPage, "📄 Export as JSON", 65)
local exportLuaBtn = createFeatureButton(exportPage, "📝 Export as Lua Modules", 120)
local exportStudioBtn = createFeatureButton(exportPage, "🔧 Studio-Compatible", 175)
local backupGameBtn = createFeatureButton(exportPage, "💾 Create Backup", 230)

-- Script Tab
local decompileAllBtn = createFeatureButton(scriptPage, "🔍 Decompile All Scripts", 10)
local viewScriptsBtn = createFeatureButton(scriptPage, "👁️ View Script Sources", 65)
local searchScriptsBtn = createFeatureButton(scriptPage, "🔎 Search in Scripts", 120)
local extractScriptsBtn = createFeatureButton(scriptPage, "📤 Extract All Scripts", 175)

-- Model Tab
local viewModelsBtn = createFeatureButton(modelPage, "👁️ View 3D Models", 10)
local cloneModelBtn = createFeatureButton(modelPage, "📋 Clone Model", 65)
local saveModelBtn = createFeatureButton(modelPage, "💾 Save Model as .rbxm", 120)
local modelInfoBtn = createFeatureButton(modelPage, "📊 Model Statistics", 175)

-- Tools Tab
local scanGameBtn = createFeatureButton(toolsPage, "🔍 Scan Game Structure", 10)
local viewStatsBtn = createFeatureButton(toolsPage, "📊 View Statistics", 65)
local debugModeBtn = createFeatureButton(toolsPage, "🐛 Debug Mode", 120)
local cleanupBtn = createFeatureButton(toolsPage, "🧹 Cleanup Cache", 175)

-- ============== DEEP SAVE FUNCTIONS ==============

-- Save Full Game (Deep)
saveFullGameBtn.MouseButton1Click:Connect(function()
    local startTime = tick()
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "🔥 DEEP SAVE STARTED",
        Text = "Scanning game structure...",
        Duration = 3
    })
    
    -- Tạo loading indicator
    local loadingFrame = Instance.new("Frame")
    loadingFrame.Size = UDim2.new(0, 300, 0, 100)
    loadingFrame.Position = UDim2.new(0.5, -150, 0.5, -50)
    loadingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    loadingFrame.Parent = screenGui
    
    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1, -20, 0, 50)
    loadingText.Position = UDim2.new(0, 10, 0, 10)
    loadingText.Text = "🔍 Scanning Game...\nPlease wait"
    loadingText.Font = Enum.Font.Gotham
    loadingText.TextSize = 14
    loadingText.TextColor3 = Color3.fromRGB(0, 255, 255)
    loadingText.BackgroundTransparency = 1
    loadingText.Parent = loadingFrame
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 0, 0, 20)
    progressBar.Position = UDim2.new(0, 10, 0, 70)
    progressBar.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
    progressBar.Parent = loadingFrame
    
    spawn(function()
        -- Thực hiện deep save
        local gameData = DeepSave:SaveFullGame()
        
        -- Cập nhật progress
        progressBar.Size = UDim2.new(0.5, 0, 0, 20)
        loadingText.Text = "💾 Saving Data...\nObjects: "..gameData.statistics.objects
        
        -- Lưu JSON data
        local filename = "DeepSave_"..game.PlaceId.."_"..os.time()..".json"
        local jsonData = HttpService:JSONEncode(gameData)
        writefile(filename, jsonData)
        
        -- Tạo RBXL file
        progressBar.Size = UDim2.new(0.75, 0, 0, 20)
        loadingText.Text = "📁 Creating RBXL file..."
        
        local rbxmContent = DeepSave:CreateRBXLFile(gameData)
        writefile("Game_"..game.PlaceId..".rbxlx", rbxmContent)
        
        -- Tạo Lua modules
        progressBar.Size = UDim2.new(1, -20, 0, 20)
        loadingText.Text = "📝 Creating Lua modules..."
        
        local folderName = "LuaModules_"..os.time()
        for _, serviceName in pairs({"Workspace", "ReplicatedStorage", "ServerScriptService"}) do
            local service = game:GetService(serviceName)
            if service then
                for _, obj in ipairs(service:GetDescendants()) do
                    if obj:IsA("ModuleScript") then
                        local moduleCode = DeepSave:CreateLuaModule(obj)
                        local safeName = string.gsub(obj.Name, "[^%w]", "_")
                        writefile(folderName.."/"..safeName..".lua", moduleCode)
                    end
                end
            end
        end
        
        -- Hoàn thành
        local elapsedTime = tick() - startTime
        
        loadingFrame:Destroy()
        
        game.StarterGui:SetCore("SendNotification", {
            Title = "✅ DEEP SAVE COMPLETE",
            Text = string.format("Saved %d objects in %.1f seconds\nFiles: %s, Game_%s.rbxlx, %s/",
                gameData.statistics.objects,
                elapsedTime,
                filename,
                game.PlaceId,
                folderName),
            Duration = 8
        })
        
        print("\n=== DEEP SAVE STATISTICS ===")
        print("Total Objects:", gameData.statistics.objects)
        print("Parts:", gameData.statistics.parts)
        print("Scripts:", gameData.statistics.scripts)
        print("Models:", gameData.statistics.models)
        print("Players:", gameData.statistics.players)
        print("Time:", string.format("%.2f seconds", elapsedTime))
        print("===========================\n")
    end)
end)

-- Save All Models
saveModelsBtn.MouseButton1Click:Connect(function()
    local models = {}
    local modelCount = 0
    
    -- Tìm tất cả models
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and #obj:GetChildren() > 0 then
            modelCount = modelCount + 1
            table.insert(models, {
                name = obj.Name,
                path = obj:GetFullName(),
                partCount = 0,
                model = obj
            })
        end
    end
    
    -- Lưu model data
    local modelData = {
        total = modelCount,
        models = models,
        timestamp = os.time(),
        placeId = game.PlaceId
    }
    
    local filename = "Models_"..game.PlaceId.."_"..os.time()..".json"
    writefile(filename, HttpService:JSONEncode(modelData))
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "🏗️ MODELS SAVED",
        Text = "Found "..modelCount.." models\nSaved to: "..filename,
        Duration = 5
    })
end)

-- Save All Scripts
saveScriptsBtn.MouseButton1Click:Connect(function()
    local scriptCount = 0
    local folderName = "Scripts_"..os.time()
    
    -- Thu thập và lưu scripts
    local services = {
        Workspace,
        ReplicatedStorage,
        ServerScriptService,
        ServerStorage,
        StarterPlayer,
        StarterPack,
        StarterGui
    }
    
    for _, service in ipairs(services) do
        for _, obj in ipairs(service:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                local success, source = pcall(function()
                    return obj.Source
                end)
                
                if success and source then
                    scriptCount = scriptCount + 1
                    local safeName = string.gsub(obj.Name, "[^%w]", "_")
                    local filename = folderName.."/"..safeName.."_"..scriptCount..".lua"
                    
                    local fileContent = "-- Script: "..obj.Name.."\n"
                    fileContent = fileContent .. "-- Class: "..obj.ClassName.."\n"
                    fileContent = fileContent .. "-- Path: "..obj:GetFullName().."\n"
                    fileContent = fileContent .. "-- Saved: "..os.date().."\n\n"
                    fileContent = fileContent .. source
                    
                    writefile(filename, fileContent)
                end
            end
        end
    end
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "📜 SCRIPTS SAVED",
        Text = "Saved "..scriptCount.." scripts to folder: "..folderName,
        Duration = 5
    })
end)

-- Export as .rbxl
exportRBXLBtn.MouseButton1Click:Connect(function()
    local xmlContent = DeepSave:CreateRBXLFile(DeepSave:SaveFullGame())
    local filename = "ExportedGame_"..game.PlaceId..".rbxlx"
    writefile(filename, xmlContent)
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "📁 RBXL EXPORTED",
        Text = "Saved as: "..filename.."\nCan open in Roblox Studio",
        Duration = 6
    })
end)

-- Decompile All Scripts
decompileAllBtn.MouseButton1Click:Connect(function()
    local scripts = {}
    local scriptCount = 0
    
    local function collectScripts(parent)
        for _, obj in ipairs(parent:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                local success, source = pcall(function()
                    return obj.Source
                end)
                
                if success and source then
                    scriptCount = scriptCount + 1
                    table.insert(scripts, {
                        name = obj.Name,
                        class = obj.ClassName,
                        path = obj:GetFullName(),
                        source = source,
                        lineCount = #string.split(source, "\n")
                    })
                end
            end
        end
    end
    
    collectScripts(game)
    
    -- Tạo viewer
    local viewerGui = Instance.new("ScreenGui")
    viewerGui.Name = "ScriptViewer"
    viewerGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 800, 0, 600)
    frame.Position = UDim2.new(0.5, -400, 0.5, -300)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.Parent = viewerGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.Text = "📜 Decompiled Scripts ("..scriptCount.." found)"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.BackgroundTransparency = 1
    title.Parent = frame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 10)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    closeBtn.AutoButtonColor = true
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function()
        viewerGui:Destroy()
    end)
    
    -- Script list
    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(0, 250, 1, -60)
    listFrame.Position = UDim2.new(0, 10, 0, 50)
    listFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    listFrame.Parent = frame
    
    local scrollList = Instance.new("ScrollingFrame")
    scrollList.Size = UDim2.new(1, -10, 1, -10)
    scrollList.Position = UDim2.new(0, 5, 0, 5)
    scrollList.BackgroundTransparency = 1
    scrollList.ScrollBarThickness = 5
    scrollList.Parent = listFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollList
    
    -- Script content
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -280, 1, -60)
    contentFrame.Position = UDim2.new(0, 270, 0, 50)
    contentFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    contentFrame.Parent = frame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -20, 1, -20)
    textBox.Position = UDim2.new(0, 10, 0, 10)
    textBox.Text = "Select a script to view..."
    textBox.Font = Enum.Font.Code
    textBox.TextSize = 12
    textBox.TextColor3 = Color3.new(1, 1, 1)
    textBox.BackgroundTransparency = 1
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.TextYAlignment = Enum.TextYAlignment.Top
    textBox.TextWrapped = false
    textBox.MultiLine = true
    textBox.TextEditable = false
    textBox.Parent = contentFrame
    
    -- Add scripts to list
    for i, scriptData in ipairs(scripts) do
        local scriptBtn = Instance.new("TextButton")
        scriptBtn.Size = UDim2.new(1, -10, 0, 35)
        scriptBtn.Position = UDim2.new(0, 5, 0, (i-1)*40)
        scriptBtn.Text = scriptData.name.." ("..scriptData.class..")"
        scriptBtn.Font = Enum.Font.Gotham
        scriptBtn.TextSize = 11
        scriptBtn.TextColor3 = Color3.new(1, 1, 1)
        scriptBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        scriptBtn.AutoButtonColor = true
        scriptBtn.Parent = scrollList
        
        scriptBtn.MouseButton1Click:Connect(function()
            textBox.Text = "-- "..scriptData.name.." ("..scriptData.class..")\n"
            textBox.Text = textBox.Text .. "-- Path: "..scriptData.path.."\n"
            textBox.Text = textBox.Text .. "-- Lines: "..scriptData.lineCount.."\n\n"
            textBox.Text = textBox.Text .. scriptData.source
        end)
    end
    
    scrollList.CanvasSize = UDim2.new(0, 0, 0, #scripts * 40)
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "🔍 DECOMPILED",
        Text = "Found "..scriptCount.." scripts",
        Duration = 3
    })
end)

-- View 3D Models
viewModelsBtn.MouseButton1Click:Connect(function()
    local models = {}
    
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
                    name = obj.Name,
                    partCount = partCount,
                    model = obj
                })
            end
        end
    end
    
    -- Tạo model viewer
    local viewerGui = Instance.new("ScreenGui")
    viewerGui.Name = "ModelViewer"
    viewerGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 500)
    frame.Position = UDim2.new(0.5, -200, 0.5, -250)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.Parent = viewerGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.Text = "🏗️ 3D Models ("..#models.." found)"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.BackgroundTransparency = 1
    title.Parent = frame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 10)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    closeBtn.AutoButtonColor = true
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function()
        viewerGui:Destroy()
    end)
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -60)
    scrollFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.Parent = frame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = scrollFrame
    
    for i, modelData in ipairs(models) do
        local modelFrame = Instance.new("Frame")
        modelFrame.Size = UDim2.new(1, -10, 0, 80)
        modelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        modelFrame.Parent = scrollFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.7, -10, 0, 30)
        nameLabel.Position = UDim2.new(0, 10, 0, 10)
        nameLabel.Text = "🔧 "..modelData.name
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Parent = modelFrame
        
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(0.7, -10, 0, 40)
        infoLabel.Position = UDim2.new(0, 10, 0, 40)
        infoLabel.Text = "Parts: "..modelData.partCount
        infoLabel.Font = Enum.Font.Gotham
        infoLabel.TextSize = 11
        infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Parent = modelFrame
        
        local viewBtn = Instance.new("TextButton")
        viewBtn.Size = UDim2.new(0.25, -10, 0, 30)
        viewBtn.Position = UDim2.new(0.75, 5, 0, 10)
        viewBtn.Text = "👁️ View"
        viewBtn.Font = Enum.Font.Gotham
        viewBtn.TextSize = 12
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
            
            game.StarterGui:SetCore("SendNotification", {
                Title = "👁️ VIEWING MODEL",
                Text = "Highlighting: "..modelData.name,
                Duration = 3
            })
        end)
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #models * 90)
end)

-- Scan Game Structure
scanGameBtn.MouseButton1Click:Connect(function()
    local stats = {
        parts = 0,
        scripts = 0,
        models = 0,
        lights = 0,
        sounds = 0,
        guis = 0,
        remotes = 0
    }
    
    local function scanObject(obj)
        if obj:IsA("BasePart") then
            stats.parts = stats.parts + 1
        elseif obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            stats.scripts = stats.scripts + 1
        elseif obj:IsA("Model") then
            stats.models = stats.models + 1
        elseif obj:IsA("Light") then
            stats.lights = stats.lights + 1
        elseif obj:IsA("Sound") then
            stats.sounds = stats.sounds + 1
        elseif obj:IsA("GuiObject") then
            stats.guis = stats.guis + 1
        elseif obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            stats.remotes = stats.remotes + 1
        end
        
        for _, child in ipairs(obj:GetChildren()) do
            scanObject(child)
        end
    end
    
    scanObject(game)
    
    local statsText = string.format(
        "📊 GAME STATISTICS:\n"..
        "• Parts: %d\n"..
        "• Scripts: %d\n"..
        "• Models: %d\n"..
        "• Lights: %d\n"..
        "• Sounds: %d\n"..
        "• GUIs: %d\n"..
        "• Remote Events: %d\n"..
        "• Total Players: %d",
        stats.parts, stats.scripts, stats.models,
        stats.lights, stats.sounds, stats.guis,
        stats.remotes, #Players:GetPlayers()
    )
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "🔍 SCAN COMPLETE",
        Text = statsText,
        Duration = 8
    })
end)

-- ============== MENU CONTROLS ==============
menuIcon.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Draggable menu
local dragging = false
local dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
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
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Thông báo load thành công
wait(2)
game.StarterGui:SetCore("SendNotification", {
    Title = "🔥 DUNG SKY HUB v3.0",
    Text = "Deep Game Saver loaded!\nClick 💾 icon to open menu",
    Duration = 8
})

print("\n=== DUNG SKY HUB DEEP SAVER v3.0 ===")
print("✅ Deep Save Engine: READY")
print("✅ Model Serializer: READY")
print("✅ Script Decompiler: READY")
print("✅ RBXL Exporter: READY")
print("✅ Game Scanner: READY")
print("===============================\n")