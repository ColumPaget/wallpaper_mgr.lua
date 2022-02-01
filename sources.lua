

--"chandra:dwarf", "chandra:snr", "chandra:quasars", "chandra:nstars",  "chandra:clusters", "chandra:bh"}


function InitSources()
local mod={}

mod.default_sources={"bing:zh-CN", "nasa:apod", "wallpapers13:cities-wallpapers", "wallpapers13:nature-wallpapers/beach-wallpapers", "wallpapers13:nature-wallpapers/waterfalls-wallpapers", "wallpapers13:nature-wallpapers/flowers-wallpapers", "wallpapers13:nature-wallpapers/sunset-wallpapers", "wallpapers13:other-topics-wallpapers/church-cathedral-wallpapers", "wallpapers13:nature-wallpapers/landscapes-wallpapers", "getwallpapers:ocean-scene-wallpaper", "getwallpapers:nature-desktop-wallpapers-backgrounds", "getwallpapers:milky-way-wallpaper-1920x1080", "getwallpapers:1920x1080-hd-autumn-wallpapers", "hipwallpapers:daily", "suwalls:flowers", "suwalls:beaches", "suwalls:abstract", "suwalls:nature", "suwalls:space", "chandra:stars", "chandra:galaxy", "esahubble:nebulae", "esahubble:galaxies", "esahubble:stars", "esahubble:starclusters"}



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

S=stream.STREAM(working_dir .. "/sources.lst", "r")
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

filesys.mkdirPath(working_dir.."/")
S=stream.STREAM(working_dir .. "/sources.lst", "w")
print("SAVE:"..working_dir.." "..tostring(S))
if S == nil then return nil end

for i, str in ipairs(sources)
do
	S:writeln(str.."\n")
end
S:close()

end


mod.select=function(self, source)
local obj

if string.sub(source, 1, 5)=="bing:" then obj=InitBing()
elseif string.sub(source, 1, 5)=="nasa:" then obj=InitNASA()
elseif string.sub(source, 1, 8)=="chandra:" then obj=InitChandra()
elseif string.sub(source, 1, 10)=="esahubble:" then obj=InitESAHubble()
elseif string.sub(source, 1, 13)=="wallpapers13:" then obj=InitWallpapers13()
elseif string.sub(source, 1, 14)=="getwallpapers:" then obj=InitGetWallpapers()
elseif string.sub(source, 1, 14)=="hipwallpapers:" then obj=InitHipWallpaper()
elseif string.sub(source, 1, 10)=="wikimedia:" then obj=InitWikimedia()
elseif string.sub(source, 1, 8)=="suwalls:" then obj=InitSUWalls()
elseif string.sub(source, 1, 6)=="local:" then obj=InitLocalFiles()
end

return obj
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


mod.sources=mod:load()
if mod.sources == nil
then
	mod:save(mod.default_sources)
	mod.sources=mod:load()
end


return mod

end


