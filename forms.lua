function set_skin.open_formspec(name)
    local basic_form = table.concat({
        "formspec_version[5]",
        "size[5,2.9]",
	}, "")

    --minetest.chat_send_all(dump(set_skin.textures))

    local textures = ""
    if set_skin.textures then
        for k, v in pairs( set_skin.textures ) do
            textures = textures .. v .. ","
        end

	    basic_form = basic_form.."dropdown[0.5,0.5;4,0.8;textures;".. textures ..";1;false]"
        basic_form = basic_form.."button[0.5,1.6;4,0.8;set_texture;Set Player Texture]"

        minetest.show_formspec(name, "set_skin:change", basic_form)
    else
        minetest.chat_send_player(name, "The isn't activated as secure. Aborting")
    end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "set_skin:change" then
        local name = set_skin.curr_target --player:get_player_name()
        local t_player = minetest.get_player_by_name(set_skin.curr_target)
		if (fields.textures or fields.set_texture) and t_player then
            set_skin.set_player_skin(t_player, fields.textures, true)
        else
		    if t_player then
                set_skin.set_player_skin(t_player, "", true)
		    end
		end

        minetest.close_formspec(name, "set_skin:change")
    end
end)
