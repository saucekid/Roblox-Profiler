if profiler then profiler:Destroy() profiler = nil end

-- // <Constants>
local getAsset = getsynasset or getcustomasset
local request = request or syn.request

local UserInputService = game:GetService("UserInputService");
local RunService = game:GetService("RunService");
local Players = game:GetService("Players");

local LocalPlayer = Players.LocalPlayer;
local CurrentCamera = workspace.CurrentCamera;
local Mouse = LocalPlayer:GetMouse();

function getRAP(plr)
    local g = request({
        Url = "https://inventory.roblox.com/v1/users/" .. plr.UserId .. "/assets/collectibles?sortOrder=Asc&limit=100",
        Method = "GET"
    })
    g = game:GetService("HttpService"):JSONDecode(g.Body)
    local rap = 0
    if g.data then
        for i, v in pairs(g.data) do
            rap = rap + v.recentAveragePrice
        end
    end
    return (rap)
end

function typeWrite(obj, text)
    local GoalLength = #text
    local TimeToTake = GoalLength / 30
    local Accumulated = 0

    local frameSize = UDim2.new(0, 10 * GoalLength, 0, obj.Size.Y.Offset)
    obj.Size = UDim2.new(0, 0, 0, obj.Size.Y.Offset)
    obj:TweenSize(frameSize, Enum.EasingDirection.In, Enum.EasingStyle.Sine, TimeToTake)

    task.spawn(function()
        while TimeToTake > Accumulated do
            Accumulated = Accumulated + RunService.Heartbeat:Wait()
            obj.Text = string.sub(text, 1, math.floor((Accumulated / TimeToTake) * GoalLength))
        end
    end)
end

local path = "https://raw.githubusercontent.com/saucekid/Ro-Profiler/main/"


local Terpy = loadstring(game:HttpGet(path .. "modules/Terpy.lua"))()
local Highlight = loadstring(game:HttpGet(path .. "modules/Highlight.lua"))()


-- // <Files & Assets>
local folder = "Ro-Profiler";

local function getGitAsset(p) --this shit sucks help
    local folderPath = folder.. "/".. p
    local gitPath = path.. p
    local req = request({
        Url = gitPath,
        Method = "GET"
    })
    writefile(folderPath, req.Body)
end

if (not isfolder(folder)) then
    makefolder(folder)
    makefolder(folder .. "/assets")
    makefolder(folder .. "/assets/images")
    makefolder(folder .. "/assets/videos")
end

--BRUH IS THERE ANY OTHER WAY TO DO THIS
getGitAsset("assets/Profiler.rbxm")
getGitAsset("assets/images/checkers.png") 
getGitAsset("assets/images/Skull.png")
getGitAsset("assets/images/RAP.png")
getGitAsset("assets/images/Frame.png")
getGitAsset("assets/images/Teleport.png")
getGitAsset("assets/images/Friend.png")
getGitAsset("assets/videos/Glitch.webm")

local profilerPart, profilerGui = game:GetObjects(getAsset(folder .. "/assets/Profiler.rbxm"))[1] do
    profilerPart.Transparency = 1
    profilerPart.Parent = CurrentCamera
    profilerGui = profilerPart:WaitForChild("ProfilerGui").BackgroundFrame;
end

local images = {} do
    for _, img in next, listfiles(folder .. "/assets/images") do
        local assetID = getAsset(img)
        images[img:sub(27):gsub(".png", "")] = assetID
    end
end

local videos = {} do
    for _, img in next, listfiles(folder .. "/assets/videos") do
        local assetID = getAsset(img)
        videos[img:sub(27):gsub(".webm", "")] = assetID
    end
end

-- // <Profiler>
getgenv().profiler = {}

profiler.Offset = CFrame.new(5, 0, -15)
profiler.Occupations = {
        "Professional Skater",
        "Monkey Catcher",
        "Lawyer",
        "Developer (sucks)",
        "Gangster",
        "Daycare Worker",
        "Factory Worker",
        "Sign Holder",
        "Hacker",
        "Fencing Master",
        "Mafia Boss",
        "Hash-Slinging Slasher",
        "Freeloader",
        "Prostitute",
        "Shoe-maker",
        "Grass toucher",
        "Food tester"
}

