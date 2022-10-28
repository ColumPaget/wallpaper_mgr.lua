
--get images from a local directory


function InitLocalFiles(root_dir)
local mod={}

mod.root_dir=""
if strutil.strlen(root_dir) > 0 then mod.root_dir=root_dir.."/" end
mod.files={}

mod.get=function(self, source)
local item, GLOB

path=mod.root_dir..string.sub(source, 7)
GLOB=filesys.GLOB(path.."/*")
item=GLOB:next()
while item ~= nil
do
	if GLOB:info().type == "file"
	then
	 table.insert(self.files, item)
	elseif GLOB:info().type == "directory" and string.sub(item, 1, 1) ~= "."
	then
	 mod:get("local:"..item)
	end

	item=GLOB:next()
end

return SelectRandomItem(self.files)
end

mod.add_image=function(self, url, source)
local path, str

path=string.sub(source, 7).."/"
filesys.mkdirPath(path)
print("mkdir: " .. path)
str=hash.hashstr(url, "md5", "p64") .. "-" .. filesys.basename(url)
print("fave:" .. path..str)
filesys.copy(url, path..str)
end

return mod
end
