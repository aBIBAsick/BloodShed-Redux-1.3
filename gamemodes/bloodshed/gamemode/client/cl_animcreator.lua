local PANEL = {}

function PANEL:Init()
    self:SetSize(800, 570)
    self:SetTitle("Animation Creator")
    self:Center()
    self:MakePopup()
    self.Paint = function(self,w,h)
        surface.SetDrawColor(0, 0, 0, 240)
        surface.DrawRect(0,0,w,h)
    end
    self:ShowCloseButton(false)

    self.ExitBtn = vgui.Create("DButton", self)
    self.ExitBtn:SetSize(60, 20)
    self.ExitBtn:SetPos(self:GetWide() - 80, 5)
    self.ExitBtn:SetText("Exit")
    self.ExitBtn:SetTextColor(Color(255, 100, 100))
    self.ExitBtn.DoClick = function()
        self:ShowExitConfirmation()
    end
    
    self.Bones = {}
    self.CurrentFrame = 1
    self.Frames = {[1] = {}}
    self.PlaySpeed = 1
    self.IsPlaying = false
    
    self.BonePanel = vgui.Create("DPanel", self)
    self.BonePanel:SetSize(200, 400)
    self.BonePanel:SetPos(10, 50)
    self.BonePanel:SetBackgroundColor(Color(20,20,35))
    
    self.BoneList = vgui.Create("DListView", self.BonePanel)
    self.BoneList:Dock(FILL)
    self.BoneList:AddColumn("Bone Name")
    self.BoneList:SetMultiSelect(false)
    self.BoneList.OnRowSelected = function(_, _, row)
        self.SelectedBone = row:GetValue(1)
        self:UpdateRotationControls()
    end
    
    self:PopulateBoneList()
    
    self.RotationPanel = vgui.Create("DPanel", self)
    self.RotationPanel:SetSize(200, 200)
    self.RotationPanel:SetPos(220, 50)
    self.RotationPanel:SetBackgroundColor(Color(20,20,35))

    self.ResetBoneBtn = vgui.Create("DButton", self.RotationPanel)
    self.ResetBoneBtn:SetPos(10, 160)
    self.ResetBoneBtn:SetSize(180, 25)
    self.ResetBoneBtn:SetText("Reset Selected Bone")
    self.ResetBoneBtn.DoClick = function()
        if self.SelectedBone then
            self:ResetBone(self.SelectedBone)
        end
    end
    
    self.PitchSlider = vgui.Create("DNumSlider", self.RotationPanel)
    self.PitchSlider:SetPos(10, 0)
    self.PitchSlider:SetSize(180, 50)
    self.PitchSlider:SetText("Pitch")
    self.PitchSlider:SetMin(-180)
    self.PitchSlider:SetMax(180)
    self.PitchSlider:SetDecimals(1)
    self.PitchSlider.OnValueChanged = function(_, value)
        if self.SelectedBone then
            self:UpdateBoneRotation(self.SelectedBone, "pitch", value)
        end
    end
    
    self.YawSlider = vgui.Create("DNumSlider", self.RotationPanel)
    self.YawSlider:SetPos(10, 50)
    self.YawSlider:SetSize(180, 50)
    self.YawSlider:SetText("Yaw")
    self.YawSlider:SetMin(-180)
    self.YawSlider:SetMax(180)
    self.YawSlider:SetDecimals(1)
    self.YawSlider.OnValueChanged = function(_, value)
        if self.SelectedBone then
            self:UpdateBoneRotation(self.SelectedBone, "yaw", value)
        end
    end
    
    self.RollSlider = vgui.Create("DNumSlider", self.RotationPanel)
    self.RollSlider:SetPos(10, 100)
    self.RollSlider:SetSize(180, 50)
    self.RollSlider:SetText("Roll")
    self.RollSlider:SetMin(-180)
    self.RollSlider:SetMax(180)
    self.RollSlider:SetDecimals(1)
    self.RollSlider.OnValueChanged = function(_, value)
        if self.SelectedBone then
            self:UpdateBoneRotation(self.SelectedBone, "roll", value)
        end
    end
    
    self.FramePanel = vgui.Create("DPanel", self)
    self.FramePanel:SetSize(780, 100)
    self.FramePanel:SetPos(10, 460)
    self.FramePanel:SetBackgroundColor(Color(20,20,35))
    
    self.FrameSlider = vgui.Create("DNumSlider", self.FramePanel)
    self.FrameSlider:SetPos(10, 10)
    self.FrameSlider:SetSize(380, 30)
    self.FrameSlider:SetText("Frame")
    self.FrameSlider:SetMin(1)
    self.FrameSlider:SetMax(30)
    self.FrameSlider:SetDecimals(0)
    self.FrameSlider:SetValue(1)
    self.FrameSlider.OnValueChanged = function(_, value)
        self:ChangeFrame(math.floor(value))
    end
    
    self.AddFrameBtn = vgui.Create("DButton", self.FramePanel)
    self.AddFrameBtn:SetPos(400, 10)
    self.AddFrameBtn:SetSize(80, 30)
    self.AddFrameBtn:SetText("Add Frame")
    self.AddFrameBtn.DoClick = function()
        self:AddFrame()
    end
    
    self.DeleteFrameBtn = vgui.Create("DButton", self.FramePanel)
    self.DeleteFrameBtn:SetPos(490, 10)
    self.DeleteFrameBtn:SetSize(80, 30)
    self.DeleteFrameBtn:SetText("Delete Frame")
    self.DeleteFrameBtn.DoClick = function()
        self:DeleteFrame()
    end
    
    self.PlayBtn = vgui.Create("DButton", self.FramePanel)
    self.PlayBtn:SetPos(10, 50)
    self.PlayBtn:SetSize(80, 30)
    self.PlayBtn:SetText("Play")
    self.PlayBtn.DoClick = function()
        self:TogglePlayback()
    end
    
    self.SpeedSlider = vgui.Create("DNumSlider", self.FramePanel)
    self.SpeedSlider:SetPos(100, 50)
    self.SpeedSlider:SetSize(250, 30)
    self.SpeedSlider:SetText("Speed")
    self.SpeedSlider:SetMin(0.1)
    self.SpeedSlider:SetMax(5)
    self.SpeedSlider:SetDecimals(2)
    self.SpeedSlider:SetValue(1)
    self.SpeedSlider.OnValueChanged = function(_, value)
        self.PlaySpeed = value
    end
    
    self.SaveBtn = vgui.Create("DButton", self.FramePanel)
    self.SaveBtn:SetPos(360, 50)
    self.SaveBtn:SetSize(100, 30)
    self.SaveBtn:SetText("Save Animation")
    self.SaveBtn.DoClick = function()
        self:SaveAnimation()
    end
    
    self.LoadBtn = vgui.Create("DButton", self.FramePanel)
    self.LoadBtn:SetPos(470, 50)
    self.LoadBtn:SetSize(100, 30)
    self.LoadBtn:SetText("Load Animation")
    self.LoadBtn.DoClick = function()
        self:LoadAnimation()
    end

    self.DeleteAnimBtn = vgui.Create("DButton", self.FramePanel)
    self.DeleteAnimBtn:SetPos(610, 50)
    self.DeleteAnimBtn:SetSize(150, 30)
    self.DeleteAnimBtn:SetText("Delete Saved")
    self.DeleteAnimBtn.DoClick = function()
        self:DeleteSavedAnimation()
    end

    self.ResetAllBonesBtn = vgui.Create("DButton", self.FramePanel)
    self.ResetAllBonesBtn:SetPos(610, 10)
    self.ResetAllBonesBtn:SetSize(150, 30)
    self.ResetAllBonesBtn:SetText("Reset Bones in Frame")
    self.ResetAllBonesBtn.DoClick = function()
        self:ResetAllBones()
    end
    
    self.PreviewPanel = vgui.Create("DModelPanel", self)
    self.PreviewPanel:SetSize(350, 370)
    self.PreviewPanel:SetPos(430, 30)
    self.PreviewPanel:SetModel(LocalPlayer():GetModel() or "models/player/Group01/male_07.mdl")
    self.PreviewPanel:SetLookAt(Vector(0, 0, 56))
    self.PreviewPanel:SetCamPos(Vector(50, 50, 50))
    self.PreviewPanel:SetFOV(50)
    self.PreviewPanel.PaintOver = function(self,w,h)
        surface.SetDrawColor(255,255,255)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    self.PreviewPanel.Angles = Angle(0, 0, 0)
    self.PreviewPanel.IsMouseDown = false
    self.PreviewPanel.LastMouseX = 0
    self.PreviewPanel.LastMouseY = 0

    function self.PreviewPanel:LayoutEntity(Entity)
        if self.bAnimated then
            self:RunAnimation()
        end
        
        if self.IsMouseDown then
            local x, y = gui.MousePos()
            local dx = x - self.LastMouseX
            local dy = y - self.LastMouseY
            
            self.LastMouseX = x
            self.LastMouseY = y
            
            self.Angles.pitch = math.Clamp(self.Angles.pitch - dy * 0.5, -89, 89)
            self.Angles.yaw = self.Angles.yaw - dx * 0.5
            
            local rad = math.rad(self.Angles.yaw)
            local radius = 100
            local origin = Vector(0, 0, 56)
            local campos = Vector(
                origin.x + math.sin(rad) * radius,
                origin.y + math.cos(rad) * radius,
                origin.z + math.tan(math.rad(self.Angles.pitch)) * radius
            )
            
            self:SetCamPos(campos)
            self:SetLookAt(origin)
        end

        return
    end

    self.PreviewPanel.OnMousePressed = function(pnl, keyCode)
        if keyCode == MOUSE_LEFT then
            pnl.IsMouseDown = true
            local x, y = gui.MousePos()
            pnl.LastMouseX = x
            pnl.LastMouseY = y
        end
    end

    self.PreviewPanel.OnMouseReleased = function(pnl, keyCode)
        if keyCode == MOUSE_LEFT then
            pnl.IsMouseDown = false
        end
    end
    
    self.ZoomSlider = vgui.Create("DNumSlider", self)
    self.ZoomSlider:SetPos(430, 410)
    self.ZoomSlider:SetSize(350, 20)
    self.ZoomSlider:SetText("Zoom")
    self.ZoomSlider:SetMin(10)
    self.ZoomSlider:SetMax(100)
    self.ZoomSlider:SetDecimals(0)
    self.ZoomSlider:SetValue(50)
    self.ZoomSlider.OnValueChanged = function(_, value)
        self.PreviewPanel:SetFOV(value)
    end
    
    self.ResetCameraBtn = vgui.Create("DButton", self)
    self.ResetCameraBtn:SetPos(625, 435)
    self.ResetCameraBtn:SetSize(80, 20)
    self.ResetCameraBtn:SetText("Reset View")
    self.ResetCameraBtn.DoClick = function()
        self:ResetCamera()
    end
    
    self:InitThink()
