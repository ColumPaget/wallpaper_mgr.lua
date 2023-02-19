


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



function WallpaperFromRandomSource(source_list)
local i, item 
local result=false

if source_list ~= nil
then
  for i=1,5,1
  do
    item=sources:random(source_list)
    result=GetWallpaperFromSite(item) 
    if result == true then break end
  end

  -- fall back to only local sources if above didn't work
  if result==false
  then
    locals=sources:locals(source_list)
    item=sources:random(locals)
    if item ~= nil then result=GetWallpaperFromSite(item) end
  end
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



function ParseCommandLine()
local i, str, list, source_list, src_url
local act="random"
local target=""

source_list=sources:load()
for i,str in ipairs(arg)
do
if strutil.strlen(str) > 0
then
	if str=="-sources" then source_list=sources:parse(arg[i+1])  ; arg[i+1]=""
	elseif str=="+sources" then list=table_join(source_list, sources:parse(arg[i+1]))  ; arg[i+1]=""
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
	elseif str=="-exe_path" then process.setenv("PATH", arg[i+1]); arg[i+1]=""
	elseif str=="-sync" then act="sync"; target=arg[i+1]; arg[i+1]=""
	elseif str=="-?" then act="help" 
	elseif str=="-help" then act="help"
	elseif str=="--help" then act="help"
	else act="error"; print("unknown option '"..str.."'")
	end
end
end

if source_list==nil then source_list=settings.default_sources end

return act,target,src_url,source_list
end


-- seed random number generator so it doesn't produce the same
-- pattern of values!
math.randomseed(os.time()+process.getpid())


InitSettings()
sources=InitSources()
blocklist=InitBlocklist()
resolution=InitResolution()

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
elseif act=="sync" then PigeonholedSync(target)
else print("unrecognized command-line.")
end

