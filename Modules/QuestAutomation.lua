local addonName, ns = ...

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")

local function GetDB()
    NaowhQOL = NaowhQOL or {}
    NaowhQOL.misc = NaowhQOL.misc or {}
    return NaowhQOL.misc
end

frame:SetScript("OnEvent", function(self, event, ...)
    local db = GetDB()

    if event == "PLAYER_LOGIN" then
        self:RegisterEvent("QUEST_DETAIL")
        self:RegisterEvent("QUEST_PROGRESS")
        self:RegisterEvent("QUEST_COMPLETE")
        self:RegisterEvent("QUEST_ACCEPT_CONFIRM")
        self:RegisterEvent("QUEST_GREETING")
        self:RegisterEvent("GOSSIP_SHOW")
        return
    end

    if IsAltKeyDown() then return end

    if event == "QUEST_DETAIL" then
        if not db.autoQuestAccept then return end

        if QuestGetAutoAccept() then
            CloseQuest()
        else
            AcceptQuest()
        end
        return
    end

    if event == "QUEST_ACCEPT_CONFIRM" then
        if not db.autoQuestAccept then return end
        ConfirmAcceptQuest()
        StaticPopup_Hide("QUEST_ACCEPT")
        return
    end

    if event == "QUEST_PROGRESS" then
        if not db.autoQuestTurnIn then return end
        if not IsQuestCompletable() then return end
        CompleteQuest()
        return
    end

    if event == "QUEST_COMPLETE" then
        if not db.autoQuestTurnIn then return end

        if GetNumQuestChoices() <= 1 then
            GetQuestReward(GetNumQuestChoices())
        end
        return
    end

    if event == "GOSSIP_SHOW" or event == "QUEST_GREETING" then
        if not db.autoGossipSelect then return end

        if event == "QUEST_GREETING" then
            if db.autoQuestTurnIn then
                local activeQuests = C_QuestLog.GetActiveQuests and C_QuestLog.GetActiveQuests()
                if activeQuests then
                    for _, questInfo in ipairs(activeQuests) do
                        if questInfo.title and questInfo.isComplete and questInfo.questID then
                            return C_GossipInfo.SelectActiveQuest(questInfo.questID)
                        end
                    end
                else
                    for i = 1, GetNumActiveQuests() do
                        local title, isComplete = GetActiveTitle(i)
                        if title and isComplete then
                            SelectActiveQuest(i)
                            return
                        end
                    end
                end
            end

            if db.autoQuestAccept then
                local availableQuests = C_QuestLog.GetAvailableQuests and C_QuestLog.GetAvailableQuests()
                if availableQuests then
                    for _, questInfo in ipairs(availableQuests) do
                        if questInfo.questID then
                            return C_GossipInfo.SelectAvailableQuest(questInfo.questID)
                        end
                    end
                else
                    for i = 1, GetNumAvailableQuests() do
                        SelectAvailableQuest(i)
                        return
                    end
                end
            end
        else
            if db.autoQuestTurnIn then
                local activeQuests = C_GossipInfo.GetActiveQuests()
                for _, questInfo in ipairs(activeQuests) do
                    if questInfo.title and questInfo.isComplete and questInfo.questID then
                        return C_GossipInfo.SelectActiveQuest(questInfo.questID)
                    end
                end
            end

            if db.autoQuestAccept then
                local availableQuests = C_GossipInfo.GetAvailableQuests()
                for _, questInfo in ipairs(availableQuests) do
                    if questInfo.questID then
                        return C_GossipInfo.SelectAvailableQuest(questInfo.questID)
                    end
                end
            end
        end
        return
    end
end)
