local js = panorama['open']()
local MyPersonaAPI, LobbyAPI, PartyListAPI, FriendsListAPI = js['MyPersonaAPI'], js['LobbyAPI'], js['PartyListAPI'], js['FriendsListAPI']
local L = {}

if (not LobbyAPI.IsSessionActive()) then
    LobbyAPI.CreateSession()
    PartyListAPI.SessionCommand('MakeOnline', '')
end

local events = panorama['loadstring']([[
    var waitForSearchingEventHandler = $.RegisterForUnhandledEvent('PanoramaComponent_Lobby_MatchmakingSessionUpdate', function() {});

    return {
        start: function(callback) {
            waitForSearchingEventHandler = $.RegisterForUnhandledEvent('PanoramaComponent_Lobby_MatchmakingSessionUpdate', callback);
        },
        stop: function(event) {
            $.UnregisterForUnhandledEvent('PanoramaComponent_Lobby_MatchmakingSessionUpdate', event);
        },
        get_event: function() {
            return waitForSearchingEventHandler;
        }
    }
]])()

L['Config'] = {
    ['Panel'] = 'LUA',
    ['Side'] = 'B'
}

L['Chat'] = {
    ['DefaultChatMsg'] = 'i\'m jackin off',
    ['ErrorPrefix'] = '#SFUI_QMM_ERROR_',
    ['Errors'] = {
        "1_FailPingServer",
        "1_FailReadyUp",
        "1_FailReadyUp_Title",
        "1_FailVerifyClan",
        "1_FailVerifyClan_Title",
        "1_InsufficientLevel",
        "1_InsufficientLevel02",
        "1_InsufficientLevel03",
        "1_InsufficientLevel04",
        "1_InsufficientLevel05",
        "1_NotLoggedIn",
        "1_NotVacVerified",
        "1_OngoingMatch",
        "1_PenaltySeconds",
        "1_PenaltySecondsGreen",
        "1_VacBanned",
        "1_VacBanned_Title",
        "ClientBetaVersionMismatch",
        "ClientUpdateRequired",
        "FailedToPingServers",
        "FailedToReadyUp",
        "FailedToSetupSearchData",
        "FailedToVerifyClan",
        "InvalidGameMode",
        "NoOngoingMatch",
        "NotLoggedIn",
        "NotVacVerified",
        "OperationPassInvalid",
        "OperationQuestIdInactive",
        "PartyRequired1",
        "PartyRequired2",
        "PartyRequired3",
        "PartyRequired4",
        "PartyRequired5",
        "PartyTooLarge",
        "SkillGroupLargeDelta",
        "SkillGroupMissing",
        "TournamentMatchInvalidEvent",
        "TournamentMatchNoEvent",
        "TournamentMatchRequired",
        "TournamentMatchSetupNoTeam",
        "TournamentMatchSetupSameTeam",
        "TournamentMatchSetupYourTeam",
        "TournamentTeamAccounts",
        "TournamentTeamSize",
        "UnavailMapSelect",
        "VacBanned",
        "X_AccountWarningNonPrime",
        "X_AccountWarningTrustMajor",
        "X_AccountWarningTrustMajor_Summary",
        "X_AccountWarningTrustMinor",
        "X_FailPingServer",
        "X_FailReadyUp",
        "X_FailVerifyClan",
        "X_InsecureBlocked",
        "X_InsufficientLevel",
        "X_InsufficientLevel02",
        "X_InsufficientLevel03",
        "X_InsufficientLevel04",
        "X_InsufficientLevel05",
        "X_NotLoggedIn",
        "X_NotVacVerified",
        "X_OngoingMatch",
        "X_PenaltySeconds",
        "X_PenaltySecondsGreen",
        "X_PerfectWorldDenied",
        "X_PerfectWorldRequired",
        "X_VacBanned"
    },
    ['QueueErrors'] = {
        'X_VacBanned',
        'X_PenaltySeconds',
        'X_InsecureBlocked',
        'SkillGroupLargeDelta'
    },
    ['MessageTypes'] = {
        'Invite',
        'Error',
        'Chat',
        'Start/Stop Queue',
        'Popup Window',
        'Ear Rape [1]',
        'Ear Rape [2]',
        'Mass Popup'
    },
    ['Colours'] = {
        'Red',
        'Green',
        'Yellow'
    }
}

