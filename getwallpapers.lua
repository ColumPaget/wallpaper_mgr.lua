-- module to download a random image from getwallpapers.com


function InitGetWallpapers()
local mod={}

mod.base_url="https://getwallpapers.com/"
mod.image_urls={}

mod.div_tag=function(self, data) 
local str, url

str=HtmlTagExtractAttrib(data, "data-fullimg")
if strutil.strlen(str) > 0 
then 
url=self.base_url .. strutil.stripQuotes(str)
table.insert(self.image_urls, url) 
end

end


mod.get=function(self, source)
local S, XML, tag, html, str

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
		if tag.type=="div" then self:div_tag(tag.data) end
		tag=XML:next()
	end
end

return SelectRandomItem(self.image_urls)
end


return mod
end

