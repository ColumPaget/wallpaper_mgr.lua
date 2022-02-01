all:
	cat common.lua sources.lua html.lua bing.lua nasa.lua chandra.lua esahubble.lua hip_wallpaper.lua localfiles.lua wallpapers13.lua getwallpapers.lua suwalls.lua wikimedia.lua xsetroot.lua download.lua main.lua > wallpaper_mgr.lua
	chmod a+x wallpaper_mgr.lua
