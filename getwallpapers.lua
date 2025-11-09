-- module to download a random image from getwallpapers.com


function InitGetWallpapers()
local mod={}

mod.base_url="https://getwallpapers.com/"


mod.div_tag=function(self, data) 
local str, item

str=HtmlTagExtractAttrib(data, "data-fullimg")
if strutil.strlen(str) > 0 
then 
item={}
item.url=self.base_url .. strutil.stripQuotes(str)
end

return item
end


mod.get=function(self, source)
local S, XML, tag, html, str, item
local items={}

str=source_parse(source, "nature-desktop-wallpapers-backgrounds")
url=self.base_url .. "/collection/" .. str

print("GET: "..url)
S=stream.STREAM(url,"r")
if S ~= nil
then
	html=S:readdoc()
	XML=xml.XML(html)
	S:close()

	tag=XML:next()
	while tag ~= nil
	do
		if tag.type=="div" 
		then 
				item=self:div_tag(tag.data) 
				if item ~= nil then table.insert(items, item) end
		end
		tag=XML:next()
	end
end

return SelectRandomItem(items)
end


return mod
end