end

function PANEL:PopulateBoneList()
    local handBones = {
        "ValveBiped.Bip01_Head1",
        "ValveBiped.Bip01_L_UpperArm",
        "ValveBiped.Bip01_L_Forearm",
        "ValveBiped.Bip01_L_Hand",
        "ValveBiped.Bip01_R_UpperArm",
        "ValveBiped.Bip01_R_Forearm",
        "ValveBiped.Bip01_R_Hand",
        "ValveBiped.Bip01_L_Finger0",
        "ValveBiped.Bip01_L_Finger01",
        "ValveBiped.Bip01_L_Finger02",
        "ValveBiped.Bip01_L_Finger1",
        "ValveBiped.Bip01_L_Finger11",
        "ValveBiped.Bip01_L_Finger12",
        "ValveBiped.Bip01_L_Finger2",
        "ValveBiped.Bip01_L_Finger21",
        "ValveBiped.Bip01_L_Finger22",
        "ValveBiped.Bip01_L_Finger3",
        "ValveBiped.Bip01_L_Finger31",
        "ValveBiped.Bip01_L_Finger32",
        "ValveBiped.Bip01_L_Finger4",
        "ValveBiped.Bip01_L_Finger41",
        "ValveBiped.Bip01_L_Finger42",
        "ValveBiped.Bip01_R_Finger0",
        "ValveBiped.Bip01_R_Finger01",
        "ValveBiped.Bip01_R_Finger02",
        "ValveBiped.Bip01_R_Finger1",
        "ValveBiped.Bip01_R_Finger11",
        "ValveBiped.Bip01_R_Finger12",
        "ValveBiped.Bip01_R_Finger2",
        "ValveBiped.Bip01_R_Finger21",
        "ValveBiped.Bip01_R_Finger22",
        "ValveBiped.Bip01_R_Finger3",
        "ValveBiped.Bip01_R_Finger31",
        "ValveBiped.Bip01_R_Finger32",
        "ValveBiped.Bip01_R_Finger4",
        "ValveBiped.Bip01_R_Finger41",
        "ValveBiped.Bip01_R_Finger42"
    }
    local adminBones = {
        "ValveBiped.Bip01_Pelvis",
        "ValveBiped.Bip01_Spine",
        "ValveBiped.Bip01_Spine2",
        "ValveBiped.Bip01_Spine4",
        "ValveBiped.Bip01_R_Thigh",
        "ValveBiped.Bip01_R_Calf",
        "ValveBiped.Bip01_R_Foot",
        "ValveBiped.Bip01_L_Thigh",
        "ValveBiped.Bip01_L_Calf",
        "ValveBiped.Bip01_L_Foot",
    }
    
    if LocalPlayer():IsSuperAdmin() then
        for _, bone in ipairs(adminBones) do
            self.BoneList:AddLine(bone)
            self.Bones[bone] = {pitch = 0, yaw = 0, roll = 0}
            self.Frames[1][bone] = {pitch = 0, yaw = 0, roll = 0}
        end
    end
    for _, bone in ipairs(handBones) do
        self.BoneList:AddLine(bone)
        self.Bones[bone] = {pitch = 0, yaw = 0, roll = 0}
        self.Frames[1][bone] = {pitch = 0, yaw = 0, roll = 0}
    end
