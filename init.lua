--
-- Moon Boat
--


--
-- Helper functions
--

local function is_water(pos)
	local nn = minetest.env:get_node(pos).name
	return minetest.get_item_group(nn, "water") ~= 0
end

local function get_sign(i)
	if i == 0 then
		return 0
	else
		return i/math.abs(i)
	end
end

local function get_velocity(v, yaw, y)
	local x = math.cos(yaw)*v
	local z = math.sin(yaw)*v
	return {x=x, y=y, z=z}
end

local function get_v(v)
	return math.sqrt(v.x^2+v.z^2)
end

--
-- Cart entity
--

local moon_boat = {
	physical = true,
	collisionbox = {-0.6,-0.4,-0.6, 0.6,0.3,0.6},
	visual = "mesh",
	mesh = "boat.x",
	textures = {"galaxy.png"},
	
	driver = nil,
	v = 0,
}

function moon_boat:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function moon_boat:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function moon_boat:get_staticdata()
	return tostring(v)
end

function moon_boat:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "nboats:moon_boat")
	end
end

function moon_boat:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.05
		end
		if ctrl.down then
			self.v = self.v-0.01
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/200+dtime*math.pi/200)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/200-dtime*math.pi/200)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 40 then
		self.v = 40*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_water(p) then
		if minetest.registered_nodes[minetest.env:get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-5, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_water(p) then
			self.object:setacceleration({x=0, y=1.5, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=5, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end

minetest.register_entity("nboats:moon_boat", moon_boat)


minetest.register_craftitem("nboats:moon_boat", {
	description = "Moon Boat",
	inventory_image = "mboat_inventory.png",
	wield_image = "mboat_wield.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_water(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+0.5
		minetest.env:add_entity(pointed_thing.under, "nboats:moon_boat")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "nboats:moon_boat",
	recipe = {
		{"", "", ""},
		{"default:obsidian", "", "default:obsidian"},
		{"default:dirt", "default:leaves", "default:dirt"},
	},
})

--
-- Expert Race Boat
--

--
-- Helper functions
--

local function is_water(pos)
	local nn = minetest.env:get_node(pos).name
	return minetest.get_item_group(nn, "water","lava") ~= 0
end

local function get_sign(i)
	if i == 0 then
		return 0
	else
		return i/math.abs(i)
	end
end

local function get_velocity(v, yaw, y)
	local x = math.cos(yaw)*v
	local z = math.sin(yaw)*v
	return {x=x, y=y, z=z}
end

local function get_v(v)
	return math.sqrt(v.x^2+v.z^2)
end

--
-- Cart entity
--

local boatre = {
	physical = true,
	collisionbox = {-0.6,-0.4,-0.6, 0.6,0.3,0.6},
	visual = "mesh",
	mesh = "boat.x",
	textures = {"default_desert_stone.png"},
	
	driver = nil,
	v = 0,
}

function boatre:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function boatre:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function boatre:get_staticdata()
	return tostring(v)
end

function boatre:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "nboats:boatre")
	end
end

function boatre:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.2
		end
		if ctrl.down then
			self.v = self.v-0.18
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/30+dtime*math.pi/30)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/30-dtime*math.pi/30)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 80 then
		self.v = 80*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_water(p) then
		if minetest.registered_nodes[minetest.env:get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-30, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_water(p) then
			self.object:setacceleration({x=0, y=15, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=30, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end

minetest.register_entity("nboats:boatre", boatre)


minetest.register_craftitem("nboats:boatre", {
	description = "Expert race boat",
	inventory_image = "boatre_inventory.png",
	wield_image = "boatre_wield.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_water(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+0.5
		minetest.env:add_entity(pointed_thing.under, "nboats:boatre")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "nboats:boatre",
	recipe = {
		{"", "", ""},
		{"default:desert_stone", "", "default:desert_stone"},
		{"default:desert_stone", "default:mese_block", "default:desert_stone"},
	},
})


--
-- Race Boat
--


--
-- Helper functions
--

local function is_water(pos)
	local nn = minetest.env:get_node(pos).name
	return minetest.get_item_group(nn, "water") ~= 0
end

local function get_sign(i)
	if i == 0 then
		return 0
	else
		return i/math.abs(i)
	end
end

local function get_velocity(v, yaw, y)
	local x = math.cos(yaw)*v
	local z = math.sin(yaw)*v
	return {x=x, y=y, z=z}
end

local function get_v(v)
	return math.sqrt(v.x^2+v.z^2)
end

--
-- Cart entity
--

local boatr = {
	physical = true,
	collisionbox = {-0.6,-0.4,-0.6, 0.6,0.3,0.6},
	visual = "mesh",
	mesh = "boat.x",
	textures = {"default_gravel.png"},
	
	driver = nil,
	v = 0,
}

function boatr:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function boatr:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function boatr:get_staticdata()
	return tostring(v)
end

function boatr:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "nboats:boatr")
	end
end

function boatr:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.25
		end
		if ctrl.down then
			self.v = self.v-0.25
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/60+dtime*math.pi/60)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/60-dtime*math.pi/60)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 15 then
		self.v = 15*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_water(p) then
		if minetest.registered_nodes[minetest.env:get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-20, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_water(p) then
			self.object:setacceleration({x=0, y=6, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=20, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end

minetest.register_entity("nboats:boatr", boatr)


minetest.register_craftitem("nboats:boatr", {
	description = "Race boat",
	inventory_image = "boatr_inventory.png",
	wield_image = "boatr_wield.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_water(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+0.5
		minetest.env:add_entity(pointed_thing.under, "nboats:boatr")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "nboats:boatr",
	recipe = {
		{"", "", ""},
		{"default:gravel", "", "default:gravel"},
		{"default:gravel", "default:steel_block", "default:gravel"},
	},
})

--
-- Water Boat
--


--
-- Helper functions
--

local function is_water(pos)
	local nn = minetest.env:get_node(pos).name
	return minetest.get_item_group(nn, "water") ~= 0
end

local function get_sign(i)
	if i == 0 then
		return 0
	else
		return i/math.abs(i)
	end
end

local function get_velocity(v, yaw, y)
	local x = math.cos(yaw)*v
	local z = math.sin(yaw)*v
	return {x=x, y=y, z=z}
end

local function get_v(v)
	return math.sqrt(v.x^2+v.z^2)
end

--
-- Cart entity
--

local wboat = {
	physical = true,
	collisionbox = {-0.6,-0.4,-0.6, 0.6,0.3,0.6},
	visual = "mesh",
	mesh = "boat.x",
	textures = {"default_water.png"},
	
	driver = nil,
	v = 0,
}

function wboat:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function wboat:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function wboat:get_staticdata()
	return tostring(v)
end

function wboat:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "nboats:wboat")
	end
end

function wboat:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.3
		end
		if ctrl.down then
			self.v = self.v-0.24
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/100+dtime*math.pi/100)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/100-dtime*math.pi/100)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 9 then
		self.v = 9*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_water(p) then
		if minetest.registered_nodes[minetest.env:get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-5, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_water(p) then
			self.object:setacceleration({x=0, y=0, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=0, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end

minetest.register_entity("nboats:wboat", wboat)


minetest.register_craftitem("nboats:wboat", {
	description = "Water Boat",
	inventory_image = "boat_inventory.png",
	wield_image = "boat_wield.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_water(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+0.5
		minetest.env:add_entity(pointed_thing.under, "nboats:wboat")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "nboats:wboat",
	recipe = {
		{"", "", ""},
		{"default:glass", "", "default:glass"},
		{"default:glass", "bucket:water", "default:glass"},
	},
})


--
-- Boat
--


--
-- Helper functions
--

local function is_water(pos)
	local nn = minetest.env:get_node(pos).name
	return minetest.get_item_group(nn, "water") ~= 0
end

local function get_sign(i)
	if i == 0 then
		return 0
	else
		return i/math.abs(i)
	end
end

local function get_velocity(v, yaw, y)
	local x = math.cos(yaw)*v
	local z = math.sin(yaw)*v
	return {x=x, y=y, z=z}
end

local function get_v(v)
	return math.sqrt(v.x^2+v.z^2)
end

--
-- Cart entity
--

local boat = {
	physical = true,
	collisionbox = {-0.6,-0.4,-0.6, 0.6,0.3,0.6},
	visual = "mesh",
	mesh = "boat.x",
	textures = {"default_wood.png"},
	
	driver = nil,
	v = 0,
}

function boat:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function boat:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function boat:get_staticdata()
	return tostring(v)
end

function boat:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "nboats:boat")
	end
end

function boat:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.1
		end
		if ctrl.down then
			self.v = self.v-0.08
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_water(p) then
		if minetest.registered_nodes[minetest.env:get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_water(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end

minetest.register_entity("nboats:boat", boat)


minetest.register_craftitem("nboats:boat", {
	description = "Boat",
	inventory_image = "boat_inventory.png",
	wield_image = "boat_wield.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_water(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+0.5
		minetest.env:add_entity(pointed_thing.under, "nboats:boat")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "nboats:boat",
	recipe = {
		{"", "", ""},
		{"group:wood", "", "group:wood"},
		{"group:wood", "group:wood", "group:wood"},
	},
})
