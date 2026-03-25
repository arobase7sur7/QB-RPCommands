Config = {}

-- Change this to your webhook link
Config.discordwebhooklink = 'https://discord.com/api/webhooks/1486277163517874246/5JdYBBHalMmJYnmny4RxkNRCcNyl4Z_QabBXW-hdZuMOMDuMnXVGayfW2kf3IC2sBBoJ' 

-- Discord avatar image for webhooks
DISCORD_IMAGE = 'https://i.imgur.com/placeholder.png'

-- =============================
-- ### COMMAND CONFIGURATION ###
-- =============================
-- distance: visibility range in meters (use false/nil for global)
-- override: force re-registration for priority (e.g., against poodlechat)
-- server_only: if true, registration is handled only on server (e.g., dispatch)
-- client_side: if true, command is registered on client for distance-based priority
Config.Commands = {
    ["twt"] = {
        enabled = true,
        override = true,
        distance = false,
        title = "TWITTER",
        color = "#1da1f2",
        webhook = "TWITTER",
        help = "Send a global tweet"
    },
    ["dispatch"] = {
        enabled = true,
        override = true,
        distance = false,
        title = "Dispatch",
        color = "#3498db",
        webhook = "DISPATCH",
        server_only = true,
        help = "Send a message to other emergency units"
    },
    ["darkweb"] = {
        enabled = true,
        override = true,
        distance = false,
        title = "Dark Web",
        color = "#0a0d11ff",
        webhook = "DARKWEB",
        help = "Send an anonymous illegal message"
    },
    ["news"] = {
        enabled = true,
        override = true,
        distance = false,
        title = "NEWS",
        color = "#1ec234ff",
        webhook = "NEWS",
        help = "Broadcast news to everyone"
    },
    ["ooc"] = {
        enabled = true,
        override = true,
        distance = false,
        title = "OOC",
        color = "#95a5a6",
        webhook = "OOC",
        help = "Out of Character chat"
    },
    ["me"] = {
        enabled = true,
        override = true,
        distance = 10.0,
        title = "Me",
        color = "#cf7fecff",
        webhook = "ME",
        client_side = true,
        help = "Describe a personal action"
    },
    ["do"] = {
        enabled = true,
        override = true,
        distance = 10.0,
        title = "Do",
        color = "#9f94feff",
        webhook = "DO",
        client_side = true,
        help = "Describe a situational action"
    },
    ["showid"] = {
        enabled = true,
        override = true,
        distance = 10.0,
        title = "Identity Card",
        color = "#ecf0f1",
        webhook = "SHOWID",
        client_side = true,
        help = "Show your ID card to nearby players"
    }
}

-- =========================
-- ### DISPATCH SETTINGS ###
-- =========================
-- List of jobs that can use and see /dispatch
-- color: HEX string ("#RRGGBB" or "#RRGGBBAA")
-- label: Custom department name (optional override)
Config.DispatchJobs = {
    ["police"] = { color = "#2641c5ff", label = "POLICE" },
    ["ambulance"] = { color = "#c52c52ff", label = "EMS" }
}

Config.showJobInDispatch = true
Config.missingargs = "^1Please provide a message."

-- Override settings
Config.enableCommandOverride = true

-- ============================
-- ### NICKNAME INTEGRATION ###
-- ============================
Config.GetNickname = function(source)
    if GetResourceState('poodlechat') == 'started' then
        local nickname = exports.poodlechat:getName(source)
        if nickname == GetPlayerName(source) then return nil end
        return nickname
    end
    return nil -- if nil use the player name from qb-core (e.g. John D.)
end
