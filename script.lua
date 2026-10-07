-- Roblox Auto Job BedilPusat (Delta Executor Compatible)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local isRunning = false

-- Fungsi Teleport Character atau Kendaraan
local function tpTo(targetPart)
    if not targetPart or not targetPart:IsA("BasePart") then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    
    -- Jika sedang mengendarai mobil, teleport kendaraannya
    if humanoid and humanoid.SeatPart and humanoid.SeatPart:IsA("VehicleSeat") then
        local vehicle = humanoid.SeatPart.Parent
        if vehicle and vehicle:IsA("Model") then
            vehicle:PivotTo(targetPart.CFrame * CFrame.new(0, 3, 0))
            return
        end
    end
    
    -- Teleport karakter biasa
    if root then
        root.CFrame = targetPart.CFrame * CFrame.new(0, 3, 0)
    end
end

-- Fungsi mencari Target yang memiliki indikator panah merah
local function getActiveTarget()
    local bedilPusat = Workspace:FindFirstChild("BediIPusat") or Workspace:FindFirstChild("BedilPusat")
    if not bedilPusat then return nil end
    
    local targetsFolder = bedilPusat:FindFirstChild("DeliveryTargets")
    if not targetsFolder then return nil end
    
    for _, target in pairs(targetsFolder:GetChildren()) do
        if target:IsA("BasePart") then
            -- Mencari UI, Beam, Attachment, atau Light panah merah di dalam Target
            for _, child in pairs(target:GetDescendants()) do
                if child:IsA("BillboardGui") or child:IsA("SurfaceGui") or child:IsA("Beam") or child:IsA("SelectionBox") then
                    if child.Enabled == true then
                        return target
                    end
                elseif child:IsA("GuiObject") or child:IsA("ImageLabel") then
                    if child.Visible == true then
                        return target
                    end
                end
            end
        end
    end
    
    -- Jika tidak ada panah aktif terdeteksi, ambil Target pertama yang ada
    return targetsFolder:FindFirstChild("Target")
end

-- Main Loop Auto Job
local function startAutoJob()
    task.spawn(function()
        while isRunning do
            local bedilPusat = Workspace:FindFirstChild("BediIPusat") or Workspace:FindFirstChild("BedilPusat")
            
            if bedilPusat then
                -- 1. Teleport Ambil Job
                local jobPart = bedilPusat:FindFirstChild("Job")
                if jobPart then
                    tpTo(jobPart)
                    task.wait(1.5)
                end
                
                -- 2. Teleport Mengikuti Panah Merah pada Target
                local targetPart = getActiveTarget()
                if targetPart then
                    tpTo(targetPart)
                    task.wait(1.5)
                end
                
                -- 3. Teleport Selesai (Finish)
                local finishPart = bedilPusat:FindFirstChild("Finish")
                if finishPart then
                    tpTo(finishPart)
                    task.wait(1.5)
                end
            end
            
            task.wait(0.5)
        end
    end)
end

-- Minimalist Floating GUI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "AutoJobGUI"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 150, 0, 80)
MainFrame.Active = true
MainFrame.Draggable = true

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = MainFrame

TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, 0, 0.4, 0)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "Auto Job Bedil"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15

ToggleButton.Parent = MainFrame
ToggleButton.Position = UDim2.new(0.1, 0, 0.45, 0)
ToggleButton.Size = UDim2.new(0.8, 0, 0.45, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16

UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        ToggleButton.Text = "ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        startAutoJob()
    else
        ToggleButton.Text = "OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)