end

function PANEL:ShowExitConfirmation()
    local confirmPanel = vgui.Create("DFrame")
    confirmPanel:SetSize(300, 150)
    confirmPanel:SetTitle("Confirm Exit")
    confirmPanel:Center()
    confirmPanel:MakePopup()
    confirmPanel:SetZPos(32767)
    confirmPanel:DoModal()
    confirmPanel.Paint = function(self,w,h)
        surface.SetDrawColor(20, 20, 140, 255)
        surface.DrawRect(0,0,w,h)
    end
    
    local label = vgui.Create("DLabel", confirmPanel)
    label:SetPos(20, 40)
    label:SetSize(260, 30)
    label:SetText("Are you sure you want to exit?\nUnsaved changes will be lost.")
    label:SetContentAlignment(5)
    
    local cancelBtn = vgui.Create("DButton", confirmPanel)
    cancelBtn:SetText("Cancel")
    cancelBtn:SetPos(30, 90)
    cancelBtn:SetSize(100, 30)
    cancelBtn.DoClick = function()
        confirmPanel:Close()
    end
    
    local confirmBtn = vgui.Create("DButton", confirmPanel)
    confirmBtn:SetText("OK")
    confirmBtn:SetPos(170, 90)
    confirmBtn:SetSize(100, 30)
    confirmBtn.DoClick = function()
        confirmPanel:Close()
        self:Remove()
    end
