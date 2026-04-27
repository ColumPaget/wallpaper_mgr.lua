



function InitSources()
local mod={}



mod.parse=function(self, src_list)
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



mod.load=function(self, include_disabled)
local S, str
local sources={}

S=stream.STREAM(settings.working_dir .. "/sources.lst", "r")
if S == nil then return nil end

str=S:readln()
while str ~= nil
do
str=strutil.trim(str)
if include_disabled == true or string.sub(str, 1, 2) ~= '#' then table.insert(sources, str) end
str=S:readln()
end
S:close()

return sources
end



mod.save=function(self, sources)
local S, str,i

filesys.mkdirPath(settings.working_dir.."/")
S=stream.STREAM(settings.working_dir .. "/sources.lst", "w")
if S == nil then return nil end

for i, str in ipairs(sources)
do
  if strutil.strlen(str) > 0 then S:writeln(str.."\n") end
end
S:close()

end


mod.select=function(self, source)
local obj, source_type, toks

toks=strutil.TOKENIZER(source, ":")
source_type=toks:next()

if source_type == "bing" then obj=InitBing()
elseif source_type == "nasa" then obj=InitNASA()
elseif source_type == "chandra" then obj=InitChandra()
elseif source_type == "eso" then obj=InitESO()
elseif source_type == "esa" then obj=InitESA("https://esa.int")
elseif source_type == "esahubble" then obj=InitESA("https://esahubble.org")
elseif source_type == "esawebb" then obj=InitESA("https://esawebb.org")
elseif source_type == "wallpapers13" then obj=InitWallpapers13()
elseif source_type == "getwallpapers" then obj=InitGetWallpapers()
elseif source_type == "hipwallpaper" then obj=InitHipWallpaper()
elseif source_type == "hipwallpapers" then obj=InitHipWallpaper()
elseif source_type == "wikimedia" then obj=InitWikimedia()
elseif source_type == "wallhaven" then obj=InitWallhaven()
elseif source_type == "sourcesplash" then obj=InitSourceSplash()
elseif source_type == "wallpaperscraft" then obj=InitWallpapersCraft()
elseif source_type == "suwalls" then obj=InitSUWalls()
elseif source_type == "archive.org" then obj=InitArchiveOrg()
elseif source_type == "archive_org" then obj=InitArchiveOrg()
elseif source_type == "local" then obj=InitLocalFiles()
elseif source_type == "faves" then obj=InitLocalFiles(filesys.pathaddslash(settings.working_dir).."faves/")
elseif source_type == "playlist" then obj=InitPlaylist()
elseif source_type == "ssh" then obj=InitSSH()
end

return obj
end


mod.locals=function(self, source_list)
local i, str, stype
local locals_list={}

for i, str in ipairs(source_list)
do
  stype=string.sub(str, 1, 6)
  if stype=="local:" or stype=="faves:" then table.insert(locals_list, str) end
end

return locals_list
end


mod.list=function(self)
local sources

sources=self:load(true)
for i,item in ipairs(sources) do print(tostring(i) .. ": " .. item) end
end


mod.disable=function(self, target)
local sources

sources=self:load(true)
for i,item in ipairs(sources)
do
  if item==target then sources[i]="#"..item end
end
self:save(sources)

end



mod.enable=function(self, target)
local sources

sources=self:load(true)
for i,item in ipairs(sources)
do
  if item == "#"..target then sources[i]=target end
end
self:save(sources)

end


mod.random=function(self, source_list)
local choice

if source_list ~= nil then choice= SelectRandomItem(source_list)
else choice=SelectRandomItem(self.sources)
end

return choice
end



mod.add=function(self, target)
local sources

sources=self:load(true)
table.insert(sources, target)
self:save(sources)

end


mod.remove=function(self, target)
local sources

sources=self:load(true)
for i,item in ipairs(sources)
do
  if item==target then sources[i]="" end
end
self:save(sources)

end



mod.sources=mod:load()
if mod.sources == nil or #mod.sources == 0
then
  mod:save(settings.default_sources)
  mod.sources=mod:load()
end


return mod

end


