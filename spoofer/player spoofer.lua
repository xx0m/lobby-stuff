local js = panorama['open']()
local MyPersonaAPI, LobbyAPI, PartyListAPI, FriendsListAPI = js['MyPersonaAPI'], js['LobbyAPI'], js['PartyListAPI'], js['FriendsListAPI']
local S = {}

if (not LobbyAPI.IsSessionActive()) then
    LobbyAPI.CreateSession()
    PartyListAPI.SessionCommand('MakeOnline', '')
end

local events = panorama['loadstring']([[
    var waitForPlayerUpdateEventHandler = $.RegisterForUnhandledEvent( "PanoramaComponent_Lobby_PlayerUpdated", function(xuid) {});

    return {
        start: function(message) {
            PartyListAPI.UpdateSessionSettings(message);

            waitForPlayerUpdateEventHandler = $.RegisterForUnhandledEvent( "PanoramaComponent_Lobby_PlayerUpdated", function(xuid) {
                PartyListAPI.UpdateSessionSettings(message);
            });
        },
        stop: function(event) {
            $.UnregisterForUnhandledEvent('PanoramaComponent_Lobby_MatchmakingSessionUpdate', event);
        },
        get_event: function() {
            return waitForPlayerUpdateEventHandler
        }
    }
]])()

S['Config'] = {
    ['Panel'] = 'LUA',
    ['Side'] = 'B'
}

