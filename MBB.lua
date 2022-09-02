MBB_Version = GetAddOnMetadata("MinimapButtonBag-TurtleWoW", "Version");
MBB_DebugFlag = 0;
MBB_DragFlag = 0;
MBB_ShowTimeout = -1;
MBB_Buttons = {};
MBB_Exclude = {};
MBB_DragPos ={
["orig"] = {},
["start"] = {}
};
MBB_DefaultOptions = {
	["ButtonPos"] = {-18, -100},
	["AttachToMinimap"] = 1,
	["CollapseTimeout"] = 1,
	["ExpandDirection"] = 1,
	["MaxButtonsPerLine"] = 0,
	["AltExpandDirection"] = 4,
	["Scale"] = 100,
	["Version"] = MBB_Version
};

MBB_Include = {
	[1] = "DPSMate_MiniMap",
};

--McPewPew
TW_Include = {
};
	
isTWoW = 0

if (TWMinimapShopFrame~=nil) then
	TWMinimapShopFrame:ClearAllPoints() TWMinimapShopFrame:SetParent(Minimap) TWMinimapShopFrame:SetPoint("LEFT",Minimap,"RIGHT",-1, -1)
	isTWoW = 1
	table.insert(TW_Include, "Turtle WoW Shop");
end
if (TWMiniMapBattlefieldFrame~=nil) then
	TWMiniMapBattlefieldFrame:ClearAllPoints() TWMiniMapBattlefieldFrame:SetParent(Minimap) TWMiniMapBattlefieldFrame:SetPoint("LEFT",Minimap,"RIGHT",-1, -1)
	isTWoW = 1
	table.insert(TW_Include, "Turtle WoW Battleground Finder");
end
if (LFT_Minimap~=nil) then
	LFT_Minimap:ClearAllPoints() LFT_Minimap:SetParent(Minimap) LFT_Minimap:SetPoint("LEFT",Minimap,"RIGHT",-1, -1)
	isTWoW = 1
	table.insert(TW_Include, "LookingForTurtles");
end

if 	isTWoW == 1 then
	for i,TWMMB in ipairs(TW_Include) do
		DEFAULT_CHAT_FRAME:AddMessage("scruunch scruunch "..TWMMB, 1, 0, 1)
	end
	DEFAULT_CHAT_FRAME:AddMessage("Don't worry TurtleSnacks has fed your turtles", 1, 0, 1);
else
	DEFAULT_CHAT_FRAME:AddMessage("Many sad Turtle noises :(", 1, 0, 1);
end
--McPewPew

MBB_Ignore = {
	[1] = "MiniMapTrackingFrame",
	[2] = "MiniMapMeetingStoneFrame",
	[3] = "MiniMapMailFrame",
	[4] = "MiniMapBattlefieldFrame",
	[5] = "MiniMapPing",
	[6] = "MinimapBackdrop",
	[7] = "MinimapZoomIn",
	[8] = "MinimapZoomOut",
	[9] = "BookOfTracksFrame",
	[10] = "GatherNote",
	[11] = "FishingExtravaganzaMini",
	[12] = "MiniNotePOI",
	[13] = "RecipeRadarMinimapIcon",
	[14] = "FWGMinimapPOI",
	[15] = "MBB_MinimapButtonFrame",
	[16] = "QuestieNote",
	[17] = "MetaMap",
	[18] = "LootLinkMinimapButton",
	[19] = "TimeManagerClockButton",
	[20] = "pfMiniMapPin"
};

MBB_IgnoreSize = {
	[1] = "AM_MinimapButton",
	[2] = "STC_HealthstoneButton",
	[3] = "STC_ShardButton",
	[4] = "STC_SoulstoneButton",
	[5] = "STC_SpellstoneButton",
	[6] = "STC_FirestoneButton",
};

--Code by Grayhoof (SCT)
local function CloneTable(t)				-- return a copy of the table t
	local new = {};					-- create a new table
	local i, v = next(t, nil);		-- i is an index of t, v = t[i]
	while i do
		if type(v)=="table" then 
			v=CloneTable(v);
		end 
		new[i] = v;
		i, v = next(t, i);			-- get next index
	end
	return new;
