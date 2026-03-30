local function EscapeHTML(text)
    if not text then return "" end
    local replacements = {
        ['&'] = '&amp;',
        ['<'] = '&lt;',
        ['>'] = '&gt;',
        ['"'] = '&quot;',
        ["'"] = '&#39;'
    }
    return tostring(text):gsub('[&<>"\' ]', function(c) return replacements[c] or c end)
end

-- ========================
-- ### IDENTIFICATION CARD ###
-- ========================

RegisterNetEvent('sendMessageShowID')
AddEventHandler('sendMessageShowID', function(id, displayName, firstName, lastName, gender, birthdate, age, idNumber, maxDistance)
    local myId = PlayerId()
    local pid = GetPlayerFromServerId(id)
    if pid == -1 then return end

    local canSee = true
    if maxDistance then
        canSee = (pid == myId) or #(GetEntityCoords(GetPlayerPed(myId)) - GetEntityCoords(GetPlayerPed(pid))) < maxDistance
    end

    if canSee then
        local genderText = (gender == 1 or gender == 'f' or gender == 'F') and "Female" or "Male"
        
        -- Load template
        local htmlCard = LoadResourceFile(GetCurrentResourceName(), "html/id_card.html")
        if not htmlCard then return end

        -- Sanitize and substitute
        local replacements = {
            ["{{name}}"] = EscapeHTML(firstName .. " " .. lastName),
            ["{{gender}}"] = EscapeHTML(genderText),
            ["{{age}}"] = EscapeHTML(age),
            ["{{birthdate}}"] = EscapeHTML(birthdate),
            ["{{id}}"] = EscapeHTML(idNumber)
        }

        for key, value in pairs(replacements) do
            htmlCard = htmlCard:gsub(key, value)
        end

        TriggerEvent('chat:addMessage', {
            args = {"Identity Card"},
            templateId = 'identity_card',
            template = htmlCard,
            color = {255, 255, 255}
        })
    end
end)

-- ============================
-- ### COMMAND SUGGESTIONS ###
-- ============================

local function RefreshSuggestions()
    TriggerServerEvent('requestCommandSuggestions')
end

RegisterNetEvent('addCommandSuggestions')
AddEventHandler('addCommandSuggestions', function(hasDispatchAccess)
    for cmdName, cfg in pairs(Config.Commands) do
        if cfg.enabled then
            if cmdName == "dispatch" then
                if hasDispatchAccess then
                    TriggerEvent('chat:addSuggestion', '/' .. cmdName, cfg.help or 'Dispatch message')
                end
            else
                TriggerEvent('chat:addSuggestion', '/' .. cmdName, cfg.help or 'Roleplay command')
            end
        end
    end
end)

-- ============================
-- ### CLIENT REGISTRATION ###
-- ============================

local function RegisterClientCommands()
    for cmdName, cfg in pairs(Config.Commands) do
        if cfg.enabled and cfg.client_side then
            RegisterCommand(cmdName, function(source, args, raw)
                TriggerServerEvent('QB-RPCommands:server:' .. cmdName, args)
            end, false)
        end
    end
end

Citizen.CreateThread(function()
    RegisterClientCommands()
end)

-- =====================
-- ### CORE EVENTS ###
-- =====================

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    RefreshSuggestions()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    RefreshSuggestions()
end)

Citizen.CreateThread(function()
    Wait(2000)
    RefreshSuggestions()
end)
