

function InitBlocklist()
local mod={}

mod.items={}

mod.add=function(self, url)
local S, str

if strutil.strlen(url) == 0 then return false end

for i,item in ipairs(self.items)
do
if item==url then return false end
end

S=stream.STREAM(settings.working_dir.."/blocked.lst", "a")
if S ~= nil
then
S:writeln(url.."\n")
S:close()
end

return true
end

mod.load=function(self)
local S, str

S=stream.STREAM(settings.working_dir.."/blocked.lst", "r")
if S ~= nil
then
	str=S:readln()
	while str ~= nil
	do
	str=strutil.trim(str)
	table.insert(self.items, str)
	str=S:readln()
	end
	S:close()
end

end

mod.check=function(self, url)
local i, item

for i,item in ipairs(self.items)
do
if item==url then return true end
end

return false
end

mod:load()
return mod
end
