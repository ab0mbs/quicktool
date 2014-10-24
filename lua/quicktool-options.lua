--
-- Quicktool Menu
-- Options Menu
--

if CLIENT then
	local settingsPanelShown = false
	local selectedListTool = nil -- Currently selected tool (Really not nice to do in a global, but doesn't seem like theres any other way
	local selectedListPreset = nil
	local MaxItems = 12
	local FrameWidth = 192
	local ItemHeight = 16

	-- Add the current toolset to the listbox
	local function addToolsToListbox(listbox)
		-- Add tools to listbox
		local listboxTools = {}

		for k,v in pairs(quicktoolConfigTools) do
			listboxTools[k] = vgui.Create("DButton")
			listboxTools[k]:SetDrawBorder(false)
			listboxTools[k]:SetText(v.name)
			listboxTools[k]:SizeToContents()
			listboxTools[k]:SetTall(20)
			listboxTools[k].DoClick = function()
				if selectedListTool ~= nil then
					-- A tool was selected prior
					listboxTools[selectedListTool]:SetSelected(false)
					selectedListTool = k
					listboxTools[selectedListTool]:SetSelected(true)
				else
					-- No tool was selected
					selectedListTool = k
					listboxTools[selectedListTool]:SetSelected(true)
				end
			end

			-- Add the item to the listbox
			listbox:AddItem(listboxTools[k])	
		end
		
		-- If a tool is selected, draw it
		if selectedListTool ~= nil then
			listboxTools[selectedListTool]:SetSelected(true)
		end
	end

	local function addPresetsToListbox(presetsListbox)
		local listboxPresets = {}

		for k,v in pairs(quicktoolConfigPresets) do
			listboxPresets[k] = vgui.Create("DButton")
			listboxPresets[k]:SetDrawBorder(false)
			listboxPresets[k]:SetText(v.name)
			listboxPresets[k]:SizeToContents()
			listboxPresets[k]:SetTall(20)
			listboxPresets[k].DoClick = function()
				if selectedListPreset ~= nil then
					-- A tool was selected prior
					listboxPresets[selectedListPreset]:SetSelected(false)
					selectedListPreset = k
					listboxPresets[selectedListPreset]:SetSelected(true)
				else
					-- No tool was selected
					selectedListPreset = k
					listboxPresets[selectedListPreset]:SetSelected(true)
				end
			end

			-- Add the item to the listbox
			presetsListbox:AddItem(listboxPresets[k])
		end

		-- If a tool is selected, draw it
		if selectedListPreset ~= nil then
			listboxPresets[selectedListPreset]:SetSelected(true)
		end
	end
	
	--Set convar textbox to tool convar
	function PasteConvar( str2 )
		toolAddCon:SetText( str2 )
		toolAddName:SetText("")
		toolAddName:RequestFocus()
	end
	
	
	-- New Options menu drawing
	function OptionsMenu(optionsPanel)
		local toolEdited = 0
		-- Spacing
		local panelWide = optionsPanel:GetWide()
		optionsPanel:AddControl("Label", { Text = "Quicktool Settings" })
		optionsPanel:SetName("Quicktool Menu Settings")
		optionsPanel:SetSpacing(10)
		
	-- Add menu deadzone settings slider
		local deadzoneSlider = vgui.Create("DNumSlider")
		deadzoneSlider:SetText("Menu Deadzone")
		deadzoneSlider:SetMin( 0 )
		deadzoneSlider:SetMax( 200 )
		deadzoneSlider:SetDecimals( 0 )
		deadzoneSlider:SetValue(quicktoolConfig["quicktool-menudeadzone"])			
		deadzoneSlider.ValueChanged = function()
			quicktoolConfig["quicktool-menudeadzone"] = deadzoneSlider:GetValue()
				CalculateMenuLayout()
				saveConfig()
				saveTools()
			end		
		optionsPanel:AddItem(deadzoneSlider)
	
	-- Add "Labels sized individually" checkbox
	
		local labelSize = vgui.Create("DCheckBoxLabel")
			labelSize:SetText("Labels sized individually")
			labelSize:SizeToContents()
			labelSize:SetTextColor(Color(0,0,0,255))
			labelSize:SetValue(quicktoolConfig["quicktool-menulabelssizedindividually"])			
			labelSize.OnChange = function()
				if labelSize:GetChecked() then quicktoolConfig["quicktool-menulabelssizedindividually"] = 1 else quicktoolConfig["quicktool-menulabelssizedindividually"] = 0 end
				CalculateMenuLayout()
				saveConfig()
				saveTools()
			end
		optionsPanel:AddItem(labelSize)
		
	-- Add "Draw selector traceline" checkbox
		local drawTraceline = vgui.Create("DCheckBoxLabel")
			drawTraceline:SetText("Draw selector traceline")
			drawTraceline:SizeToContents()
			drawTraceline:SetTextColor(Color(0,0,0,255))
			drawTraceline:SetValue(quicktoolConfig["quicktool-menushowtraceline"])			
			drawTraceline.OnChange = function()
				if drawTraceline:GetChecked() then quicktoolConfig["quicktool-menushowtraceline"] = 1 else quicktoolConfig["quicktool-menushowtraceline"] = 0 end
				CalculateMenuLayout()
				saveConfig()
				saveTools()
			end
		optionsPanel:AddItem(drawTraceline)
		
	-- Add "Show menu splitters" checkbox	
		local showSplitters = vgui.Create("DCheckBoxLabel")
			showSplitters:SetText("Show menu splitters")
			showSplitters:SizeToContents()
			showSplitters:SetTextColor(Color(0,0,0,255))
			showSplitters:SetValue(quicktoolConfig["quicktool-menushowsplitters"])			
			showSplitters.OnChange = function()
				if showSplitters:GetChecked() then quicktoolConfig["quicktool-menushowsplitters"] = 1 else quicktoolConfig["quicktool-menushowsplitters"] = 0 end
				CalculateMenuLayout()
				saveConfig()
				saveTools()
			end
		optionsPanel:AddItem(showSplitters)
	
	-- Add "Splitter Length" slider
		local splitterSlider = vgui.Create("DNumSlider")
			splitterSlider:SetText("Splitter Length")
			splitterSlider:SetMin(1)
			splitterSlider:SetMax(200)
			splitterSlider:SetDecimals(0)			
			splitterSlider:SetValue(quicktoolConfig["quicktool-menusplitterlength"])			
			splitterSlider.ValueChanged = function()
				quicktoolConfig["quicktool-menusplitterlength"] = splitterSlider:GetValue()
				CalculateMenuLayout()
				saveConfig()
				saveTools()
			end
		
		optionsPanel:AddItem(splitterSlider)
		
	-- Add tools list panel
		local toolsListPanel = vgui.Create("DPanel")
			toolsListPanel:SetWide(panelWide)
			toolsListPanel:SetTall(250)
			toolsListPanel:SetVisible(true)
		
		local toolsListPanelWide = toolsListPanel:GetWide()
		
	-- Add tools list
		local toolsList = vgui.Create("DPanelList", toolsListPanel)
			toolsList:SetSize(10,238)
			toolsList:SizeToContentsX()
			toolsList:SetSpacing(2)
			toolsList:SetPadding(2)
			toolsList:EnableHorizontal(false)
			toolsList:EnableVerticalScrollbar(true)
			
			-- Add the current tools to the listbox
			addToolsToListbox(toolsList)
		
		optionsPanel:AddItem(toolsListPanel)
		toolsListPanel:InvalidateLayout(true)
		toolsListPanel.PerformLayout = function()
		local toolsListPanelWide = toolsListPanel:GetWide()
		toolsList:SetWide(toolsListPanelWide - 12)
		toolsList:SetTall(238)
		toolsList:SetPos(6,6)
		end
		
	-- Create move tools panel
	local moveToolsPanel = vgui.Create("DPanel")
		moveToolsPanel:SetWide(panelWide)
		moveToolsPanel:SetTall(20)
		moveToolsPanel:SetVisible(true)
		
	local moveToolsWide = moveToolsPanel:GetWide()

	-- Add UP Button
		local toolUpButton = vgui.Create("DButton", moveToolsPanel)
			toolUpButton:SetText("UP")
			toolUpButton:SetPos(0, 0)
			toolUpButton:SetTall(20)
			toolUpButton:SetVisible(true)
			toolUpButton.DoClick = function()
				-- Check if the selected tool is the first
				if selectedListTool ~= nil and selectedListTool > 1 then
					-- Not the first, we do a swap
					local tempTool = quicktoolConfigTools[selectedListTool - 1]
					quicktoolConfigTools[selectedListTool - 1] = quicktoolConfigTools[selectedListTool]
					quicktoolConfigTools[selectedListTool] = tempTool

					selectedListTool = selectedListTool - 1

					-- Clean and redraw the listbox
					toolsList:Clear()
					
					addToolsToListbox(toolsList)
					CalculateMenuLayout()
					saveConfig()
					saveTools()
				end
			end
		
	-- Add delete button
		local toolDeleteButton = vgui.Create("DButton", moveToolsPanel)
			toolDeleteButton:SetText("Delete")
			toolDeleteButton:SetTall(20)
			toolDeleteButton:SetVisible(true)
			toolDeleteButton.DoClick = function()
				-- Delete the selected tool, if a tool is selected
				if selectedListTool ~= nil then
					quicktoolConfigTools[selectedListTool] = nil
					
					-- Check if index is fragmented
					if not table.IsSequential(quicktoolConfigTools) then
						-- Table needs to be reordered
						local tempToolTable = {}
						local tempToolTableCounter = 1
						
						for k,v in pairs(quicktoolConfigTools) do
							tempToolTable[tempToolTableCounter] = v
							
							tempToolTableCounter = tempToolTableCounter + 1
						end
						
						quicktoolConfigTools = tempToolTable					
						tempToolTable = nil
					end
	
					-- No tool is selected
					selectedListTool = nil
					
					-- Clean and redraw the listbox
					toolsList:Clear()
					
					-- Clear the tool name and con command labels
					toolAddCon:SetText("")
					toolAddName:SetText("")
					
				if toolEdited ~= 0 then
					toolEditButton:SetText("Edit Tool")
					toolEdited = 0
				end
					
					addToolsToListbox(toolsList)
					CalculateMenuLayout()
					saveConfig()
					saveTools()
				end
			end
	
	-- Add Down button
		local toolDownButton = vgui.Create("DButton", moveToolsPanel)
			toolDownButton:SetText("DOWN")
			toolDownButton:SetTall(20)
			toolDownButton:SetVisible(true)
			toolDownButton.DoClick = function()
				-- Check if the selected tool is the last
				if selectedListTool ~= nil and selectedListTool < table.getn(quicktoolConfigTools) then
					-- Not the last, we do a swap
					local tempTool = quicktoolConfigTools[selectedListTool + 1]
					quicktoolConfigTools[selectedListTool + 1] = quicktoolConfigTools[selectedListTool]
					quicktoolConfigTools[selectedListTool] = tempTool
					
					selectedListTool = selectedListTool + 1
					
					-- Clean and redraw the listbox
					toolsList:Clear()
					
					addToolsToListbox(toolsList)
					CalculateMenuLayout()
					saveConfig()
					saveTools()					
				end
			end
			
		optionsPanel:AddItem(moveToolsPanel)
		moveToolsPanel:InvalidateLayout(true)
		moveToolsPanel.PerformLayout = function()
		local moveToolsWide = moveToolsPanel:GetWide()
		toolUpButton:SetWide(moveToolsWide / 3)
		toolDeleteButton:SetWide(moveToolsWide / 3)
		toolDeleteButton:SetPos(moveToolsWide / 3, 0)
		toolDownButton:SetWide(moveToolsWide / 3)
		toolDownButton:SetPos((moveToolsWide / 3) * 2, 0)
	end
	
		optionsPanel:AddControl("Label", { Text = "Add Tool" })
		
		-- Add Tool Panel
		local toolAddPanel = vgui.Create("DPanel")
			toolAddPanel:SetWide(panelWide)
			toolAddPanel:SetTall(72)
			toolAddPanel:SetVisible(true)
			
		local toolAddPanelWide = toolAddPanel:GetWide()
			
		-- Add Tool Name Label
		local toolNameLabel = vgui.Create("DLabel", toolAddPanel)
			toolNameLabel:SetText("Name:  ")
			toolNameLabel:SizeToContents()
			toolNameLabel:SetColor(Color(0,0,0,255))
			
		-- Add Tool Name Textentry
			toolAddName = vgui.Create("DTextEntry", toolAddPanel)
			toolAddName:SetEnterAllowed(false)
			toolAddName:SetTall(16)
			
		-- Add Tool Con Label
		local toolConLabel = vgui.Create("DLabel", toolAddPanel)
			toolConLabel:SetText("Command:  ")
			toolConLabel:SizeToContents()
			toolConLabel:SetColor(Color(0,0,0,255))
			
		-- Add Tool Con Textentry
			toolAddCon = vgui.Create("DTextEntry", toolAddPanel)
			toolAddCon:SetEnterAllowed(false)
			toolAddCon:SetTall(16)
			
		-- Add Tool Current Color Label
		local toolCurrentColorLabel = vgui.Create("DLabel", toolAddPanel)
			toolCurrentColorLabel:SetText("Current Color:  ")
			toolCurrentColorLabel:SizeToContents()
			toolCurrentColorLabel:SetColor(Color(0,0,0,255))
			
		-- Add Tool Current Color
			toolCurrentColorButton = vgui.Create( "DColorButton", toolAddPanel )
			toolCurrentColorButton:SetSize(16,16)
			toolCurrentColorButton:SetColor(Color(100, 100, 100, 255))
			toolRedColor = 100
			toolGreenColor = 100
			toolBlueColor = 100

		-- Add Tool Default Color
		local toolDefaultColorButton = vgui.Create("DButton", toolAddPanel)
			toolDefaultColorButton:SetText("Set Default Color")
			toolDefaultColorButton:SetTall(16)
			toolDefaultColorButton:SetVisible(true)
			toolDefaultColorButton.DoClick = function()
				toolCurrentColorButton:SetColor(Color(100, 100, 100, 255))
				toolRedColor = 100
				toolGreenColor = 100
				toolBlueColor = 100
			end
		optionsPanel:AddItem(toolAddPanel)
		toolAddPanel:InvalidateLayout(true)
		toolAddPanel.PerformLayout = function()
		local toolAddPanelWide = toolAddPanel:GetWide()
		toolNameLabel:SetWide(toolNameLabel:GetWide())
		toolNameLabel:SetPos(6,6)
		
		toolAddName:SetWide((toolAddPanelWide - toolNameLabel:GetWide()) - 6)
		toolAddName:SetPos(toolNameLabel:GetWide(), 6)
		
		toolConLabel:SetWide(toolConLabel:GetWide())
		toolConLabel:SetPos(6,28)
		
		toolAddCon:SetWide((toolAddPanelWide - toolConLabel:GetWide()) - 6)
		toolAddCon:SetPos(toolConLabel:GetWide(), 28)
		
		toolCurrentColorLabel:SetWide(toolCurrentColorLabel:GetWide())
		toolCurrentColorLabel:SetPos(6, 50)
		
		toolCurrentColorButton:SetWide(16)
		toolCurrentColorButton:SetPos(toolCurrentColorLabel:GetWide() + 6, 50)
		
		toolDefaultColorButton:SetWide((toolAddPanelWide - toolCurrentColorLabel:GetWide()) - 6 - 6 - 16 - 6)
		toolDefaultColorButton:SetPos(toolCurrentColorLabel:GetWide() + 6 + 16 + 6, 50)
		end
		
		-- Tool Box Color Palete Label
		optionsPanel:AddControl("Label", { Text = "Select Tool Color" })
		
		-- Tool Box Color Palette
	local toolColorSelector = vgui.Create( "DColorPalette" )
		toolColorSelector:SetTall(75)
		toolColorSelector:SetButtonSize(16)
		toolColorSelector.DoClick = function(ctrl, color, btn)
			toolColorSelector:SetColor(Color(color.r, color.g, color.b, 255))
			toolCurrentColorButton:SetColor(Color(color.r, color.g, color.b, 255))
			toolRedColor = color.r
			toolGreenColor = color.g
			toolBlueColor = color.b
		end
	optionsPanel:AddItem(toolColorSelector)
	
	-- Create add tool panel
	local addToolPanel = vgui.Create("DPanel")
		addToolPanel:SetWide(panelWide)
		addToolPanel:SetTall(20)
		addToolPanel:SetVisible(true)
		
	local addToolWide = addToolPanel:GetWide()
		
		-- Add Add Tool Button
			local toolAddButton = vgui.Create("DButton", addToolPanel)
			toolAddButton:SetText("Add")
			toolAddButton:SetTall(20)
			toolAddButton:SetVisible(true)
			toolAddButton.DoClick = function()
				local toolName = toolAddName:GetValue()
				local toolCon = toolAddCon:GetValue()
				
				-- Do we have enough information to add a new tool?
				if #toolName > 0 and #toolCon > 0 then
					-- Yes we do, add a new tool
					quicktoolConfigTools[#quicktoolConfigTools + 1] = { name = toolName, rconcommand = toolCon, color = Color(toolRedColor,toolGreenColor,toolBlueColor,255)}
					
					-- Clean the entryfields
					toolAddName:SetValue("")
					toolAddCon:SetValue("")
					
					-- Clean and redraw the listbox
					toolsList:Clear()
					
					addToolsToListbox(toolsList)
				end
				if toolEdited ~= 0 then
					toolEditButton:SetText("Edit Tool")
					toolEdited = 0
				end
					CalculateMenuLayout()
					saveConfig()
					saveTools()
			end	

			-- Edit tool button
			toolEditButton = vgui.Create("DButton", addToolPanel)
			toolEditButton:SetText("Edit Tool")
			toolEditButton:SetTall(20)
			toolEditButton:SetVisible(true)
			toolEditButton.DoClick = function()
				--EditTool()
				if selectedListTool ~= nil then
					if toolEdited == 0 then
						toolEdited = 1
						toolAddCon:SetText(quicktoolConfigTools[selectedListTool].rconcommand)
						toolAddName:SetText(quicktoolConfigTools[selectedListTool].name)
						local toolColor = quicktoolConfigTools[selectedListTool].color
						toolRedColor = toolColor.r
						toolGreenColor = toolColor.g
						toolBlueColor = toolColor.b
						toolCurrentColorButton:SetColor(Color(toolRedColor, toolGreenColor, toolBlueColor, 255))
						toolColorSelector:SetColor(Color(toolRedColor, toolGreenColor, toolBlueColor, 255))
						toolEditButton:SetText("Save Tool")
					elseif toolEdited == 1 then
						toolEdited = 0
						local TN = toolAddName:GetValue()
						local TC = toolAddCon:GetValue()
						quicktoolConfigTools[selectedListTool] = { name = TN, rconcommand = TC, color = Color(toolRedColor, toolGreenColor, toolBlueColor, 255)}
						toolsList:Clear()
						addToolsToListbox(toolsList)	
						toolEditButton:SetText("Edit Tool")
						-- Clear the tool name and con command labels
						toolAddCon:SetText("")
						toolAddName:SetText("")
					end
				end
				CalculateMenuLayout()
				saveConfig()
				saveTools()
			end	
			
		optionsPanel:AddItem(addToolPanel)
		addToolPanel:InvalidateLayout(true)
		addToolPanel.PerformLayout = function()
		local addToolWide = addToolPanel:GetWide()
		toolAddButton:SetWide(addToolWide / 2)
		toolEditButton:SetWide(addToolWide / 2)
		toolEditButton:SetPos(addToolWide / 2, 0)
		end
		
		-- Add "Add Current Tool" Button
		local toolAddCurrentTool = vgui.Create("DButton")
		toolAddCurrentTool:SetWide(panelWide)
		toolAddCurrentTool:SetText("Add Current Tool")
		toolAddCurrentTool:SetTall(20)
		toolAddCurrentTool:SetVisible(true)
		toolAddCurrentTool.DoClick = function()
		
		local weaponClass = LocalPlayer():GetActiveWeapon():GetClass()
		local explodeClass = string.Explode("_", weaponClass)
		
			if (weaponClass == "gmod_tool") then
				PasteConvar(LocalPlayer():GetTool().Mode)
			end
			
			if (explodeClass[1] == "weapon" ) then
				PasteConvar("wep " .. weaponClass)
			end
			CalculateMenuLayout()
			saveConfig()
			saveTools()
		end
		
		optionsPanel:AddItem(toolAddCurrentTool)	
	
		-- Add Find Tools label
		optionsPanel:AddControl("Label", { Text = "Find Tools" })
		
		-- Find Tools VGUI
		local toolFindPanel = vgui.Create( "DPanel" )
		toolFindPanel:SetWide(panelWide)
		toolFindPanel:SetTall(256)
		toolFindPanel:SetVisible(true)
		toolFindPanel:SetKeyboardInputEnabled( true )
		toolFindPanel:SetMouseInputEnabled( true )
		
		-- Add Tool Find Search Label
		local toolSearchLabel = vgui.Create("DLabel", toolFindPanel)
			toolSearchLabel:SetText("Search:  ")
			toolSearchLabel:SizeToContents()
			toolSearchLabel:SetColor(Color(0,0,0,255))
		
		toolFindEntry = vgui.Create( "DTextEntry", toolFindPanel)
		-- FindEntry:SetParent( FindPanel )
		-- toolFindEntry:SetPos( 80, 36 )
		-- toolFindEntry:SetSize( 96, 24 )
		toolFindEntry.Value = ""


		
		local toolButtonsPanel = vgui.Create( "DPanel", toolFindPanel)
		toolButtonsPanel:SetWide(panelWide)
		toolButtonsPanel:SetTall(194)
		toolButtonsPanel:SetVisible(true)
		toolButtonsPanel:SetKeyboardInputEnabled( true )
		toolButtonsPanel:SetMouseInputEnabled( true )
		
				local function ButtonRefresh()
		local Size = table.Count( Results )
		local Text = ""
		if Size > MaxItems then Text = "And " .. tostring( Size - MaxItems ) .. " results not listed." end
		toolResult2:SetText( Text )
		for k2, v2 in pairs(SToolButtons) do
			v2:Remove()
		end
		SToolButtons = {}
		local i = 0
		for k2, v2 in pairs( Results ) do
			i = i + 1
			local Button = vgui.Create( "DButton", toolButtonsPanel )
			Button:SetPos( 0, ( i - 1 ) * ItemHeight )
			Button:SetSize( toolButtonsPanel:GetWide(), ItemHeight )
			if v2[ 2 ] then
				Button:SetText( string.gsub( v2[ 2 ] .. " - " .. k2, "#", "" ) )
			else
				Button:SetText( k2 )
			end
			Button.Tool = v2[ 1 ]
			function Button:DoClick() 
				PasteConvar(self.Tool) -- Write Convar to textbox in options menu.
				toolFindEntry:SetText("") -- Clear the search box
				--SToolButtons = {}
			end
			table.insert( SToolButtons, Button ) 
			if i >= MaxItems then break end
		end
	end
		
		
		
		function toolFindEntry:Think()

			local Value = self:GetValue()

			if not ( self.Value == Value ) then

				self.Value = Value

				Results = {}

				if not ( Value == "" ) then

					local TOOLS = ents.FindByClass( "gmod_tool" )[ 1 ].Tool

					if TOOLS then

						for Tool, v2 in pairs( TOOLS ) do

							local Found = true

							local Name = v2.Name or "#" .. Tool
							local Category = v2.Category

							local Explode = string.Explode( " " , Value )

							for j, c in pairs( Explode ) do

								if not ( string.find( string.lower( Tool ), string.lower( c ) ) or string.find( string.lower( Name ), string.lower( c ) ) or string.find( string.lower( Category or "" ), string.lower( c ) ) ) then

									Found = false

								end

							end

							if Found then

								Results[ Name ] = { Tool, Category }

							end

						end

					end

				end

				ButtonRefresh()

			end

		end

		toolResult2 = vgui.Create( "DLabel", toolFindPanel )
		toolResult2:SetText( "" )
		toolResult2:SizeToContentsX()
		toolResult2:SetColor(Color(0,0,0,255))
		
		optionsPanel:AddItem(toolFindPanel)
		toolFindPanel:InvalidateLayout(true)
		toolFindPanel.PerformLayout = function()
		local toolFindWide = toolFindPanel:GetWide()
		toolSearchLabel:SetWide(toolSearchLabel:GetWide())
		toolSearchLabel:SetPos(6,8)
		toolFindEntry:SetWide((toolFindWide - toolSearchLabel:GetWide()) - 6)
		toolFindEntry:SetPos(toolSearchLabel:GetWide(), 6)
		toolButtonsPanel:SetWide(toolFindWide - 12)
		toolButtonsPanel:SetPos(6,32)
		toolResult2:SetWide(130)
		toolResult2:SetPos(((toolFindWide/2) - (toolResult2:GetWide()/2)) + 6,230)
		end
	end

	function OptionsMenuPresets(presetsPanel)
		local presetEdited = 0
			-- Spacing
		local panelWide = presetsPanel:GetWide()
		presetsPanel:AddControl("Label", { Text = "Quicktool Menu Presets" })
		presetsPanel:SetName("Quicktool Menu Presets")
		presetsPanel:SetSpacing(10)

			-- Add tools list panel
		local presetsListPanel = vgui.Create("DPanel")
			presetsListPanel:SetWide(panelWide)
			presetsListPanel:SetTall(250)
			presetsListPanel:SetVisible(true)
		
		local presetsListPanelWide = presetsListPanel:GetWide()
		
	-- Add tools list
		local presetsList = vgui.Create("DPanelList", presetsListPanel)
			presetsList:SetSize(10,238)
			presetsList:SizeToContentsX()
			presetsList:SetSpacing(2)
			presetsList:SetPadding(2)
			presetsList:EnableHorizontal(false)
			presetsList:EnableVerticalScrollbar(true)
			
			-- Add the current tools to the listbox
			addPresetsToListbox(presetsList)
		
		presetsPanel:AddItem(presetsListPanel)
		presetsListPanel:InvalidateLayout(true)
		presetsListPanel.PerformLayout = function()
		local presetsListPanelWide = presetsListPanel:GetWide()
		presetsList:SetWide(presetsListPanelWide - 12)
		presetsList:SetTall(238)
		presetsList:SetPos(6,6)
		end
		
	-- Create move tools panel
	local editPresetsPanel = vgui.Create("DPanel")
		editPresetsPanel:SetWide(panelWide)
		editPresetsPanel:SetTall(20)
		editPresetsPanel:SetVisible(true)
		
	local loadDeletePresetsWide = editPresetsPanel:GetWide()

	-- Add Load preset button
		local loadPresetButton = vgui.Create("DButton", editPresetsPanel)
			loadPresetButton:SetText("Load Selected Preset")
			loadPresetButton:SetPos(0, 0)
			loadPresetButton:SetTall(20)
			loadPresetButton:SetVisible(true)
			loadPresetButton.DoClick = function()

				-- Check if preset is selected
				if selectedListPreset ~= nil then

					local tempToolTable = {}

					for k,v in pairs(quicktoolConfigPresets[selectedListPreset].presettable) do
						tempToolTable[k] = {name = v.name, rconcommand = v.rconcommand, color = v.color}
					end

					-- Set the current tool to the preset
					quicktoolConfigTools = tempToolTable

					CalculateMenuLayout()

					saveTools()
				end
			end
		
	-- Add delete preset button
		local presetDeleteButton = vgui.Create("DButton", editPresetsPanel)
			presetDeleteButton:SetText("Delete Preset")
			presetDeleteButton:SetTall(20)
			presetDeleteButton:SetVisible(true)
			presetDeleteButton.DoClick = function()

				-- Delete the selected tool, if a tool is selected
				if selectedListPreset ~= nil then
					quicktoolConfigPresets[selectedListPreset] = nil
					
					-- Check if index is fragmented
					if not table.IsSequential(quicktoolConfigPresets) then
						-- Table needs to be reordered
						local tempPresetTable = {}
						local tempPresetTableCounter = 1
						
						for k,v in pairs(quicktoolConfigPresets) do
							tempPresetTable[tempPresetTableCounter] = v
							
							tempPresetTableCounter = tempPresetTableCounter + 1
						end
						
						quicktoolConfigPresets = tempPresetTable					
						tempPresetTable = nil
					end
	
					-- No tool is selected
					selectedListPreset = nil
					
					-- Clean and redraw the listbox
					presetsList:Clear()
					
					-- Clear the tool name and con command labels
					presetAddName:SetText("")
					
				if presetEdited ~= 0 then
					presetEditButton:SetText("Edit Preset Name")
					presetEdited = 0
				end
					
					addPresetsToListbox(presetsList)
					CalculateMenuLayout()
					saveConfig()
					saveTools()
					savePresets()
				end
			end
			
		presetsPanel:AddItem(editPresetsPanel)
		editPresetsPanel:InvalidateLayout(true)
		editPresetsPanel.PerformLayout = function()
		local loadDeletePresetsWide = editPresetsPanel:GetWide()
		loadPresetButton:SetWide(loadDeletePresetsWide / 2)
		presetDeleteButton:SetWide(loadDeletePresetsWide / 2)
		presetDeleteButton:SetPos(loadDeletePresetsWide / 2, 0)
	end

			-- Add Tool Panel
		local presetAddPanel = vgui.Create("DPanel")
			presetAddPanel:SetWide(panelWide)
			presetAddPanel:SetTall(28)
			presetAddPanel:SetVisible(true)
			
		local presetAddPanelWide = presetAddPanel:GetWide()
			
		-- Add Tool Name Label
		local presetNameLabel = vgui.Create("DLabel", presetAddPanel)
			presetNameLabel:SetText("Name:  ")
			presetNameLabel:SizeToContents()
			presetNameLabel:SetColor(Color(0,0,0,255))
			
		-- Add Tool Name Textentry
			presetAddName = vgui.Create("DTextEntry", presetAddPanel)
			presetAddName:SetEnterAllowed(false)
			presetAddName:SetTall(16)

		presetsPanel:AddItem(presetAddPanel)
		presetAddPanel:InvalidateLayout(true)
		presetAddPanel.PerformLayout = function()
		local presetAddPanelWide = presetAddPanel:GetWide()
		presetNameLabel:SetWide(presetNameLabel:GetWide())
		presetNameLabel:SetPos(6,6)
		
		presetAddName:SetWide((presetAddPanelWide - presetNameLabel:GetWide()) - 6)
		presetAddName:SetPos(presetNameLabel:GetWide(), 6)
		end

		-- Edit tool button
		presetEditButton = vgui.Create("DButton", addToolPanel)
		presetEditButton:SetText("Edit Preset Name")
		presetEditButton:SetTall(20)
		presetEditButton:SetVisible(true)
		presetEditButton.DoClick = function()

			--EditTool()
			if selectedListPreset ~= nil then
				if presetEdited == 0 then
					presetEdited = 1
					presetAddName:SetText(quicktoolConfigPresets[selectedListPreset].name)
					presetEditButton:SetText("Save Preset Name")
				elseif presetEdited == 1 then
					presetEdited = 0
					local PN = presetAddName:GetValue()
					local tempPresetTable = quicktoolConfigPresets[selectedListPreset].presettable

					quicktoolConfigPresets[selectedListPreset] = { name = PN, presettable = tempPresetTable}
					presetsList:Clear()
					addPresetsToListbox(presetsList)	
					presetEditButton:SetText("Edit Preset Name")
					-- Clear the preset name
					presetAddName:SetText("")
				end
			end
			CalculateMenuLayout()
			saveConfig()
			savePresets()
		end	
			
		presetsPanel:AddItem(presetEditButton)
		
		-- Add "Add Current Tool" Button
		local presetAddCurrentTools = vgui.Create("DButton")
		presetAddCurrentTools:SetWide(panelWide)
		presetAddCurrentTools:SetText("Add Current Tools to new preset")
		presetAddCurrentTools:SetTall(20)
		presetAddCurrentTools:SetVisible(true)
		presetAddCurrentTools.DoClick = function()
				
				local presetName = presetAddName:GetValue()
				
				-- Do we have enough information to add a new tool?
				if #presetName > 0 then

					local tempToolsAdd = {}

					for k,v in pairs(quicktoolConfigTools) do
						tempToolsAdd[k] = {name = v.name, rconcommand = v.rconcommand, color = v.color}
					end

					-- Yes we do, add a new tool
					quicktoolConfigPresets[#quicktoolConfigPresets + 1] = {name = presetName, presettable = tempToolsAdd}					
					
					-- Clean the entryfields
					presetAddName:SetValue("")
					
					-- Clean and redraw the listbox
					presetsList:Clear()
					addPresetsToListbox(presetsList)

				end
				if presetEdited ~= 0 then
					presetEditButton:SetText("Edit Preset Name")
					presetEdited = 0
				end

			CalculateMenuLayout()
			saveConfig()
			savePresets()
		end
		
		presetsPanel:AddItem(presetAddCurrentTools)
	end
			
	
	-- Actual options menu adding
	function PopulateToolMenu()
		spawnmenu.AddToolMenuOption("Options", "Quicktool Menu", "QuicktoolMenuSettings", "Settings", "", "", OptionsMenu, {})
		spawnmenu.AddToolMenuOption("Options", "Quicktool Menu", "QuicktoolMenuSettingsPresets", "Presets", "", "", OptionsMenuPresets, {})
	end
	
	-- Add the hook, so we get shown in the Options menu
	hook.Add("PopulateToolMenu", "QuicktoolOptions", PopulateToolMenu)
end