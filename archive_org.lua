
--get images from 'wallpaper collections' posted at archive.org


function InitArchiveOrg()
local mod={}

mod.image_urls={}



mod.get=function(self, source)
local S, XML, str, html, item, root, item
local collection
local images={}

if strutil.strlen(source) ==0 then return nil end

collection=source_parse(source, "wallpaperscollection")
root="https://archive.org/download/" .. collection


print("GET: "..root)
S=stream.STREAM(root, "r")
if S ~= nil
then
	html=S:readdoc()
	XML=xml.XML(html)
	S:close()

	tag=XML:next()
	while tag ~= nil
	do
	if tag.type=="a"
	then 
	  str=HtmlTagExtractHRef(tag.data, "")
		if strutil.strlen(str) > 0  and IsImageURL(str) == true and string.find(str, "thumb") == nil
		then
			table.insert(images, str)
		end
	end
	tag=XML:next()
	end
end


str=SelectRandomItem(images)
if str ~= nil
then
item={}
item.url=root .. "/" .. str
end

return item
end

return mod
end