end


MBB_ExtraSize = {
	["GathererMinimapButton"] = function()
		GathererMinimapButton.mask:SetHeight(31);
		GathererMinimapButton.mask:SetWidth(31);
	end,
	["WIM_IconFrame"] = function()
		WIM_IconFrameButton:SetScale(1);
	end,
	["MonkeyBuddyIconButton"] = function()
		MonkeyBuddyIconButton:SetHeight(33);
		MonkeyBuddyIconButton:SetWidth(33);
	end,
	["DPSMate_MiniMap"] = function()
		DPSMate_MiniMap:SetScale(MBB_Options.Scale /100);
	end
};

MBB_CallBack = {
	["RecipeRadarMinimapButton"] = function()
		RecipeRadar_MinimapButton_UpdatePosition();
	end
}


_rescanned = false;
_starttime = GetTime();

function MBB_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("ADDON_LOADED");
	SLASH_MBB1 = "/mbb";
	SlashCmdList["MBB"] = MBB_SlashHandler;
end

function MBB_SlashHandler(cmd)
	if( cmd == "buttons" ) then
		MBB_Print("MBB Buttons:");
		for i,name in ipairs(MBB_Buttons) do
			MBB_Print("  " .. name);
		end
	elseif( string.sub(cmd, 1, 6) == "debug " ) then
		local iStart, iEnd, sFrame = string.find(cmd, "debug (.+)");
		
		local hasClick, hasMouseUp, hasMouseDown, hasEnter, hasLeave = MBB_TestFrame(sFrame);
		
		MBB_Debug("Frame: " .. sFrame);
		if( hasClick ) then
			MBB_Debug("  has OnClick script");
		else
			MBB_Debug("  has no OnClick script");
		end
		if( hasMouseUp ) then
			MBB_Debug("  has OnMouseUp script");
		else
			MBB_Debug("  has no OnMouseUp script");
		end
		if( hasMouseDown ) then
			MBB_Debug("  has OnMouseDown script");
		else
			MBB_Debug("  has no OnMouseDown script");
		end
		if( hasEnter ) then
			MBB_Debug("  has OnEnter script");
		else
			MBB_Debug("  has no OnEnter script");
		end
		if( hasLeave ) then
			MBB_Debug("  has OnLeave script");
		else
			MBB_Debug("  has no OnLeave script");
		end
	elseif( cmd == "reset position" ) then
		MBB_ResetPosition();
	elseif( cmd == "reset all" ) then
		MBB_Options = CloneTable(MBB_DefaultOptions);
		for i=1,table.getn(MBB_Exclude) do
			MBB_AddButton(MBB_Exclude[1]);
		end
		MBB_SetPositions();
		MBB_ResetPosition();
	else
		MBB_Print("MBB v" .. MBB_Version .. ":");
		MBB_Print(MBB_HELP1);
		MBB_Print(MBB_HELP2);
		MBB_Print(MBB_HELP3);
		MBB_Print(MBB_HELP4);
	end
end

function MBB_TestFrame(name)
	local hasClick = false;
	local hasMouseUp = false;
	local hasMouseDown = false;
	local hasEnter = false;
	local hasLeave = false;
	local frame = getglobal(name);
	
	if( frame ) then
		if( frame:HasScript("OnClick") ) then
			local test = frame:GetScript("OnClick");
			if( test ) then
				hasClick = true;
			end
		end
		if( frame:HasScript("OnMouseUp") ) then
			local test = frame:GetScript("OnMouseUp");
			if( test ) then
				hasMouseUp = true;
			end
		end
		if( frame:HasScript("OnMouseDown") ) then
			local test = frame:GetScript("OnMouseDown");
			if( test ) then
				hasMouseDown = true;
			end
		end
		if( frame:HasScript("OnEnter") ) then
			local test = frame:GetScript("OnEnter");
			if( test ) then
				hasEnter = true;
			end
		end
		if( frame:HasScript("OnLeave") ) then
			local test = frame:GetScript("OnLeave");
			if( test ) then
				hasLeave = true;
			end
		end
	end
	
	return hasClick, hasMouseUp, hasMouseDown, hasEnter, hasLeave;
