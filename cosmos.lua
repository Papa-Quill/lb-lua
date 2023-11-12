-- Created by 'abflb'
-- I have fixed, rewrote, and added a bunch of stuff to these different scripts. I however do not own the original code. All credits can be found within this file above the code of the scripts as well as links to their original sources.

---------------------------
-- COSMOS CONFIGURATIONS --
---------------------------

-- TRAJECTORIES --

local TrajectoriesConfig = {
	polygon = {
		enabled = true;
		r = 60; g = 155; b = 200; a = 50;
		size = 10; segments = 20;
	};
	
	line = {
		enabled = true;
		r = 255; g = 255; b = 255; a = 20;
	};

	flags = {
		enabled = false;
		r = 255; g = 0; b = 0; a = 255;
		size = 5;
	};

	outline = {
		line_and_flags = true; polygon = true;
		r = 0; g = 0; b = 0; a = 155;
	};

	-- 0.5 to 8, determines the size of the segments traced, lower values = worse performance (default 2.5)
	measure_segment_size = 2.5;
};

-- WATERMARK --

local WatermarkConfig = {
    enabled = true,
	showfps = true,
	showping = true,
	showtime = true,
    X = 0.11, -- 0.11 for top left, 0.9305 for top right
    Y = 0.03,
    Colors123321 = {
    main_Color = {255, 255, 255, 255}, -- main text color
    big_text_fade1_color = {60, 155, 200, 255}, -- 1st shadow
    big_text_fade2_color = {90, 195, 200, 255}, -- 2nd shadow
    background_Color_Primary = {0, 0, 0, 128}, -- transparent backdrop
    background_Color_Secondary = {30, 40, 50, 255} -- front panel
    }
}

-- CHAT EXTRAS --

local ChatExtrasConfig = {
    enabled = true,
	timestamps = true,
	chatprefix = '[COSMOS] ',
	timestampcolor = '#aaaaaaff',
	prefixcolor = '#00aaffff'
}

-- CHARGE BAR (DT/DASH) --

local ChargeBarConfig = {
    enabled = true
}

-- TRIMP HELPER --

local TrimpHelperConfig = {
    enabled = true
}

-- STICKY AUTORELEASE --

local StickyAutoReleaseConfig = {
	--[[
		set this to a number between 0 and 1 for what charge you want to release the sticky at
		example:
		0 = instant release
		1 = wait until fully charge
		0.5 = wait for %50 charge
	]]
    charge = 0
}

-- INSTANT REVOLVER RELOAD --

local InstantRevolveReload = {
    enabled = true
}



