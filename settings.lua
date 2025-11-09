function InitSettings()

settings={}
settings.filetypes={".jpg", ".jpeg", ".png"}
settings.working_dir=process.getenv("HOME").."/.local/share/wallpaper/"
settings.default_sources={
"bing:en-US", "bing:en-GB", "nasa:apod", "wallpapers13:cities", "wallpapers13:nature-wallpapers/beach", "wallpapers13:nature-wallpapers/waterfalls", "wallpapers13:nature-wallpapers/flowers", "wallpapers13:nature-wallpapers/sunset", "wallpapers13:other-topics-wallpapers/church-cathedral", "wallpapers13:nature-wallpapers/landscapes", "getwallpapers:ocean-scene-wallpaper", "getwallpapers:nature-desktop-wallpapers-backgrounds", "getwallpapers:milky-way-wallpaper-1920x1080", "getwallpapers:1920x1080-hd-autumn-wallpapers", "hipwallpapers:nature", "suwalls:flowers", "suwalls:beaches", "suwalls:abstract", "suwalls:nature", "suwalls:space", "wallpaperscraft:nature", "wallpaperscraft:space", "wallhaven:mars", "chandra:stars", "chandra:galaxy", "chandra:clusters", "esahubble:nebulae", "esahubble:galaxies", "esahubble:stars", "esahubble:starclusters", "esawebb:nebulae", "esawebb:galaxies", "esawebb:stars", "esawebb:solarsystem", "esa:earth", "eso:nebula", "eso:galaxy", "eso:telescope", "eso:observatory", "wikimedia:Category:Commons_featured_desktop_backgrounds", "wikimedia:Category:Hubble_images_of_galaxies", "wikimedia:Category:Hubble_images_of_nebulae", "wikimedia:User:Pfctdayelise/wallpapers", "wikimedia:User:Miya/POTY/Nature_views2008", "wikimedia:Lightning", "wikimedia:Fog", "wikimedia:Autumn", "wikimedia:Sunset", "wikimedia:Commons:Featured_pictures/Places/Other", "wikimedia:Commons:Featured_pictures/Places/Architecture/Exteriors", "wikimedia:Commons:Featured_pictures/Places/Architecture/Cityscapes", "archive.org:wallpaperscollection", "archive.org:wallpaper-1.2037", "archive.org:jcorl_white_sands", "archive.org:21590", "archive.org:macwallpapers", "archive.org:macos-wallpapers_202402", "archive.org:android6wallpapers", "archive.org:wallpapers-pack-selected-images", "sourcesplash:galaxy", "sourcesplash:forest"
}
--"chandra:dwarf", "chandra:snr", "chandra:quasars", "chandra:nstars",  "chandra:clusters", "chandra:bh"}

end