end

function MBB_OnEvent()
	if(event == "ADDON_LOADED" and (arg1 == "Squeenix" or arg1 == "MBB")) then
		MBB_SetButtonPosition();
	end
	if ( event == "VARIABLES_LOADED" ) then
		if ( MBB_Options == nil or MBB_Options["Version"] ~= MBB_Version)  then
			MBB_Options = CloneTable(MBB_DefaultOptions)
		end
	end
end

function MBB_GatherIcons()
	local children = {Minimap:GetChildren()};
	local additional = {MinimapBackdrop:GetChildren()};
	for _,child in ipairs(additional) do
		table.insert(children, child);
	end
	for _,child in ipairs(MBB_Include) do
		local frame = getglobal(child);
		if( frame ) then
			table.insert(children, frame);
		end
	end
	
	for _,child in ipairs(children) do
		if( child:GetName() ) then
			local ignore = false;
			local exclude = false;
			for i,needle in ipairs(MBB_Ignore) do
				if( string.find(child:GetName(), needle) ) then
					ignore = true;
				end
			end
--McPewPew
		if 	isTWoW == 1 then
			for i,needle in ipairs(MBB_Ignore) do
				if( string.find(child:GetName(), "TWMiniMapBattlefieldFrame") ) then
					ignore = false;
				end
			end
		end
--McPewPew
			if( not ignore ) then
				if( not child:HasScript("OnClick") ) then
					for _,subchild in ipairs({child:GetChildren()}) do
						if( subchild:HasScript("OnClick") ) then
							child = subchild;
							break;
						end
					end
				end
				
				local hasClick, hasMouseUp, hasMouseDown, hasEnter, hasLeave = MBB_TestFrame(child:GetName());
				
				if( hasClick or hasMouseUp or hasMouseDown ) then
					local name = child:GetName();
					
					MBB_PrepareButton(name);
					if( not MBB_IsExcluded(name) ) then
						if( child:IsVisible() ) then
							MBB_Debug("Button is visible: " .. name);
						else
							MBB_Debug("Button is not visible: " .. name);
						end
						MBB_Debug("Button added: " .. name);
						MBB_AddButton(name);
					else
						MBB_Debug("Button excluded: " .. name);
					end
				else
					MBB_Debug("Frame is no button: " .. child:GetName());
				end
			else
				MBB_Debug("Frame ignored: " .. child:GetName());
			end
		end
	end
	
	MBB_SetPositions();
end

