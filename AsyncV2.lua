local Library=loadstring(game:HttpGet("https://raw.githubusercontent.com/TynaRan/Decoder/refs/heads/main/cat%20(1).txt"))()
local Window=Library:CreateWindow("Async V2",Vector2.new(492,598),Enum.KeyCode.RightControl)
local AimingTab=Window:CreateTab("Aim Settings")
--Main Settings
local MainSection=AimingTab:CreateSector("Main Settings","left")
local ToggleAim=MainSection:AddToggle("Aim",true,function(state)_G.Enabled=state end)
local AutoAimToggle=MainSection:AddToggle("Enable Auto Aim",false,function(state)_G.AutoAim=state end)
local AutoHitToggle=MainSection:AddToggle("Enable Auto Hit",false,function(state)_G.AutoHit=state end)
local AimColor=MainSection:AddToggle("Custom Aim Color",false,function(state)_G.CustomColor=state end)
local AimColorPicker=AimColor:AddColorpicker(Color3.fromRGB(255,255,255),function(color)_G.AimColor=color end)
MainSection:AddSlider("Aim Size",8,16,50,1,function(size)_G.Size=size end)
MainSection:AddSlider("Aim Rotation",-180,-45,180,1,function(angle)_G.Rotation=angle end)
MainSection:AddToggle("Show Mouse",false,function(state)_G.ShowMouse=state end)
--Target Filters
local FilterSection=AimingTab:CreateSector("Target Filters","right")
FilterSection:AddToggle("Visibility Check",true,function(state)_G.VisibilityCheck=state end)
FilterSection:AddToggle("Health Check",true,function(state)_G.HealthCheck=state end)
FilterSection:AddSlider("Min Health %",0,0,100,1,function(health)_G.MinHealth=health end)
FilterSection:AddToggle("Team Check",true,function(state)_G.TeamCheck=state end)
FilterSection:AddDropdown("Priority Target",{"Head","HumanoidRootPart","Torso"},"Head",false,function(part)_G.PriorityPart=part end)
--Hit Effects
local EffectsSection=AimingTab:CreateSector("Hit Effects","left")
EffectsSection:AddToggle("Enable Hit Sound",true,function(state)_G.HitSound=state end)
EffectsSection:AddToggle("Enable Hit Effect",true,function(state)_G.HitEffect=state end)
local EffectColor=EffectsSection:AddToggle("Custom Effect Color",false,function(state)_G.CustomEffectColor=state end)
local EffectColorPicker=EffectColor:AddColorpicker(Color3.fromRGB(255,0,0),function(color)_G.EffectColor=color end)
EffectsSection:AddSlider("Effect Duration",0.1,0.5,2,0.1,function(duration)_G.EffectDuration=duration end)
--Damage Settings
local DamageSection=AimingTab:CreateSector("Damage Settings","right")
DamageSection:AddToggle("Damage Players",true,function(state)_G.DamagePlayers=state end)
DamageSection:AddToggle("Damage NPCs",true,function(state)_G.DamageNPCs=state end)
DamageSection:AddTextbox("Damage Event Name","GUN_DAMAGE",function(text)_G.EventName=text end)
--Initialize
_G.Enabled=true
_G.AutoAim=false
_G.AutoHit=false
_G.Size=16
_G.Rotation=-45
_G.AimColor=Color3.fromRGB(255,255,255)
_G.CustomColor=false
_G.ShowMouse=false
_G.VisibilityCheck=true
_G.HealthCheck=true
_G.MinHealth=0
_G.TeamCheck=true
_G.PriorityPart="Head"
_G.HitSound=true
_G.HitEffect=true
_G.EffectColor=Color3.fromRGB(255,0,0)
_G.CustomEffectColor=false
_G.EffectDuration=0.5
_G.DamagePlayers=true
_G.DamageNPCs=true
_G.EventName="GUN_DAMAGE"
--Core
local Players=game:GetService("Players")
local player=Players.LocalPlayer
local mouse=player:GetMouse()
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local livingThings=workspace:WaitForChild("LivingThings")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local Camera=workspace.CurrentCamera
UserInputService.MouseIconEnabled=_G.ShowMouse
local triangle=Drawing.new("Triangle")
triangle.Visible=_G.Enabled
triangle.Color=_G.CustomColor and _G.AimColor or Color3.fromRGB(255,255,255)
triangle.Thickness=1
triangle.Filled=true
--Functions
local function isVisible(targetPart)
if not _G.VisibilityCheck then return true end
local origin=Camera.CFrame.Position
local target=targetPart.Position
local direction=(target-origin).Unit*1000
local ray=Ray.new(origin,direction)
local hitPart=workspace:FindPartOnRayWithIgnoreList(ray,{player.Character,Camera})
return hitPart and hitPart:IsDescendantOf(targetPart.Parent)
end
local function isValidTarget(target)
if not target:FindFirstChild("Humanoid") then return false end
if _G.HealthCheck and target.Humanoid.Health<=(_G.MinHealth/100*target.Humanoid.MaxHealth) then return false end
if _G.TeamCheck and Players:GetPlayerFromCharacter(target) and Players:GetPlayerFromCharacter(target).Team==player.Team then return false end
return true
end
local function findBestTarget()
if not _G.AutoAim then return nil end
local closestTarget=nil
local closestDistance=math.huge
for _,target in ipairs(Players:GetPlayers())do
if target~=player and target.Character and isValidTarget(target.Character)then
local targetPart=target.Character:FindFirstChild(_G.PriorityPart)
if targetPart and isVisible(targetPart)then
local distance=(targetPart.Position-player.Character.HumanoidRootPart.Position).Magnitude
if distance<closestDistance then
closestDistance=distance
closestTarget=targetPart
end end end end
if _G.DamageNPCs then
for _,npc in ipairs(livingThings:GetChildren())do
if npc:FindFirstChild("Humanoid")and isValidTarget(npc)then
local targetPart=npc:FindFirstChild(_G.PriorityPart)or npc:FindFirstChild("HumanoidRootPart")
if targetPart and isVisible(targetPart)then
local distance=(targetPart.Position-player.Character.HumanoidRootPart.Position).Magnitude
if distance<closestDistance then
closestDistance=distance
closestTarget=targetPart
end end end end end
return closestTarget
end
local function doDamage(target)
if _G.HitSound then
local hitSound=Instance.new("Sound")
hitSound.SoundId="rbxassetid://160432334"
hitSound.Parent=target
hitSound:Play()
end
if _G.HitEffect then
local hitEffect=Instance.new("Part")
hitEffect.Name="BulletTracer"
hitEffect.Transparency=0.3
hitEffect.Size=Vector3.new(0.15,0.15,(player.Character.HumanoidRootPart.Position-target.Position).Magnitude)
hitEffect.Color=_G.CustomEffectColor and _G.EffectColor or Color3.fromRGB(255,50,50)
hitEffect.Material=Enum.Material.Neon
hitEffect.CanCollide=false
hitEffect.Anchored=true
hitEffect.CastShadow=false
local pointLight=Instance.new("PointLight")
pointLight.Brightness=5
pointLight.Range=5
pointLight.Color=hitEffect.Color
pointLight.Parent=hitEffect
local startPos=player.Character.HumanoidRootPart.Position
local endPos=target.Position
hitEffect.CFrame=CFrame.new(startPos,endPos)*CFrame.new(0,0,-hitEffect.Size.Z/2)
hitEffect.Parent=workspace
game:GetService("Debris"):AddItem(hitEffect,_G.EffectDuration)
spawn(function()
local fadeTime=0.3
local startTime=tick()
while tick()-startTime<fadeTime do
hitEffect.Transparency=0.3+(0.7*((tick()-startTime)/fadeTime))
task.wait()
end
end)
end
local args={_G.EventName,target.Parent}
ReplicatedStorage:WaitForChild("NetworkEvents"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end
local function getTrianglePoints(center)
local size=_G.Size
local angle=math.rad(_G.Rotation)
local points={Vector2.new(0,-size),Vector2.new(-size,size),Vector2.new(size,size)}
local cos,sin=math.cos(angle),math.sin(angle)
for i,point in ipairs(points)do
points[i]=Vector2.new(point.X*cos-point.Y*sin+center.X,point.X*sin+point.Y*cos+center.Y)
end
return points
end
--Main Loop
RunService.Heartbeat:Connect(function()
UserInputService.MouseIconEnabled=_G.ShowMouse
triangle.Visible=_G.Enabled
triangle.Color=_G.CustomColor and _G.AimColor or Color3.fromRGB(255,255,255)
local targetPos
if _G.AutoAim then
local target=findBestTarget()
targetPos=target and Camera:WorldToViewportPoint(target.Position)
if _G.AutoHit and target then doDamage(target)end
end
local mouseLocation=targetPos and Vector2.new(targetPos.X,targetPos.Y)or Vector2.new(mouse.X,mouse.Y)
local points=getTrianglePoints(mouseLocation)
triangle.PointA=points[1]
triangle.PointB=points[2]
triangle.PointC=points[3]
end)
mouse.Button1Down:Connect(function()
local target=mouse.Target
if not target then return end
local hitCharacter=target.Parent
if not hitCharacter:IsA("Model")then return end
if hitCharacter:FindFirstChild("Humanoid")and _G.DamagePlayers then
local hitPlayer=Players:GetPlayerFromCharacter(hitCharacter)
if hitPlayer and isValidTarget(hitCharacter)then doDamage(target)end
end
if hitCharacter:FindFirstChild("HumanoidRootPart")and _G.DamageNPCs and isValidTarget(hitCharacter)then
if not Players:GetPlayerFromCharacter(hitCharacter)then
hitCharacter.Name="NPC_"..tostring(math.random(1000,9999))
end
doDamage(hitCharacter:FindFirstChild("HumanoidRootPart"))
end
end)
