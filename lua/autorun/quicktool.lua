--
-- Quicktool Menu
-- Adds a quicktool menu for easier tool-access
	

	-- Include Options menu LUA
	
if SERVER then	
	AddCSLuaFile("quicktool-options.lua")
	AddCSLuaFile("quicktool-utils.lua")
end
	
if CLIENT then
	-- Variables used globally
	quicktoolConfig = {}								-- Config object
	quicktoolConfigTools = {}							-- Config object - Tools
	quicktoolConfigPresets = {}						-- Config object - Presets
	SToolButtons = {}								-- Search Menu
	Results = {}									-- Search menu - Results
	local quicktoolMenuShown = false				-- Is the menu visible?
	local screenCenterX = ScrW() / 2		-- X center
	local screenCenterY = ScrH() / 2		-- Y center
	local pi = 4 * math.atan2(1, 1)			-- Pi (Yum :)
	local quicktoolEntrySize = 0						-- How many degrees does a menu entry span?
	local quicktoolMenuSelectedTool = 0		-- The currently selected tool
	local quicktoolVersion = "2014-10-21"	-- Used for config file checking
	
	--[[
	local toolbuttons = {}
	hook.Add("PostReloadToolsMenu", "toolcpanel_ListTools",function()
	local toolmenu = g_SpawnMenu:GetToolMenu()
	for toolpanelid=1,#toolmenu.ToolPanels do
		if toolmenu:GetToolPanel(toolpanelid) and toolmenu:GetToolPanel(toolpanelid).List.GetChildren and toolmenu:GetToolPanel(toolpanelid).List:GetChildren()[1] then
			for sectionid,section in pairs(toolmenu:GetToolPanel(toolpanelid).List:GetChildren()[1]:GetChildren()) do
				for buttonid,button in pairs(section:GetChildren()) do
					if tobool(button.Command) then toolbuttons[button.Command] = button end
				end
			end
		end
	end
	end)
	concommand.Add("toolcpanel", function(ply,cmd,args)
	local panel = toolbuttons["gmod_tool "..args[1]]--
	--[[
	if panel then panel:DoClick() end
	end)
	]]--
	
	
	include("quicktool-options.lua")
	include("quicktool-utils.lua")

	-- Config Setup, check for an existing config
	if file.Exists("data/quicktool-config.txt", "game") and file.Exists("data/quicktool-config-tools.txt", "game") then
		-- Config files exists, read and parse
		local configFile = file.Read("data/quicktool-config.txt", "game")

		-- Check that we read something, and that there's actually data in our variable
		if (configFile and #configFile > 0) then
			quicktoolConfig = util.KeyValuesToTable(configFile)

			-- Version Check, if its a new version, reset the config var so we use the default instead
			if quicktoolConfig["quicktool-version"] ~= quicktoolVersion then
				--quicktoolConfig = {}
			end
		end

		-- Tools
		configFile = file.Read("data/quicktool-config-tools.txt", "game")

		if (configFile and #configFile > 0) then
			quicktoolConfigTools = util.KeyValuesToTable(configFile)
			
			-- Seems like numeric type information is lost when saving tables using KeyValuesToTable
			--   Writing a new table-saver could be an exercise later?
			local tempToolTable = {}

			for k,v in pairs(quicktoolConfigTools) do				
				if (type(k) ~= "number") then
					-- Convert key value from string to numeric
					tempToolTable[tonumber(k)] = v
				else
					tempToolTable[k] = v
				end
			end
			
			quicktoolConfigTools = tempToolTable
			tempToolTable = nil

			if (quicktoolConfig["quicktool-version"] ~= quicktoolVersion) then
				for k,v in pairs(quicktoolConfigTools) do
					if (v.color == nil) then
						v.color = Color(100, 100, 100, 255)
					end
					
					if (string.find(v.rconcommand, "gmod_tool") ~= nil) then
						quicktoolConfigTools = {}
					end
				end
				
				saveTools()
			end
		end
	end

	if file.Exists("data/quicktool-config-presets.txt", "game") then

		local configFile = file.Read("data/quicktool-config-presets.txt", "game")

		if (configFile and #configFile > 0) then

			quicktoolConfigPresets = util.KeyValuesToTable(configFile)

			local tempPresetTable = {}

			for k,v in pairs(quicktoolConfigPresets) do				
				if (type(k) ~= "number") then
					-- Convert key value from string to numeric
					tempPresetTable[tonumber(k)] = v
				else
					tempPresetTable[k] = v
				end
			end

			quicktoolConfigPresets = tempPresetTable
			tempPresetTable = nil

		end
	end
	
	if table.Count(quicktoolConfig) == 0 then
		-- Default Config
		--quicktoolConfig["quicktool-version"] = quicktoolVersion						-- Used for config file checking
		quicktoolConfig["quicktool-menudeadzone"] = 40									-- Defines the "dead area" around the screen center, where you can't select anything
		quicktoolConfig["quicktool-menufont"] = "DermaLarge"					-- Font used to print the quicktool menu
		quicktoolConfig["quicktool-menusplitterlength"] = 60						-- The lenght of the split-lines between menu items
		quicktoolConfig["quicktool-menushowsplitters"] = 1							-- Show or don't show the menu splitter lines
		quicktoolConfig["quicktool-menulabelssizedindividually"] = 1		-- Should all tool labels be the same size or not?
		quicktoolConfig["quicktool-menushowtraceline"] = 0							-- Draw a line from center screen to mouse cursor?
		
		-- Save config
		saveConfig()
	end
		-- Check if we read and parsed the config, and if not, create a default valued one
	if quicktoolConfig["quicktool-version"] ~= quicktoolVersion then
		quicktoolConfig["quicktool-version"] = quicktoolVersion
		saveConfig()
		savePresets()
	end
			-- Default Tools, only set these if they haven't been loaded before
	if table.Count(quicktoolConfigTools) == 0 then
		quicktoolConfigTools[1] = { name = "Phys Gun", rconcommand = "wep weapon_physgun", color = Color(100, 100, 100, 255)}
		quicktoolConfigTools[2] = { name = "Welder", rconcommand = "weld", color = Color(100, 100, 100, 255) }
		quicktoolConfigTools[3] = { name = "Remover", rconcommand = "remover", color = Color(100, 100, 100, 255) }
		quicktoolConfigTools[4] = { name = "Duplicator", rconcommand = "duplicator", color = Color(100, 100, 100, 255) }
		quicktoolConfigTools[5] = { name = "Axis", rconcommand = "axis", color = Color(100, 100, 100, 255) }

		-- Save the tool setup
		saveTools()
	end

	-- Calculate positions for the various quicktool menu entries
	function CalculateMenuLayout()
		local angle = 0				-- Our starting angle
		local longestName = 0	-- The length of the longest name, used to calculate x/y position
		quicktoolEntrySize = math.floor(360 / table.getn(quicktoolConfigTools))

		-- Find the pixelsize of the largest word, to get an even circle
		for key,value in pairs(quicktoolConfigTools) do
			-- Is this the longest name yet?
			surface.SetFont("DermaLarge")
			tw, th = surface.GetTextSize(value.name)
			
			if tw > longestName then longestName = tw end
		end

		-- Loop through all tools, and calculate span-angle, x/y position and menu-splitter
		for key,value in pairs(quicktoolConfigTools) do
			value.minangle = angle - (quicktoolEntrySize / 2)
			if value.minangle < 0 then value.minangle = 360 + value.minangle end	-- First tool MinAngle will always dip below 0, and have to "wrap" down from 360

			value.maxangle = angle + (quicktoolEntrySize / 2)

			value.xpos = screenCenterX - ((quicktoolConfig["quicktool-menudeadzone"] + (longestName / 2)) * math.sin((360 - angle) * (pi / 180)))	-- X position of the menu point text
			value.ypos = screenCenterY - ((quicktoolConfig["quicktool-menudeadzone"] + (longestName / 2)) * math.cos((360 - angle) * (pi / 180)))	-- Y position of the menu point text

			value.menusplitxinner = screenCenterX - (quicktoolConfig["quicktool-menudeadzone"] * math.sin((360 - value.minangle) * (pi / 180)))	-- Used to draw a split-line from center-screen, 100 pixels out
			value.menusplityinner = screenCenterY - (quicktoolConfig["quicktool-menudeadzone"] * math.cos((360 - value.minangle) * (pi / 180)))	-- -O-
			value.menusplitxouter = screenCenterX - ((quicktoolConfig["quicktool-menusplitterlength"] + quicktoolConfig["quicktool-menudeadzone"]) * math.sin((360 - value.minangle) * (pi / 180)))	-- -O-
			value.menusplityouter = screenCenterY - ((quicktoolConfig["quicktool-menusplitterlength"] + quicktoolConfig["quicktool-menudeadzone"]) * math.cos((360 - value.minangle) * (pi / 180)))	-- -O-

			-- Should labels be the same size or not?
			tw, th = surface.GetTextSize(value.name)
			
			if quicktoolConfig["quicktool-menulabelssizedindividually"] == 1 then
				-- Labels are individually sized
				value.labelwidth = tw
				value.labelheight = th
			else
				-- Labels are same size (ie, size of the longest name)
				value.labelwidth = longestName
				value.labelheight = th
			end

			-- Increase the angle
			angle = angle + quicktoolEntrySize
		end
		
		-- Set the last entrys max to the first entrys min, so we don't get any "empty" menu-space
		if quicktoolConfigTools and #quicktoolConfigTools > 0 then
			quicktoolConfigTools[table.getn(quicktoolConfigTools)].maxangle = quicktoolConfigTools[1].minangle
		end
	end

	-- Calculate the menu layout
	CalculateMenuLayout()

	-- Functions to show and hide the menu
	function ShowQuicktoolMenu()
		-- Enable mouse cursor
		gui.EnableScreenClicker(true)
		
		-- Set cursor centerscreen
		gui.SetMousePos(screenCenterX, screenCenterY)
		
		-- Show menu
		quicktoolMenuShown = true		
	end

	function HideQuicktoolMenu()
		-- Is there an active tool?
		if quicktoolMenuSelectedTool > 0 then
			-- Yes there is, select the tool
			local toolCommand = quicktoolConfigTools[quicktoolMenuSelectedTool].rconcommand
			local tempToolCommand = string.Explode(" ", quicktoolConfigTools[quicktoolMenuSelectedTool].rconcommand)
			local implodeToolCommand = ""
			local conCommand = ""

			if (tempToolCommand[1]:lower() == "wep") then
				RunConsoleCommand("give", tempToolCommand[2])
				RunConsoleCommand("use", tempToolCommand[2])
			elseif (tempToolCommand[1]:lower() == "con") then
				conCommand = tempToolCommand[2]
				table.remove(tempToolCommand,1)
				table.remove(tempToolCommand,1)
				implodeToolCommand = string.Implode(" ", tempToolCommand)
				if (implodeToolCommand != "") then
					RunConsoleCommand(conCommand, implodeToolCommand)
				else
					RunConsoleCommand(conCommand)
				end
				

			else
				--RunConsoleCommand("gmod_tool", toolCommand)
				spawnmenu.ActivateTool(toolCommand)
			end
			
			
			-- Now we dont have a selected tool
			quicktoolMenuSelectedTool = 0
		end
		
		-- Disable mouse cursor
		gui.EnableScreenClicker(false)

		-- Hide menu
		quicktoolMenuShown = false
	end
	
	-- Print text in a RoundedBox, centered at required coordinates, using given color
	function DrawQuicktoolMenuItem(itemText, itemXpos, itemYpos, labelWidth, labelHeight, boxColor, textColor)
		if not itemText then return end
		
		
		-- Draw the roundedbox
		-- draw.RoundedBox(8, (itemXpos - (labelWidth / 2) - 5), (itemYpos - (labelHeight / 2) - 2), labelWidth + 10, labelHeight + 4, boxColor)
		draw.RoundedBox(8, (itemXpos - (labelWidth / 2) + 10), (itemYpos - (labelHeight / 2) + 5), labelWidth - 20, labelHeight - 10, boxColor)
		-- Draw the text
		draw.SimpleText(itemText, quicktoolMenuFont, itemXpos, itemYpos, textColor, 1, 1)
	end
	
	function DrawQuicktoolMenu()
		-- Do not draw the menu if it is not shown
		if not quicktoolMenuShown then return end
		
		-- Draw a line from screen-center to mouse cursor, if enabled
		if quicktoolConfig["quicktool-menushowtraceline"] == 1 then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawLine(screenCenterX, screenCenterY, gui.MouseX(), gui.MouseY())					
		end
		
		-- Is the distance from screen-center to the cursor larger than the set deadspace?
		if math.Dist(screenCenterX, screenCenterY, gui.MouseX(), gui.MouseY()) > quicktoolConfig["quicktool-menudeadzone"] then
			-- We have moved out of the deadzone
			-- Calculate the angle from screen-center to the mousecursor, so we can determine which quicktool element the cursor is over
			local quicktoolSelectAngle = 360 - (math.deg(math.atan2(gui.MouseX() - screenCenterX, gui.MouseY() - screenCenterY)) + 180)	-- Manipulate the degrees, so we get 0 to be upwards, and increasing clockwise

			-- Loop tools them and find out which one is active
			for key,value in pairs(quicktoolConfigTools) do
				-- Check for a "normal" entry first (one that doesn't span 0)
				if (value.minangle <= quicktoolSelectAngle) and (value.maxangle > quicktoolSelectAngle) then
					-- We have found the active tool
					quicktoolMenuSelectedTool = key
					-- Break out of the for loop
					break
				end

				if value.minangle > value.maxangle then
					-- MinAngle is larger than MaxAngle, we have the entry that spans 0 degrees (straight up)
					if (value.minangle <= quicktoolSelectAngle) or (value.maxangle > quicktoolSelectAngle) then
						-- We have found the active tool
						quicktoolMenuSelectedTool = key

						-- Break out of the for loop
						break
					end
				end
			end			
		else
			-- We are in the deadzone, no tools are selected
			quicktoolMenuSelectedTool = 0
		end

		function getContrastYIQ(color)
		local r = color.r
		local g = color.g
		local b = color.b
			local yiq = ((r*299)+(g*587)+(b*114))/1000
			
			if (yiq >= 128) then
				return Color(0,0,0,255)
			else
				return Color(255,255,255,255)
			end
		end

		-- Draw the tool menu entries
		for key,value in pairs(quicktoolConfigTools) do
			if key == quicktoolMenuSelectedTool then
			invertColor = Color(255 - value.color.r, 255 - value.color.g, 255 - value.color.b, value.color.a)
				-- This is the selected tool
				DrawQuicktoolMenuItem(value.name, value.xpos, value.ypos, value.labelwidth, value.labelheight, invertColor, getContrastYIQ(invertColor))
				
			else
			invertColor = Color(255 - value.color.r, 255 - value.color.g, 255 - value.color.b, value.color.a)
				-- This is not the selected tool
				DrawQuicktoolMenuItem(value.name, value.xpos, value.ypos, value.labelwidth, value.labelheight, value.color, getContrastYIQ(value.color))
			end
			
			-- Draw the splitter-line, if the user wants to
			if quicktoolConfig["quicktool-menushowsplitters"] == 1 then
				surface.SetDrawColor(255, 255, 255, 80)
				surface.DrawLine(value.menusplitxinner, value.menusplityinner, value.menusplitxouter, value.menusplityouter)			
			end
		end				
	end

	-- Add hook to paint the quicktool menu
	hook.Add("HUDPaint", "DrawQuicktoolMenu", DrawQuicktoolMenu)
	
	-- Capture both left and right-click (to override left, and open settings menu on right
	function CaptureMouseClicks(mouseInfo)
		-- Do not do any of this if the menu is not shown
		if not quicktoolMenuShown then return end
		
		-- Handle different clicktypes
		if mouseInfo == 107 then
			-- Left click, just make it impossible to left-click
			return true
		elseif mouseInfo == 108 then
			-- Right click, open the config menu
			-- openQuicktoolMenuConfig()
			
			return true
		end
	end
	hook.Add("GUIMousePressed", "CaptureMouseClicks", CaptureMouseClicks)
		
	
	-- Add con commands to show/hide the menu
	concommand.Add("+quicktool", ShowQuicktoolMenu)
	concommand.Add("-quicktool", HideQuicktoolMenu)
end
