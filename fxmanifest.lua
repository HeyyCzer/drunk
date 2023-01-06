fx_version "bodacious"
game "gta5"
lua54 "yes"

shared_scripts {
	"@vrp/config/Item.lua",
	"@vrp/lib/Utils.lua",
}

client_scripts {
	"src/client.lua"
}

server_scripts {
	"src/server.lua"
}