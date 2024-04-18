-- No Wall Clip v1.0.0
-- Klehrik

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.hfuncs then Helper = v end end end)

local player = nil
local last_x = 0
local last_y = 0



-- ========== Main ==========

gm.post_script_hook(gm.constants.__input_system_tick, function()
    if Helper.instance_exists(player) then
        -- Wall collision detected
        local in_wall = gm.collision_line(player.x, player.y, last_x, last_y, gm.constants.pBlockStatic, false, true) ~= -4.0
        if in_wall and not (player.activity == 92.0 and player.activity_flags == 0.0) then
            player.x, player.y = last_x, last_y
            player.pHspeed = 0.0
        end

        last_x, last_y = player.x, player.y

    else
        player = Helper.get_client_player()
        if player then last_x, last_y = player.x, player.y end
    end
end)