end

function PANEL:GetInterpolatedFrameData(frameIndex, fraction)
    local currentFrame = self.Frames[frameIndex]
    local nextFrame = self.Frames[frameIndex % #self.Frames + 1]
    
    local result = {}
    
    for bone, currentRotation in pairs(currentFrame) do
        result[bone] = {}
        
        if nextFrame[bone] then
            result[bone].pitch = Lerp(fraction, currentRotation.pitch, nextFrame[bone].pitch)
            result[bone].yaw = Lerp(fraction, currentRotation.yaw, nextFrame[bone].yaw)
            result[bone].roll = Lerp(fraction, currentRotation.roll, nextFrame[bone].roll)
        else
            result[bone] = table.Copy(currentRotation)
        end
    end
    
    return result
end

function PANEL:DeleteSavedAnimation()
    local files = file.Find("hand_animations/*.txt", "DATA")
    
    if #files == 0 then
        notification.AddLegacy("No saved animations found", NOTIFY_ERROR, 3)
        return
    end
    
    local menu = DermaMenu()
    
    for _, f in ipairs(files) do
        local name = string.StripExtension(f)
        menu:AddOption(name, function()
            file.Delete("hand_animations/" .. f)
            notification.AddLegacy("Animation " .. name .. " deleted", NOTIFY_GENERIC, 3)
        end)
    end
    
    menu:Open()
end

function PANEL:ApplyFrameDataToModel(frameData)
    if not IsValid(self.PreviewPanel.Entity) then return end
    
    for bone, rotation in pairs(frameData) do
        local boneID = self.PreviewPanel.Entity:LookupBone(bone)
        if boneID then
            local angle = Angle(rotation.pitch, rotation.yaw, rotation.roll)
            self.PreviewPanel.Entity:ManipulateBoneAngles(boneID, angle)
        end
    end
end

function PANEL:UpdateRotationControls()
    if not self.SelectedBone then return end
    
    local boneData = self.Frames[self.CurrentFrame][self.SelectedBone] or {pitch = 0, yaw = 0, roll = 0}
    
    self.PitchSlider:SetValue(boneData.pitch)
    self.YawSlider:SetValue(boneData.yaw)
    self.RollSlider:SetValue(boneData.roll)
    
    self:UpdatePreviewModel()
end

function PANEL:UpdateBoneRotation(bone, axis, value)
    if not self.Frames[self.CurrentFrame][bone] then
        self.Frames[self.CurrentFrame][bone] = {pitch = 0, yaw = 0, roll = 0}
    end
    
    self.Frames[self.CurrentFrame][bone][axis] = value
    self:UpdatePreviewModel()
end

function PANEL:UpdatePreviewModel()
    if not IsValid(self.PreviewPanel.Entity) then return end
    
    for bone, rotation in pairs(self.Frames[self.CurrentFrame]) do
        local boneID = self.PreviewPanel.Entity:LookupBone(bone)
        if boneID then
            local angle = Angle(rotation.pitch, rotation.yaw, rotation.roll)
            self.PreviewPanel.Entity:ManipulateBoneAngles(boneID, angle)
        end
    end
end

function PANEL:ChangeFrame(frame)
    if frame < 1 then frame = 1 end
    if frame > #self.Frames then frame = #self.Frames end
    
    self.CurrentFrame = frame
    self.FrameSlider:SetValue(frame)
    
    if not self.Frames[frame] then
        self.Frames[frame] = table.Copy(self.Frames[frame - 1] or {})
    end
    
    self:UpdateRotationControls()
    self:UpdatePreviewModel()
end

function PANEL:AddFrame()
    local newFrame = self.CurrentFrame + 1
    
    table.insert(self.Frames, newFrame, table.Copy(self.Frames[self.CurrentFrame] or {}))
    
    self.FrameSlider:SetMax(#self.Frames)
    self:ChangeFrame(newFrame)
end

function PANEL:DeleteFrame()
    if #self.Frames <= 1 then return end
    
    table.remove(self.Frames, self.CurrentFrame)
    
    self.FrameSlider:SetMax(#self.Frames)
    
    if self.CurrentFrame > #self.Frames then
        self:ChangeFrame(#self.Frames)
    else
        self:ChangeFrame(self.CurrentFrame)
    end
end

function PANEL:TogglePlayback()
    self.IsPlaying = not self.IsPlaying
    
    if self.IsPlaying then
        self.PlayBtn:SetText("Stop")
        self.PlayTime = CurTime()
        self.StartFrame = self.CurrentFrame
    else
        self.PlayBtn:SetText("Play")
    end
end

function PANEL:SaveAnimation()
    Derma_StringRequest(
        "Save Animation",
        "Enter a name for your animation:",
        "",
        function(text)
            if text and text ~= "" then
                local saveData = {
                    frames = self.Frames,
                    speed = self.PlaySpeed
                }
                
                local data = util.TableToJSON(saveData)
                file.CreateDir("hand_animations")
                file.Write("hand_animations/" .. text .. ".txt", data)
                notification.AddLegacy("Animation saved as " .. text, NOTIFY_GENERIC, 3)
            end
        end
    )
end

function PANEL:LoadAnimation()
    local files = file.Find("hand_animations/*.txt", "DATA")
    
    if #files == 0 then
        notification.AddLegacy("No saved animations found", NOTIFY_ERROR, 3)
        return
    end
    
    local menu = DermaMenu()
    
    for _, f in ipairs(files) do
        local name = string.StripExtension(f)
        menu:AddOption(name, function()
            local data = file.Read("hand_animations/" .. f, "DATA")
            if data then
                local saveData = util.JSONToTable(data) or {frames = {[1] = {}}, speed = 1}
                
                if saveData.frames then
                    self.Frames = saveData.frames
                    self.PlaySpeed = saveData.speed or 1
                    self.SpeedSlider:SetValue(self.PlaySpeed)
                else
                    self.Frames = saveData
                    self.PlaySpeed = 1
                    self.SpeedSlider:SetValue(1)
                end
                
                self.FrameSlider:SetMax(#self.Frames)
                self:ChangeFrame(1)
                notification.AddLegacy("Animation " .. name .. " loaded", NOTIFY_GENERIC, 3)
            else
                notification.AddLegacy("Failed to load animation", NOTIFY_ERROR, 3)
            end
        end)
    end
    
    menu:Open()
end

function PANEL:ResetCamera()
    self.PreviewPanel.Angles = Angle(0, 0, 0)
    self.PreviewPanel:SetLookAt(Vector(0, 0, 56))
    self.PreviewPanel:SetCamPos(Vector(50, 50, 50))
    self.PreviewPanel:SetFOV(50)
    self.ZoomSlider:SetValue(50)
end

function PANEL:ResetBone(boneName)
    if not self.Frames[self.CurrentFrame][boneName] then return end
    
    self.Frames[self.CurrentFrame][boneName] = {
        pitch = 0, 
        yaw = 0, 
        roll = 0
    }
    
    self.PitchSlider:SetValue(0)
    self.YawSlider:SetValue(0)
    self.RollSlider:SetValue(0)
    
    self:UpdatePreviewModel()
    
    notification.AddLegacy("Reset bone: " .. boneName, NOTIFY_GENERIC, 2)
end

function PANEL:ResetAllBones()
    for boneName, _ in pairs(self.Frames[self.CurrentFrame]) do
        self.Frames[self.CurrentFrame][boneName] = {
            pitch = 0, 
            yaw = 0, 
            roll = 0
        }
    end
    
    if self.SelectedBone then
        self.PitchSlider:SetValue(0)
        self.YawSlider:SetValue(0)
        self.RollSlider:SetValue(0)
    end
    
    self:UpdatePreviewModel()
    
    notification.AddLegacy("Reset all bones in frame " .. self.CurrentFrame, NOTIFY_GENERIC, 2)
end

function PANEL:InitThink()
    local oldThink = self.Think
    self.Think = function(self)
        if oldThink then oldThink(self) end
        
        if self.IsPlaying then
            local elapsed = CurTime() - self.PlayTime
            local frameTime = 1 / (10 * self.PlaySpeed)
            local totalProgress = elapsed / frameTime
            
            local targetFrame = self.StartFrame + math.floor(totalProgress)
            local frameFraction = totalProgress % 1
            
            if targetFrame > #self.Frames then
                self.PlayTime = CurTime()
                self.StartFrame = 1
                targetFrame = 1
                frameFraction = 0
            end
            
            if targetFrame ~= self.CurrentFrame or self.lastFrameFraction ~= frameFraction then
                self.CurrentFrame = targetFrame
                self.FrameSlider:SetValue(targetFrame)
                self.lastFrameFraction = frameFraction
                
                if frameFraction > 0 then
                    local interpolatedFrameData = self:GetInterpolatedFrameData(targetFrame, frameFraction)
                    self:ApplyFrameDataToModel(interpolatedFrameData)
                else
                    self:UpdatePreviewModel()
                end
            end
        end
    end
end

vgui.Register("AnimationCreator", PANEL, "DFrame")

concommand.Add("mur_animation_creator", function()
    vgui.Create("AnimationCreator")
end)

------------------------------------------------------------------
------------------------------------------------------------------

local PLAYER_ANIM_PANEL = {}

function PLAYER_ANIM_PANEL:Init()
    self:SetSize(400, 500)
    self:SetTitle("Play Animation")
    self:Center()
    self:MakePopup()
    self.Paint = function(self,w,h)
        surface.SetDrawColor(20, 20, 40, 240)
        surface.DrawRect(0,0,w,h)
    end
    
    self.AnimList = vgui.Create("DListView", self)
    self.AnimList:SetSize(380, 400)
    self.AnimList:SetPos(10, 30)
    self.AnimList:AddColumn("Animation Name")
    self.AnimList:SetMultiSelect(false)
    
    self:PopulateAnimList()
    
    self.PlayBtn = vgui.Create("DButton", self)
    self.PlayBtn:SetSize(380, 30)
    self.PlayBtn:SetPos(10, 440)
    self.PlayBtn:SetText("Play Animation")
    self.PlayBtn:SetDisabled(true)
    self.PlayBtn.DoClick = function()
        if self.SelectedAnim then
            self:PlayAnimationOnPlayer(self.SelectedAnim)
            self:Remove()
        end
    end
    
    self.AnimList.OnRowSelected = function(_, _, row)
        self.SelectedAnim = row:GetValue(1)
        self.PlayBtn:SetDisabled(false)
    end
end

function PLAYER_ANIM_PANEL:PopulateAnimList()
    self.AnimList:Clear()
    
    local files = file.Find("hand_animations/*.txt", "DATA")
    
    if #files == 0 then
        self.AnimList:AddLine("No animations found")
        return
    end
    
    for _, f in ipairs(files) do
        local name = string.StripExtension(f)
        self.AnimList:AddLine(name)
    end
end

function PLAYER_ANIM_PANEL:PlayAnimationOnPlayer(animName)
    local data = file.Read("hand_animations/" .. animName .. ".txt", "DATA")
    if data then
        local frames = util.JSONToTable(data)
        if frames then
            net.Start("MuR.PlayHandAnimation")
            net.WriteData(util.Compress(data))
            net.SendToServer()
            notification.AddLegacy("Playing animation: " .. animName, NOTIFY_GENERIC, 3)
        else
            notification.AddLegacy("Failed to load animation data", NOTIFY_ERROR, 3)
        end
    else
        notification.AddLegacy("Animation file not found", NOTIFY_ERROR, 3)
    end
end

vgui.Register("PlayerAnimationPanel", PLAYER_ANIM_PANEL, "DFrame")

concommand.Add("mur_animation_playanim", function(ply, _, args)
    local nm = args[1]
    if !isstring(nm) then return end
    PLAYER_ANIM_PANEL:PlayAnimationOnPlayer(nm)
end)

concommand.Add("mur_animation_play", function()
    vgui.Create("PlayerAnimationPanel")
end)

net.Receive("MuR.ResetHandAnimation", function()
    local playerIndex = net.ReadEntity()
    if not IsValid(playerIndex) or !playerIndex.PlayingHandAnim then return end
    local time = net.ReadFloat()

    playerIndex.HandAnimDurOther = time
    playerIndex.HandAnimStart = 0
end)

net.Receive("MuR.SyncHandAnimation", function(len)
    local playerIndex = net.ReadEntity()
    local compressedData = net.ReadData(len)
    if not IsValid(playerIndex) then return end
    
    local animData = util.Decompress(compressedData)
    if not animData then return end
    local saveData = util.JSONToTable(animData)
    if not saveData then return end
    local frames, speed
    if saveData.frames then
        frames = saveData.frames
        speed = saveData.speed or 1
    else
        frames = saveData
        speed = 1
    end
    if not frames or #frames == 0 then return end
    if playerIndex.PlayingHandAnim then
        if playerIndex.HandAnimFadingOut then return end
        
        playerIndex.HandAnimFadingOut = true
        playerIndex.HandAnimFadeStart = CurTime()
        playerIndex.LastFrameBoneData = {}
        
        for boneName, _ in pairs(frames[1]) do
            local boneID = playerIndex:LookupBone(boneName)
            if boneID then
                local angle = playerIndex:GetManipulateBoneAngles(boneID)
                playerIndex.LastFrameBoneData[boneName] = {
                    pitch = angle.pitch,
                    yaw = angle.yaw,
                    roll = angle.roll
                }
            end
        end
        
        timer.Simple(0.3, function()
            if IsValid(playerIndex) then
                playerIndex.PlayingHandAnim = true
                playerIndex.HandAnimFrames = frames
                playerIndex.HandAnimSpeed = speed
                playerIndex.HandAnimStart = CurTime()
                playerIndex.HandAnimFrame = 1
                playerIndex.HandAnimLastUpdate = 0
                playerIndex.HandAnimFadingOut = false
            end
        end)
    else
        playerIndex.PlayingHandAnim = true
        playerIndex.HandAnimFrames = frames
        playerIndex.HandAnimSpeed = speed
        playerIndex.HandAnimStart = CurTime()
        playerIndex.HandAnimFrame = 1
        playerIndex.HandAnimLastUpdate = 0
        playerIndex.HandAnimFadingOut = false
    end
end)

hook.Add("CalcMainActivity", "PlayHandAnimations", function(ply, vel)
    if ply.PlayingHandAnim then
        if vel:Length() < 25 then
            return ACT_HL2MP_IDLE, -1
        else
            return ACT_HL2MP_WALK, -1
        end
    end
end)

hook.Add("CalcView", "MuR_GestureHandView", function(ply, pos, angles, fov)
	local wep = ply:GetActiveWeapon()
	local allow = true
	if ply:GetSVAnimation() ~= "" then allow = false end

	if ply:Alive() and ply.PlayingHandAnim and allow then
		local velocity = ply:GetVelocity():Length()
		local eyes = ply:GetAttachment(ply:LookupAttachment("eyes"))

		local view = {}
		view.origin = eyes.Pos
		view.angles = angles
		view.fov = fov
		view.drawviewer = true
        view.znear = 4

		return view
	end
end)

hook.Add("Think", "PlayHandAnimations", function()
    for _, ply in pairs(player.GetAll()) do
        if ply.PlayingHandAnim and ply.HandAnimFrames then
            local elapsed = CurTime() - ply.HandAnimStart
            local speed = ply.HandAnimSpeed
            local frameTime = 0.1 / speed
            
            if elapsed > frameTime * #ply.HandAnimFrames then
                if not ply.HandAnimFadingOut then
                    ply.HandAnimFadingOut = true
                    ply.HandAnimFadeStart = CurTime()
                    ply.LastFrameBoneData = {}
                    
                    local lastFrame = ply.HandAnimFrames[#ply.HandAnimFrames]
                    for boneName, rotation in pairs(lastFrame) do
                        ply.LastFrameBoneData[boneName] = {
                            pitch = rotation.pitch,
                            yaw = rotation.yaw,
                            roll = rotation.roll
                        }
                    end
                end
                
                local fadeElapsed = CurTime() - ply.HandAnimFadeStart
                local fadeDuration = 0.2
                if ply.HandAnimDurOther then
                    fadeDuration = ply.HandAnimDurOther
                    ply.HandAnimDurOther = nil
                end
                
                if fadeElapsed >= fadeDuration then
                    ply.PlayingHandAnim = false
                    ply.HandAnimFadingOut = false
                    
                    for boneName, _ in pairs(ply.LastFrameBoneData) do
                        local boneID = ply:LookupBone(boneName)
                        if boneID then
                            ply:ManipulateBoneAngles(boneID, Angle(0,0,0))
                        end
                    end
                else
                    local fadeFraction = fadeElapsed / fadeDuration
                    
                    for boneName, rotation in pairs(ply.LastFrameBoneData) do
                        local boneID = ply:LookupBone(boneName)
                        if boneID then
                            local angle = Angle(
                                Lerp(fadeFraction, rotation.pitch, 0),
                                Lerp(fadeFraction, rotation.yaw, 0),
                                Lerp(fadeFraction, rotation.roll, 0)
                            )
                            if ply:GetNW2String("SVAnim", "") != "" then
                                angle = Angle(0,0,0)
                            end
                            ply:ManipulateBoneAngles(boneID, angle)
                        end
                    end
                end
                
                return
            end
            
            local totalProgress = elapsed / frameTime
            local targetFrame = math.floor(totalProgress) + 1
            local frameFraction = totalProgress % 1
            
            if ply.HandAnimLastUpdate ~= targetFrame or frameFraction > 0 then
                ply.HandAnimLastUpdate = targetFrame
                
                local currentFrame = ply.HandAnimFrames[targetFrame]
                local nextFrame = ply.HandAnimFrames[math.min(targetFrame + 1, #ply.HandAnimFrames)]
                
                for boneName, rotation in pairs(currentFrame) do
                    local boneID = ply:LookupBone(boneName)
                    if boneID then
                        local angle
                        
                        if nextFrame and nextFrame[boneName] and frameFraction > 0 then
                            angle = Angle(
                                Lerp(frameFraction, rotation.pitch, nextFrame[boneName].pitch),
                                Lerp(frameFraction, rotation.yaw, nextFrame[boneName].yaw),
                                Lerp(frameFraction, rotation.roll, nextFrame[boneName].roll)
                            )
                        else
                            angle = Angle(rotation.pitch, rotation.yaw, rotation.roll)
                        end
                        
                        ply:ManipulateBoneAngles(boneID, angle)
                    end
                end
            end
        end
    end
end)