S['Data'] = {
    ['PlayerData'] = { -- dont touch the index numbers aka [0] -> [4], not conforming to my notes may cause errors & that's on you
        [0] = {
            ['Enable'] = true, -- Do you want this player to be spoofed?
            ['Rank'] = '-', -- Default is '-' to not change rank (ranks are case sensitive ie Silver IV)
            ['Level'] = -1, -- Default is -1 to not change level, must be positive otherwise it'll just display their normal rank
            ['Colour'] = '-', -- Default is '-' (Yellow Purple Green Blue Orange all case sensitive)
            ['Prime'] = true, -- Do you want this player to show prime status? (false appears as non prime person)
            ['Medal'] = 0, -- The medal to display on the person (diamond shattered web coin as example is 4553) (find medal ids here: https://tf2b.com/itemlist.php?gid=730)
            ['Commends'] = { -- self explanatory really
                ['Friendly'] = 0,
                ['Teacher'] = 0,
                ['Leader'] = 0
            }
        },
        [1] = {
            ['Enable'] = true,
            ['Rank'] = '-',
            ['Level'] = -1,
            ['Colour'] = '-',
            ['Prime'] = true,
            ['Medal'] = 0,
            ['Commends'] = {
                ['Friendly'] = 0,
                ['Teacher'] = 0,
                ['Leader'] = 0
            }
        },
        [2] = {
            ['Enable'] = true,
            ['Rank'] = '-',
            ['Level'] = -1,
            ['Colour'] = '-',
            ['Prime'] = true,
            ['Medal'] = 0,
            ['Commends'] = {
                ['Friendly'] = 0,
                ['Teacher'] = 0,
                ['Leader'] = 0
            }
        },
        [3] = {
            ['Enable'] = true,
            ['Rank'] = '-',
            ['Level'] = -1,
            ['Colour'] = '-',
            ['Prime'] = true,
            ['Medal'] = 0,
            ['Commends'] = {
                ['Friendly'] = 0,
                ['Teacher'] = 0,
                ['Leader'] = 0
            }
        },
        [4] = {
            ['Enable'] = true,
            ['Rank'] = '-',
            ['Level'] = -1,
            ['Colour'] = '-',
            ['Prime'] = true,
            ['Medal'] = 0,
            ['Commends'] = {
                ['Friendly'] = 0,
                ['Teacher'] = 0,
                ['Leader'] = 0
            }
        }
    },
    ['Ranks'] = {
        ['-'] = 0,
        ['Silver I'] = 1,
        ['Silver II'] = 2,
        ['Silver III'] = 3,
        ['Silver IV'] = 4,
        ['Silver Elite'] = 5,
        ['Silver Elite Master'] = 6,

        ['Gold Nova I'] = 7,
        ['Gold Nova II'] = 8,
        ['Gold Nova III'] = 9,
        ['Gold Nova Master'] = 10,
        ['Master Guardian I'] = 11,
        ['Master Guardian II'] = 12,

        ['Master Guardian Elite'] = 13,
        ['Distinguished Master Guardian'] = 14,
        ['Legendary Eagle'] = 15,
        ['Legendary Eagle Master'] = 16,
        ['Supreme Master First Class'] = 17,
        ['Global Elite'] = 18
    },
    ['Colours'] = {
        ['Yellow'] = 0,
        ['Purple'] = 1,
        ['Green'] = 2,
        ['Blue'] = 3,
        ['Orange'] = 4
    },
    ['ComboRanks'] = {},
    ['ComboColours'] = {}
}
-- ceebs typing / c+p them again
for k, v in pairs(S['Data']['Ranks']) do S['Data']['ComboRanks'][v + 1] = k end
for k, v in pairs(S['Data']['Colours']) do S['Data']['ComboColours'][v + 1] = k end

S['Funcs'] = {
    ['GetTarget'] = function()
        return S['Data']['PlayerData'][ui['get'](S['UI']['Target']['Element']) - 1]
    end,
    ['UpdateUI'] = function()
        local ply = S['Funcs']['GetTarget']()
        local base = S['UI']
        local commendType = ui['get'](base['Commend']['Element'])

        ui['set'](base['Enable']['Element'], ply['Enable'])
        ui['set'](base['Prime']['Element'], ply['Prime'])
        ui['set'](base['Rank']['Element'], ply['Rank'])
        ui['set'](base['Level']['Element'], ply['Level'])
        ui['set'](base['Colour']['Element'], ply['Colour'])
        ui['set'](base['Medal']['Element'], ply['Medal'])

        ui['set'](base['Commend']['Element'], commendType)
        ui['set'](base['Amt']['Element'], ply['Commends'][commendType])
    end,
    ['BuildJS'] = function()
        local updateMsg = ''

        events.stop(events.get_event())

        for i = 0, #S['Data']['PlayerData'] do
            local ply = S['Data']['PlayerData'][i]

            if (ply['Enable']) then
                if (PartyListAPI.GetCount() > 1 and PartyListAPI.GetXuidByIndex(i) ~= 0) then
                    local machineName = 'Update/Members/machine' .. i ..'/player0/game/'

                    if (ply['Rank'] ~= '-') then
                        updateMsg = updateMsg .. machineName .. 'ranking ' .. S['Data']['Ranks'][ply['Rank']] .. ' '
                    end

                    if (ply['Level'] ~= '-') then
                        updateMsg = updateMsg .. machineName .. 'level ' .. S['Data']['Ranks'][ply['Rank']] .. ' '
                    end

                    updateMsg = updateMsg .. machineName .. 'prime ' .. (ply['Prime'] and '1' or '0') .. ' '

                    if (ply['Medal'] ~= nil) then
                        updateMsg = updateMsg .. machineName .. 'medals [!' .. ply['Medal'] .. '][^' .. ply['Medal'] .. ' '
                    end

                    updateMsg = updateMsg .. machineName .. 'commends [f' .. ply['Commends']['Friendly'] .. '][t' .. ply['Commends']['Teacher'] .. '][l' .. ply['Commends']['Leader'] .. '] ';

                    if (ply['Colour'] ~= '-') then
                        updateMsg = updateMsg .. machineName .. 'teamcolor ' .. S['Data']['Colours'][ply['Colour']] .. ' '
                    end
                end
            end
        end

        events.start(updateMsg)
    end
}

S['UI'] = {
    ['Target'] = {
        ['Element'] = ui['new_slider'](S['Config']['Panel'], S['Config']['Side'], 'Target Player', 1, 5, 0),
        ['Callback'] = S['Funcs']['UpdateUI']
    },

    ['Enable'] = {
        ['Element'] = ui['new_checkbox'](S['Config']['Panel'], S['Config']['Side'], 'Enable for Player'),
        ['Callback'] = function(e)
            local ply = S['Funcs']['GetTarget']()

            if (ui['get'](e) ~= ply['Enable']) then
                ply['Enable'] = ui['get'](e)
        
                S['Funcs']['BuildJS']()
            end
        end
    },

    ['Prime'] = {
        ['Element'] = ui['new_checkbox'](S['Config']['Panel'], S['Config']['Side'], 'Prime Status'),
        ['Callback'] = function(e)
            local ply = S['Funcs']['GetTarget']()

            if (ui['get'](e) ~= ply['Prime']) then
                ply['Prime'] = ui['get'](e)
        
                S['Funcs']['BuildJS']()
            end
        end
    },

    ['Rank'] = {
        ['Element'] = ui['new_combobox'](S['Config']['Panel'], S['Config']['Side'], 'Modify Rank', S['Data']['ComboRanks']),
        ['Callback'] = function(e)
            local ply = S['Funcs']['GetTarget']()

            if (ui['get'](e) ~= ply['Rank']) then
                ply['Rank'] = ui['get'](e)
        
                S['Funcs']['BuildJS']()
            end
        end
    },

    ['Level'] = {
        ['Element'] = ui['new_slider'](S['Config']['Panel'], S['Config']['Side'], 'Modify Level', -1, 10000, -1),
        ['Callback'] = function(e)
            local ply = S['Funcs']['GetTarget']()

            if (ui['get'](e) ~= ply['Level']) then
                ply['Level'] = ui['get'](e)
        
                S['Funcs']['BuildJS']()
            end
        end
    },

    ['Colour'] = {
        ['Element'] = ui['new_combobox'](S['Config']['Panel'], S['Config']['Side'], 'Modify Colour', {'-', 'Yellow', 'Purple', 'Green', 'Blue', 'Orange'}),
        ['Callback'] = function(e)
            local ply = S['Funcs']['GetTarget']()

            if (ui['get'](e) ~= ply['Colour']) then
                ply['Colour'] = ui['get'](e)
        
                S['Funcs']['BuildJS']()
            end
        end
    },

    ['lblMedal'] = {
        ['Element'] = ui['new_label'](S['Config']['Panel'], S['Config']['Side'], 'Modify Medal'),
        ['Callback'] = function(e) end
    },

    ['Medal'] = {
        ['Element'] = ui['new_textbox'](S['Config']['Panel'], S['Config']['Side'], 'Modify Medal', ''),
        ['Callback'] = function(e)
            local ply = S['Funcs']['GetTarget']()
            local medal = ui['get'](e)

            if (medal ~= ply['Medal'] and tonumber(medal) ~= nil) then
                ply['Medal'] = medal
        
                S['Funcs']['BuildJS']()
            end
        end
    },

    ['Commend'] = {
        ['Element'] = ui['new_combobox'](S['Config']['Panel'], S['Config']['Side'], 'Commend Type', {'Friendly', 'Teacher', 'Leader'}),
        ['Callback'] = function(e)
            local ply = S['Funcs']['GetTarget']()
            local commendType = ui['get'](e)
            local commends = ui['get'](S['UI']['Amt']['Element'])

            if (ply['Commends'][commendType] ~= commends) then
                ui['set'](S['UI']['Amt']['Element'], ply['Commends'][commendType])
            end
        end
    },

    ['Amt'] = {
        ['Element'] = ui['new_slider'](S['Config']['Panel'], S['Config']['Side'], 'Modify Commends', -10000, 10000, -1),
        ['Callback'] = function(e)
            local ply = S['Funcs']['GetTarget']()
            local amt = ui['get'](e)
            local commendType = ui['get'](S['UI']['Commend']['Element'])

            if (amt ~= ply['Commends'][commendType]) then
                ply['Commends'][commendType] = amt
        
                S['Funcs']['BuildJS']()
            end
        end
    },

    ['Update Medal'] = {
        ['Element'] = ui['new_button'](S['Config']['Panel'], S['Config']['Side'], 'Update Medal', function(e) return end),
        ['Callback'] = function(e)
            local ply = S['Funcs']['GetTarget']()
            local medal = ui['get'](S['UI']['Medal']['Element'])
        
            if (medal ~= ply['Medal'] and (tonumber(medal) ~= nil)) then
                ply['Medal'] = medal
        
                S['Funcs']['BuildJS']()
            end
        end
    },

    ['Rand Stats'] = {
        ['Element'] = ui['new_button'](S['Config']['Panel'], S['Config']['Side'], 'Randomise All Player Stats', function(e) return end),
        ['Callback'] = function(e)
            local comboRanks = S['Data']['ComboRanks']
            local comboCols = S['Data']['ComboColours']
            local rand = client.random_int

            for _, v in pairs(S['Data']['PlayerData']) do
                v['Rank'] = comboRanks[rand(1, #comboRanks)]
                v['Level'] = rand(1, 10000)
                v['Colour'] = comboCols[rand(1, #comboCols)]
        
                v['Medal'] = rand(1, 5000)
        
                v['Prime'] = (rand(0, 1) == 1 and true or false)
        
                v['Commends']['Friendly'] = rand(-10000, 10000)
                v['Commends']['Teacher'] = rand(-10000, 10000)
                v['Commends']['Leader'] = rand(-10000, 10000)
            end
        
            S['Funcs']['BuildJS']()
            S['Funcs']['UpdateUI']()
        end
    }
}

S['Funcs']['BuildJS']()
S['Funcs']['UpdateUI']()

client.set_event_callback('shutdown', function()
    events.stop(events.get_event())
end)

for _, entry in pairs(S['UI']) do
    if (entry['Hidden']) then
        for _, hidden in pairs(entry['Hidden']) do
            if (type(hidden) == 'table') then
                ui['set_callback'](hidden['Element'], hidden['Callback'])
                ui['set_visible'](hidden['Element'], false)
            else
                ui['set_visible'](hidden, false)
            end
        end
    else
        ui['set_visible'](entry['Element'], true)
    end

    ui['set_callback'](entry['Element'], entry['Callback'])
end
