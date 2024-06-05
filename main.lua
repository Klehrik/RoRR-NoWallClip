-- No Wall Clip v1.0.6
-- Klehrik

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.hfuncs then Helper = v end end end)

MOD_NoWallClip = true

local last_x, last_y = nil, nil
disable = 0

local marble_down = false



-- ========== Functions ==========

function reset_actor_activity(actor)
    actor.activity = 0.0
    actor.activity_flags = 0.0
    actor.activity_free = true
    actor.activity_move_factor = 1.0
    actor.activity_type = 0.0
    actor.actor_state_current_id = -1.0
end


function marble_gate_present()
    local gate = Helper.find_active_instance(gm.constants.oHome)
    if gate and gate.parent == Helper.get_client_player() then return true end
    return false
end



-- ========== Main ==========

gm.post_code_execute(function(self, other, code, result, flags)
    if code.name:match("oP_Step") then
        -- Check if this player belongs to this client
        if Helper.get_client_player() ~= self then return end

        -- Disable when teleporting to Carrara Marble
        local gate = marble_gate_present()
        if marble_down and not gate then disable = 1 end
        marble_down = gate

        -- Disable timer
        if disable > 0 then
            disable = disable - 1
            last_x = nil
            return
        end

        -- Reset saved position when falling out of the room
        if self.y >= gm.variable_global_get("room_height") then
            last_x = nil
            return
        end

        -- Wall collision detected
        if last_x ~= nil then
            local in_wall = gm.collision_line(self.x, self.y, last_x, last_y, gm.constants.pBlockStatic, false, true) ~= -4.0
            local is_climbing = self.activity == 92.0 and self.activity_type == 2.0
            if in_wall and not is_climbing then
                self.x, self.y = last_x, last_y
                self.pHspeed = 0.0

                -- Loader: Cancel alt secondary
                if self.actor_state_current_id == 89.0 then reset_actor_activity(self) end
            end
        end

        -- Don't save during teleporter transitions
        if self.activity_type ~= 7 then last_x, last_y = self.x, self.y
        else last_x = nil
        end

        -- Acrid: Allow alt utility to function
        if self.actor_state_current_id == 93.0 and self.activity_type == 3.0 then last_x = nil end
    end
end)


gm.post_script_hook(gm.constants.run_create, function(self, other, result, args)
    last_x = nil
    disable = 6     -- Disable this for the first 0.1 seconds of run loading in
end)


-- Debug
-- gm.post_code_execute(function(self, other, code, result, flags)
--     if code.name:match("oInit_Draw_7") then
--         if last_x ~= nil then gm.draw_circle(last_x, last_y, 4, false) end
--     end
-- end)