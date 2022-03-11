


function GetWallpaperFromSite(source)
local url, title, description
local result=false

mod=sources:select(source)

if mod ~= nil
then 
url,title,description=mod:get(source) 
if strutil.strlen(url) > 0 
then

if blocklist:check(url) == false then result=GetWallpaper(url, source, title, description) 
else print("BLOCKED: " .. url .. ". Never use this image.")
end

end
end

return result
end


function ParseSources(src_list) 
local toks, tok
local sources={}

toks=strutil.TOKENIZER(src_list, ",")
tok=toks:next()
while tok ~= nil
do
table.insert(sources, tok)
tok=toks:next()
end

return sources
end


function WallpaperFromRandomSource(source_list)
local i, item

for i=1,5,1
do
item=sources:random(source_list)
if GetWallpaperFromSite(item) == true then break end
end

end


function SaveWallpaper(url, dest, root_dir)
local obj

if strutil.strlen(dest)==0 
then
print("ERROR: no destination directory given")
else
	if url=="current" then url=GetCurrWallpaperDetails().url end
	obj=InitLocalFiles(root_dir)
	obj:add_image(url, "local:"..dest) 
end
end

function FaveWallpaper(url, dest)
if strutil.strlen(dest)==0 
then
print("ERROR: no favorites category given")
else
SaveWallpaper(url, settings.working_dir.."/faves/"..dest, settings.working_dir.."/faves/")
end

end

function PrintHelp()

print("")
print("wallpaper_mgr.lua [options]")
print("options:")
print("  -sources <comma separated list of sources>       list of sources to get images from, overriding the default list.")
print("  -list                                            list default sources.")
print("  -add <source>                                    add a source to the list of default sources.")
print("  -del <source>                                    remove an item from the list of default sources.")
print("  -rm <source>                                     remove an item from the list of default sources.")
print("  -remove <source>                                 remove an item from the list of default sources.")
print("  -disable <source>                                disable a source in the list of default sources.")
print("  -enable <source>                                 enable a source in the list of default sources.")
print("  -block <image url>                               block an image url so this image can never be used.")
print("  -block-curr                                      block the current image so it is never used.")
print("  -save-curr  <dest directory>                     save current image to a destination directory.")
print("  -fave-curr  <name>                               save current image to a favorites collection named '<name>'.")
print("  -save <url> <dest directory>                     save image at <url> to a destination directory.")
print("  -fave <url> <name>                               save image at <url> to a favorites collection named '<name>'.")
print("  -info                                            info on current image.")
print("  -title                                           title of current image (or URL if no title).")
print("  -setroot <program name>                          use specified program to set background.")
print("  -resolution <resolution>                         get images matching <resolution>")
print("  -res <resolution>                                get images matching <resolution>")
print("  -?                                               this help")
print("  -help                                            this help")
print("  --help                                           this help")
print("")
print("wallpaper_mgr.lua uses xrandr or 'xprop -root' to discover the size of the desktop, and downloads images close to that on sites that support multiple resolutions. If xrandr and xprop aren't available, and the user doesn't supply a resolution on the command line, then it defaults to 1920x1200.")
print("")
print("wallpaper_mgr.lua has a default list of sources consisting of:")
print("")
print("   'bing:en-US, bing:en-GB, nasa:apod, wallpapers13:cities-wallpapers, wallpapers13:nature-wallpapers/beach-wallpapers, wallpapers13:nature-wallpapers/waterfalls-wallpapers, wallpapers13:nature-wallpapers/flowers-wallpapers, wallpapers13:nature-wallpapers/sunset-wallpapers, wallpapers13:other-topics-wallpapers/church-cathedral-wallpapers, wallpapers13:nature-wallpapers/landscapes-wallpapers, getwallpapers:ocean-scene-wallpaper, getwallpapers:nature-desktop-wallpapers-backgrounds, getwallpapers:milky-way-wallpaper-1920x1080, getwallpapers:1920x1080-hd-autumn-wallpapers, hipwallpapers:daily, suwalls:flowers, suwalls:beaches, suwalls:abstract, suwalls:nature, suwalls:space, chandra:stars, chandra:galaxy, esahubble:nebulae, esahubble:galaxies, esahubble:stars, esahubble:starclusters, wikimedia:Category:Commons_featured_desktop_backgrounds, wikimedia:Category:Hubble_images_of_galaxies, wikimedia:Category:Hubble_images_of_nebulae, wikimedia:wikimedia:User:Pfctdayelise/wallpapers, wikimedia:User:Miya/POTY/Nature_views2008, wikimedia:Lightning, wikimedia:Fog, wikimedia:Autumn, wikimedia:Sunset, wikimedia:Commons:Featured_pictures/Places/Other, wikimedia:Commons:Featured_pictures/Places/Architecture/Exteriors, wikimedia:Commons:Featured_pictures/Places/Architecture/Cityscapes.")
print("")
print("This list includes entries from all supported sites, and other things can be added from these sites by paying attention to the urls of the 'category' pages on each site.")
end


