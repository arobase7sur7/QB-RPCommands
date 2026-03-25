RegisterNetEvent('sendMessageShowID')
AddEventHandler('sendMessageShowID', function(id, displayName, firstName, lastName, gender, birthdate, age, idNumber)
    local myId = PlayerId()
    local pid = GetPlayerFromServerId(id)
    if pid == -1 then return end
    if pid == myId or #(GetEntityCoords(GetPlayerPed(myId)) - GetEntityCoords(GetPlayerPed(pid))) < 10 then
        local genderText = (gender == 1 or gender == 'f' or gender == 'F') and "Female" or "Male"
        local htmlCard = [[
            <style>
                .id-container {
                    display: flex;
                    justify-content: center;
                    margin: 10px 0;
                }
                .id-card {
                    background: linear-gradient(145deg, #f5f5f5 0%, #e0e0e0 100%);
                    background-image: url('https://www.transparenttextures.com/patterns/brushed-alum.png');
                    border: 2px solid #999;
                    border-radius: 10px;
                    padding: 15px;
                    width: 400px;
                    font-family: 'Segoe UI', Arial, sans-serif;
                    color: #222;
                    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
                    position: relative;
                }
                .id-header {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    border-bottom: 2px solid #2d5a7b;
                    margin-bottom: 15px;
                    padding-bottom: 5px;
                }
                .id-title {
                    font-size: 15px;
                    font-weight: 900;
                    color: #2d5a7b;
                    text-transform: uppercase;
                    letter-spacing: 1px;
                }
                .id-body {
                    display: grid;
                    grid-template-columns: 1fr 1fr;
                    gap: 12px;
                }
                .id-field {
                    padding: 4px;
                }
                .id-label {
                    font-size: 9px;
                    font-weight: 700;
                    color: rgba(51, 51, 51, 1);
                    text-transform: uppercase;
                    display: block;
                }
                .id-value {
                    font-size: 14px;
                    font-weight: 600;
                    color: #000;
                    display: block;
                    border-bottom: 1px solid #bbb;
                }
                .id-footer {
                    margin-top: 15px;
                    font-size: 9px;
                    text-align: center;
                    color: #565656ff;
                    border-top: 1px solid #ddd;
                    padding-top: 5px;
                }
            </style>
            <div class="id-container">
                <div class="id-card">
                    <div class="id-header">
                        <div class="id-title">Identification Card</div>
                    </div>
                    <div class="id-body">
                        <div class="id-field" style="grid-column: span 2;">
                            <span class="id-label">Name</span>
                            <span class="id-value">]] .. firstName .. " " .. lastName .. [[</span>
                        </div>
                        <div class="id-field">
                            <span class="id-label">Gender</span>
                            <span class="id-value">]] .. genderText .. [[</span>
                        </div>
                        <div class="id-field">
                            <span class="id-label">Age</span>
                            <span class="id-value">]] .. age .. [[</span>
                        </div>
                        <div class="id-field">
                            <span class="id-label">Birthdate</span>
                            <span class="id-value">]] .. birthdate .. [[</span>
                        </div>
                        <div class="id-field">
                            <span class="id-label">ID Number</span>
                            <span class="id-value">]] .. idNumber .. [[</span>
                        </div>
                    </div>
                    <div class="id-footer">
                        STATE OF SAN ANDREAS - DEPARTMENT OF JUSTICE
                    </div>
                </div>
            </div>
        ]]
        TriggerEvent('chat:addMessage', {
            args = {"Identity Card"},
            templateId = 'identity_card',
            template = htmlCard,
            color = {255, 255, 255}
        })
    end
end)

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
    Wait(2000)
    RegisterClientCommands()
    Wait(5000)
    RegisterClientCommands()
end)

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
