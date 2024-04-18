-- No Wall Clip v1.0.1
-- Klehrik

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.hfuncs then Helper = v end end end)

local player = nil
local last_x = nil
local last_y = nil



-- ========== Main ==========

gm.post_script_hook(gm.constants.__input_system_tick, function()
    if Helper.instance_exists(player) then
        -- Reset saved position when falling out of the room
        if player.y >= gm.variable_global_get("room_height") then
            last_x = nil
            return
        end

        -- Wall collision detected
        if last_x ~= nil then
            local in_wall = gm.collision_line(player.x, player.y, last_x, last_y, gm.constants.pBlockStatic, false, true) ~= -4.0
            if in_wall and not (player.activity == 92.0 and player.activity_flags == 0.0) then
                player.x, player.y = last_x, last_y
                player.pHspeed = 0.0
            end
        end

        last_x, last_y = player.x, player.y

    else
        player = Helper.get_client_player()
        if player then last_x, last_y = player.x, player.y end
    end
end)