L['Data'] = {
    ['Targets'] = {
        [0] = '-',
        [1] = '-',
        [2] = '-',
        [3] = '-',
        [4] = '-',
        [5] = '-'
    },
    ['BadMessages'] = {
        'Ear Rape [1]',
        'Ear Rape [2]',
        'Mass Popup'
    }
}

L['Funcs'] = {
    ['table.HasValue'] = function(tble, value)
        for _, v in ipairs(L['Data']['BadMessages']) do
            if (v == value) then
                return true
            end
        end
    
        return false
    end,
    ['arrToStr'] = function()
        local str = '['

        for _, v in pairs(L['Data']['Targets']) do
            str = string.format('%s\'%s\',', str, v)
        end

        return string.format('%s];', str)
    end,
    ['GetRandomErrorMessage'] = function()
        return L['Chat']['Errors'][client['random_int'](1, #L['Chat']['Errors'])]
    end,
    ['BuildFuncs'] = function()
        local trustOnSearch = ui['get'](L['UI']['TrustMsgOnSearch']['Element'])
        local errPrefix = L['Chat']['ErrorPrefix']
        local tfArrToStr = L['Funcs']['arrToStr']()
        local autoStopQueue = ui['get'](L['UI']['StopQueue']['Element'])
        local autoStopMsg = ui['get'](L['UI']['StopQueue']['Hidden']['Error']['Element'])
        local autoStopQueueSilent = ui['get'](L['UI']['StopQueue']['Hidden']['Silent']['Element'])
        local target = ui['get'](L['UI']['Target']['Element'])

        events.stop(events.get_event())

        events.start(panorama['loadstring'](string.format([[
            return function() {
                if (LobbyAPI.GetMatchmakingStatusString() == '#SFUI_QMM_State_find_searching') {
                    if (%s) {
                        let trustFactorData = %s
                        let sendTrustMsg = false;

                        for (let i = 0; i < trustFactorData.length; i++) {
                            let trustOption = trustFactorData[i];
            
                            if (trustOption != '-') {
                                let userXUID = PartyListAPI.GetXuidByIndex(i);

                                if (trustOption === 'Red' || trustOption === 'Yellow') {sendTrustMsg = true;}
                
                                let msgType = (trustOption === 'Red') ? 'ChatReportError' : 'ChatReportYellow';
                                let msgCol = (trustOption === 'Red') ? "error" : "yellow";
                                let trustMessage = (trustOption === 'Red') ? 'X_AccountWarningTrustMajor' : 'X_AccountWarningTrustMinor';
                
                                PartyListAPI.SessionCommand(`Game::${msgType}`, `run all xuid ${userXUID} ${msgCol} %s${trustMessage}`);
                            }
                        }
                
                        if (sendTrustMsg) {
                            PartyListAPI.SessionCommand('Game::ChatReportError', `run all xuid ${MyPersonaAPI.GetXuid()} error %sX_AccountWarningTrustMajor_Summary `);
                        }
                    }
    
                    if (%s) {
                        let target = (LobbyAPI.BIsHost()) ? PartyListAPI.GetXuidByIndex(%s) : MyPersonaAPI.GetXuid();
    
                        if (!%s) {
                            PartyListAPI.SessionCommand('Game::ChatReportError', `run all xuid ${target} error %s%s`);
                        }
    
                        LobbyAPI.StopMatchmaking();
                    }
                }
            }
        ]], tostring(trustOnSearch), tfArrToStr, errPrefix, errPrefix, tostring(autoStopQueue), (target - 1), tostring(autoStopQueueSilent), errPrefix, autoStopMsg                 ) )())
    end,
    ['ClearPopups'] = function()
        panorama.loadstring('UiToolkitAPI.CloseAllVisiblePopups()', 'CSGOMainMenu')()
    end,
    ['ExecuteMessage'] = function()
        local baseMsgType = L['UI']['MessageType']
        local msgType = ui['get'](baseMsgType['Element'])
        local msg, other, extra = 'Game::', '', ''
        local target = LobbyAPI.BIsHost() and PartyListAPI.GetXuidByIndex(ui['get'](L['UI']['Target']['Element']) - 1) or MyPersonaAPI.GetXuid()

        if (msgType == 'Chat') then
            msg = string.format('%sChat', msg)
            other = 'chat'
            extra = ui['get'](baseMsgType['Hidden']['Text']):gsub(' ', ' ') -- if we dont replace regular space with invisible character we cant have spaces in msg :^(
        elseif (msgType == 'Error') then
            other = ui['get'](baseMsgType['Hidden']['Colour'])

            if (other == 'Red') then
                msg = string.format('%sChatReportError', msg)
                other = 'error'
            else
                msg = string.format('%sChatReport%s', msg, other)

                other = other:lower()
            end

            extra = string.format('%s%s', extra, L['Chat']['ErrorPrefix'])

            if (ui['get'](baseMsgType['Hidden']['RandErr']['Element'])) then
                extra = string.format('%s%s', extra, L['Funcs']['GetRandomErrorMessage']())
            else
                extra = string.format('%s%s', extra, L['Chat']['Errors'][ ui['get'](baseMsgType['Hidden']['ErrorList']) + 1 ])
            end
        elseif (msgType == 'Invite') then
            msg = string.format('%sChatInviteMessage', msg)
            target = MyPersonaAPI.GetXuid()
            other = 'friend'
            extra = FriendsListAPI.GetXuidByIndex(client.random_int(1, FriendsListAPI.GetCount() - 1))
        elseif (msgType == 'Start/Stop Queue') then
            LobbyAPI.StartMatchmaking( '', '', '', '' )
            LobbyAPI.StopMatchmaking()

            return
        elseif (msgType == 'Popup Window') then
            msg = string.format('%sHostEndGamePlayAgain', msg)
        elseif (msgType == 'Ear Rape [1]') then
            for i = 1, ui['get'](L['UI']['LoopMessages']['Hidden']['Amt']) do
                LobbyAPI.StartMatchmaking( "", "", "", "" )
                LobbyAPI.StopMatchmaking()
            end

            return
        elseif (msgType == 'Ear Rape [2]') then
            for i = 1, ui['get'](L['UI']['LoopMessages']['Hidden']['Amt']) do
                PartyListAPI.SessionCommand('Game::Chat', string.format('run all xuid %s name %s chat ', MyPersonaAPI.GetXuid(), MyPersonaAPI.GetName()))
            end

            return
        else -- must be mass pop up
            for i = 1, ui['get'](L['UI']['LoopMessages']['Hidden']['Amt']) do
                PartyListAPI.SessionCommand('Game::HostEndGamePlayAgain', string.format('run all xuid %s', MyPersonaAPI.GetXuid()))
            end

            client['delay_call'](0.5, function()
                L['Funcs']['ClearPopups']()
            end)

            return
        end

        PartyListAPI.SessionCommand(msg, string.format('run all xuid %s %s %s', target, (#other > 1 and ' ' .. other or ''), (#extra > 1 and ' ' .. extra or '')))
    end,
    ['HandleMessage'] = function()
        local baseLoop = L['UI']['LoopMessages']['Hidden']
        local msgType = ui['get'](L['UI']['MessageType']['Element'])

        if (ui['get'](L['UI']['LoopMessages']['Element']) and not L['Funcs']['table.HasValue'](L['Data']['BadMessages'], msgType)) then
            for i = 1, ui['get'](baseLoop['Amt']) do
                L['Funcs']['ExecuteMessage']()

                if (not ui['get'](L['UI']['LoopMessages']['Element'])) then
                    break
                end
            end

            client['delay_call'](ui['get'](baseLoop['Delay']) / 1000, L['Funcs']['HandleMessage'])
        else
            L['Funcs']['ExecuteMessage']()
        end
    end
}

L['UI'] = {
    ['Target'] = {
        ['Element'] = ui['new_slider'](L['Config']['Panel'], L['Config']['Side'], 'Target Player', 1, 5, 0),
        ['Callback'] = function(e)
            ui['set'](L['UI']['TrustMsgOnSearch']['Hidden']['Message']['Element'], L['Data']['Targets'][ui['get'](e) - 1])

            L['Funcs']['BuildFuncs']()
        end
    },

    ['TrustMsgOnSearch'] = {
        ['Element'] = ui['new_checkbox'](L['Config']['Panel'], L['Config']['Side'], 'Trust Message on Search'),
        ['Hidden'] = {
            ['Message'] = {
                ['Element'] = ui['new_combobox'](L['Config']['Panel'], L['Config']['Side'], 'Trust Message', {'-', 'Yellow', 'Red'}),
                ['Callback'] = function(e)
                    local target = ui['get'](L['UI']['Target']['Element'])

                    if (L['Data']['Targets'][target - 1] ~= ui['get'](e)) then
                        L['Data']['Targets'][target - 1] = ui['get'](e)
                    end

                    L['Funcs']['BuildFuncs']()
                end
            }
        },
        ['Callback'] = function(e)
            ui['set_visible'](L['UI']['TrustMsgOnSearch']['Hidden']['Message']['Element'], ui['get'](e))

            L['Funcs']['BuildFuncs']()
        end
    },
    
    ['StopQueue'] = {
        ['Element'] = ui['new_checkbox'](L['Config']['Panel'], L['Config']['Side'], 'Auto Stop Queue'),
        ['Hidden'] = {
            ['Silent'] = {
                ['Element'] = ui['new_checkbox'](L['Config']['Panel'], L['Config']['Side'], 'Silent'),
                ['Callback'] = function(e)
                    ui['set_visible'](L['UI']['StopQueue']['Hidden']['Error']['Element'], not ui['get'](e))

                    L['Funcs']['BuildFuncs']()
                end
            },
            ['Error'] = {
                ['Element'] = ui['new_combobox'](L['Config']['Panel'], L['Config']['Side'], 'Queue Error', L['Chat']['QueueErrors']),
                ['Callback'] = function(e)
                    L['Funcs']['BuildFuncs']()
                end
            }
        },
        ['Callback'] = function(e)
            local bool = ui['get'](e)
            local base = L['UI']['StopQueue']['Hidden']

            ui['set_visible'](base['Silent']['Element'], bool)
            ui['set_visible'](base['Error']['Element'], bool)

            L['Funcs']['BuildFuncs']()
        end
    },

    ['LoopMessages'] = {
        ['Element'] = ui['new_checkbox'](L['Config']['Panel'], L['Config']['Side'], 'Loop Messages'),
        ['Hidden'] = {
            ['Delay'] = ui['new_slider'](L['Config']['Panel'], L['Config']['Side'], 'Spam Delay', 1, 1000, 250, true, 'ms'),
            ['Amt'] = ui['new_slider'](L['Config']['Panel'], L['Config']['Side'], 'Spam Per Loop', 1, 200, 1, true)
        },
        ['Callback'] = function(e)
            local bool = ui['get'](e)
            local base = L['UI']['LoopMessages']['Hidden']

            ui['set_visible'](base['Delay'], bool)
            ui['set_visible'](base['Amt'], bool)
        end
    },

    ['MessageType'] = {
        ['Element'] = ui['new_combobox'](L['Config']['Panel'], L['Config']['Side'], 'Message Type', L['Chat']['MessageTypes']),
        ['Hidden'] = {
            ['Text'] = ui['new_textbox'](L['Config']['Panel'], L['Config']['Side'], 'Message Text'),
            ['Colour'] = ui['new_combobox'](L['Config']['Panel'], L['Config']['Side'], 'Message Colour', L['Chat']['Colours']),
            ['RandErr'] = {
                ['Element'] = ui['new_checkbox'](L['Config']['Panel'], L['Config']['Side'], 'Random Error'),
                ['Callback'] = function(e) ui['set_visible'](L['UI']['MessageType']['Hidden']['ErrorList'], not ui['get'](e)) L['Funcs']['BuildFuncs']() end
            },
            ['ErrorList'] = ui['new_listbox'](L['Config']['Panel'], L['Config']['Side'], 'Error List', L['Chat']['Errors'])
        },
        ['Callback'] = function(e)
            local bool = (ui['get'](e) == 'Error')
            local base = L['UI']['MessageType']['Hidden']

            ui['set_visible'](base['Text'], (ui['get'](e) == 'Chat'))

            ui['set_visible'](base['Colour'], bool)

            ui['set_visible'](base['RandErr']['Element'], bool)

            if (ui['get'](base['RandErr']['Element'])) then
                ui['set_visible'](base['ErrorList'], not ui['get'](base['RandErr']['Element']))
            else
                ui['set_visible'](base['ErrorList'], bool)
            end

            L['Funcs']['BuildFuncs']()
        end
    },

    ['Close Windows'] = {
        ['Element'] = ui['new_button'](L['Config']['Panel'], L['Config']['Side'], 'Force Close Windows', function(e) return end),
        ['Callback'] = L['Funcs']['ClearPopups']
    },

    ['Execute Message'] = {
        ['Element'] = ui['new_button'](L['Config']['Panel'], L['Config']['Side'], 'Execute Message', function(e) return end),
        ['Callback'] = L['Funcs']['HandleMessage']
    }
}

client['set_event_callback']('shutdown', function()
    events.stop(events.get_event())
end)

L['Funcs']['BuildFuncs']()

for _, entry in pairs(L['UI']) do
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
