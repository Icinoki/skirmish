_addon = {}
_addon.name = 'Skirmish'
_addon.version = '1.0'
_addon.author = 'Ragnarok.Ikonic'

enemiesGoal = 0;
enemiesDefeated = 0;
obsidianObtained = 0;
obsidianTotal = 0;

require 'tablehelper'
require 'mathhelper'

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
			send_command('input /echo '.. enemiesDefeated+1 ..' of 66 enemies vanquished.')
        else
            return
        end
	else
		event_addon_command('help')
    end
end

function reset()
	enemiesGoal = 0;
	enemiesDefeated = 0;
	obsidianObtained = 0;
	obsidianTotal = 0;
	createTextLabel();
end

function start()
	tb_create("skirmishTracker");
	reset();
	createTextLabel();
end

function stop()
	add_to_chat(160,_addon.name.." v".._addon.version..". final stats:")
	add_to_chat(160,"Defeated: "..enemiesDefeated.." of "..enemiesGoal.." ("..math.round((enemiesDefeated/enemiesGoal*100),2).."%)")
	add_to_chat(160,"Obsidian Obtained: "..obsidianObtained..", Total: "..obsidianTotal)
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

	-- You obtained 4 obsidian fragments! 
	elseif (string.find(original, "You obtained (%d+) obsidian fragments!")) then
		a,b,amount = string.find(original, "You obtained (%d+) obsidian fragments!")
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
	end
	
end

function createTextLabel()
	tb_set_bg_color("skirmishTracker", 200, 30, 30, 30)
	tb_set_bg_visibility("skirmishTracker", 1)
	tb_set_color("skirmishTracker", 255, 200, 200, 200)
	tb_set_font("skirmishTracker", "Arial", 8)
	tb_set_location("skirmishTracker", 5, 450)
	tb_set_visibility("skirmishTracker", 1)
	tb_set_text("skirmishTracker", "Defeated: "..enemiesDefeated.."\n"
		.."Goal: "..enemiesGoal.."\n"
		.."% Finished: "..math.round((enemiesDefeated/enemiesGoal*100),2).."%\n"
		.."Obsidian: "..obsidianObtained.."\n"
		.."Total: "..obsidianTotal)
end

