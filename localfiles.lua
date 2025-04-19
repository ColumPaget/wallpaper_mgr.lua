
--get images from a local directory


function InitLocalFiles(root_dir)
local mod={}

mod.root_dir=""
if strutil.strlen(root_dir) > 0 then mod.root_dir=filesys.pathaddslash(root_dir) end
mod.files={}

mod.get=function(self, source)
local item, path, str, GLOB, len

path=filesys.pathaddslash(self.root_dir..string.sub(source, 7))

print("GET: "..path)

GLOB=filesys.GLOB(path.."*")
item=GLOB:next()
while item ~= nil
do
	if GLOB:info().type == "file"
	then
	 table.insert(self.files, item)
	elseif GLOB:info().type == "directory" and string.sub(item, 1, 1) ~= "."
	then
	 len=strutil.strlen(self.root_dir)
	 if len > 0 and string.sub(item, 1, len)==self.root_dir then str=string.sub(item, len) 
	 else str=item
	 end
	 self:get("local:" .. str)
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