function MBB_PrepareButton(name)
	local frame = getglobal(name);
	
	if( frame ) then
		if( frame.RegisterForClicks ) then
			frame:RegisterForClicks("LeftButtonDown","RightButtonDown");
		end
		
		if( not MBB_IsInArray(MBB_IgnoreSize, name) ) then
			frame:SetScale(MBB_Options.Scale * (1/Minimap:GetEffectiveScale())/100);
		end
		frame.isvisible = frame:IsVisible();
		frame.oshow = frame.Show;
		frame.Show = function(frame)
			frame.isvisible = true;
			MBB_Debug("Showing frame: " .. frame:GetName());
			if( not MBB_IsExcluded(frame:GetName()) ) then
				MBB_SetPositions();
			end
			if( MBB_IsExcluded(frame:GetName()) or (MBB_Buttons[1] and MBB_Buttons[1] ~= frame:GetName() and getglobal(MBB_Buttons[1]):IsVisible()) ) then
				frame.oshow(frame);
			end
		end
		frame.ohide = frame.Hide;
		frame.Hide = function(frame)
			frame.isvisible = false;
			MBB_Debug("Hiding frame: " .. frame:GetName());
			frame.ohide(frame);
			if( not MBB_IsExcluded(frame:GetName()) ) then
				MBB_SetPositions();
			end
		end
		
		if( frame:HasScript("OnClick") ) then
			frame.oclick = frame:GetScript("OnClick");
			frame:SetScript("OnClick", function()
				if( arg1 and arg1 == "RightButton" and IsControlKeyDown() ) then
					local name = this:GetName();
					if( MBB_IsExcluded(name) ) then
						MBB_AddButton(name);
					else
						MBB_RestoreButton(name);
					end
					MBB_SetPositions();
				elseif( this.oclick ) then
					this.oclick();
				end
			end);
		elseif( frame:HasScript("OnMouseUp") ) then
			frame.omouseup = frame:GetScript("OnMouseUp");
			frame:SetScript("OnMouseUp", function()
				if( arg1 and arg1 == "RightButton" and IsControlKeyDown() ) then
					local name = this:GetName();
					if( MBB_IsExcluded(name) ) then
						MBB_AddButton(name);
					else
						MBB_RestoreButton(name);
					end
					MBB_SetPositions();
				elseif( this.omouseup ) then
					this.omouseup();
				end
			end);
		elseif( frame:HasScript("OnMouseDown") ) then
			frame.omousedown = frame:GetScript("OnMouseDown");
			frame:SetScript("OnMouseDown", function()
				if( arg1 and arg1 == "RightButton" and IsControlKeyDown() ) then
					local name = this:GetName();
					if( MBB_IsExcluded(name) ) then
						MBB_AddButton(name);
					else
						MBB_RestoreButton(name);
					end
					MBB_SetPositions();
				elseif( this.omousedown ) then
					this.omousedown();
				end
			end);
		end
		if( frame:HasScript("OnEnter") ) then
			frame.oenter = frame:GetScript("OnEnter");
			frame:SetScript("OnEnter", function()
				if( not MBB_IsExcluded(this:GetName()) ) then
					MBB_ShowTimeout = -1;
				end
				if( this.oenter ) then
					this.oenter();
				end
			end);
		end
		if( frame:HasScript("OnLeave") ) then
			frame.oleave = frame:GetScript("OnLeave");
			frame:SetScript("OnLeave", function()
				if( not MBB_IsExcluded(this:GetName()) ) then
					MBB_ShowTimeout = 0;
				end
				if( this.oleave ) then
					this.oleave();
				end
			end);
		end
		
		if MBB_CallBack[name] then
			
			MBB_Debug("Calling callback: ".. name)
			local func = MBB_CallBack[name];
			func();
		end
		
	end
end

function MBB_AddButton(name)
	local show = false;
	local child = getglobal(name);
	
	if not child then return end

	if( MBB_Buttons[1] and MBB_Buttons[1] ~= name and getglobal(MBB_Buttons[1]):IsVisible() ) then
		show = true;
	end
	
	child.opoint = {child:GetPoint()};
	if( not child.opoint[1] ) then
		child.opoint = {"TOP", Minimap, "BOTTOM", 0, 0};
	end
	child.osize = {child:GetHeight(),child:GetWidth()};
	child.oclearallpoints = child.ClearAllPoints;
	child.ClearAllPoints = function() end;
	child.osetpoint = child.SetPoint;
	child.SetPoint = function() end;
	if( not show ) then
		child.ohide(child);
	end
	table.insert(MBB_Buttons, name);
	local i = MBB_IsInArray(MBB_Exclude, name);
	if( i ) then
			table.remove(MBB_Exclude, i);
	end
end

function MBB_IsExcluded(name)
	for i,needle in ipairs(MBB_Exclude) do
		if( needle == name ) then
			return true;
		end
	end
	return false;
end

function MBB_RestoreButton(name)
	local button = getglobal(name);
	
	button.oclearallpoints(button);
	button.osetpoint(button, button.opoint[1], button.opoint[2], button.opoint[3], button.opoint[4], button.opoint[5]);
	button:SetHeight(button.osize[1]);
	button:SetWidth(button.osize[1]);
	button.ClearAllPoints = button.oclearallpoints;
	button.SetPoint = button.osetpoint;
	if (button.isvisible) then
	button.oshow(button);
	else
		button.ohide(button);
	end
	
	table.insert(MBB_Exclude, name);
	local i = MBB_IsInArray(MBB_Buttons, button:GetName());
	if( i ) then
			table.remove(MBB_Buttons, i);
	end