function ParseCommandLine()
local i, str, source_list, src_url
local act="random"
local target=""

for i,str in ipairs(arg)
do
if strutil.strlen(str) > 0
then
	if str=="-sources" then source_list=sources:parse(arg[i+1])  ; arg[i+1]=""
	elseif str=="-info" then act="info" 
	elseif str=="-title" then act="title" 
	elseif str=="-list" then act="list" 
	elseif str=="-add" then act="add" ; target=arg[i+1] ; arg[i+1]=""
	elseif str=="-del" then act="remove" ; target=arg[i+1] ; arg[i+1]=""
	elseif str=="-rm" then act="remove" ; target=arg[i+1] ; arg[i+1]=""
	elseif str=="-remove" then act="remove" ; target=arg[i+1] ; arg[i+1]=""
	elseif str=="-disable" then act="disable" ; target=arg[i+1] ; arg[i+1]=""
	elseif str=="-enable" then act="enable" ; target=arg[i+1] ; arg[i+1]=""
	elseif str=="-block" then act="block" ; target=arg[i+1] ; arg[i+1]=""
	elseif str=="-block-curr" then act="block-curr"
	elseif str=="-save-curr" then act="save-curr"; target=arg[i+1]; arg[i+1]=""
	elseif str=="-fave-curr" then act="fave-curr"; target=arg[i+1]; arg[i+1]=""
	elseif str=="-save" then act="save"; src_url=arg[i+1]; target=arg[i+2]; arg[i+1]=""; arg[i+2]=""
	elseif str=="-fave" then act="fave"; src_url=arg[i+1]; target=arg[i+2]; arg[i+1]=""; arg[i+2]=""
	elseif str=="-setroot" then settings.setroot=arg[i+1]; arg[i+1]=""
	elseif str=="-resolution" then settings.resolution=arg[i+1]; arg[i+1]=""
	elseif str=="-res" then settings.resolution=arg[i+1]; arg[i+1]=""
	elseif str=="-?" then act="help" 
	elseif str=="-help" then act="help"
	elseif str=="--help" then act="help"
	else act="error"; print("unknown option '"..str.."'")
	end
end
end

return act,target,src_url
end


-- seed random number generator so it doesn't produce the same
-- pattern of values!
math.randomseed(os.time()+process.getpid())


settings={}
settings.working_dir=process.getenv("HOME").."/.local/share/wallpaper/"

sources=InitSources()
blocklist=InitBlocklist()
resolution=InitResolution()

settings.resolution=resolution:get()
process.lu_set("HTTP:UserAgent", "wallpaper.lua (colum.paget@gmail.com)")


act,target,src_url,source_list=ParseCommandLine()

if act=="help" then PrintHelp()
elseif act=="random" then WallpaperFromRandomSource(source_list)
elseif act=="info" then ShowCurrWallpaperDetails()
elseif act=="title" then ShowCurrWallpaperTitle()
elseif act=="list" then sources:list()
elseif act=="disable" then sources:disable(target)
elseif act=="enable" then sources:enable(target)
elseif act=="add" then sources:add(target)
elseif act=="remove" then sources:remove(target)
elseif act=="block-curr" then blocklist:add(GetCurrWallpaperDetails().url) 
elseif act=="save-curr" then SaveWallpaper("current", target)
elseif act=="fave-curr" then FaveWallpaper("current", target)
elseif act=="block" then blocklist:add(target) 
elseif act=="save" then SaveWallpaper(src_url, target)
elseif act=="fave" then FaveWallpaper(src_url, target)
else print("unrecognized command-line.")
end