profiler.Interests = {
        "Hasn't touched grass",
        "Skilled Sword Fighter",
        "Huffs paint",
        "Out on parole",
        "Anime watcher",
        "Big boobies",
        "Served 10 years in prison",
        "Video-game addict",
        "Father left at the age of 2",
        "Chronically Depressed",
        "Wanks to MILFs",
        "Milf-Enjoyer",
        "Birthday Boy"

}

profiler.Highlight = Highlight.create(workspace.Terrain, {
        Enabled = true,
        FillTransparency = 1,
        OutlineColor = Color3.new(1, 1, 1),
})
profiler.Terpy = Terpy.new(profilerGui.Parent)

profiler.Target = nil
profiler.TargetEvent = Instance.new("BindableEvent")
profiler.Visible = true

profiler.Assets = {
    BackgroundVideo = profilerGui.VideoFrame,
    ProfileImage = profilerGui.ProfileImage,
    ProfileFrame = profilerGui.ProfileImage.Frame,
    InfoFrame = profilerGui.InfoFrame,
    ColorTargets = {
        { ["Target"] = profilerGui.ProfileImage.Frame, ["Change"] = "ImageColor3" },
        { ["Target"] = profilerGui.ProfileImage.InfoImage, ["Change"] = "BackgroundColor3" },
        { ["Target"] = profilerGui.ProfileImage.InfoImage2, ["Change"] = "BackgroundColor3" },
    }
}

profiler.Info = {
        Image = profilerGui.ProfileImage,
        Name = profilerGui.InfoFrame:FindFirstChild("Name"),
        Age = profilerGui.InfoFrame.Age,
        Interest = profilerGui.InfoFrame.Interest,
        Occupation = profilerGui.InfoFrame.Occupation,
        RAP = profilerGui.InfoFrame.RAP,
        InfoImage = profilerGui.ProfileImage.InfoImage,
        InfoImage2 = profilerGui.ProfileImage.InfoImage2
}

profiler.Modes = {
        ["Default"] = {
            Color = Color3.fromRGB(0, 0, 0),
            check = function() return true end,
            func = function()
                profiler.Info.InfoImage.Visible = false
                profiler.Info.InfoImage2.Visible = false
            end,
            Priority = 1
        },
        ["Dead"] = {
            Color = Color3.fromRGB(219, 57, 60),
            check = function(plr)
                if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") and
                    plr.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
                    return true
                end
                return false
            end,
            func = function(self)
                profiler.Info.InfoImage.Visible = true
                profiler.Info.InfoImage2.Visible = false
            end,
            Priority = 10
        },
        ["RAP"] = {
            Color = Color3.fromRGB(2, 196, 255),
            check = function(plr)
                if plr.RAP > 0 then
                    return true
                end
                return false
            end,
            func = function(self)
                profiler.Info.InfoImage.Visible = false
                profiler.Info.InfoImage2.Visible = true
            end,
            Priority = 2
        },
        ["Friend"] = {
            Color = Color3.fromRGB(70, 140, 0),
            check = function(plr)
                if LocalPlayer:IsFriendsWith(plr.UserId) then
                    return true
                end
                return false
            end,
            func = function(self)
                profiler.Info.InfoImage.Visible = false
                profiler.Info.InfoImage2.Visible = true
            end,
            Priority = 3
        }
}

