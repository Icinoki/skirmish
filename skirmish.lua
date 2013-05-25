--[[
Copyright (c) 2013, Ikonic
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Skirmish nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL IKONIC BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon = {}
_addon.name = 'Skirmish'
_addon.version = '1.2'
_addon.author = 'Ragnarok.Ikonic'

require 'tablehelper'
require 'mathhelper'
require 'stringhelper'

zoneTimeLimit = 0;
enemiesGoal = 0;
enemiesDefeated = 0;
obsidianObtained = 0;
obsidianTotal = 0;
possibleWeapons = {"bocluamni", "faizzeer", "aedold", "leisilonu", "iclamar", "shichishito", "crobaci", "ninza", "kannakiri", "hgafircian", "qatsunoci", "iizamal", "lehbrailg", "uffrat", "iztaasu"};
poolWeapons = {};
poolWeaponsRedone = {};
showName = 1;
showType = 1;
showTypeAbr = 1;
showJob = 1;

skirmishWeapons = T{};
-- skirmishWeapons.name.type.job
skirmishWeapons.bocluamni = {name="Bocluamni", type="Archery", typeAbr="Arch", job="RNG"};
skirmishWeapons.faizzeer = {name="Faizzeer", type="Axe", typeAbr="Axe", job="WAR/BST"};
skirmishWeapons.aedold = {name="Aedold", type="Club", typeAbr="Club", job="WHM"};
skirmishWeapons.leisilonu = {name="Leisilonu", type="Dagger", typeAbr="Dagger", job="THF/BRD/DNC"};
skirmishWeapons.iclamar = {name="Iclamar", type="Great Axe", typeAbr="GA", job="WAR"};
skirmishWeapons.shichishito = {name="Shichishito", type="Great Katana", typeAbr="GK", job="SAM"};
skirmishWeapons.crobaci = {name="Crobaci", type="Great Sword", typeAbr="GS", job="PLD/DRK/RUN"};
skirmishWeapons.ninza = {name="Ninza", type="Hand-to-Hand", typeAbr="H2H", job="MNK/PUP"};
skirmishWeapons.kannakiri = {name="Kannakiri", type="Katana", typeAbr="Katana", job="NIN"};
skirmishWeapons.hgafircian = {name="Hgafircian", type="Marksmanship", typeAbr="Marks", job="RNG/COR"};
skirmishWeapons.qatsunoci = {name="Qatsunoci", type="Polearm", typeAbr="Pole", job="DRG"};
skirmishWeapons.iizamal = {name="Iizamal", type="Scythe", typeAbr="Scythe", job="DRK"};
skirmishWeapons.lehbrailg = {name="Lehbrailg", type="Staff", typeAbr="Staff", job="BLM/SCH/GEO"};
skirmishWeapons.uffrat = {name="Uffrat", type="Staff", typeAbr="Staff", job="SMN"};
skirmishWeapons.iztaasu = {name="Iztaasu", type="Sword", typeAbr="Sword", job="RDM/PLD/BLU"};

function event_load()
	send_command('alias skirmish lua command skirmish')
	add_to_chat(55, "Loading ".._addon.name.." v".._addon.version.." (written by ".._addon.author..")")
	tb_create("skirmishTracker");
	createTextLabel();
	event_addon_command('help');
end

function event_unload()
	send_command('unalias skirmish')
	tb_delete("skirmishTracker");
	add_to_chat(55, "Unloading ".._addon.name.." v".._addon.version..".")
end

function event_addon_command(...)
    local args = {...}
    if args[1] ~= nil then
        comm = args[1]
        if comm:lower() == 'help' then
            add_to_chat(55,_addon.name.." v".._addon.version..' possible commands:')
            add_to_chat(55,'     //skirmish help  : Lists this menu.')
            add_to_chat(55,'     //skirmish start : Sets defaults and starts tracking.')
            add_to_chat(55,'     //skirmish stop  : Prints summary and stops tracking.')
            add_to_chat(55,'     //skirmish reset : Resets stats to default.')
            add_to_chat(55,'     //skirmish exit  : Prints summary and exits addon.')
		elseif comm:lower() == 'start' then
            start();
        elseif comm:lower() == 'stop' then
            stop();
		elseif comm:lower() == 'reset' then
			add_to_chat(160, _addon.name.." v".._addon.version.." resetting stats.");
            reset();
        elseif comm:lower() == 'exit' then
            stop();
			send_command('lua u skirmish')
        elseif comm:lower() == 'test' then
			send_command('input /echo 61 of 66 enemies vanquished.')
        elseif comm:lower() == 'test2' then
			send_command('input /echo You obtained 4 obsidian fragments!')
        elseif comm:lower() == 'test3' then
			send_command('input /echo You now possess 550 fragments of 9999 maximum.')
        elseif comm:lower() == 'test4' then
			send_command('input /echo '.. enemiesDefeated+1 ..' of '.. enemiesGoal .. ' enemies vanquished.')
        elseif comm:lower() == 'test5' then
			send_command('input /echo -A Shichishito')
			send_command('input /echo -An uffrat')
			send_command('input /echo -A lehbrailg')
			send_command('input /echo -A crobaci')
			send_command('input /echo -A iizamal')
        elseif comm:lower() == 'test6' then
			send_command('input /echo You will reap the spoils from accomplishing your primary objective:')
        elseif comm:lower() == 'test7' then
			send_command('input /echo You have 60 minutes (Earth time) to complete the battle.')
        else
			add_to_chat(160, "Not a valid ".._addon.name.." v".._addon.version.." command.  //skirmish help for a list of valid commands.");
            return
        end
	else
		event_addon_command('help')
    end
end

function reset()
	zoneTimeLimit = 0;
	enemiesGoal = 0;
	enemiesDefeated = 0;
	obsidianObtained = 0;
	obsidianTotal = 0;
	poolWeapons = {};
	createTextLabel();
	poolWeaponsRedone = {};
end

function start()
	tb_create("skirmishTracker");
	reset();
	createTextLabel();
end

function stop()
	if (enemiesGoal ~= 0) then
--		enemiesPercent = math.round((enemiesDefeated/enemiesGoal*100),2)
		enemiesPercent = string.format("%.2f", enemiesDefeated/enemiesGoal*100)
	else
		enemiesPercent = 0;
	end
	poolWeaponsDisplay();
	add_to_chat(160,_addon.name.." v".._addon.version..". final stats:")
	add_to_chat(160,"Defeated: "..enemiesDefeated.." of "..enemiesGoal.." ("..enemiesPercent.."%)")
	add_to_chat(160,"Obsidian Obtained: "..obsidianObtained..", Total: "..obsidianTotal)
	add_to_chat(160,"Pool Weapons: \n   "..table.concat(poolWeaponsRedone, '\n   '))
	tb_delete("skirmishTracker");
end

function event_incoming_text(original, modified, color)
	-- 61 of 66 enemies vanquished.
	if (string.find(original, "(%d+) of (%d+) enemies vanquished.")) then
		a,b,amount,bob = string.find(original, "(%d+) of (%d+) enemies")
		if (amount ~= nil) then
			enemiesDefeated = amount;
			enemiesGoal = bob;
		end
		createTextLabel();
	
	--	Primary objective: Vanquish 80 enemies.
	elseif (string.find(original, "Primary objective: Vanquish (%d+) enemies.")) then
		a,b,amount = string.find(original, "Vanquish (%d+) enemies.")
		if (amount ~= nil) then
			enemiesGoal = amount;
		end
		createTextLabel();

	--You have 60 minutes (Earth time) to complete the battle.
	elseif (string.find(original, "You have (%d+) minutes %(Earth time%) to complete the battle.")) then
		a,b,sTime = string.find(original, "You have (%d+) minutes %(Earth time%) to complete the battle.")
		if (sTime ~= nil) then
			zoneTimeLimit = sTime;
		end
		createTextLabel();
		
	-- You obtained 4 obsidian fragments! 
	elseif (string.find(original, "You obtained (%d+) obsidian fragment")) then
		a,b,amount = string.find(original, "You obtained (%d+) obsidian fragment")
		if (amount ~= nil) then
			obsidianObtained = obsidianObtained + amount;
			obsidianTotal = obsidianTotal + amount;
		end
		createTextLabel();
	
	-- You now possess 550 fragments of 9999 maximum. 
	elseif (string.find(original, "You now possess (%d+) fragments of 9999 maximum.")) then
		a,b,amount = string.find(original, "You now possess (%d+) fragments of 9999 maximum.")
		if (amount ~= nil) then
			obsidianTotal = amount;
		end
		createTextLabel();
		
	--You will reap the spoils from accomplishing your primary objective: 
	--You will reap the spoils from accomplishing your secondary objective: 
	elseif (string.find(original, "You will reap the spoils from accomplishing your (%a+) objective:")) then
		a,b,amount = string.find(original, "You will reap the spoils from accomplishing your (%a+) objective:")
		if (amount ~= nil) then
			poolWeapons = {};
		end
		
	-- -A qatsunoci
	-- -An uffrat
	elseif (string.find(original, "-(%a+) (%a+)")) then
		a,b,trash,filler,weapon = string.find(original, "(.*)-(%a+) (%a+)")
--		add_to_chat(14,"weapon? filler: "..filler..", weapon: "..weapon);
		if ((#trash == 0) and (weapon ~= nil)) then
			if (skirmishWeapons[weapon:lower()] ~= nil) then
				poolWeapons[#poolWeapons+1] = weapon:lower();
--				add_to_chat(160,"exists: "..skirmishWeapons[weapon:lower()].name);
			else
				--this should never fire
				add_to_chat(160,"weapon '"..weapon.."' doesn't exist");
			end
		end
		createTextLabel();
	end
	
end

function poolWeaponsDisplay()
		poolWeaponsRedone = {};

		if (poolWeapons ~= nil) then
			local pwrBlah = "";
			for i,v in ipairs(poolWeapons) do
				if showName == 1 then
					pwrBlah = skirmishWeapons[v].name
				end
				if (showType == 1) or (showTypeAbr == 1) or (showJob == 1) then
					pwrBlah = pwrBlah .. ": "
				end
				if showType == 1 then
					pwrBlah = pwrBlah .. skirmishWeapons[v].type
				end
				if (showTypeAbr == 1) or (showJob == 1) then
					pwrBlah = pwrBlah .. " : "
				end
				if showTypeAbr == 1 then
					pwrBlah = pwrBlah .. skirmishWeapons[v].typeAbr
				end
				if (showJob == 1) then
					pwrBlah = pwrBlah .. " : "
				end
				if showJob == 1 then
					pwrBlah = pwrBlah ..skirmishWeapons[v].job;
				end
				poolWeaponsRedone[#poolWeaponsRedone+1] = pwrBlah;
			end
		end
--	add_to_chat(160,'   '..table.concat(poolWeaponsRedone, '\n   '));
end

function createTextLabel()
	tb_set_bg_color("skirmishTracker", 200, 30, 30, 30)
	tb_set_bg_visibility("skirmishTracker", 1)
	tb_set_color("skirmishTracker", 255, 200, 200, 200)
	tb_set_font("skirmishTracker", "Arial", 8)
	tb_set_location("skirmishTracker", 750, 125) --5, 450)
	tb_set_visibility("skirmishTracker", 1)
	if (enemiesGoal ~= 0) then
--		enemiesPercent = math.round((enemiesDefeated/enemiesGoal*100),2)
		enemiesPercent = string.format("%.2f", enemiesDefeated/enemiesGoal*100)
	else
		enemiesPercent = 0;
	end
		poolWeaponsDisplay();
		tb_set_text("skirmishTracker", "Time Limit: "..zoneTimeLimit.." minutes\n"
		.."Defeated: "..enemiesDefeated.."\n"
		.."Goal: "..enemiesGoal.."\n"
		.."% Finished: "..enemiesPercent.."%\n"
		.."Obsidian: "..obsidianObtained.."\n"
		.."Total: "..obsidianTotal.."\n"
--		.."Possible Weapons: \n   "..table.concat(poolWeapons, '\n   '))
		.."Possible Weapons: \n   "..table.concat(poolWeaponsRedone, '\n   '));
end
