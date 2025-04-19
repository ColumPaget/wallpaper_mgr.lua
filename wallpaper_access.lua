-- module to download a random image from getwallpapers.com


function InitWallpaperAccess()
local mod={}

mod.base_url="https://wallpaperaccess.com/"
mod.image_urls={}


mod.div_tag=function(self, data) 
local url

str=HtmlTagExtractAttrib(data, "data-fullimg")
if strutil.strlen(str) > 0 
then 
table.insert(self.image_urls, self.base_url ..  str) 
end

end


mod.get=function(self, source)
local S, XML, tag, html, url, category

category=source_parse(source, "nature")
url=self.base_url..category

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

