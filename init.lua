--require("./debugger")("127.0.0.1", 10000, "luaidekey")
require("mobdebug").start()
TEX = "earth-icon26x26.png"
local lot = os.clock()
minetest.log("action", "[planets] Loading...")

planets = { running = true }

MOD_NAME = minetest.get_current_modname();
MOD_PATH = minetest.get_modpath(MOD_NAME);

dofile(MOD_PATH .. "/utility.lua")
dofile(MOD_PATH .. "/planet.lua")
dofile(MOD_PATH .. "/commands.lua")


local tot = (os.clock() - lot) * 1000
minetest.log("action", "[planets] Loaded in " .. tot .. "ms")