function profiler:GetRandomInterest()
    return self.Interests[math.random(1, #self.Interests)]
end

function profiler:GetRandomOccupation()
    return self.Occupations[math.random(1, #self.Occupations)]
end

function profiler:SetVisible(visibility, tween)
    if visibility ~= self.Visible then
        self.Visible = visibility
        self.Assets.BackgroundVideo.Visible = visibility
        local transparency = visibility and 0 or 1
        if tween then
            self.Terpy:TweenTransparency(TweenInfo.new(.3), transparency)
        else
            self.Terpy:SetTransparency(transparency, true)
        end
    end
end

function profiler:SetColor(color, name)
    local brightness = (color.R + color.G + color.B) / 3
    self.Info.InfoImage.Color = brightness >= 0.5 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
    self.Info.InfoImage2.Color = brightness >= 0.5 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
    for _, t in pairs(self.Assets.ColorTargets) do
        t.Target[t.Change] = color
    end
    for _, t in pairs(self.Assets.ColorTargets) do
        t.Target[t.Change] = color
    end
end

function profiler:Destroy()
    profilerPart:Destroy()
    self.TargetEvent:Destroy()
    self.Highlight:Destroy()
    self.profilerCon:Disconnect()
    self.controlCon:Disconnect()
    self.OnTarget:Disconnect()
end

function profiler:SetTarget(chr)
    local plr = Players:GetPlayerFromCharacter(chr)
    if plr and self.Target ~= chr then
        self.Target = chr
        local plrInfo = {
            Name = plr.Name,
            DisplayName = plr.DisplayName,
            RAP = getRAP(plr),
            Character = chr,
            UserId = plr.UserId,
            Team = plr.Team,
            Age = plr.AccountAge,
            Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. plr.UserId .. "&width=50&height=50&format=png"
        }
        self.TargetEvent:Fire(plrInfo)
    end
end
    
profiler.OnTarget = profiler.TargetEvent.Event:Connect(function(plrInfo)
    local passed = {}
    for _, mode in pairs(profiler.Modes) do
        local check = mode.check(plrInfo)
        if check then
            table.insert(passed, mode)
        end
    end
    local highestPriority = 0
    local currentMode
    for _, mode in pairs(passed) do
        if mode.Priority > highestPriority then
            highestPriority = mode.Priority
            currentMode = mode
        end
    end
    currentMode.func(profiler)
    profiler:SetColor(currentMode.Color)
    
    profiler.Info.Image.Image = plrInfo.Image
    typeWrite(profiler.Info.Name, plrInfo.DisplayName ~= plrInfo.Name and " " .. plrInfo.DisplayName .. " @" .. plrInfo.Name or " " .. plrInfo.Name)
    typeWrite(profiler.Info.Age, " Age: " .. tostring(plrInfo.Age))
    typeWrite(profiler.Info.RAP, " RAP: " .. tostring(plrInfo.RAP))
    typeWrite(profiler.Info.Interest, " " .. profiler:GetRandomInterest())
    typeWrite(profiler.Info.Occupation, " Occupation: " .. profiler:GetRandomOccupation())
    task.wait(0.2)
    profiler:SetVisible(true, true)
end)

profiler.profilerCon = RunService.RenderStepped:Connect(function(dt)
    profilerPart.CFrame = profilerPart.CFrame:Lerp(CFrame.new(profilerPart.Position, CurrentCamera.CFrame.Position),
        dt * 2)
    profilerPart.Position = (CurrentCamera.CFrame * profiler.Offset).Position
    
    if profiler.Target then
        profiler.Highlight:Edit({
            Adornee = profiler.Target,
            Enabled = true,
        })

        if CurrentCamera:WorldToScreenPoint(profiler.Target:GetPivot().Position).Z < 0 then
            profiler.Target = nil
        end
    else
        profiler:SetVisible(false, true)

        local mouseTarget = Mouse.Target
        if mouseTarget and mouseTarget.Parent:FindFirstChildOfClass("Humanoid") and
            mouseTarget.Parent ~= LocalPlayer.Character then
            profiler.Highlight:Edit({
                Adornee = mouseTarget.Parent,
                Enabled = true,
            })
        else
            profiler.Highlight:Edit({
                Adornee = nil,
                Enabled = false,
            })
        end
    end
end)

profiler.controlCon = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mouseTarget = Mouse.Target
        if mouseTarget and (mouseTarget.Parent:FindFirstChildOfClass("Humanoid") or mouseTarget.Parent.Parent:FindFirstChildOfClass("Humanoid")) and mouseTarget.Parent ~= LocalPlayer.Character then
            local chr = mouseTarget.Parent:FindFirstChildOfClass("Humanoid") and mouseTarget.Parent or mouseTarget.Parent.Parent
            profiler:SetTarget(chr)
        else
            profiler.Target = nil
            profiler:SetVisible(false, true)
        end
    end
end)

function profiler:Init()
    self:SetVisible(false)
    self.Assets.BackgroundVideo.Video = videos.Glitch
    self.Assets.BackgroundVideo.Looped = true
    self.Assets.BackgroundVideo.Playing = true
    self.Assets.BackgroundVideo.Volume = 0
end

profiler:Init()

return profiler
