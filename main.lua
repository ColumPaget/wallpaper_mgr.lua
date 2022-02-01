

function GetWallpaperFromSite(source)
local url, title, description
local result=false

mod=sources:select(source)

print(source)
if mod ~= nil
then 
url,title,description=mod:get(source) 
if strutil.strlen(url) > 0 then result=GetWallpaper(url, source, title, description) end
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


function ParseCommandLine()
local i, str
local act="random"

for i,str in ipairs(arg)
do
	if str=="-sources" then source_list=sources:parse(arg[i+1])  ; arg[i+1]=""
	elseif str=="-info" then act="info" 
	elseif str=="-title" then act="title" 
	elseif str=="-list" then act="list" 
	elseif str=="-disable" then act="disable:" .. arg[i+1] ; arg[i+1]=""
	elseif str=="-enable" then act="enable:" .. arg[i+1] ; arg[i+1]=""
	end
end

return act
end


math.randomseed(os.time()+process.getpid())
working_dir=process.getenv("HOME").."/.local/share/wallpaper/"
process.lu_set("HTTP:UserAgent", "wallpaper.lua (colum.paget@gmail.com)")
sources=InitSources()

act=ParseCommandLine()


if act=="random" then WallpaperFromRandomSource(source_list)
elseif act=="info" then ShowCurrWallpaperDetails()
elseif act=="title" then ShowCurrWallpaperTitle()
elseif act=="list" then sources:list()
elseif string.sub(act, 1, 8) == "disable:" then sources:disable(string.sub(act, 9))
elseif string.sub(act, 1, 7) == "enable:" then sources:enable(string.sub(act, 8))
end

