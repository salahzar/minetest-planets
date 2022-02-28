minetest.register_craftitem("planets:placer", {
	description = "planet",
	image = TEX,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then return end



		local position = pointed_thing.above
		planets.ask_formspec("",position)



		return itemstack
	end,
})

minetest.register_chatcommand("plclear",
	{
		params = "", -- Short parameter description
		description = "clear all planets", -- Full description

		func = function(name, param)
			for id, data in pairs(planets.list) do
				minetest.chat_send_player(name,"removing planet "..id)
				obj = data.object
				obj:remove()
			end
			planets.list = {}
			return true, "Cleared all planets"
		end,
	})

minetest.register_chatcommand("pllist",
	{
		params = "", -- Short parameter description
		description = "list all planets", -- Full description

		func = function(name, param)
			--			local player = minetest.get_player_by_name(name)

			for id, data in pairs(planets.list) do
				minetest.chat_send_player(name, "planet "..id.." "..dump(data.object))
			end

			return true, "--- End of listing ---"
		end,
	})

minetest.register_chatcommand("plstop",
	{
		params = "", -- Short parameter description
		description = "stop planets", -- Full description

		func = function(name, param)

			planets.running = false
			return true, "stopped planets"
		end,
	})

minetest.register_chatcommand("plstart",
	{
		params = "", -- Short parameter description
		description = "start planets", -- Full description

		func = function(name, param)

			planets.running = true
			return true, "started planets"
		end,
	})
