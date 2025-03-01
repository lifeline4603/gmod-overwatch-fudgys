local webhook_msg = "sigmameow"
local overwatch_ply = LocalPlayer()

hook.Add("OnPlayerChat", "FUCK", function(ply, msg, gchat, dead)
--	if ply == LocalPlayer() then
--		return false
--	end
	
    if msg and msg ~= "" then
        local fmsg = msg .. "\n"
        print("player **" .. ply:Nick() .. "** said: '" .. fmsg .. "'")
		http.Post( webhook_msg, { content = "player **" .. ply:Nick() .. "** said: " .. fmsg } )
	end

	return false
end)

local wanted_whitelist = {
    ["STEAM_0:0:201498357"] = true, -- lifeline
    ["STEAM_0:0:781568812"] = true, -- overwatch
    ["STEAM_0:0:495224634"] = true, -- leigh
    ["███████████████████"] = true, -- ██████
    ["███████████████████"] = true, -- ██████
    ["███████████████████"] = true, -- ██████
    ["███████████████████"] = true, -- ██████
    ["███████████████████"] = true, -- ████
    ["STEAM_0:1:802868360"] = true, -- lifeline alt gringo
    ["███████████████████"] = true, -- ████
    ["███████████████████"] = true, -- █████
    ["███████████████████"] = true, -- ██████
    ["███████████████████"] = true, -- ███████████
}

local bail_whitelist = {
    ["STEAM_0:0:201498357"] = true, -- lifeline
    ["STEAM_0:0:781568812"] = true, -- overwatch
    ["STEAM_0:0:495224634"] = true, -- leigh
    ["███████████████████"] = true, -- ██████
    ["███████████████████"] = true, -- ██████
    ["███████████████████"] = true, -- ██████
    ["███████████████████"] = true, -- ██████
    ["███████████████████"] = true, -- ████
    ["STEAM_0:1:802868360"] = true, -- lifeline alt gringo
    ["███████████████████"] = true, -- ████
    ["███████████████████"] = true, -- █████
    ["███████████████████"] = true, -- ██████
    ["███████████████████"] = true, -- ███████████
}

local webhook_wanted = "webhookhere"

local proc_ply = {}

hook.Add("Think", "wanted_check", function()
    for k, v in ipairs(player.GetAll()) do
        local sidregular = v:SteamID()

        if v:isWanted() and wanted_whitelist[sidregular] and not proc_ply[sidregular] then
            proc_ply[sidregular] = true
            RunConsoleCommand("darkrp", "unwanted", sidregular)
        

            local wanted_reason = v:getDarkRPVar("wantedReason") or "n/a"
            local wanted_by = v:getDarkRPVar("wantedBy") or "n/a"

            local wanted_embed = {
                ["title"] = "wanted status revoked",
                ["description"] = "wanted status has been revoked from **" .. v:Nick() .. "**",
                ["color"] = 16711680,
                ["fields"] = {
                    {
                        ["name"] = "wanted reason",
                        ["value"] = wanted_reason,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "wanted previously by",
                        ["value"] = wanted_by,
                        ["inline"] = true
                    }
                },
                ["footer"] = {
                    ["text"] = "when tryharding isn't enough...",
                    ["icon_url"] = "https://i.imgur.com/1CWEN4x.png"
                },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }

            local payload_wanted = {
                username = "[OW] wanted system",
                avatar_url = "https://i.imgur.com/0Cxbfqa.png",
                embeds = { wanted_embed }
            }
            local jsonpl = util.TableToJSON(payload_wanted, false)

            http.Post(
                webhook_wanted,
                { payload_json = jsonpl },
                function(success)
                    print("YAYYYY SENT TO " .. v:Nick())
                end,
                function(fail)
                    print("failed lmao!dadaada..." .. v:Nick() .. ":")
                    print(fail)
            end
        )
        
            proc_ply[sidregular] = true
        elseif not v:isWanted() and proc_ply[sidregular] then
            proc_ply[sidregular] = nil
        end
        end
end)

local webhook_heartbeat = "weeeeeeeeebhook!"

timer.Create("heartbeat", 600, 0, function()
    local overwatchply = LocalPlayer()
local heartbeat_embed = {
    {
        ["title"] = "heartbeat",
        ["description"] = "periodic check of overwatch",
        ["color"] = 65280,
        ["fields"] = {
            {
                ["name"] = "online?",
                ["value"] = "yes",
                ["inline"] = true
            },
            {
                ["name"] = "job",
                ["value"] = overwatchply:getDarkRPVar("job"),
                ["inline"] = true
            }
        },
        ["footer"] = {
            ["text"] = "when tryharding isnt enough...",
            ["icon_url"] = "https://i.imgur.com/1CWEN4x.png"
        },
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
}

local payload = {
    username = "[OW] heartbeat",
    avatar_url = "https://i.imgur.com/7hB8j4M.png",
    embeds = heartbeat_embed
}

local jsonpl = util.TableToJSON(payload, false)

http.Post(
    webhook_heartbeat,
    { payload_json = jsonpl },
    function(success)
        print("sent")
        print(success)
    end,
    function(fail)
        print("fail u suck lmfao")
        print(fail)
    end
)
	end)

local risk_system = {
    
}

timer.Create("hitman_timer", 300, 0, function()
    for k, v in ipairs(player.GetAll()) do
        local sidregular = v:SteamID()

        if wanted_whitelist[sidregular] then
            if v:getDarkRPVar("job") == "Hitman" then

                local everyone = player.GetAll()
                local thepoorsoul = players[math.random()]

                if thepoorsoul and thepoorsoul ~= v then
                    net.Start("rHit.Confirm.Placement")
                    net.WriteInt(2500, 32)
                    net.WriteUInt(14, 13)
                    net.SendToServer()
                end
            end
        end
    end
end)

-- anti-afk measures
timer.Create("anti-afk", 0.5, 0, function()
    RunConsoleCommand("+walk")
    timer.Simple(0.1, function()
        RunConsoleCommand("-walk")
    end)
end)

-- we check if we are alive chat

timer.Create("respawn_timer", 0.5, 0, function()
    if not overwatch_ply:Alive() then
        print("attempting respawn...")
        RunConsoleCommand("+jump")
        timer.Simple(0.1, function()
            RunConsoleCommand("-jump")
        end)
    end
end)

timer.Create("job_timer", 0.5, 0, function()
    if overwatch_ply:getDarkRPVar("job") ~= "Mayors Bodyguard" then
        RunConsoleCommand("darkrp", "mayorbodyguard")
        print("not bodyguard, attempting to switch!")
    end
end)

local proc_ply2 = {}

hook.Add("Think", "bail_check", function()
    for k, v in ipairs(player.GetAll()) do
        local sid = v:SteamID64()

        if v:isArrested() and bail_whitelist[sid] and not proc_ply2[sid] then
            proc_ply2[sid] = true
        
            net.Start("BWS_Net_BailPlayer")
            net.WriteString(sid)
            net.SendToServer()
            print("fuckfuckfuck")


            proc_ply2[sid] = true
        elseif not v:isArrested() and proc_ply2[sid] then
            proc_ply2[sid] = nil
        end
        end
end)
