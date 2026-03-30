Config = {}

-- ==========================
-- ### INTEGRATION SETTINGS ###
-- ==========================

-- Discord Webhook Link for RP Logs
Config.discordwebhooklink = 'https://discord.com/api/webhooks/1486277163517874246/5JdYBBHalMmJYnmny4RxkNRCcNyl4Z_QabBXW-hdZuMOMDuMnXVGayfW2kf3IC2sBBoJ' 

-- Discord avatar image for webhooks
DISCORD_IMAGE = 'https://i.imgur.com/placeholder.png'

-- Put your separator directly in each command title.
-- Example: title = "DO | " or title = "DO "

Config.Commands = {
    ["twt"] = {
        enabled     = true, -- Whether the command is enabled or not
        override    = true, -- Is this command overriding the other chat resources?
        distance    = false, -- false = no distance, any number = distance in that range, function(source) return distance end = dynamic distance based on source
        title       = "TWITTER | ", -- Title that will be shown in the chat message (e.g. "TWITTER | John Doe: Hello world!")
        color       = "#1da1f2", -- Color of the title and username (HEX format, e.g. "#1da1f2" for Twitter blue) overrided by /nick
        webhook     = "TWITTER", -- title of the webhook
        help        = "Send a global tweet" -- Help text showing in the suggestions when typing the command (e.g. "/twt [message]")
    },
    ["dispatch"] = {
        enabled     = true,
        override    = true,
        distance    = false,
        title       = "Dispatch",
        color       = "#3498db",
        webhook     = "DISPATCH",
        server_only = true,
        help        = "Send a message to other emergency units"
    },
    ["darkweb"] = {
        enabled     = true,
        override    = true,
        distance    = false,
        title       = "Dark Web | ",
        color       = "#0a0d11ff",
        webhook     = "DARKWEB",
        help        = "Send an anonymous illegal message"
    },
    ["news"] = {
        enabled     = true,
        override    = true,
        distance    = false,
        title       = "NEWS | ",
        color       = "#1ec234ff",
        webhook     = "NEWS",
        help        = "Broadcast news to everyone"
    },
    ["ooc"] = {
        enabled     = true,
        override    = true,
        distance    = false,
        title       = "OOC | ",
        color       = "#95a5a6",
        webhook     = "OOC",
        help        = "Out of Character chat"
    },
    ["me"] = {
        enabled     = true,
        override    = true,
        distance    = function(source)
            return Config.GetDistance(source)
        end,
        title       = "Me | ",
        color       = "#cf7fecff",
        webhook     = "ME",
        client_side = true,
        help        = "Describe a personal action"
    },
    ["do"] = {
        enabled     = true,
        override    = true,
        distance    = function(source) return Config.GetDistance(source) end,
        title       = "Do | ",
        color       = "#9f94feff",
        webhook     = "DO",
        client_side = true,
        help        = "Describe a situational action"
    },
    ["showid"] = {
        enabled     = true,
        override    = true,
        distance    = function(source)
            return Config.GetDistance(source)
        end,
        title       = "Identity Card | ",
        color       = "#ecf0f1",
        webhook     = "SHOWID",
        client_side = true,
        help        = "Show your ID card to nearby players"
    }
}


-- List of jobs that can use and see /dispatch
-- color: HEX string ("#RRGGBB" or "#RRGGBBAA")
-- label: Custom department name (optional override)

Config.DispatchJobs = {
    ["police"]    = { color = "#2641c5ff", label = "POLICE" },
    ["ambulance"] = { color = "#c52c52ff", label = "EMS" }
}

Config.showJobInDispatch = true
Config.missingargs      = "^1Please provide a message."



-- Enable this if you have other chat resources that might conflict
Config.enableCommandOverride = true



Config.GetNickname = function(source)
    if GetResourceState('poodlechat') == 'started' then
        local nickname = exports.poodlechat:getName(source)
        if nickname == GetPlayerName(source) then return nil end
        return nickname
    end
    return nil -- if nil use the player name from qb-core (e.g. John D.)
end

Config.GetDistance = function(source)
    local ok, value = pcall(function()
        return exports['pma-voice']:getVoiceRange()
    end)
    value = tonumber(value)
    if ok and value and value > 0 then return value end

    local proximity
    if type(Player) == "function" then
        local player = Player(source)
        proximity = player and player.state and player.state.proximity
    end
    return (type(proximity) == "table" and tonumber(proximity.distance)) or tonumber(proximity) or 10.0
end
