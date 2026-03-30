local QBCore = exports['qb-core']:GetCoreObject()

-- ==========================
-- ### INITIALIZATION LOGIC ###
-- ==========================

Citizen.CreateThread(function()
    Wait(1000)
    print("^3[QB-RPCommands]^7 Initialized successfully")
end)

-- ========================
-- ### HELPER FUNCTIONS ###
-- ========================

local function GetAge(birthdate)
    if not birthdate or birthdate == "Unknown" then return "N/A" end
    local year = string.match(birthdate, "(%d%d%d%d)")
    if not year then return "N/A" end
    local currentYear = tonumber(os.date("%Y"))
    local birthYear = tonumber(year)
    return currentYear - birthYear
end

local function GetPlayerDisplayName(source)
    if source == 0 then return "Console" end
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return GetPlayerName(source) end
    local charinfo = player.PlayerData.charinfo
    local initial = string.sub(charinfo.lastname, 1, 1)
    local qbName = charinfo.firstname .. " " .. initial .. "."
    local nickname = Config.GetNickname(source)
    return nickname or qbName
end

local function HexToDec(hex)
    hex = hex:gsub("#", "")
    if #hex == 8 then hex = hex:sub(1, 6) end
    return tonumber(hex, 16)
end

local function StripColorCodes(text)
    if not text then return "" end
    local s = text
    s = s:gsub("%^%d", "")
    s = s:gsub("%^#%x%x%x%x%x%x%x%x", "")
    s = s:gsub("%^#%x%x%x%x%x%x", "")
    s = s:gsub("%^[*_~iur]", "")
    return s
end

local function ResolveCommandDistance(source, commandKey, cfg)
    if not cfg then return false end

    local distance = cfg.distance
    if distance == nil or distance == false then
        return false
    end

    if type(distance) == "number" then
        return distance > 0 and distance or false
    end

    if type(distance) == "function" then
        local ok, resolved = pcall(distance, source, commandKey, cfg)
        if not ok then
            print(("[QB-RPCommands] Distance resolver failed for /%s: %s"):format(commandKey, resolved))
            return false
        end
        resolved = tonumber(resolved)
        if resolved and resolved > 0 then
            return resolved
        end
        return false
    end

    print(("[QB-RPCommands] Invalid distance type for /%s. Use number, function, or false."):format(commandKey))
    return false
end

-- =========================
-- ### LOGGING FUNCTIONS ###
-- =========================

local function SendDiscordLog(title, description, color, source, playerName, fields)
    if not Config.discordwebhooklink or Config.discordwebhooklink == "" then return end
    
    local payload = {
        username = "RP Logs",
        embeds = {{
            title = title,
            description = description,
            color = HexToDec(color),
            footer = { text = "System ID: " .. source .. " | Name: " .. playerName }
        }},
        avatar_url = DISCORD_IMAGE
    }

    if fields then
        payload.embeds[1].fields = fields
        payload.embeds[1].description = nil
    end

    PerformHttpRequest(Config.discordwebhooklink, function(err, text, headers) end, 'POST', 
        json.encode(payload), { ['Content-Type'] = 'application/json' })
end

-- =====================
-- ### CORE MESSAGING ###
-- =====================

local PlayerSeeds = {}

