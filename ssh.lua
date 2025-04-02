-- module to download the current daily astronomy picture from apod.nasa.gov


function InitSSH()
local mod={}


mod.readdir=function(self, source, url_list, dir_list)
local line, extn, path
local S

S=stream.STREAM(source.."/*", "l")
if S ~= nil
then
	line=S:readln()
	while line ~= nil
	do
	line=strutil.trim(line)
  extn=filesys.extn(line)
	extn=string.lower(extn)
	path=source.."/"..filesys.basename(line)
	if extn ~= nil and (extn==".jpeg" or extn==".jpg" or extn==".png")
	then
    table.insert(url_list, path)
  elseif dir_list ~= nil
	then
	  table.insert(dir_list, path)
	end
	line=S:readln()
	end

S:close()
end

end


mod.get=function(self, source)
local url_list={}
local dir_list={}
local str

self:readdir(source, url_list)
str=source .."/*"
self:readdir(str, url_list)

return SelectRandomItem(url_list)
end


return mod
end

