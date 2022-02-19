-- get random id of n digits
function planets.random_id(n)
	local idst = ""
	for i = 1, n do
		idst = idst .. (math.random(0, 9))
	end
	return idst
end

planets.list = {}

planet = {
	initial_properties = {
		visual = "cube",
		visual_size = { x = 1, y = 1 },
		textures = { TEX,TEX,TEX,TEX,TEX,TEX },
		collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
		physical = false
	}
}

function planets.create_planet(pos, radius)
	local new_id = planets.random_id(4)
	while planets.list[new_id] do new_id = planets.random_id() end
	local pldata = {}
	pldata.center = pos
	pldata.radius = radius
	pldata.theta = 0
	pldata.speedtheta = 0.1
	pldata.speedyaw = 0.3
	planets.list[new_id] = pldata
	return new_id
end

-- when right clicked offer to show my properties
function planet:on_rightclick(hitter)
	local message = "MyId is " .. self.myid .. dump(planets.list[self.myid])
	minetest.chat_send_player(hitter:get_player_name(), message)
end


-- make the planet rotate around center
-- here we can do something with center
function planet:on_step(dtime)
	if self.myid then
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

			self.object:move_to(np, true)

			local newyaw = self.object:get_yaw() + data.speedyaw
			self.object:set_yaw(newyaw)
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
