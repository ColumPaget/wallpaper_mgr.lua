
--get images from a local directory


function InitLocalFiles()
local mod={}

mod.files={}

mod.get=function(self, source)
local item, GLOB

path=string.sub(source, 7)
GLOB=filesys.GLOB(path.."/*")
item=GLOB:next()
while item ~= nil
do
	if GLOB:info().type == "file" then table.insert(self.files, item) end
	item=GLOB:next()
end

return SelectRandomItem(self.files)
end

return mod
end
