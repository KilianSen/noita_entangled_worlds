local ctx = dofile_once("mods/quant.ew/files/src/ctx.lua")
local net = dofile_once("mods/quant.ew/files/src/net.lua")
local np = require("noitapatcher")

local rpc = net.new_rpc_namespace()

local module = {}

ModLuaFileAppend("data/scripts/magic/fungal_shift.lua", "mods/quant.ew/files/src/system/fungal_shift/append/fungal_shift.lua")

local log_messages = {
	"$log_reality_mutation_00",
	"$log_reality_mutation_01",
	"$log_reality_mutation_02",
	"$log_reality_mutation_03",
	"$log_reality_mutation_04",
	"$log_reality_mutation_05",
}

-- TODO figure out what to do when player isn't online at the time of shifting
rpc.opts_reliable()
function rpc.fungal_shift(conversions, iter, from_material_name)
    dofile_once("data/scripts/lib/utilities.lua")

    local entity = ctx.my_player.entity
    local x, y = EntityGetTransform(entity)

    GlobalsSetValue("fungal_shift_iteration", iter)
    for _, conv in ipairs(conversions) do
        ConvertMaterialEverywhere(conv[1], conv[2])
        GameCreateParticle( CellFactory_GetName(conv[1]), x-10, y-10, 20, rand(-100,100), rand(-100,-30), true, true )
		GameCreateParticle( CellFactory_GetName(conv[1]), x+10, y-10, 20, rand(-100,100), rand(-100,-30), true, true )
    end

    -- remove tripping effect
    EntityRemoveIngestionStatusEffect( entity, "TRIP" );

    -- audio
    GameTriggerMusicFadeOutAndDequeueAll( 5.0 )
    GameTriggerMusicEvent( "music/oneshot/tripping_balls_01", false, x, y )

    -- particle fx
    local eye = EntityLoad( "data/entities/particles/treble_eye.xml", x,y-10 )
    if eye ~= 0 then
        EntityAddChild( entity, eye )
    end

    -- log
    local log_msg = ""
    if from_material_name ~= "" then
        log_msg = GameTextGet( "$logdesc_reality_mutation", from_material_name )
        GamePrint( log_msg )
    end
    GamePrintImportant( random_from_array( log_messages ), log_msg, "data/ui_gfx/decorations/3piece_fungal_shift.png" )
    local frame = GameGetFrameNum()
    GlobalsSetValue( "fungal_shift_last_frame", tostring(frame) )

    -- add ui icon
    local add_icon = true
    local children = EntityGetAllChildren(entity)
    if children ~= nil then
        for i,it in ipairs(children) do
            if ( EntityGetName(it) == "fungal_shift_ui_icon" ) then
                add_icon = false
                break
            end
        end
    end

    if add_icon then
        local icon_entity = EntityCreateNew( "fungal_shift_ui_icon" )
        EntityAddComponent( icon_entity, "UIIconComponent",
        {
            name = "$status_reality_mutation",
            description = "$statusdesc_reality_mutation",
            icon_sprite_file = "data/ui_gfx/status_indicators/fungal_shift.png"
        })
        EntityAddChild( entity, icon_entity )
    end
end

local conversions = {}

np.CrossCallAdd("ew_fungal_shift_conversion", function(from_mat, to_mat)
    table.insert(conversions, {from_mat, to_mat})
end)

np.CrossCallAdd("ew_fungal_shift", function(iter, from_material_name)
    rpc.fungal_shift(conversions, iter, from_material_name)
    conversions = {}
end)

return module

