--
-- Quicktool Menu
-- Utils
--

if CLIENT then
	function saveConfig()	
		local configFile = util.TableToKeyValues(quicktoolConfig)
		file.Write("quicktool-config.txt", configFile)
	end
	
	function saveTools()
		-- Only save relevant information
		local saveToolTable = {}
		local toolEnum = 0
		
		for toolEnum = 1, table.getn(quicktoolConfigTools), 1 do
			saveToolTable[toolEnum] = { name = quicktoolConfigTools[toolEnum].name, rconcommand = quicktoolConfigTools[toolEnum].rconcommand, color = quicktoolConfigTools[toolEnum].color}
		end
	
		local configFile = util.TableToKeyValues(saveToolTable)
		file.Write("quicktool-config-tools.txt", configFile)
	end

	function savePresets()
		local savePresetsTable = {}
		local presetsEnum = 0
		for presetsEnum = 1, table.getn(quicktoolConfigPresets), 1 do
			savePresetsTable[presetsEnum] = {name = quicktoolConfigPresets[presetsEnum].name, presettable = quicktoolConfigPresets[presetsEnum].presettable}
		end
		local configFile = util.TableToKeyValues(savePresetsTable)
		file.Write("quicktool-config-presets.txt", configFile)
	end
end