------------------ (https://lmaobox.net/forum/v/discussion/23942/release-visualize-arc-trajectories/p1)
-- TRAJECTORIES -- (https://raw.githubusercontent.com/GoodEveningFellOff/lmaobox-visualize-arc-trajectories/main/main.lua)
------------------ (https://lmaobox.net/forum/v/profile/34540519/DeathThe1)



-- Boring shit ahead!
local CROSS = (function(a, b, c) return (b[1] - a[1]) * (c[2] - a[2]) - (b[2] - a[2]) * (c[1] - a[1]); end);
local CLAMP = (function(a, b, c) return (a<b) and b or (a>c) and c or a; end);
local TRACE_HULL = engine.TraceHull;
local WORLD2SCREEN = client.WorldToScreen;
local POLYGON = draw.TexturedPolygon;
local LINE = draw.Line;
local COLOR = draw.Color;

local aItemDefinitions = {};
do
	local laDefinitions = {
		[222]	= 11;		--Mad Milk                                      tf_weapon_jar_milk
		[812]	= 12;		--The Flying Guillotine                         tf_weapon_cleaver
		[833]	= 12;		--The Flying Guillotine (Genuine)               tf_weapon_cleaver
		[1121]	= 11;		--Mutated Milk                                  tf_weapon_jar_milk

		[18]	= -1;		--Rocket Launcher                               tf_weapon_rocketlauncher
		[205]	= -1;		--Rocket Launcher (Renamed/Strange)             tf_weapon_rocketlauncher
		[127]	= -1;		--The Direct Hit                                tf_weapon_rocketlauncher_directhit
		[228]	= -1;		--The Black Box                                 tf_weapon_rocketlauncher
		[237]	= -1;		--Rocket Jumper                                 tf_weapon_rocketlauncher
		[414]	= -1;		--The Liberty Launcher                          tf_weapon_rocketlauncher
		[441]	= -1;		--The Cow Mangler 5000                          tf_weapon_particle_cannon	
		[513]	= -1;		--The Original                                  tf_weapon_rocketlauncher
		[658]	= -1;		--Festive Rocket Launcher                       tf_weapon_rocketlauncher
		[730]	= -1;		--The Beggar's Bazooka                          tf_weapon_rocketlauncher
		[800]	= -1;		--Silver Botkiller Rocket Launcher Mk.I         tf_weapon_rocketlauncher
		[809]	= -1;		--Gold Botkiller Rocket Launcher Mk.I           tf_weapon_rocketlauncher
		[889]	= -1;		--Rust Botkiller Rocket Launcher Mk.I           tf_weapon_rocketlauncher
		[898]	= -1;		--Blood Botkiller Rocket Launcher Mk.I          tf_weapon_rocketlauncher
		[907]	= -1;		--Carbonado Botkiller Rocket Launcher Mk.I      tf_weapon_rocketlauncher
		[916]	= -1;		--Diamond Botkiller Rocket Launcher Mk.I        tf_weapon_rocketlauncher
		[965]	= -1;		--Silver Botkiller Rocket Launcher Mk.II        tf_weapon_rocketlauncher
		[974]	= -1;		--Gold Botkiller Rocket Launcher Mk.II          tf_weapon_rocketlauncher
		[1085]	= -1;		--Festive Black Box                             tf_weapon_rocketlauncher
		[1104]	= -1;		--The Air Strike                                tf_weapon_rocketlauncher_airstrike
		[15006]	= -1;		--Woodland Warrior                              tf_weapon_rocketlauncher
		[15014]	= -1;		--Sand Cannon                                   tf_weapon_rocketlauncher
		[15028]	= -1;		--American Pastoral                             tf_weapon_rocketlauncher
		[15043]	= -1;		--Smalltown Bringdown                           tf_weapon_rocketlauncher
		[15052]	= -1;		--Shell Shocker                                 tf_weapon_rocketlauncher
		[15057]	= -1;		--Aqua Marine                                   tf_weapon_rocketlauncher
		[15081]	= -1;		--Autumn                                        tf_weapon_rocketlauncher
		[15104]	= -1;		--Blue Mew                                      tf_weapon_rocketlauncher
		[15105]	= -1;		--Brain Candy                                   tf_weapon_rocketlauncher
		[15129]	= -1;		--Coffin Nail                                   tf_weapon_rocketlauncher
		[15130]	= -1;		--High Roller's                                 tf_weapon_rocketlauncher
		[15150]	= -1;		--Warhawk                                       tf_weapon_rocketlauncher

		[442]	= -1;		--The Righteous Bison                           tf_weapon_raygun

		[1178]	= -1;		--Dragon's Fury                                 tf_weapon_rocketlauncher_fireball

		[39]	= 8;		--The Flare Gun                                 tf_weapon_flaregun
		[351]	= 8;		--The Detonator                                 tf_weapon_flaregun
		[595]	= 8;		--The Manmelter                                 tf_weapon_flaregun_revenge
		[740]	= 8;		--The Scorch Shot                               tf_weapon_flaregun
		[1180]	= 0;		--Gas Passer                                    tf_weapon_jar_gas

		[19]	= 5;		--Grenade Launcher                              tf_weapon_grenadelauncher
		[206]	= 5;		--Grenade Launcher (Renamed/Strange)            tf_weapon_grenadelauncher
		[308]	= 5;		--The Loch-n-Load                               tf_weapon_grenadelauncher
		[996]	= 6;		--The Loose Cannon                              tf_weapon_cannon
		[1007]	= 5;		--Festive Grenade Launcher                      tf_weapon_grenadelauncher
		[1151]	= 4;		--The Iron Bomber                               tf_weapon_grenadelauncher
		[15077]	= 5;		--Autumn                                        tf_weapon_grenadelauncher
		[15079]	= 5;		--Macabre Web                                   tf_weapon_grenadelauncher
		[15091]	= 5;		--Rainbow                                       tf_weapon_grenadelauncher
		[15092]	= 5;		--Sweet Dreams                                  tf_weapon_grenadelauncher
		[15116]	= 5;		--Coffin Nail                                   tf_weapon_grenadelauncher
		[15117]	= 5;		--Top Shelf                                     tf_weapon_grenadelauncher
		[15142]	= 5;		--Warhawk                                       tf_weapon_grenadelauncher
		[15158]	= 5;		--Butcher Bird                                  tf_weapon_grenadelauncher

		[20]	= 1;		--Stickybomb Launcher                           tf_weapon_pipebomblauncher
		[207]	= 1;		--Stickybomb Launcher (Renamed/Strange)         tf_weapon_pipebomblauncher
		[130]	= 3;		--The Scottish Resistance                       tf_weapon_pipebomblauncher
		[265]	= 3;		--Sticky Jumper                                 tf_weapon_pipebomblauncher
		[661]	= 1;		--Festive Stickybomb Launcher                   tf_weapon_pipebomblauncher
		[797]	= 1;		--Silver Botkiller Stickybomb Launcher Mk.I     tf_weapon_pipebomblauncher
		[806]	= 1;		--Gold Botkiller Stickybomb Launcher Mk.I       tf_weapon_pipebomblauncher
		[886]	= 1;		--Rust Botkiller Stickybomb Launcher Mk.I       tf_weapon_pipebomblauncher
		[895]	= 1;		--Blood Botkiller Stickybomb Launcher Mk.I      tf_weapon_pipebomblauncher
		[904]	= 1;		--Carbonado Botkiller Stickybomb Launcher Mk.I  tf_weapon_pipebomblauncher
		[913]	= 1;		--Diamond Botkiller Stickybomb Launcher Mk.I    tf_weapon_pipebomblauncher
		[962]	= 1;		--Silver Botkiller Stickybomb Launcher Mk.II    tf_weapon_pipebomblauncher
		[971]	= 1;		--Gold Botkiller Stickybomb Launcher Mk.II      tf_weapon_pipebomblauncher
		[1150]	= 2;		--The Quickiebomb Launcher                      tf_weapon_pipebomblauncher
		[15009]	= 1;		--Sudden Flurry                                 tf_weapon_pipebomblauncher
		[15012]	= 1;		--Carpet Bomber                                 tf_weapon_pipebomblauncher
		[15024]	= 1;		--Blasted Bombardier                            tf_weapon_pipebomblauncher
		[15038]	= 1;		--Rooftop Wrangler                              tf_weapon_pipebomblauncher
		[15045]	= 1;		--Liquid Asset                                  tf_weapon_pipebomblauncher
		[15048]	= 1;		--Pink Elephant                                 tf_weapon_pipebomblauncher
		[15082]	= 1;		--Autumn                                        tf_weapon_pipebomblauncher
		[15083]	= 1;		--Pumpkin Patch                                 tf_weapon_pipebomblauncher
		[15084]	= 1;		--Macabre Web                                   tf_weapon_pipebomblauncher
		[15113]	= 1;		--Sweet Dreams                                  tf_weapon_pipebomblauncher
		[15137]	= 1;		--Coffin Nail                                   tf_weapon_pipebomblauncher
		[15138]	= 1;		--Dressed to Kill                               tf_weapon_pipebomblauncher
		[15155]	= 1;		--Blitzkrieg                                    tf_weapon_pipebomblauncher

		[588]	= -1;		--The Pomson 6000                               tf_weapon_drg_pomson
		[997]	= 9;		--The Rescue Ranger                             tf_weapon_shotgun_building_rescue

		[17]	= 10;		--Syringe Gun                                   tf_weapon_syringegun_medic
		[204]	= 10;		--Syringe Gun (Renamed/Strange)                 tf_weapon_syringegun_medic
		[36]	= 10;		--The Blutsauger                                tf_weapon_syringegun_medic
		[305]	= 9;		--Crusader's Crossbow                           tf_weapon_crossbow
		[412]	= 10;		--The Overdose                                  tf_weapon_syringegun_medic
		[1079]	= 9;		--Festive Crusader's Crossbow                   tf_weapon_crossbow

		[56]	= 7;		--The Huntsman                                  tf_weapon_compound_bow
		[1005]	= 7;		--Festive Huntsman                              tf_weapon_compound_bow
		[1092]	= 7;		--The Fortified Compound                        tf_weapon_compound_bow

		[58]	= 11;		--Jarate                                        tf_weapon_jar
		[1083]	= 11;		--Festive Jarate                                tf_weapon_jar
		[1105]	= 11;		--The Self-Aware Beauty Mark                    tf_weapon_jar
	};

	local iHighestItemDefinitionIndex = 0;
	for i, _ in pairs(laDefinitions) do
		iHighestItemDefinitionIndex = math.max(iHighestItemDefinitionIndex, i);
	end

	for i = 1, iHighestItemDefinitionIndex do
		table.insert(aItemDefinitions, laDefinitions[i] or false)
	end
end

local PhysicsEnvironment = physics.CreateEnvironment();
do
	PhysicsEnvironment:SetGravity( Vector3( 0, 0, -800 ) )
	PhysicsEnvironment:SetAirDensity( 2.0 )
	PhysicsEnvironment:SetSimulationTimestep(1/66)
end

local PhysicsObjectHandler = {
    m_aObjects = {},
    m_iActiveObject = 0
}

function PhysicsObjectHandler:Initialize()
    if #self.m_aObjects > 0 then return end

    local function addObject(path)
        local solid, model = physics.ParseModelByName(path)
        table.insert(self.m_aObjects, PhysicsEnvironment:CreatePolyObject(model, solid:GetSurfacePropName(), solid:GetObjectParameters()))
    end

    addObject("models/weapons/w_models/w_stickybomb.mdl")                                     -- Stickybomb
    addObject("models/workshop/weapons/c_models/c_kingmaker_sticky/w_kingmaker_stickybomb.mdl") -- QuickieBomb
    addObject("models/weapons/w_models/w_stickybomb_d.mdl")                                    -- ScottishResistance, StickyJumper

    self.m_aObjects[1]:Wake()
    self.m_iActiveObject = 1
end

function PhysicsObjectHandler:Destroy()
    self.m_iActiveObject = 0

    if #self.m_aObjects == 0 then return end

    for _, obj in ipairs(self.m_aObjects) do
        PhysicsEnvironment:DestroyObject(obj)
    end

    self.m_aObjects = {}
end

setmetatable(PhysicsObjectHandler, {
    __call = function(self, iRequestedObject)
        if iRequestedObject ~= self.m_iActiveObject then
            self.m_aObjects[self.m_iActiveObject]:Sleep()
            self.m_aObjects[iRequestedObject]:Wake()
            self.m_iActiveObject = iRequestedObject
        end

        return self.m_aObjects[self.m_iActiveObject]
    end
})

local TrajectoryLine = {
    m_aPositions = {},
    m_iSize = 0,
    m_vFlagOffset = Vector3(0, 0, 0),
}

function TrajectoryLine:Insert(vec)
    self.m_iSize = self.m_iSize + 1
    self.m_aPositions[self.m_iSize] = vec
end

local iLineRed, iLineGreen, iLineBlue, iLineAlpha = TrajectoriesConfig.line.r, TrajectoriesConfig.line.g, TrajectoriesConfig.line.b, TrajectoriesConfig.line.a
local iFlagRed, iFlagGreen, iFlagBlue, iFlagAlpha = TrajectoriesConfig.flags.r, TrajectoriesConfig.flags.g, TrajectoriesConfig.flags.b, TrajectoriesConfig.flags.a
local iOutlineRed, iOutlineGreen, iOutlineBlue, iOutlineAlpha = TrajectoriesConfig.outline.r, TrajectoriesConfig.outline.g, TrajectoriesConfig.outline.b, TrajectoriesConfig.outline.a
local iOutlineOffsetInner = (TrajectoriesConfig.flags.size < 1) and -1 or 0
local iOutlineOffsetOuter = (TrajectoriesConfig.flags.size < 1) and -1 or 1

local function drawOutline(new, last)
    if math.abs(last[1] - new[1]) > math.abs(last[2] - new[2]) then
        LINE(last[1], last[2] - 1, new[1], new[2] - 1)
        LINE(last[1], last[2] + 1, new[1], new[2] + 1)
    else
        LINE(last[1] - 1, last[2], new[1] - 1, new[2])
        LINE(last[1] + 1, last[2], new[1] + 1, new[2])
    end
end

local metatable = { __call = nil }

if TrajectoriesConfig.outline.line_and_flags then
    local function drawLinesAndFlags(color, positions, offset, offsetInner, offsetOuter)
        local last = nil

        for i = #positions, 1, -1 do
            local this_pos = positions[i]
            local new, newf = WORLD2SCREEN(this_pos), WORLD2SCREEN(this_pos + offset)

            if last and new then
                COLOR(iOutlineRed, iOutlineGreen, iOutlineBlue, iOutlineAlpha)
                drawOutline(new, last)
                COLOR(color[1], color[2], color[3], color[4])
                LINE(last[1], last[2], new[1], new[2])
            end

            if new and newf then
                COLOR(iFlagRed, iFlagGreen, iFlagBlue, iFlagAlpha)
                LINE(newf[1], newf[2], new[1], new[2])
                COLOR(iOutlineRed, iOutlineGreen, iOutlineBlue, iOutlineAlpha)
                LINE(newf[1] - offsetOuter, newf[2] - 1, newf[1] - offsetOuter, newf[2] + 2)
            end

            last = new
        end
    end

    if TrajectoriesConfig.line.enabled and TrajectoriesConfig.flags.enabled then
        metatable.__call = function(self)
            drawLinesAndFlags({ iLineRed, iLineGreen, iLineBlue, iLineAlpha }, self.m_aPositions, self.m_vFlagOffset, iOutlineOffsetInner, iOutlineOffsetOuter)
        end
    elseif TrajectoriesConfig.line.enabled then
        metatable.__call = function(self)
            local last = nil

            for i = #self.m_aPositions, 1, -1 do
                local new = WORLD2SCREEN(self.m_aPositions[i])

                if last and new then
                    COLOR(iOutlineRed, iOutlineGreen, iOutlineBlue, iOutlineAlpha)
                    drawOutline(new, last)
                    COLOR(iLineRed, iLineGreen, iLineBlue, iLineAlpha)
                    LINE(last[1], last[2], new[1], new[2])
                end

                last = new
            end
        end
    else
        metatable.__call = function(self)
            drawLinesAndFlags({ iFlagRed, iFlagGreen, iFlagBlue, iFlagAlpha }, self.m_aPositions, self.m_vFlagOffset, iOutlineOffsetInner, iOutlineOffsetOuter)
        end
    end
else
    if TrajectoriesConfig.line.enabled and TrajectoriesConfig.flags.enabled then
        metatable.__call = function(self)
            local last = nil

            for i = #self.m_aPositions, 1, -1 do
                local this_pos = self.m_aPositions[i]
                local new, newf = WORLD2SCREEN(this_pos), WORLD2SCREEN(this_pos + self.m_vFlagOffset)

                if last and new then
                    COLOR(iLineRed, iLineGreen, iLineBlue, iLineAlpha)
                    LINE(last[1], last[2], new[1], new[2])
                end

                if new and newf then
                    COLOR(iFlagRed, iFlagGreen, iFlagBlue, iFlagAlpha)
                    LINE(newf[1], newf[2], new[1], new[2])
                end

                last = new
            end
        end
    elseif TrajectoriesConfig.line.enabled then
        metatable.__call = function(self)
            local last = nil

            COLOR(iLineRed, iLineGreen, iLineBlue, iLineAlpha)
            for i = #self.m_aPositions, 1, -1 do
                local new = WORLD2SCREEN(self.m_aPositions[i])

                if last and new then
                    LINE(last[1], last[2], new[1], new[2])
                end

                last = new
            end
        end
    else
        metatable.__call = function(self)
            COLOR(iFlagRed, iFlagGreen, iFlagBlue, iFlagAlpha)
            for i = #self.m_aPositions, 1, -1 do
                local this_pos = self.m_aPositions[i]
                local new, newf = WORLD2SCREEN(this_pos), WORLD2SCREEN(this_pos + self.m_vFlagOffset)

                if new and newf then
                    LINE(newf[1], newf[2], new[1], new[2])
                end
            end
        end
    end
end

setmetatable(TrajectoryLine, metatable)

local ImpactPolygon = {
    m_iTexture = draw.CreateTextureRGBA(string.char(0xff, 0xff, 0xff, TrajectoriesConfig.polygon.a, 0xff, 0xff, 0xff, TrajectoriesConfig.polygon.a, 0xff, 0xff, 0xff, TrajectoriesConfig.polygon.a, 0xff, 0xff, 0xff, TrajectoriesConfig.polygon.a), 2, 2)
}

local iSegments = TrajectoriesConfig.polygon.segments
local fSegmentAngleOffset = math.pi / iSegments
local fSegmentAngle = fSegmentAngleOffset * 2

local function calculatePositions(plane, origin)
    local positions = {}
    local radius = TrajectoriesConfig.polygon.size

    if math.abs(plane.z) >= 0.99 then
        for i = 1, iSegments do
            local ang = i * fSegmentAngle + fSegmentAngleOffset
            positions[i] = WORLD2SCREEN(origin + Vector3(radius * math.cos(ang), radius * math.sin(ang), 0))
            if not positions[i] then
                return
            end
        end
    else
        local right = Vector3(-plane.y, plane.x, 0)
        local up = Vector3(plane.z * right.y, -plane.z * right.x, (plane.y * right.x) - (plane.x * right.y))
        radius = radius / math.cos(math.asin(plane.z))

        for i = 1, iSegments do
            local ang = i * fSegmentAngle + fSegmentAngleOffset
            positions[i] = WORLD2SCREEN(origin + (right * (radius * math.cos(ang))) + (up * (radius * math.sin(ang))))
            if not positions[i] then
                return
            end
        end
    end

    return positions
end

local function drawPolygonOutlines(positions)
    local last = positions[#positions]

    local function drawLine(x1, y1, x2, y2)
        LINE(x1, y1, x2, y2)
    end

    COLOR(TrajectoriesConfig.outline.r, TrajectoriesConfig.outline.g, TrajectoriesConfig.outline.b, TrajectoriesConfig.outline.a)

    for i = 1, #positions do
        local new = positions[i]

        if math.abs(new[1] - last[1]) > math.abs(new[2] - last[2]) then
            drawLine(last[1], last[2] + 1, new[1], new[2] + 1)
            drawLine(last[1], last[2] - 1, new[1], new[2] - 1)
        else
            drawLine(last[1] + 1, last[2], new[1] + 1, new[2])
            drawLine(last[1] - 1, last[2], new[1] - 1, new[2])
        end

        last = new
    end
end

local function drawPolygon(plane, origin)
    local positions = calculatePositions(plane, origin)

    if not positions then
        return
    end

    local function drawLine(x1, y1, x2, y2)
        LINE(x1, y1, x2, y2)
    end

    COLOR(TrajectoriesConfig.polygon.r, TrajectoriesConfig.polygon.g, TrajectoriesConfig.polygon.b, 255)

    local cords, reverse_cords = {}, {}
    local sizeof = #positions
    local sum = 0

    for i, pos in ipairs(positions) do
        local convertedTbl = { pos[1], pos[2], 0, 0 }
        cords[i], reverse_cords[sizeof - i + 1] = convertedTbl, convertedTbl
        sum = sum + CROSS(pos, positions[(i % sizeof) + 1], positions[1])
    end

    POLYGON(ImpactPolygon.m_iTexture, (sum < 0) and reverse_cords or cords, true)

    drawPolygonOutlines(positions)
end

local metatable = { __call = function(self, plane, origin) end }

if TrajectoriesConfig.polygon.enabled then
    if TrajectoriesConfig.outline.polygon then
        metatable.__call = function(self, plane, origin)
            local positions = calculatePositions(plane, origin)
            if positions then
                drawPolygonOutlines(positions)
                drawPolygon(plane, origin)
            end
        end
    else
        metatable.__call = drawPolygon
    end
end

setmetatable(ImpactPolygon, metatable)

local GetProjectileInformation = (function()
    local offsets = {
        Vector3(16, 8, -6),
        Vector3(23.5, -8, -3),
        Vector3(23.5, 12, -3),
        Vector3(16, 6, -8)
    }

    local collisionMaxs = {
        Vector3(0, 0, 0),
        Vector3(1, 1, 1),
        Vector3(2, 2, 2),
        Vector3(3, 3, 3)
    }

    local function calculateRocketLauncherValues(bDucking, iDefIndex, iWepID)
        local vOffset, vCollisionMax, fForwardVelocity = Vector3(23.5, -8, bDucking and 8 or -3), collisionMaxs[2], 0
        
        if iWepID == 22 or iWepID == 65 then
            vOffset.y, vCollisionMax, fForwardVelocity = (iDefIndex == 513) and 0 or 12, collisionMaxs[1], (iWepID == 65) and 2000 or (iDefIndex == 414) and 1550 or 1100
        elseif iWepID == 109 then
            vOffset.y, vOffset.z = 6, -3
        else
            fForwardVelocity = 1200
        end
        
        return vOffset, fForwardVelocity, 0, vCollisionMax, 0
    end

    -- Previous code remains unchanged

	return function(pLocal, bDucking, iCase, iDefIndex, iWepID)
	    local fChargeBeginTime = (pLocal:GetPropFloat("PipebombLauncherLocalData", "m_flChargeBeginTime") or 0)
	
	    if fChargeBeginTime ~= 0 then
	        fChargeBeginTime = globals.CurTime() - fChargeBeginTime
	    end
	
	    if iCase == -1 then
			return calculateRocketLauncherValues(bDucking, iDefIndex, iWepID)
		elseif iCase == 1 then
			return offsets[1], 900 + CLAMP(fChargeBeginTime / 4, 0, 1) * 1500, 200, collisionMaxs[3], 0		-- StickyBomb
		elseif iCase == 2 then
			return offsets[1], 900 + CLAMP(fChargeBeginTime / 1.2, 0, 1) * 1500, 200, collisionMaxs[3], 0	-- QuickieBomb
		elseif iCase == 3 then
			return offsets[1], 900 + CLAMP(fChargeBeginTime / 4, 0, 1) * 1500, 200, collisionMaxs[3], 0		-- ScottishResistance, StickyJumper
		elseif iCase == 4 then
			return offsets[1], 1200, 200, collisionMaxs[3], 400, 0.45										-- TheIronBomber
		elseif iCase == 5 then
			return offsets[1], (iDefIndex == 308) and 1500 or 1200, 200, collisionMaxs[3], 400,				-- GrenadeLauncher, LochnLoad
				   (iDefIndex == 308) and 0.225 or 0.45
		elseif iCase == 6 then
			return offsets[1], 1440, 200, collisionMaxs[3], 560, 0.5										-- LooseCannon
		elseif iCase == 7 then
			return offsets[2], 1800 + CLAMP(fChargeBeginTime, 0, 1) * 800, 0, collisionMaxs[2],				-- Huntsman
				   200 - CLAMP(fChargeBeginTime, 0, 1) * 160
		elseif iCase == 8 then
			return Vector3(23.5, 12, bDucking and 8 or -3), 2000, 0, collisionMaxs[1], 120					-- FlareGuns
		elseif iCase == 9 then
			return offsets[2], 2400, 0, collisionMaxs[((iDefIndex == 997) and 2 or 4)], 80					-- CrusadersCrossbow, RescueRanger
		elseif iCase == 10 then
			return offsets[4], 1000, 0, collisionMaxs[2], 120												-- SyringeGuns
		elseif iCase == 11 then
			return Vector3(23.5, 8, -3), 1000, 200, collisionMaxs[4], 450									-- Jarate, MadMilk
		elseif iCase == 12 then
			return Vector3(23.5, 8, -3), 3000, 300, collisionMaxs[3], 900, 1.3								-- FlyingGuillotine
		end		
	end
end)()

local g_fTraceInterval = CLAMP(TrajectoriesConfig.measure_segment_size, 0.5, 8) / 66;
local g_fFlagInterval = g_fTraceInterval * 1320;

callbacks.Register("CreateMove", "LoadPhysicsObjects", function()
	callbacks.Unregister("CreateMove", "LoadPhysicsObjects")

	PhysicsObjectHandler:Initialize()

	callbacks.Register("Draw", function()
		TrajectoryLine.m_aPositions, TrajectoryLine.m_iSize = {}, 0;

		if engine.Con_IsVisible() or engine.IsGameUIVisible() then
			return;
		end

		local pLocal = entities.GetLocalPlayer();
		if not pLocal or pLocal:InCond(7) or not pLocal:IsAlive() then return end
	
		local pWeapon = pLocal:GetPropEntity("m_hActiveWeapon");
		if not pWeapon or (pWeapon:GetWeaponProjectileType() or 0) < 2 then return end

		local iItemDefinitionIndex = pWeapon:GetPropInt("m_iItemDefinitionIndex");
		local iItemDefinitionType = aItemDefinitions[iItemDefinitionIndex] or 0;
		if iItemDefinitionType == 0 then return end

		local vOffset, fForwardVelocity, fUpwardVelocity, vCollisionMax, fGravity, fDrag = GetProjectileInformation(pWeapon, (pLocal:GetPropInt("m_fFlags") & FL_DUCKING) == 2, iItemDefinitionType, iItemDefinitionIndex, pWeapon:GetWeaponID());
		local vCollisionMin = -vCollisionMax;

		local vStartPosition, vStartAngle = pLocal:GetAbsOrigin() + pLocal:GetPropVector("localdata", "m_vecViewOffset[0]"), engine.GetViewAngles();

		local results = TRACE_HULL(vStartPosition, vStartPosition + (vStartAngle:Forward() * vOffset.x) + (vStartAngle:Right() * (vOffset.y * (pWeapon:IsViewModelFlipped() and -1 or 1))) + (vStartAngle:Up() * vOffset.z), vCollisionMin, vCollisionMax, 100679691);
		if results.fraction ~= 1 then return end

		vStartPosition = results.endpos;

		if iItemDefinitionType == -1 or (iItemDefinitionType >= 7 and iItemDefinitionType < 11) and fForwardVelocity ~= 0 then
			local res = engine.TraceLine(results.startpos, results.startpos + (vStartAngle:Forward() * 2000), 100679691);
			vStartAngle = (((res.fraction <= 0.1) and (results.startpos + (vStartAngle:Forward() * 2000)) or res.endpos) - vStartPosition):Angles();
		end
			
		local vVelocity = (vStartAngle:Forward() * fForwardVelocity) + (vStartAngle:Up() * fUpwardVelocity);

		if TrajectoriesConfig.flags.enabled then
			TrajectoryLine.m_vFlagOffset = vStartAngle:Right() * -TrajectoriesConfig.flags.size;
		end
		TrajectoryLine:Insert(vStartPosition);

		if iItemDefinitionType == -1 then
			results = TRACE_HULL(vStartPosition, vStartPosition + (vStartAngle:Forward() * 10000), vCollisionMin, vCollisionMax, 100679691);

			if results.startsolid then return end
				
			local iSegments = math.floor((results.endpos - results.startpos):Length() / g_fFlagInterval);
			local vForward = vStartAngle:Forward();
				
			for i = 1, iSegments do
				TrajectoryLine:Insert(vForward * (i * g_fFlagInterval) + vStartPosition);
			end

			TrajectoryLine:Insert(results.endpos);

		elseif iItemDefinitionType > 3 then
		
			local vPosition = Vector3(0, 0, 0);
			for i = 0.01515, 5, g_fTraceInterval do
				local scalar = (not fDrag) and i or ((1 - math.exp(-fDrag * i)) / fDrag);

				vPosition.x = vVelocity.x * scalar + vStartPosition.x;
				vPosition.y = vVelocity.y * scalar + vStartPosition.y;
				vPosition.z = (vVelocity.z - fGravity * i) * scalar + vStartPosition.z;

				results = TRACE_HULL(results.endpos, vPosition, vCollisionMin, vCollisionMax, 100679691);

				TrajectoryLine:Insert(results.endpos);

				if results.fraction ~= 1 then break; end
			end
		
		else
			local obj = PhysicsObjectHandler(iItemDefinitionType);

			obj:SetPosition(vStartPosition, vStartAngle, true)
			obj:SetVelocity(vVelocity, Vector3(0, 0, 0))

			for i = 2, 330 do
				results = TRACE_HULL(results.endpos, obj:GetPosition(), vCollisionMin, vCollisionMax, 100679691);
				TrajectoryLine:Insert(results.endpos);

				if results.fraction ~= 1 then break; end
				PhysicsEnvironment:Simulate(g_fTraceInterval);
			end

			PhysicsEnvironment:ResetSimulationClock();
		end

		if TrajectoryLine.m_iSize == 0 then return end
		if results then
			ImpactPolygon(results.plane, results.endpos)
		end

		if TrajectoryLine.m_iSize == 1 then return end
		TrajectoryLine();
	end)
end)

callbacks.Register("Unload", function()
	PhysicsObjectHandler:Destroy();
	physics.DestroyEnvironment(PhysicsEnvironment);
	draw.DeleteTexture(ImpactPolygon.m_iTexture);
end)



--------------- (https://lmaobox.net/forum/v/discussion/23226/neverlose-styled-watermark/p1)
-- WATERMARK -- (https://raw.githubusercontent.com/Muqa1/Muqa-LBOX-pastas/main/neverlose%20watermark.lua)
--------------- (https://lmaobox.net/forum/v/profile/34538831/muqa)



-- Fonts
local WatermarkFont = draw.CreateFont("Museo Sans Cryl 900", 24, 800)
local WatermarkInfoFont = draw.CreateFont("Museo Sans Cryl 900", 19, 500)

-- Function to draw the watermark
local function DrawWatermark()
    if not WatermarkConfig.enabled or engine.IsGameUIVisible() then
        return
    end

    local baseBoxWidth = 90
    local baseBoxHeight = math.floor(2.5 * 10)

    local additionalWidth = 0

    -- Check if showfps, showping, or showtime are enabled, and adjust box size accordingly
    if WatermarkConfig.showfps then
        additionalWidth = additionalWidth + 70
    end

    if WatermarkConfig.showping then
        additionalWidth = additionalWidth + 60
    end

    if WatermarkConfig.showtime then
        additionalWidth = additionalWidth + 80
    end

    local boxWidth = baseBoxWidth + additionalWidth
    local boxHeight = baseBoxHeight

    local sWidth, sHeight = draw.GetScreenSize()

    local xPos = math.floor(sWidth * WatermarkConfig.X - boxWidth * 0.63)
    local yPos = math.floor(sHeight * WatermarkConfig.Y - boxHeight * 0.5)

    -- Draw background box
    draw.Color(table.unpack(WatermarkConfig.Colors123321.background_Color_Primary))
    draw.FilledRect(xPos - 2, yPos - 2, xPos + boxWidth + 2, yPos + boxHeight + 2)

    -- Draw foreground box
    draw.Color(table.unpack(WatermarkConfig.Colors123321.background_Color_Secondary))
    draw.FilledRect(xPos, yPos, xPos + boxWidth, yPos + boxHeight)

    -- Draw watermark text with fading effect
    draw.SetFont(WatermarkFont)
    draw.Color(table.unpack(WatermarkConfig.Colors123321.big_text_fade1_color))
    draw.Text(xPos + 3, yPos - 2, "COSMOS")
    draw.Color(table.unpack(WatermarkConfig.Colors123321.big_text_fade2_color))
    draw.Text(xPos + 4, yPos - 1, "COSMOS")
    draw.Color(table.unpack(WatermarkConfig.Colors123321.main_Color))
    draw.Text(xPos + 5, yPos, "COSMOS")

    -- Draw FPS
    local current_fps = math.floor(1 / globals.FrameTime())
    draw.Color(table.unpack(WatermarkConfig.Colors123321.main_Color))
    draw.SetFont(WatermarkInfoFont)
    if WatermarkConfig.showfps then
        draw.Text(xPos + 95, yPos + 2, "| " .. current_fps .. " fps")
    end

    -- Draw ping
    local ping = clientstate.GetClientSignonState() == 6 and entities.GetPlayerResources():GetPropDataTableInt("m_iPing")[entities.GetLocalPlayer():GetIndex()] or "-"
    draw.Color(table.unpack(WatermarkConfig.Colors123321.main_Color))
    if WatermarkConfig.showping then
		local pingXOffset = 165
		if not WatermarkConfig.showfps then
			pingXOffset = pingXOffset - 66
		end
    	draw.Text(xPos + pingXOffset, yPos + 2, "| " .. ping .. " ms")
    end

    -- Draw time
    draw.Color(table.unpack(WatermarkConfig.Colors123321.main_Color))
	if WatermarkConfig.showtime then
	    local timeXOffset = 220
	    if not WatermarkConfig.showping and not WatermarkConfig.showfps then
	        timeXOffset = timeXOffset - 126
		elseif not WatermarkConfig.showping then
			timeXOffset = timeXOffset - 60
	    elseif not WatermarkConfig.showfps then
	        timeXOffset = timeXOffset - 70
	    end
	    draw.Text(xPos + timeXOffset, yPos + 2, "| " .. os.date("%I:%M %p"))
	end
end

-- Register callback for drawing the watermark
callbacks.Register("Draw", "DrawWatermark", DrawWatermark)



----------------- (https://lmaobox.net/forum/v/discussion/22018/coolchatflag-lua-draft/p1)
-- CHAT EXTRAS -- (https://github.com/lmaobox-lua/lmaobox-scripting/blob/master/end-of-support-lua/coolchatflag.lua)
----------------- (https://lmaobox.net/forum/v/profile/34528194/masterhero)



-- Colors
local whiteColor, oldColor, teamColor, locationColor, achievementColor, blackColor = '\x01', '\x02', '\x03', '\x04', '\x05', '\x06'
local rgbColor = function(hexcodes) return '\x07' .. hexcodes:gsub('#', '') end
local argbColor = function(hexcodes_a) return '\x08' .. hexcodes_a:gsub('#', '') end
local toRgba = function(hexcodes_a)
    local i32 = type(hexcodes_a) == 'string' and tonumber('0x' .. hexcodes_a:gsub('#', '')) or hexcodes_a
    return {i32 >> 24 & 0xFF, i32 >> 16 & 0xFF, i32 >> 8 & 0xFF, i32 & 0xFF}
end

-- Rainbow Colors
local rainbowColors = {
    '#C11B17FF', '#F87A17FF', '#FFFF00FF', '#00FF00FF', '#2B60DEFF', '#893BFFFF', '#F63817FF', '#E78E17FF',
    '#FFFC17FF', '#5EFB6EFF', '#1531ECFF', '#8E35EFFF',
    index = 1,
}

local rainbowMake = function()
    rainbowColors.index = rainbowColors.index + 1 > #rainbowColors and 1 or rainbowColors.index + 1
    return rainbowColors[rainbowColors.index]
end

-- Utility Functions
local makeUniqueString = function(prefix) return table.concat({prefix or '', engine.RandomFloat(0, 1), GetScriptName()}, '_') end

local makeCleanString = function(original)
    -- Filter control characters
    original = string.gsub(original, '%c', '')
    -- Escape magic characters
    original = string.gsub(original, '%%', '%%%%')
    return original
end

local colorizeString = function(original, toColorize, prefix, suffix)
    prefix = prefix or '\x03'
    suffix = suffix or '\x01'
    local m, original = {}, original:gsub('\x02', '')
    local i, j = original:find(toColorize, 1, true)
    j = j + 1
    for index = 1, #original do
        if index == i then m[#m + 1] = prefix end
        if index == j then m[#m + 1] = suffix end
        m[#m + 1] = original:sub(index, index)
    end
    return table.concat(m)
end

-- Callbacks
callbacks.Register('FireGameEvent', makeUniqueString(), function(event)
    if event:GetName() == 'player_changeclass' then

        -- add a check if we want to print this during a competitive game when team change class

        local player = entities.GetByUserID( event:GetInt( 'userid' ) )
        if not player or not player:IsValid() then return end
        local player_name, chat_text = player:GetName(), client.Localize( class_name[event:GetInt( 'class' )] )

        local base = client.Localize( 'TF_Class_Change' )
        base = base:gsub( '%%(.)%d+', '%%%1' ) -- remove number after format specifier 
        -- base:gsub( '%%([acdlpsuwxz])%d+', '%%%1' ) : for lua
        -- print( 'base:', table.concat( { string.byte( clone, 1, #clone ) }, ' ' ) )

        local original = string.format( ChatExtrasConfig.prefix, base, player_name, chat_text )
        local modified = colorizeString( original, player_name )

        -- add additional info
        local time, tag
		time = argbColor( ChatExtrasConfig.prefixcolor ) .. ChatExtrasConfig.chatprefix .. argbColor( ChatExtrasConfig.timestampcolor ) .. '[' .. os.date( '%H:%M' ) .. '] :'
        tag = ''
		if ChatExtrasConfig.timestamps then
			modified = '\x01' .. table.concat( { time, tag, modified }, ' ' )
		else
			modified = '\x01' .. table.concat( { tag, modified }, ' ' )
		end

        client.ChatPrintf( utf8.char( string.byte( modified, 1, #modified ) ) )
    end
end)

callbacks.Register('FireGameEvent', makeUniqueString(), function(event)
    if event:GetName() == 'player_connect_client' then
        local name, userid, networkid, bot = event:GetString( 'name' ), event:GetInt( 'userid' ), event:GetInt( 'networkid' ),
                                             event:GetInt( 'bot' )
        if bot == 0 or bot == 1 and engine.GetServerIP() == 'loopback' then
            local player_name = name
            local base = client.Localize( 'Game_connected' )
            base = base:gsub( '%%(.)%d+', '%%%1' ) -- remove number after format specifier 
            local original = string.format( base, player_name )
            local modified = colorizeString( original, player_name )
            local time, tag
			time = argbColor( ChatExtrasConfig.prefixcolor ) .. ChatExtrasConfig.chatprefix .. argbColor( ChatExtrasConfig.timestampcolor ) .. '[' .. os.date( '%H:%M' ) .. '] :'
            tag = ''
			if ChatExtrasConfig.timestamps then
				modified = '\x01' .. table.concat( { time, tag, modified }, ' ' )
			else
				modified = '\x01' .. table.concat( { tag, modified }, ' ' )
			end

            client.ChatPrintf( utf8.char( string.byte( modified, 1, #modified ) ) )
        end
    end
end)

callbacks.Register('DispatchUserMessage', makeUniqueString(), function(msg)
    if msg:GetID() == Shake or msg:GetID() == Fade then -- remove effect
        msg:WriteInt( 0, msg:GetDataBits() )
    end

    if msg:GetID() == SayText2 then
        local elem = {}
        local ent_idx, is_text_chat, chat_type, player_name, chat_text
        ent_idx, elem[#elem + 1] = msg:ReadByte()
        is_text_chat, elem[#elem + 1] = msg:ReadByte() -- if set to 1, GetFilterForString gets called
        chat_type, elem[#elem + 1] = msg:ReadString( 256 ) -- used in ReadLocalizedString
        player_name, elem[#elem + 1] = msg:ReadString( 256 )
        chat_text, elem[#elem + 1] = msg:ReadString( 256 )

        player_name, chat_text = makeCleanString( player_name ), makeCleanString( chat_text )

        local base = client.Localize( chat_type )
        base = base:gsub( '%%(.)%d+', '%%%1' ) -- remove number after format specifier 
        -- base:gsub( '%%([acdlpsuwxz])%d+', '%%%1' ) : for lua
        -- print( 'base:', table.concat( { string.byte( clone, 1, #clone ) }, ' ' ) )

        local original = string.format( base, player_name, chat_text )
        local modified = colorizeString( original, player_name )
        print( chat_type, #chat_type )
        if chat_type == '#TF_Name_Change' then
            -- bit & 0x000002 = 0
            -- if client.GetConVar( 'cl_chatfilters' ) -- todo respect user option
            modified = colorizeString( modified, chat_text, argbColor( rainbowMake() ) )
        end

        -- add additional info
        local time, tag
		time = argbColor( ChatExtrasConfig.prefixcolor ) .. ChatExtrasConfig.chatprefix .. argbColor( ChatExtrasConfig.timestampcolor ) .. '[' .. os.date( '%H:%M' ) .. '] :'
        tag = ''
		if ChatExtrasConfig.timestamps then
			modified = '\x01' .. table.concat( { time, tag, modified }, ' ' )
		else
			modified = '\x01' .. table.concat( { tag, modified }, ' ' )
		end

        print( 'modified:', table.concat( { string.byte( modified, 1, #modified ) }, ' ' ) )
        print( 'original:', table.concat( { string.byte( original, 1, #original ) }, ' ' ) )

        msg:SetCurBit( elem[2] ) -- no string localize for you.
        msg:WriteByte( 0 )

        client.ChatPrintf( utf8.char( string.byte( modified, 1, #modified ) ) )
    end
end)

local main = (function()
    local ret = client.Localize('TF_Engineer')
    if ret ~= nil then return end
    -- Too lazy to implement own localize function
    print(255, 60, 20, 255, string.format('[ERROR] %s cannot run (unsupported language)\nFix : change game language to English', GetScriptName()))
    UnloadScript(GetScriptName())
end)()



------------------- (https://lmaobox.net/forum/v/discussion/23859/release-recreation-of-r-cheat-s-dt-bar-made-in-lua/p1)
-- DASH/DT METER -- (https://github.com/MCPEnguXD/Lmaobox-Lua-Center/blob/main/Indicators/Rijin%20DT%20Bar.lua)
------------------- (https://lmaobox.net/forum/v/profile/34543226/MCPEngu)



if ChargeBarConfig.enabled then
    local smallestPixel = draw.CreateFont("Smallest Pixel", 11, 400, FONTFLAG_OUTLINE, 1)
    local barWidth = 159
    local barHeight = 15
    local maxTicks = 23
    local barOffset = 300 -- Adjust this value to move the bar further down

    local charge = 0
    local charging = false

    local function clamp(value, min, max)
        return (value < min) and min or (value > max) and max or value
    end

    local function updateCharge()
        local lastCharge = 0

        return function()
            local maxTicks = clamp((client.GetConVar("sv_maxusrcmdprocessticks") or 23) - 2, 1, 21)
            charge = clamp((warp.GetChargedTicks() - 1) / maxTicks, 0, 1)
            charging = charge > lastCharge

            lastCharge = charge
        end
    end

    local function createGradientMask()
        local chars = {}

        for i = 0, 255 do
            local p = #chars
            chars[p + 1], chars[p + 1025] = 255, 255
            chars[p + 2], chars[p + 1026] = 255, 255
            chars[p + 3], chars[p + 1027] = 255, 255
            chars[p + 4], chars[p + 1028] = i, i
        end

        return draw.CreateTextureRGBA(string.char(table.unpack(chars)), 256, 2)
    end

    local gradientBarMask = createGradientMask()
    local updateBarCharge = updateCharge()

    callbacks.Register("Draw", function()
        if engine.Con_IsVisible() or engine.IsGameUIVisible() then
            return
        end

        draw.SetFont(smallestPixel)

        local screenX, screenY = draw.GetScreenSize()
        local barX = math.floor(screenX / 2 - barWidth / 2)
        local barY = math.floor(screenY / 2) + barOffset

        -- Background
        draw.Color(28, 29, 38, 255)
        draw.FilledRect(barX, barY, barX + barWidth, barY + barHeight)

        -- Bar gradient
        if charge ~= 0 then
            draw.Color(59, 66, 199, 255)
            draw.FilledRect(barX, barY, barX + math.floor(charge * barWidth), barY + barHeight)

            draw.Color(23, 165, 239, math.floor(math.sin(globals.CurTime() * 1.5) * 100 + 155))
            draw.TexturedRect(gradientBarMask, barX, barY, barX + math.floor(charge * barWidth), barY + barHeight)
        end

        -- Border
        draw.Color(36, 119, 198, 255)
        draw.OutlinedRect(barX, barY, barX + barWidth, barY + barHeight)

		-- Text
	    local textWidth, textHeight = draw.GetTextSize("CHARGE")
	    draw.Color(255, 255, 255, 255)
	    draw.Text(barX + 2, barY - textHeight + 1, "CHARGE")
	
	    -- Dash State Text
	    local dashStateText = "READY";
	
	    if charge == 0 then
	        dashStateText = "NO CHARGE";
	        draw.Color(207, 51, 42, 255)
		
	    elseif charging then
	        dashStateText = "CHARGING";
	        draw.Color(255, 168, 29, 255)
		
	    elseif charge ~= 1 then
	        dashStateText = "NOT ENOUGH CHARGE";
	        draw.Color(207, 51, 42, 255)
		
	    else
	        draw.Color(10, 188, 105, 255)
		
	    end
	
	    local dashStateTextWidth, dashStateTextHeight = draw.GetTextSize(dashStateText);
	
	    draw.Text(barX + barWidth - dashStateTextWidth - 2, barY - dashStateTextHeight + 1, dashStateText)
	end)

    callbacks.Register("CreateMove", function(cmd)
        updateBarCharge()
    end)

    callbacks.Register("Unload", function()
        draw.DeleteTexture(gradientBarMask)
    end)
end



------------------ (https://lmaobox.net/forum/v/discussion/23590/release-trimping-helper/p1)
-- TRIMP HELPER -- (https://raw.githubusercontent.com/Muqa1/Muqa-LBOX-pastas/main/trimping%20helper.lua)
------------------ (https://lmaobox.net/forum/v/profile/34538831/muqa)



local function TrimpHelper(cmd)
    local localPlayer = entities.GetLocalPlayer()
	if TrimpHelperConfig.enabled then
    	if localPlayer:InCond(17) then
    	    gui.SetValue("Auto Strafe", 0)

    	    local pitch, yaw, roll = cmd:GetViewAngles()

    	    local function PerformStrafe(strafeKey, yawOffset)
    	        cmd:SetViewAngles(pitch, yaw + yawOffset, roll)
    	        cmd:SetButtons(cmd.buttons | IN_FORWARD)
    	        client.Command(strafeKey, 1)
    	    end

    	    local function ResetStrafe(strafeKey)
    	        client.Command(strafeKey, 0)
    	    end

    	    if input.IsButtonDown(KEY_D) then
    	        PerformStrafe("-moveright", -55)
    	    else
    	        ResetStrafe("-moveright")
    	    end

    	    if input.IsButtonDown(KEY_A) then
    	        PerformStrafe("-moveleft", 55)
    	    else
    	        ResetStrafe("-moveleft")
    	    end
    	else
    	    gui.SetValue("Auto Strafe", 2)
    	end
	end
end

callbacks.Register("CreateMove", "TrimpHelper", TrimpHelper)



------------------------ (https://lmaobox.net/forum/v/discussion/23900/release-auto-release-stickybomb/p1)
-- STICKY AUTORELEASE -- (https://raw.githubusercontent.com/GoodEveningFellOff/lmaobox-auto-sticky-release/main/main.lua)
------------------------ (https://lmaobox.net/forum/v/profile/34534548/Greggory)


local release_value = StickyAutoReleaseConfig.charge;
local function clamp(a,b,c) return (a<b) and b or (a>c) and c or a; end

local function GetCharge(wep)
	local m_flChargeBeginTime = (wep:GetPropFloat("PipebombLauncherLocalData", "m_flChargeBeginTime") or 0);
	if wep:GetWeaponProjectileType() ~= 4 or m_flChargeBeginTime == 0 then
		return -1
	end
	return clamp((globals.CurTime() - m_flChargeBeginTime) / ((wep:GetPropInt("m_iItemDefinitionIndex") == 1150) and 1.2 or 4), 0, 1);
end

callbacks.Register("CreateMove", function(cmd)
	local pLocal = entities.GetLocalPlayer();
	if not pLocal then
		return
	end
	local pWeapon = pLocal:GetPropEntity("m_hActiveWeapon");
	if not pWeapon then
		return
	end
	if GetCharge(pWeapon) >= release_value then
		cmd:SetButtons(cmd.buttons & (~IN_ATTACK))
	end
end)



----------------------------- (https://lmaobox.net/forum/v/discussion/24056/release-scuffed-quick-spy-revolver-reload/p1)
-- INSTANT REVOLVER RELOAD -- (https://github.com/flashlbx/lboxscripts/blob/main/instantrevolvereload.lua)
----------------------------- (https://lmaobox.net/forum/v/profile/34530697/flashintv)



if InstantRevolveReload.enabled then
	local STEP = -1
	local STEPS = {
	    [0] = function(cmd)
	        cmd:SetButtons(cmd.buttons | IN_RELOAD)
	        --cmd:SetButtons(cmd.buttons | IN_ATTACK2)
	        STEP = STEP + 1
	    end,
	    [6] = function(cmd)
	        cmd:SetButtons(cmd.buttons | IN_ATTACK2)
	        STEP = STEP + 1
	    end,
	    [13] = function(cmd)
	        cmd:SetButtons(cmd.buttons | IN_ATTACK2)
	        STEP = STEP + 1
	    end,
	    [55] = function(cmd)
	        STEP = -1
	        gui.SetValue("aim bot", 1)
	    end
	}

	local function CreateMove(cmd)
	    local player = entities.GetLocalPlayer()
	    if (player == nil) or (player:GetPropInt("m_iClass") ~= 8) or ((player:GetPropInt("m_Shared", "m_bFeignDeathReady") == 1) and STEP == -1) then return end
	    if player:IsAlive() then
	        local prim = player:GetEntityForLoadoutSlot(1)
	        if not (STEP > -1) and (cmd.buttons & IN_RELOAD) ~= 0 and prim:GetPropInt("m_iClip1") ~= 6 then
	            STEP = 0
	        end
	        if STEP > -1 then
	            gui.SetValue("aim bot", 0)
	            cmd:SetButtons(cmd.buttons & ~IN_ATTACK)
	            if STEPS[STEP] == nil then
	                STEP = STEP + 1
	            else
	                STEPS[STEP](cmd)
	            end
	        end
	    end
	end
	callbacks.Unregister("CreateMove", "rv_createmove")
	callbacks.Register("CreateMove", "rv_createmove", CreateMove)
end