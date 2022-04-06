set_skin = {}
set_skin.textures = nil
set_skin.curr_target = ""
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local default_skin = "character.png"

if minetest.request_insecure_environment then
	 local insecure_environment = minetest.request_insecure_environment()
	 if not insecure_environment then
        minetest.chat_send_all("[WARNING] set_skin requires an insecure environment to download textures. Add 'secure.trusted_mods = " .. modname .. "' to the minetest.conf to enable this feature.")
     else
        set_skin.textures = minetest.get_dir_list(modpath .. DIR_DELIM .. "textures", false)
        --minetest.chat_send_all(dump(set_skin.textures))
        insecure_environment = nil
    end
end

dofile(minetest.get_modpath("set_skin") .. DIR_DELIM .. "forms.lua")

minetest.register_chatcommand("set_skin", {
    func = function(name, param)
        if minetest.check_player_privs(name, {server=true}) then
            set_skin.curr_target = param
            local player = minetest.get_player_by_name(set_skin.curr_target)
            if player then
                set_skin.open_formspec(name)
            else
                minetest.chat_send_player(name, "The player isn't online or do not exist")
            end
        end
    end,
})

minetest.register_chatcommand("reset_skin", {
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        set_skin.set_player_skin(player, "", true)
        set_skin.set_player_skin(player, default_skin)
    end,
})

local set_player_textures =
	minetest.get_modpath("player_api") and player_api.set_textures
	or default.player_set_textures

function set_skin.set_player_skin(player, skin, save)
	if skinsdb_mod_path then

		skins.set_player_skin(player, skin or skins.default)

	elseif armor_mod_path then -- if 3D_armor's installed, let it set the skin

		armor.textures[player:get_player_name()].skin = skin or default_skin
		armor:update_player_visuals(player)
	else
		set_player_textures(player, { skin or default_skin})
	end

	if save and not skinsdb_mod_path then

		if skin == default_skin or skin == "" then
			player:set_attribute("set_skin:player_skin", "")
		else
			player:set_attribute("set_skin:player_skin", skin)
		end
	end
end

if not skinsdb_mod_path then -- If not managed by skinsdb

	minetest.register_on_joinplayer(function(player)

		local skin = player:get_attribute("set_skin:player_skin")

		if skin and skin ~= "" and skin ~= default_skin then

			-- setting player skin on connect has no effect, so delay skin change
			minetest.after(1, function(player1, skin1)
				set_skin.set_player_skin(player1, skin1)
			end, player, skin)
		end
	end)
end
