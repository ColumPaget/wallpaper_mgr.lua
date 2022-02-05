

-- module to get daily wallpaper from bing.com


function InitPlaylist()
local mod={}


mod.get=function(self, source)
local S, str
local items={}


if strutil.strlen(source) < 0 then return nil end
S=stream.STREAM(string.sub(source, 10), "r")
if S ~= nil
then
	str=S:readln()
	while str ~= nil
	do
	str=strutil.trim(str)
	if strutil.strlen(str) > 0 then table.insert(items, str) end
	str=S:readln()
	end
	S:close()
end

return SelectRandomItem(items)
end

return mod
end