end

local function ResizeButton(frame)
	frame:SetHeight(31); 
	frame:SetWidth(31);
	frame:SetScale(MBB_Options.Scale * (1/Minimap:GetEffectiveScale())/100);
end

function MBB_SetPositions()
	local directions = {
		[1] = {"RIGHT", "LEFT"},
		[2] = {"BOTTOM", "TOP"},
		[3] = {"LEFT", "RIGHT"},
		[4] = {"TOP", "BOTTOM"}
	};
	local offsets = {
		[1] = {"RIGHT","LEFT"},
		[2] = {"BOTTOM","TOP"},
		[3] = {"LEFT", "RIGHT"},
		[4] = {"TOP", "BOTTOM"}
	};
	local cols ={};
	local parentid = 0;
	local count = 0;
	for i,name in ipairs(MBB_Buttons) do
		local frame = getglobal(name);
		if( frame.isvisible ) then
			count = count + 1 ;
			local mpl = MBB_Options["MaxButtonsPerLine"]
			if (MBB_Options["MaxButtonsPerLine"]==0) then mpl=100 end
			local row = math.floor (count /mpl )
			local col = count - row * mpl
			local parent;
			
			local dirchild, dirparent = directions[MBB_Options.ExpandDirection][1], directions[MBB_Options.ExpandDirection][2];
			
			if( parentid==0 ) then
				parent = MBB_MinimapButtonFrame;
				cols[row] = i
			else
				parent = getglobal(MBB_Buttons[parentid]);
			end
			if( not MBB_IsInArray(MBB_IgnoreSize, name) ) then
				if( MBB_ExtraSize[name] ) then
					local func = MBB_ExtraSize[name];
					func();
				else
					ResizeButton(frame);
				end
			end
			
			frame.oclearallpoints(frame);
			if ((col == 1) and (parentid ~= 0)) then
					cols[row] = i
					parent = getglobal(MBB_Buttons[cols[row - 1]])
					dirchild, dirparent = offsets[MBB_Options.AltExpandDirection][1], offsets[MBB_Options.AltExpandDirection][2]
					
			end
			frame.osetpoint(frame, dirchild, parent, dirparent, 0, 0);
			
			parentid = i;
		end
	end
end

function MBB_OnClick(arg1)
	if( arg1 and arg1 == "RightButton" and IsControlKeyDown() ) then
		if( MBB_Options.AttachToMinimap == 1 ) then
			local xpos,ypos = GetCursorPosition();
			local scale = MBB_Options.Scale/100;--UIParent:GetEffectiveScale(); --GetCVar("uiScale");
			MBB_Debug("cursor "..(xpos).." "..(ypos))
			MBB_Options.AttachToMinimap = 0;
			MBB_Options.ButtonPos ={xpos/scale ,ypos/scale } --{(xpos/scale)-10, (ypos/scale)-10}
			MBB_Debug("position "..(xpos/scale ).." "..(ypos/scale ))
			--(xpos/scale)-10, (ypos/scale)-10};
			MBB_SetButtonPosition();
		else
			MBB_ResetPosition();
		end
	elseif( arg1 and arg1 == "RightButton" ) then
		MBB_OptionsFrame:Show();
	else
		if( MBB_Buttons[1] and getglobal(MBB_Buttons[1]):IsVisible() ) then
			MBB_HideButtons();
		else
			for i,name in ipairs(MBB_Buttons) do
				local frame = getglobal(name);
				if frame.isvisible then frame.oshow(frame); end
			end
			--MBB_ShowTimeout = 0;
		end
	end
end

function MBB_DragStart()
	if (IsShiftKeyDown()) then
		GameTooltip:Hide();
		MBB_ShowTimeout = 0;
		MBB_DragFlag = 1;
		if( MBB_Options.AttachToMinimap == 1 ) then
			
		else
			local _,_,_,xpos,ypos = this:GetPoint();
			MBB_DragPos["orig"] = {xpos, ypos};
			MBB_Debug("orig "..(MBB_DragPos.orig[1]).." "..(MBB_DragPos.orig[2]))
			this:StartMoving();
			_,_,_,xpos,ypos = this:GetPoint();
			MBB_DragPos["start"]= {xpos, ypos};
			MBB_Debug("start "..(MBB_DragPos.start[1]).." "..(MBB_DragPos.start[2]))
		end
	else
		MBB_DragFlag = 0;
	end 
	
