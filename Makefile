all:
	cat common.lua blocklist.lua sources.lua html.lua playlist.lua bing.lua nasa.lua chandra.lua esahubble.lua hip_wallpaper.lua localfiles.lua wallpapers13.lua getwallpapers.lua suwalls.lua wikimedia.lua xsetroot.lua download.lua resolution.lua main.lua > wallpaper_mgr.lua
	chmod a+x wallpaper_mgr.lua

install:
	cp wallpaper_mgr.lua /usr/local/bin