local function sendRoleplayMessage(source, args, commandKey)
    local cfg = Config.Commands[commandKey]
    if not cfg then return end
    
    if #args <= 0 then
        TriggerClientEvent('chatMessage', source, Config.missingargs)
        return
    end

    local player = QBCore.Functions.GetPlayer(source)
    if not player then return end

    local message = table.concat(args, " ")
    local playerName = GetPlayerName(source)
    local displayName = GetPlayerDisplayName(source)
    local logDisplayName = displayName

    if commandKey == "darkweb" then
        if not PlayerSeeds[source] then PlayerSeeds[source] = math.random(100, 999) end
        local charHash = string.sub(player.PlayerData.citizenid, #player.PlayerData.citizenid - 1)
        displayName = "User_" .. PlayerSeeds[source] .. charHash
    end

    local chatColor = cfg.color
    if type(chatColor) == "table" then
        chatColor = string.format("#%02x%02x%02x", chatColor[1], chatColor[2], chatColor[3])
    end

    local isItalic = (commandKey == "me" or commandKey == "do")
    local titleWithName = (cfg.title or "") .. displayName
    local template
    if isItalic then
        template = string.format('<div style="color: %s; font-style: italic;"><b>* %s</b> %s <b>*</b></div>', chatColor, titleWithName, message)
    else
        template = string.format('<div><b style="color: %s;">%s</b>: %s</div>', chatColor, titleWithName, message)
    end

    local function SendToPlayer(targetId)
        TriggerClientEvent('chat:addMessage', targetId, { template = template })
    end

    local maxDistance = ResolveCommandDistance(source, commandKey, cfg)
    if maxDistance then
        local sourcePed = GetPlayerPed(source)
        local sourceCoords = GetEntityCoords(sourcePed)
        SendToPlayer(source)
        for _, targetId in ipairs(GetPlayers()) do
            local tid = tonumber(targetId)
            if tid ~= source then
                local targetPed = GetPlayerPed(tid)
                local targetCoords = GetEntityCoords(targetPed)
                if #(sourceCoords - targetCoords) < maxDistance then
                    SendToPlayer(tid)
                end
            end
        end
    else
        TriggerClientEvent('chat:addMessage', -1, { template = template })
    end

    -- Discord Logging
    local displayIdentity = StripColorCodes(logDisplayName)
    if commandKey == "darkweb" then
        displayIdentity = displayIdentity .. " (" .. displayName .. ")"
    end
    SendDiscordLog(cfg.webhook or cfg.title, "**Player:** " .. displayIdentity .. "\n**Message:** " .. StripColorCodes(message), chatColor, source, playerName)
end

-- ========================
-- ### COMMAND HANDLERS ###
-- ========================

RegisterNetEvent('requestCommandSuggestions')
AddEventHandler('requestCommandSuggestions', function()
    local source = source
    local hasDispatchAccess = false
    local player = QBCore.Functions.GetPlayer(source)
    if player and Config.DispatchJobs[player.PlayerData.job.name] then
        hasDispatchAccess = true
    end
    TriggerClientEvent('addCommandSuggestions', source, hasDispatchAccess)
end)

local function RegisterAllCommands()
    for cmdName, cfg in pairs(Config.Commands) do
        if cfg.enabled and not cfg.server_only and not cfg.client_side then
            RegisterCommand(cmdName, function(source, args, raw)
                sendRoleplayMessage(source, args, cmdName)
            end, false)
        end
    end

    -- Special handling for /dispatch
    if Config.Commands["dispatch"] and Config.Commands["dispatch"].enabled then
        RegisterCommand("dispatch", function(source, args, raw)
            if source == 0 then
                print("^1ERROR: ^0This command can only be used by players.")
                return
            end

            local player = QBCore.Functions.GetPlayer(source)
            local jobName = player and player.PlayerData.job.name
            local jobCfg = jobName and Config.DispatchJobs[jobName]

            if not player or not jobCfg then
                TriggerClientEvent('chatMessage', source, "^1ERROR: ^0You don't have access to this command.")
                return
            end

            if #args <= 0 then
                TriggerClientEvent('chatMessage', source, Config.missingargs)
                return
            end

            local jobLabel = jobCfg.label or player.PlayerData.job.label
            local jobColor = (type(jobCfg.color) == "table") and string.format("#%02x%02x%02x", jobCfg.color[1], jobCfg.color[2], jobCfg.color[3]) or jobCfg.color
            local displayName = GetPlayerDisplayName(source)
            local message = table.concat(args, " ")
            local playerName = GetPlayerName(source)

            local template = string.format('<div><b style="color: #1da1f2;">Dispatch</b> | <b style="color: %s; font-weight: 900;">[%s]</b> <b>%s</b>: %s</div>', jobColor, jobLabel, displayName, message)
            
            for _, targetId in ipairs(GetPlayers()) do
                local tid = tonumber(targetId)
                local targetPlayer = QBCore.Functions.GetPlayer(tid)
                if targetPlayer and Config.DispatchJobs[targetPlayer.PlayerData.job.name] then
                    TriggerClientEvent('chat:addMessage', tid, { template = template })
                end
            end
            
            SendDiscordLog("Dispatch", "**From:** " .. StripColorCodes(displayName) .. " (**" .. jobLabel .. "**)\n**Message:** " .. StripColorCodes(message), jobColor, source, playerName)
        end, false)
    end
end

-- =====================
-- ### COMMAND EVENTS ###
-- =====================

RegisterNetEvent('QB-RPCommands:server:me', function(args)
    sendRoleplayMessage(source, args, "me")
end)

RegisterNetEvent('QB-RPCommands:server:do', function(args)
    sendRoleplayMessage(source, args, "do")
end)

RegisterNetEvent('QB-RPCommands:server:showid', function()
    local source = source
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return end

    local charinfo = player.PlayerData.charinfo
    local firstName = charinfo.firstname
    local lastName = charinfo.lastname
    local gender = charinfo.gender
    local birthdate = charinfo.birthdate or "Unknown"
    local idNumber = source
    local playerName = GetPlayerName(source)
    local age = GetAge(birthdate)
    local displayName = GetPlayerDisplayName(source)
    local showIdCfg = Config.Commands["showid"] or {}
    local maxDistance = ResolveCommandDistance(source, "showid", showIdCfg)

    if maxDistance then
        local sourcePed = GetPlayerPed(source)
        local sourceCoords = GetEntityCoords(sourcePed)

        TriggerClientEvent("sendMessageShowID", source, source, displayName, firstName, lastName, gender, birthdate, age, idNumber, maxDistance)

        for _, targetId in ipairs(GetPlayers()) do
            local tid = tonumber(targetId)
            if tid ~= source then
                local targetPed = GetPlayerPed(tid)
                local targetCoords = GetEntityCoords(targetPed)
                if #(sourceCoords - targetCoords) < maxDistance then
                    TriggerClientEvent("sendMessageShowID", tid, source, displayName, firstName, lastName, gender, birthdate, age, idNumber, maxDistance)
                end
            end
        end
    else
        TriggerClientEvent("sendMessageShowID", -1, source, displayName, firstName, lastName, gender, birthdate, age, idNumber, false)
    end
    
    local fields = {
        { name = "Shown By", value = StripColorCodes(displayName), inline = true },
        { name = "Legal Name", value = firstName .. " " .. lastName, inline = true },
        { name = "Age/DOB", value = age .. " (" .. birthdate .. ")", inline = true },
        { name = "ID/Name", value = idNumber .. " (" .. playerName .. ")", inline = false }
    }
    SendDiscordLog("ID Card Shown", nil, "#ecf0f1", source, playerName, fields)
end)

-- ============================
-- ### COMMAND REGISTRATION ###
-- ============================

RegisterAllCommands()

if Config.enableCommandOverride then
    Citizen.CreateThread(function()
        Wait(5000)
        RegisterAllCommands()
        Wait(25000)
        RegisterAllCommands()
    end)
end

RegisterCommand("refreshrpcommands", function(source, args, raw)
    if source == 0 or QBCore.Functions.HasPermission(source, 'admin') then
        RegisterAllCommands()
        if source ~= 0 then 
            TriggerClientEvent('chatMessage', source, "^2SUCCESS: ^0RP Commands have been refreshed.") 
        end
    end
end, false)

AddEventHandler('playerDropped', function()
    PlayerSeeds[source] = nil
end)
