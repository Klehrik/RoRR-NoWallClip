-- No Wall Clip v1.0.7
-- Klehrik

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for _, m in pairs(mods) do if type(m) == "table" and m.RoRR_Modding_Toolkit then Actor = m.Actor Buff = m.Buff Callback = m.Callback Helper = m.Helper Instance = m.Instance Item = m.Item Net = m.Net Object = m.Object Player = m.Player Resources = m.Resources Survivor = m.Survivor break end end end)

MOD_NoWallClip = true

local last_x, last_y = nil, nil
disable = 0

local marble_down = false
local warp_dart = false



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
    local gate = Instance.find(gm.constants.oHome)
    if gate and gate.parent == Player.get_client() then return true end
    return false
end


function warp_dart_present()
    local dart = Instance.find(gm.constants.oHuntressBolt4)
    if dart and dart.parent == Player.get_client() then return true end
    return false
end



-- ========== Main ==========

gm.post_code_execute(function(self, other, code, result, flags)
    if code.name:match("oP_Step") then
        -- Check if this player belongs to this client
        if Player.get_client() ~= self then return end

        -- Disable when teleporting to Carrara Marble
        local gate = marble_gate_present()
        if marble_down and not gate then disable = 1 end
        marble_down = gate

        -- Disable when teleporting to Warp Dart
        local dart = warp_dart_present()
        if warp_dart and not dart then disable = 1 end
        warp_dart = dart

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