-- No Wall Clip v1.0.5
-- Klehrik

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.hfuncs then Helper = v end end end)

local last_x, last_y = nil, nil



-- ========== Functions ==========

function reset_actor_activity(actor)
    actor.activity = 0.0
    actor.activity_flags = 0.0
    actor.activity_free = true
    actor.activity_move_factor = 1.0
    actor.activity_type = 0.0
    actor.actor_state_current_id = -1.0
end



-- ========== Main ==========

gm.post_code_execute(function(self, other, code, result, flags)
    if code.name:match("oP_Step") then

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
end)


-- Debug
-- gm.post_code_execute(function(self, other, code, result, flags)
--     if code.name:match("oInit_Draw_7") then
--         if last_x ~= nil then gm.draw_circle(last_x, last_y, 4, false) end
--     end
-- end)