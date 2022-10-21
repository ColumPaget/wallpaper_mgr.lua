

function InitResolution()
local mod={}

mod.best_resolution=""



mod.xrandr_resolution=function(self)
local S, str, toks
local resolution=""

S=stream.STREAM("cmd:xrandr", "");
if S ~= nil
then
  str=S:readln()
  toks=strutil.TOKENIZER(str, ",")
  str=toks:next()
  while str ~= nil
  do
  str=strutil.trim(str)
  if string.sub(str, 1, 8) == "current "
  then
  str=string.sub(str, 9)
  resolution=string.gsub(str, ' ', '')
  end
  
  str=toks:next()
  end
  S:close()
end

return resolution
end



mod.xwininfo_resolution=function(self)
local S, str, pos
local resolution=""

S=stream.STREAM("cmd:xwininfo -root", "")
if S ~= nil
then
	str=S:readln()
	while str ~= nil
	do
	str=strutil.trim(str)
	if string.sub(str,1,10) == "-geometry "
	then
print(str)
		resolution=string.sub(str, 11)
		pos=string.find(resolution, '+')
		if pos ~= nil then resolution=string.sub(resolution, 1, pos-1) end
	end
	str=S:readln()
	end
end

print(resolution)
return resolution
end



mod.xprop_resolution=function(self)
local S, str, toks
local resolution=""

if strutil.strlen(resolution) ==0
then
S=stream.STREAM("cmd:xprop -root", "");
if S ~= nil
then
str=S:readln()
while str ~= nil
do
	str=strutil.trim(str)
	if string.sub(str, 1, 33) == "_NET_DESKTOP_GEOMETRY(CARDINAL) ="
	then
	str=string.sub(str, 34)
	resolution=string.gsub(str, ' ', '')
	resolution=string.gsub(resolution, ',', 'x')
	end
str=S:readln()
end
S:close()
end

end

return resolution
end



mod.get=function(self)
local S, str, resolution

if strutil.strlen(settings.resolution) > 0 then return settings.resolution end

resolution=self:xrandr_resolution()
if strutil.strlen(resolution) == 0 then resolution=self:xwininfo_resolution() end
if strutil.strlen(resolution) == 0 then resolution=self:xprop_resolution() end

return resolution
end


mod.calc_diff=function(self, target, new)
local xdiff, ydiff, target_toks, new_toks
local val1, val2

	target_toks=strutil.TOKENIZER(target, "x")
	new_toks=strutil.TOKENIZER(new, "x")
	val=tonumber(new_toks:next())
	if val == nil then return nil end
	xdiff=tonumber(target_toks:next()) - val
	val=tonumber(new_toks:next())
	if val == nil then return nil end
	ydiff=tonumber(target_toks:next()) - val
	if xdiff < 0 then xdiff=0 - xdiff end
	if ydiff < 0 then ydiff=0 - ydiff end

return (xdiff+ydiff)
end


mod.select=function(self, res)
local better=false
local new_diff, best_diff

if res==nil then return false end
if string.find(res, 'x') == nil then return false end

if mod.best_resolution==""
then
	better=true
else
	new_diff=self:calc_diff(settings.resolution, res) 
	best_diff=self:calc_diff(settings.resolution, mod.best_resolution)
	if new_diff == nil then better=false
	elseif best_diff == nil then better=true
	elseif new_diff < best_diff then better=true
	end
end

if better==true then mod.best_resolution=res end

return better
end

return mod
end