end

function MBB_DragStop()
	if MBB_DragFlag == 1 then 
		local _,_,_,xpos,ypos = this:GetPoint();
		MBB_Debug("stop "..(xpos).." "..(ypos))
		if( MBB_Options.AttachToMinimap == 1 ) then
			
			
			MBB_Options.ButtonPos = {xpos,ypos};
		else
			this:StopMovingOrSizing();
			
	--		local xpos,ypos = GetCursorPosition();
	--		local scale = MBB_Options.Scale/100;
	--		MBB_Options.ButtonPos ={xpos/scale ,ypos/scale }
			xpos = MBB_DragPos.orig[1] + (xpos - MBB_DragPos.start[1])
			ypos = MBB_DragPos.orig[2] + (ypos - MBB_DragPos.start[2])
			MBB_Options.ButtonPos ={xpos ,ypos }
			MBB_Debug("options "..(MBB_Options.ButtonPos[1]).." "..(MBB_Options.ButtonPos[2]))
		end
		MBB_DragFlag = 0;
	end
end

function MBB_HideButtons()
	MBB_ShowTimeout = -1;
	for i,name in ipairs(MBB_Buttons) do
		local frame = getglobal(name);
		frame.ohide(frame);
	end
end

function MBB_OnUpdate(elapsed)
	
	if (not _rescanned and (GetTime() - _starttime) > 5) then
			_rescanned = true;
			MBB_GatherIcons();
			MBB_SetButtonPosition();
			return;	
		end;
	
	if( MBB_DragFlag == 1 and MBB_Options.AttachToMinimap == 1 ) then
		local xpos,ypos = GetCursorPosition();
		local xmin,ymin,xm,ym = Minimap:GetLeft(), Minimap:GetBottom(), Minimap:GetRight(), Minimap:GetTop();
		local scale = Minimap:GetEffectiveScale();
		local xdelta, ydelta = (xm - xmin)/2*scale, (ym - ymin) /2 * scale;
		
		MBB_Debug( xmin..","..ymin..","..xm..","..ym)
		MBB_Debug( xdelta..","..ydelta)
		
		xpos = xmin*scale-xpos+xdelta;
		ypos = ypos-ymin*scale-ydelta;

		local angle = math.deg(math.atan2(ypos,xpos));
		
		local	x,y =0,0;
		if (Squeenix or (simpleMinimap_Skins and simpleMinimap_Skins:GetShape() == "square")
		    or (pfUI and pfUI_config["disabled"]["minimap"] ~= "1")) then
			x = math.max(-xdelta, math.min((xdelta*1.5) * cos(angle), xdelta))
			y = math.max(-ydelta, math.min((ydelta*1.5) * sin(angle), ydelta))
		else
			x= cos(angle)*xdelta
			y= sin(angle)*ydelta
		end
		local sc= MBB_Options.Scale/100
		MBB_MinimapButtonFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", (xdelta-x)/sc -17 , (y-ydelta)/sc +17);
	end
	
	if( MBB_Options.CollapseTimeout and MBB_Options.CollapseTimeout ~= 0 ) then
		if( MBB_Buttons[1] ) then
			if( MBB_ShowTimeout >= MBB_Options.CollapseTimeout and getglobal(MBB_Buttons[1]):IsVisible() ) then
				MBB_HideButtons();
			end
		end
		if( MBB_ShowTimeout ~= -1 ) then
			MBB_ShowTimeout = MBB_ShowTimeout + elapsed;
		end
	end
end

function MBB_ResetPosition()
	MBB_Options.ButtonPos[1] = MBB_DefaultOptions.ButtonPos[1];
	MBB_Options.ButtonPos[2] = MBB_DefaultOptions.ButtonPos[2];
	MBB_Options.AttachToMinimap = MBB_DefaultOptions.AttachToMinimap;
	MBB_SetButtonPosition();
