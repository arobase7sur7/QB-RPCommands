# QB-Core Roleplay Command Pack (Modernized)

A rewritten version of the original RPCommands resource for QB-Core forked from [Swqppingg/RPCommands](https://github.com/Swqppingg/RPCommands),
evolved to meet modern roleplay server standards.

### 🏆 Major Improvements & Changes

| Feature | Original Fork | Modernized Version |
|---------|---------------|-------------------|
| **Configuration** | Scattered boolean flags | **Unified `Config.Commands`** table for everything |
| **Command coloring** | Static chat codes (`^1`, `^2`) | **Advanced HEX (`#`) & RGB** support |
| **Dispatch Labels** | Simple job name | **Custom Label Overrides** (e.g., `[EMS]`) with custom HEX |
| **Identity System** | Simple text name display | **Realistic 2-Column ID Card** with Auto-Age calculation |
| **Naming Format** | Fivem Username | **"John D." format** (Firstname + Initial of Lastname) |
| **Sync/Net Safety** | Standard events | **Net-Safe `RegisterNetEvent`** for all identity sharing |
| **Overrides** | Single registration | **Multi-pass re-registration** to win against other scripts |
| **Nicknames** | QB-Core Default | **Modular Export support** on config.lua |
| **Performance** | Basic distance checks | **Vector optimization (`#`)** for high-performance proximity |


---

## 📋 Commands

| Command | Description | Range |
|---------|-------------|-------|
| `/twt` | Send a global tweet | Global |
| `/dispatch` | Emergency department chat | Job-Based |
| `/darkweb` | Anonymous illegal message | Global |
| `/news` | News broadcast to everyone | Global |
| `/ooc` | Out-Of-Character chat | Global |
| `/me` | Describe a personal action | 10m (Default) |
| `/do` | Describe a situational action| 10m (Default) |
| `/showid` | Show realistic ID card | 10m (Default) |

---

## 🛠️ Configuration

### Command Table
Control everything about your commands in one place:
```lua
Config.Commands = {
    ["twt"] = {
        enabled = true, -- Enable or disable the command
        override = true, -- Enable or disable the command override
        distance = false, -- false = global, number = fixed range, function(...) = dynamic range
        title = "TWITTER", -- The title of the command shown in chat
        color = "#1da1f2", -- The color of the command shown in chat
        webhook = "TWITTER", -- The title of the command shown in the webhook
        help = "Send a global tweet" -- The help text of the command
    },
    -- ... other commands
}
```

### Dynamic Distance (Default: pma-voice)
Nearby commands can use live voice range by setting `distance` to a function.
Use one optional provider in config (`Config.DistanceProvider`) and call `Config.GetDynamicDistance(source)`:

```lua
["me"] = {
    enabled = true,
    distance = function(source, commandName, commandCfg)
        return Config.GetDynamicDistance(source)
    end
}
```

You can still use fixed numeric ranges:

```lua
["do"] = {
    enabled = true,
    distance = 12.0
}
```

### Dispatch Labels
Personalize your emergency departments with custom labels and colors:
```lua
Config.DispatchJobs = {
    ["police"] = { color = "#2641c5ff", label = "POLICE" },
    ["ambulance"] = { color = "#c52c52ff", label = "EMS" }
}
```

---

## 🚀 Installation

1. Place `QB-RPCommands` in your resources folder.
2. Add the following to your `server.cfg` after starting qb-core:
   ```
   ensure QB-RPCommands
   ```
3. Update `config.lua` with your Discord webhook and desired colors.

---

## ⚡ Troubleshooting

- **Overriding Priority**: If another script takes over a command, use `/refreshrpcommands` (Admin only) to re-assert this script's priority.
- **Nicknames**: Modify `Config.GetNickname` in `config.lua` to link with your preferred character name export.
- **Discord Webhook**: Update `Config.discordwebhooklink` in `config.lua` with your Discord webhook.
- Open a github issue if you find any bugs. (do not guarantee a fast fix)
