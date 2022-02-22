-- get random id of n digits
function planets.random_id(n)
	local idst = ""
	for i = 1, n do
		idst = idst .. (math.random(0, 9))
	end
	return idst
end

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
field[5.2,6.4;4,0.9;currenttheta;currenttheta;${currenttheta}]
field[0.5,9.4;1.9,1.1;centerx;centerx;${centerx}]
field[2.6,9.4;2.2,1.1;centery;centery;${centery}]
field[5,9.4;2.2,1.1;centerz;centerz;${centerz}]
]]
planets.formname = "planets.properties"
planets.running = false

planet = {
	initial_properties = {
		visual = "cube",
		visual_size = { x = 1, y = 1 },
		textures = { TEX, TEX, TEX, TEX, TEX, TEX },
		collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
		physical = false
	}
}

function planets.create_planet(pos, name, radius)
	local new_id = planets.random_id(4)
	while planets.list[new_id] do
		new_id = planets.random_id()
	end
	local pldata = {}
	pldata.name = name
	pldata.center = pos
	pldata.radius = radius
	pldata.theta = 0
	pldata.speedtheta = 0.1
	pldata.speedyaw = 0.3
	planets.list[new_id] = pldata
	return new_id
end

-- when right clicked offer to show my properties (use a formspec?)
function planet:on_rightclick(hitter)

	local pldata = planets.list[self.myid]
	local formspec = planets.composeform %
		{ name = pldata.name,
		  radius = pldata.radius,
		  spinspeed = pldata.speedyaw,
		  orbitspeed = pldata.speedtheta,
		  centerx = pldata.center.x,
		  centery = pldata.center.y,
		  centerz = pldata.center.z,
		  currentyaw = self.object:get_yaw(),
		  currenttheta = pldata.theta
		}
	minetest.log("=====")
	minetest.show_formspec(hitter:get_player_name(), planets.formname, formspec)
	--local message = "MyId is " .. self.myid .. dump(planets.list[self.myid])
	--minetest.chat_send_player(hitter:get_player_name(), message)
end


-- make the planet rotate around center
-- here we can do something with center
function planet:on_step(dtime)
	if self.myid and self.initialized then
		if planets.running then
			local id = self.myid
			local data = planets.list[id]
			local center = data.center
			local radius = data.radius
			local theta = data.theta

			if radius then

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
	end
end

function planet:get_staticdata()
	return "STATIC"
end

function planet:on_activate(sd_uid, dtime_s)
	if sd_uid ~= "" then
		--destroy when loaded from static block.
		self.object:remove()
		return
	end
end
