# gmod-overwatch-fudgys
a garry's mod bot that carried out actions automatically on whitelisted people on the darkrp server fudgy gaming

## what is overwatch
overwatch is a bot i personally developed to gain an advantage for a garry's mod server called "fudgy gaming" a few months ago. it would be online 24/7 and was hosted on an actual VPS. this was some random alt account i picked and called "overwatch". what it did was exploit vulnerabilities and abuse tricks to give players in a whitelist an advantage. the bot could automatically remove the wanted status of people, bail people from distances and act as a stash account for trades and withdrawals. if anyone needed money, the account was always stocked up with money.

## how did it work
the way overwatch functioned was by having a steam account logged in the server at all times. this steam account for 24/7 uptime was hosted on a low end VPS hosted with contabo. the code was relatively simple. it basically just told it to wait for anyone on the whitelist to be wanted for example and to carry out the action. this wasnt perfect. sometimes the bot would crash or have an error. everytime i needed to push an update i would need to restart the game which took minutes and then join the server which also took a while. a high tier vps would have fixed this issue without a doubt.

## what were the features and what workarounds did you use for safety measures
the bot had a list of awesome features which will be explained below.

### send all ingame messages through a discord webhook
unfortunately i never got this to work due to the server using a weird addon that fucks up the OnPlayerChat hook.

### easy to add on whitelist
i had two whitelists. one for bails and another for wanted status. this added more customizability and control for the owner.
```lua
local wanted_whitelist = {
    ["STEAM_0:0:201498357"] = true, -- lifeline
    ["STEAM_0:0:781568812"] = true, -- overwatch
    ["STEAM_0:0:495224634"] = true, -- leigh
    ...
}

local bail_whitelist = {
    ["76561198363262442"] = true, -- lifeline
    ["76561199523403352"] = true, -- overwatch
    ["76561198950714996"] = true, -- leigh
    ...
}
```

this whitelist is used for 2 imporant features such as autobail and auto unwanted. its pretty interesting the way i made it to be fair.

### wanted checks
overwatch has a Think hook constantly checking if anyone from the whitelist is wanted. if they are, they get unwanted. this also gets posted to a webhook of choice.
```lua
local webhook_wanted = "webhookhere"

local proc_ply = {}

hook.Add("Think", "wanted_check", function()
    for k, v in ipairs(player.GetAll()) do
        local steamID = v:SteamID()

        if v:isWanted() and wanted_whitelist[steamID] and not proc_ply[steamID] then
            proc_ply[steamID] = true
            RunConsoleCommand("darkrp", "unwanted", steamID)
        

            local wanted_reason = v:getDarkRPVar("wantedReason") or "n/a"
            local wanted_by = v:getDarkRPVar("wantedBy") or "n/a"

            local wanted_embed = {
                ["title"] = "wanted status revoked",
                ["description"] = "wanted status has been revoked from **" .. v:Nick() .. "**",
                ...
            end
        end
    end
end)
```
FOOTAGE OF IT WORKING BELOW CLICK IT!!!!

[![footage of it working here](https://img.youtube.com/vi/9Lc5tMaPyII/0.jpg)](https://www.youtube.com/watch?v=9Lc5tMaPyII)

![](https://strw.club/images/m9xxtfr02zx6t9d.png)

### heartbeat
this was a simple way of checking if the bot was on the server. it basically communicated to a webhook every 600 seconds to post a "hey im still in" message so we would know if it crashed or stopped working at some point.
```lua
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
...
```
this would also tell us what job it was which played a critical role. more later on!

![](https://strw.club/images/n3ss9i8cv1wujtj.png)

### risk system
inspired by the now discontinued D3C or more commonly known as bitchbot or baconbot, it was a list of players that we didnt like or were a risk to be around as they might suspect us. this was never fully implemented but we had plans to automatically place hits on them through the phone. it was a pretty funny idea that sadly never got implemented. it would have been really funny if the same people kept getting hits. since we had infinite money, we could do anything.

### auto hits
this system was designed to work with the risk system but it never happened so it became its standalone feature. basically what it does is it abuses an exploit that allows you to place hits across the map on anyone even if they arent a hitman. this however checks if anyone from the whitelist is a hitman and if they are it starts placing random hts. we never saw this in action so we can neither confirm or deny if this works. if it worked tho this would essentially double the amount of hits for the player.

```lua
timer.Create("hitman_timer", 300, 0, function()
    for k, v in ipairs(player.GetAll()) do
        local steamID = v:SteamID()

        if wanted_whitelist[steamID] then
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
```

### auto bail
this system automatically bailed people in the whitelist. this worked really well surprisingly! it was really funny to see some reactions as this would bypass the bail npc being locked by the mayor.
```lua
hook.Add("Think", "bail_check", function()
    for k, v in ipairs(player.GetAll()) do
        local steamID64 = v:SteamID64()

        if v:isArrested() and bail_whitelist[steamID64] and not proc_ply2[steamID64] then
            proc_ply2[steamID64] = true
        
            net.Start("BWS_Net_BailPlayer")
            net.WriteString(steamID64) -- any steamid works no distance checks lmao
            net.SendToServer()
            print("fuckfuckfuck")


            proc_ply2[steamID64] = true
        elseif not v:isArrested() and proc_ply2[steamID64] then
            proc_ply2[steamID64] = nil
        end
        end
end)
```

### job check
overwatch in order to function needed to be the mayors bodyguard as it had access to the unwanted command and never required a vote.
```lua
timer.Create("job_timer", 0.5, 0, function()
    if overwatch_ply:getDarkRPVar("job") ~= "Mayors Bodyguard" then
        RunConsoleCommand("darkrp", "mayorbodyguard")
        print("not bodyguard, attempting to switch!")
    end
end)
```
if it wasnt mayor's bodyguard, it would basically attempt to switch to it.

### respawn system
in order for it to unwanted people and carry out certain actions it needed to be alive. sometimes it would get rdmd so we made it so it automatically tries respawning if its dead.
```lua
timer.Create("respawn_timer", 0.5, 0, function()
    if not overwatch_ply:Alive() then
        print("attempting respawn...")
        RunConsoleCommand("+jump")
        timer.Simple(0.1, function()
            RunConsoleCommand("-jump")
        end)
    end
end)
```

### anti afk measures
the bot would obviously get marked as afk if it stands still for a while. it could get demoted from the job if done for too long and despawn if its in spawn. in order to circumvent this i tried adding a good anti afk measure. i found out that constantly toggling +walk on and off which is the modifier for alt-walking (slow walk) would count as player activity. it never moved the player but it also never marked them as afk which was genius!
```lua
timer.Create("respawn_timer", 0.5, 0, function()
    if not overwatch_ply:Alive() then
        print("attempting respawn...")
        RunConsoleCommand("+jump")
        timer.Simple(0.1, function()
            RunConsoleCommand("-jump")
        end)
    end
end)
```

---------------------------------------

there was more planned but it was never done so here we are. feel free to use. merges will get ignored.
