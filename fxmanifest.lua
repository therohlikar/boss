fx_version 'bodacious'
game 'gta5'

export "openBossMenu"

client_scripts {
	"config.lua",
	"client/main.lua"
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	"config.lua",
	"server/main.lua"
}

ui_page "html/ui.html"

files {
	"html/ui.html",
	"html/style.css",
	"html/fonts/gs.ttf",
	"html/listener.js",
	"html/imgs/tablet.png"
}

