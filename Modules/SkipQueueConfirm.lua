local addonName, ns = ...

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")

loader:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")

    local function GetPlayerRole()
        local spec = GetSpecialization()
        if not spec then return nil end
        return GetSpecializationRole(spec)
    end

    local dialog = LFGListApplicationDialog
    if dialog then
        dialog:HookScript("OnShow", function(dlg)
            local db = NaowhQOL.misc
            if not db or not db.skipQueueConfirm then return end
            if IsControlKeyDown() then return end

            local confirmBtn = dlg.SignUpButton
            if confirmBtn and confirmBtn:IsEnabled() then
                confirmBtn:Click()
            end
        end)
    end

    local roleFrame = CreateFrame("Frame")
    roleFrame:RegisterEvent("LFG_ROLE_CHECK_SHOW")
    roleFrame:SetScript("OnEvent", function()
        local db = NaowhQOL.misc
        if not db or not db.skipQueueConfirm then return end
        if IsControlKeyDown() then return end

        local role = GetPlayerRole()
        if not role then return end

        SetLFGRoles(false, role == "TANK", role == "HEALER", role == "DAMAGER")
        CompleteLFGRoleCheck(true)
    end)
end)