end

function MBB_SetButtonPosition()
	if (not MBB_Options) then MBB_Debug("NO MBB_Options");return; end
	MBB_MinimapButtonFrame:SetScale((MBB_Options.Scale or 100 ) * (1/Minimap:GetEffectiveScale())/100);
	if( MBB_Options.AttachToMinimap == 1 ) then
		MBB_MinimapButtonFrame:ClearAllPoints();
		MBB_MinimapButtonFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", MBB_Options.ButtonPos[1], MBB_Options.ButtonPos[2]);
	else
		MBB_MinimapButtonFrame:ClearAllPoints();
		MBB_MinimapButtonFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", MBB_Options.ButtonPos[1], MBB_Options.ButtonPos[2]);
	end
end

function MBB_RadioButton_OnClick(id, alt)
	local substring;
	if( alt ) then
		substring = "Alt";
	else
		substring = "";
	end
	local buttons = {
		[1] = "Left",
		[2] = "Top",
		[3] = "Right",
		[4] = "Bottom"
	};
	
	for i,name in ipairs(buttons) do
		if( i == id ) then
			getglobal("MBB_OptionsFrame_" .. name .. substring .. "Radio"):SetChecked(true);
		else
			getglobal("MBB_OptionsFrame_" .. name .. substring .. "Radio"):SetChecked(nil);
		end
	end
end


function MBB_UpdateAltRadioButtons()
	local buttons = {
		[1] = "Left",
		[2] = "Top",
		[3] = "Right",
		[4] = "Bottom"
	};
	
	local exchecked = 1;
	
	for i,name in pairs(buttons) do
		if( getglobal("MBB_OptionsFrame_" .. name .. "Radio"):GetChecked() ) then
			exchecked = i;
			break;
		end
	end
	
	local checked = false;
	local textbox = getglobal("MBB_OptionsFrame_MaxButtonsTextBox");
	
	for i,name in pairs(buttons) do
		local radio = getglobal("MBB_OptionsFrame_" .. name .. "AltRadio");
		local label = getglobal("MBB_OptionsFrame_" .. name .. "AltRadioLabel");
		if( textbox:GetText() == "" or tonumber(textbox:GetText()) == 0 ) then
			radio:Disable();
			radio:SetChecked(nil);
			label:SetTextColor(0.5, 0.5, 0.5);
		
		else
			if(  (exchecked - math.floor(exchecked/2)*2) == (i - math.floor(i/2)*2) ) then
					if( radio:GetChecked() ) then
					checked = true;
					if( i == 4 ) then
						getglobal("MBB_OptionsFrame_LeftAltRadio"):SetChecked(true);
					else
						getglobal("MBB_OptionsFrame_" .. buttons[i+1] .. "AltRadio"):SetChecked(true);
					end
				end
				radio:Disable();
				radio:SetChecked(nil);
				label:SetTextColor(0.5, 0.5, 0.5);
			else
				if( radio:GetChecked() ) then
					checked = true;
				end
				radio:Enable();
				label:SetTextColor(1, 1, 1);
			
			end
			
		end

	end
	
	if( not checked and tonumber(textbox:GetText()) ~= 0 and textbox:GetText() ~= "" ) then
		if( (exchecked - math.floor(exchecked/2)*2 ) == 1 ) then
			getglobal("MBB_OptionsFrame_TopAltRadio"):SetChecked(true);
		else
			getglobal("MBB_OptionsFrame_LeftAltRadio"):SetChecked(true);
		end
	end

end

function MBB_Debug(msg)
	if (MBB_DebugFlag == 1) then
		MBB_Print("MBB Debug : " .. tostring(msg));
	end
end

function MBB_IsInArray(array, needle)
	if(type(array) == "table") then
		--MBB_Debug("Looking for " .. tostring(needle) .. " in " .. tostring(array));
		for i, element in pairs(array) do
			if(type(element) ==  type(needle) and element == needle) then
				return i;
			end
		end
	end
	return nil;
end
function MBB_Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg, 0.2, 0.8, 0.8);
end
