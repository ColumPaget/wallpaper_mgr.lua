-- module to select a random wallpaper from https://hipwallpaper.com/daily-wallpapers/


function InitHipWallpaper()
local mod={}

mod.image_urls={}

mod.get=function(self, source)
local S, XML, tag, html, url, category

category=source_parse(source, "nature")
url="https://hipwallpaper.com/search?q="..category

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
		if tag.type=="a" 
		then 
			url=HtmlTagExtractAttrib(tag.data, 'data-bs-src')
			if strutil.strlen(url) > 0 then table.insert(self.image_urls, url) end
		end
		tag=XML:next()
	end
end


return SelectRandomItem(self.image_urls)
end

return mod
end

