-- SkyHub Ultimate - Fixed Game Saver
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Kiểm tra writefile có tồn tại không
local function canSaveFiles()
    return type(writefile) == "function" and type(readfile) == "function" and type(listfiles) == "function"
end

-- ============== TẠO GIAO DIỆN ĐƠN GIẢN ==============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SkyHubSaver"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Menu Icon
local menuIcon = Instance.new("TextButton")
menuIcon.Name = "MenuIcon"
menuIcon.Size = UDim2.new(0, 50, 0, 50)
menuIcon.Position = UDim2.new(0, 20, 0.5, -25)
menuIcon.Text = "💾"
menuIcon.Font = Enum.Font.GothamBlack
menuIcon.TextSize = 24
menuIcon.TextColor3 = Color3.fromRGB(0, 255, 255)
menuIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
menuIcon.AutoButtonColor = true
menuIcon.Visible = true
menuIcon.Parent = screenGui

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 10)
iconCorner.Parent = menuIcon

-- Main Menu
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainMenu"
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 50)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Text = "💾 Game Saver v2.0"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(0, 255, 255)
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

-- ============== HÀM SAVE CƠ BẢN VÀ HOẠT ĐỘNG ==============

-- Hàm tạo nút đơn giản
local function createButton(parent, text, yPos)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = UDim2.new(0, 10, 0, yPos)
    button.Text = text
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    button.AutoButtonColor = true
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    return button
end

-- Tạo scroll frame cho các nút
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -70)
scrollFrame.Position = UDim2.new(0, 10, 0, 70)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 5
scrollFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.Parent = scrollFrame

-- ============== CÁC HÀM SAVE THỰC TẾ ==============

