require("stream")
require("strutil")
require("xml")
require("process")
require("filesys")



function SelectRandomItem(choices)
local val

if #choices < 1 then return nil end

val=math.random(#choices)
return choices[val]
end



function ShowCurrWallpaperDetails()
local dir,S

dir=process.getenv("HOME").."/.local/share/wallpaper/"
S=stream.STREAM(dir.."wallpapers.curr", "r")
if S ~= nil
then
	print(S:readdoc())
	S:close()
end

end

function ShowCurrWallpaperTitle()
local dir,S,str
local title=""

dir=process.getenv("HOME").."/.local/share/wallpaper/"
S=stream.STREAM(dir.."wallpapers.curr", "r")
if S ~= nil
then
  str=S:readln()
	while str ~= nil
	do
	str=strutil.trim(str)
	if string.sub(str, 1, 5) == "url: " then url=string.sub(str, 6) end
	if string.sub(str, 1, 7) == "title: " then title=string.sub(str, 8) end
  str=S:readln()
	end
	S:close()
end

if strutil.strlen(title) > 0 then print(title) 
else print(filesys.basename(url))
end
end
