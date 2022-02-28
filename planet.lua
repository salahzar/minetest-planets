planets.list = {}
planets.composeform = [[
formspec_version[5]
size[10.5,11]
field[0.7,1.9;3,0.9;name;name;${name}]
field[4.1,1.9;3,0.9;radius;radius;${radius}]
field[0.8,4.5;4,0.9;spinspeed;spinspeed;${spinspeed}]
field[5.2,4.5;4,0.9;orbitspeed;orbitspeed;${orbitspeed}]
label[1.4,1.1;Planets setting parameters]
field[0.8,6.4;4,0.9;currentyaw;currentyaw;${currentyaw}]
field[5.2,6.4;4,0.9;current_theta;current theta;${currenttheta}]
field[0.5,8.1;1.9,1.1;centerx;centerx;${centerx}]
field[2.6,8.1;2.2,1.1;centery;centery;${centery}]
field[5,8.1;2.2,1.1;centerz;centerz;${centerz}]
button[0.5,9.7;9.4,0.9;change;change data]
]]
planets.formname = "planets.properties"
planets.running = false

minetest.register_on_player_receive_fields(function(player, formname, fields)
	-- be sure to check this is really our formname to not pollute and receive others
	if formname ~= planets.formname then
		return false
	end
	local name = field.name
	local pldata = planets.list[name]
	if pldata then
		-- destroy previous planet
		planets.destroy_planet(name)
	else
		local entity = planets.create_planet(
			position,
			name,
			"planets_sphere.obj",
			"390px-Blue_Marble_2002.png",
			10)
		pldata = planets.list[name]
		minetest.log("creating planet with id " .. entity.myid)
		minetest.log("        data: " .. dump(pldata))
	end
	if fields.quit then
		minetest.log("quitting from form")
	else
		pldata.name = fields.name
		pldata.radius = tonumber(fields.radius)
		pldata.speedyaw = tonumber(fields.spinspeed)
		pldata.speedtheta = tonumber(fields.orbitspeed)
		pldata.theta = tonumber(fields.current_theta)
		pldata.center = vector.new(
			tonumber(fields.centerx),
			tonumber(fields.centery),
			tonumber(fields.centerz)
		)

		minetest.log(dump(fields))
	end

end)

function planets.create_planet(pos, name, mesh, texture, radius)
	local pldata = {}
	pldata.name = name
	pldata.center = pos
	pldata.radius = radius
	pldata.theta = 0
	pldata.speedtheta = 0.1
	pldata.speedyaw = 0.3
	planets.list[name] = pldata
	local ent_name = MOD_NAME .. ":" .. name
	minetest.register_entity(
		ent_name, {
			initialdata = {
				visual = "mesh",
				mesh = mesh,
				visual_size = { x = 1, y = 1 },
				--textures = { TEX, TEX, TEX, TEX, TEX, TEX },
				textures = { texture },
				collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
				physical = false
			},

			-- when right clicked offer to show my properties (use a formspec?)
			on_rightclick = function(hitter)
				planets.ask_formspec(self.myid, position)
			end,

			-- make the planet rotate around center
			-- here we can do something with center
			on_step = function(dtime)
				if self.myid and self.initialized then
					if planets.running then
						local id = self.myid
						local data = planets.list[id]
						local center = data.center
						local radius = data.radius
						local theta = data.theta
						theta = theta + data.speedtheta
						data.theta = theta
						local x = center.x + radius * math.cos(theta)
						local y = center.y
						local z = center.z + radius * math.sin(theta)

						local np = vector.new(x, y, z)

						-- use move_to with true instead of set_pos to have smooth movement
						self.object:move_to(np, true)
						--self.object:set_pos(np)

						local newyaw = self.object:get_yaw() + data.speedyaw
						self.object:set_yaw(newyaw)
					end
				end
			end,

			get_staticdata = function()
				return "STATIC"
			end,

			on_activate = function(sd_uid, dtime_s)
				if sd_uid ~= "" then
					--destroy when loaded from static block.
					self.object:remove()
					return
				end
			end

		}


	)

	local obj = minetest.add_entity(position, ent_name)
	--itemstack:take_item()
	entity = obj:get_luaentity()
	entity.myid = name
	local data = planets.list[planet_id]
	data.object = obj

	return entity
end
function planets:destroy_planet(name)
	local ent_name = MOD_NAME .. ":" .. name
	local pldata = planets.list[name]
	pldata.object:remove()
	minetest.unregister_item(ent_name)
end

function planets.ask_formspec(name,position)
	local pldata = planets.list[name]
	if not pldata then
		pldata = {
			name = "new_planet_name",
			radius = 0,
			speedtheta = 0,
			spinspeed = 0,
			centerx = position.x,
			centery = position.y,
			centerz = position.z,
			currentyaw = 0,
			currenttheta = 0,

		}
	end

	local formspec = planets.composeform %
		{ name = pldata.name,
		  radius = pldata.radius,
		  spinspeed = pldata.speedyaw,
		  orbitspeed = pldata.speedtheta,
		  centerx = pldata.center.x,
		  centery = pldata.center.y,
		  centerz = pldata.center.z,
		  currentyaw = self.object:get_yaw(),
		  currenttheta = pldata.theta,
		}

	minetest.show_formspec(hitter:get_player_name(), planets.formname, formspec)
end