-- 1. Save Scripts từ một service
local function saveScriptsFromService(service, serviceName)
    if not canSaveFiles() then
        warn("Không thể save files trên executor này!")
        return 0
    end
    
    local scriptCount = 0
    local allScripts = {}
    
    -- Thu thập tất cả scripts
    for _, obj in ipairs(service:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local success, source = pcall(function()
                return obj.Source
            end)
            
            if success and source and #source > 0 then
                scriptCount = scriptCount + 1
                table.insert(allScripts, {
                    name = obj.Name,
                    class = obj.ClassName,
                    path = obj:GetFullName(),
                    source = source
                })
            end
        end
    end
    
    if scriptCount > 0 then
        -- Tạo folder
        local folderName = "Scripts_"..serviceName.."_"..os.time()
        
        -- Lưu từng script
        for i, scriptData in ipairs(allScripts) do
            local safeName = string.gsub(scriptData.name, "[^%w_]", "_")
            local filename = folderName.."/"..safeName..".lua"
            
            local content = "-- Script: "..scriptData.name.."\n"
            content = content .. "-- Type: "..scriptData.class.."\n"
            content = content .. "-- Path: "..scriptData.path.."\n"
            content = content .. "-- Saved: "..os.date().."\n\n"
            content = content .. scriptData.source
            
            writefile(filename, content)
        end
        
        -- Tạo index file
        local indexContent = "Total scripts: "..scriptCount.."\n\n"
        for i, scriptData in ipairs(allScripts) do
            indexContent = indexContent .. i..". "..scriptData.name.." ("..scriptData.class..")\n"
            indexContent = indexContent .. "   Lines: "..#string.split(scriptData.source, "\n").."\n"
        end
        
        writefile(folderName.."/_INDEX.txt", indexContent)
    end
    
    return scriptCount
end

-- 2. Save Model data
local function saveModelData()
    if not canSaveFiles() then return 0 end
    
    local models = {}
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local partCount = 0
            local children = {}
            
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("BasePart") then
                    partCount = partCount + 1
                    table.insert(children, {
                        name = child.Name,
                        class = child.ClassName,
                        position = {child.Position.X, child.Position.Y, child.Position.Z},
                        size = {child.Size.X, child.Size.Y, child.Size.Z}
                    })
                end
            end
            
            if partCount > 0 then
                table.insert(models, {
                    name = obj.Name,
                    partCount = partCount,
                    children = children
                })
            end
        end
    end
    
    if #models > 0 then
        local filename = "Models_"..os.time()..".json"
        writefile(filename, HttpService:JSONEncode({
            totalModels = #models,
            models = models,
            timestamp = os.time(),
            placeId = game.PlaceId
        }))
    end
    
    return #models
end

-- 3. Save Map Info
local function saveMapInfo()
    if not canSaveFiles() then return 0 end
    
    local parts = {}
    local partCount = 0
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            partCount = partCount + 1
            table.insert(parts, {
                name = obj.Name,
                position = {obj.Position.X, obj.Position.Y, obj.Position.Z},
                size = {obj.Size.X, obj.Size.Y, obj.Size.Z},
                color = {obj.Color.R, obj.Color.G, obj.Color.B}
            })
        end
    end
    
    local filename = "MapInfo_"..game.PlaceId..".json"
    writefile(filename, HttpService:JSONEncode({
        gameName = game.Name,
        placeId = game.PlaceId,
        totalParts = partCount,
        parts = parts,
        playerCount = #Players:GetPlayers()
    }))
    
    return partCount
end

-- 4. View Scripts trong UI
local function viewScriptsInUI()
    local scripts = {}
    
    -- Thu thập scripts từ Workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local success, source = pcall(function()
                return obj.Source
            end)
            
            if success and source and #source > 0 then
                table.insert(scripts, {
                    name = obj.Name,
                    type = obj.ClassName,
                    path = obj:GetFullName(),
                    source = source
                })
            end
        end
    end
    
    -- Thu thập từ ReplicatedStorage
    for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local success, source = pcall(function()
                return obj.Source
            end)
            
            if success and source and #source > 0 then
                table.insert(scripts, {
                    name = obj.Name,
                    type = obj.ClassName,
                    path = obj:GetFullName(),
                    source = source
                })
            end
        end
    end
    
    if #scripts == 0 then
        game.StarterGui:SetCore("SendNotification", {
            Title = "❌ No Scripts",
            Text = "No scripts found to view",
            Duration = 3
        })
        return
    end
    
    -- Tạo GUI xem scripts
    local viewerGui = Instance.new("ScreenGui")
    viewerGui.Name = "ScriptViewer"
    viewerGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 600, 0, 400)
    frame.Position = UDim2.new(0.5, -300, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.Parent = viewerGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.Text = "📜 Scripts Found: "..#scripts
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
    listFrame.Size = UDim2.new(0, 200, 1, -60)
    listFrame.Position = UDim2.new(0, 10, 0, 50)
    listFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
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
    contentFrame.Size = UDim2.new(1, -230, 1, -60)
    contentFrame.Position = UDim2.new(0, 220, 0, 50)
    contentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
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
    
    -- Thêm scripts vào list
    for i, scriptData in ipairs(scripts) do
        local scriptBtn = Instance.new("TextButton")
        scriptBtn.Size = UDim2.new(1, -10, 0, 30)
        scriptBtn.Text = scriptData.name
        scriptBtn.Font = Enum.Font.Gotham
        scriptBtn.TextSize = 11
        scriptBtn.TextColor3 = Color3.new(1, 1, 1)
        scriptBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        scriptBtn.AutoButtonColor = true
        scriptBtn.Parent = scrollList
        
        scriptBtn.MouseButton1Click:Connect(function()
            textBox.Text = "-- "..scriptData.name.." ("..scriptData.type..")\n"
            textBox.Text = textBox.Text .. "-- Path: "..scriptData.path.."\n"
            textBox.Text = textBox.Text .. "-- Lines: "..#string.split(scriptData.source, "\n").."\n\n"
            textBox.Text = textBox.Text .. scriptData.source
        end)
    end
    
    scrollList.CanvasSize = UDim2.new(0, 0, 0, #scripts * 35)
end

-- 5. Save Game Data đơn giản
local function saveSimpleGameData()
    if not canSaveFiles() then return false end
    
    local gameData = {
        gameName = game.Name,
        placeId = game.PlaceId,
        players = {},
        time = os.time(),
        date = os.date()
    }
    
    -- Player data
    for _, plr in ipairs(Players:GetPlayers()) do
        table.insert(gameData.players, {
            name = plr.Name,
            userId = plr.UserId,
            displayName = plr.DisplayName
        })
    end
    
    -- Map info
    local partCount = 0
    for _ in ipairs(Workspace:GetDescendants()) do
        partCount = partCount + 1
    end
    gameData.partCount = partCount
    
    -- Lưu file
    local filename = "GameData_"..game.PlaceId.."_"..os.time()..".json"
    local success, err = pcall(function()
        writefile(filename, HttpService:JSONEncode(gameData))
    end)
    
    return success
end

-- ============== TẠO CÁC NÚT CHỨC NĂNG ==============

-- Check file saving capability
if canSaveFiles() then
    -- Nút Save Scripts từ Workspace
    local saveWorkspaceScriptsBtn = createButton(scrollFrame, "📜 Save Workspace Scripts", 0)
    saveWorkspaceScriptsBtn.MouseButton1Click:Connect(function()
        local count = saveScriptsFromService(Workspace, "Workspace")
        game.StarterGui:SetCore("SendNotification", {
            Title = "✅ Saved",
            Text = "Saved "..count.." scripts from Workspace",
            Duration = 4
        })
    end)
    
    -- Nút Save ReplicatedStorage Scripts
    local saveReplicatedScriptsBtn = createButton(scrollFrame, "📦 Save ReplicatedStorage Scripts", 50)
    saveReplicatedScriptsBtn.MouseButton1Click:Connect(function()
        local count = saveScriptsFromService(game:GetService("ReplicatedStorage"), "ReplicatedStorage")
        game.StarterGui:SetCore("SendNotification", {
            Title = "✅ Saved",
            Text = "Saved "..count.." scripts from ReplicatedStorage",
            Duration = 4
        })
    end)
    
    -- Nút Save Models
    local saveModelsBtn = createButton(scrollFrame, "🏗️ Save Models Data", 100)
    saveModelsBtn.MouseButton1Click:Connect(function()
        local count = saveModelData()
        game.StarterGui:SetCore("SendNotification", {
            Title = "✅ Saved",
            Text = "Saved "..count.." models data",
            Duration = 4
        })
    end)
    
    -- Nút Save Map Info
    local saveMapBtn = createButton(scrollFrame, "🗺️ Save Map Info", 150)
    saveMapBtn.MouseButton1Click:Connect(function()
        local count = saveMapInfo()
        game.StarterGui:SetCore("SendNotification", {
            Title = "✅ Saved",
            Text = "Saved map with "..count.." parts",
            Duration = 4
        })
    end)
    
    -- Nút Save Game Data
    local saveGameBtn = createButton(scrollFrame, "💾 Save Game Data", 200)
    saveGameBtn.MouseButton1Click:Connect(function()
        local success = saveSimpleGameData()
        if success then
            game.StarterGui:SetCore("SendNotification", {
                Title = "✅ Game Saved",
                Text = "Game data saved successfully",
                Duration = 4
            })
        else
            game.StarterGui:SetCore("SendNotification", {
                Title = "❌ Error",
                Text = "Failed to save game data",
                Duration = 4
            })
        end
    end)
else
    -- Thông báo không thể save files
    local noSaveBtn = createButton(scrollFrame, "⚠️ Cannot Save Files", 0)
    noSaveBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    noSaveBtn.MouseButton1Click:Connect(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "❌ Warning",
            Text = "Your executor doesn't support file saving",
            Duration = 5
        })
    end)
end

-- Nút View Scripts (luôn hoạt động)
local viewScriptsBtn = createButton(scrollFrame, "👁️ View Scripts", 250)
viewScriptsBtn.MouseButton1Click:Connect(function()
    viewScriptsInUI()
end)

-- Nút Scan Game
local scanBtn = createButton(scrollFrame, "🔍 Scan Game", 300)
scanBtn.MouseButton1Click:Connect(function()
    local parts = 0
    local scripts = 0
    local models = 0
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            parts = parts + 1
        elseif obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            scripts = scripts + 1
        elseif obj:IsA("Model") then
            models = models + 1
        end
    end
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "📊 Game Scan",
        Text = "Parts: "..parts.."\nScripts: "..scripts.."\nModels: "..models,
        Duration = 6
    })
end)

-- ============== CONTROLS ==============
menuIcon.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Auto-adjust scroll frame size
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end)

-- Thông báo load thành công
wait(1)
game.StarterGui:SetCore("SendNotification", {
    Title = "💾 Game Saver v2.0",
    Text = "Loaded successfully! Click 💾 icon",
    Duration = 5
})

print("=== GAME SAVER v2.0 LOADED ===")
print("File saving supported:", canSaveFiles())
print("Ready to save scripts and game data!")
