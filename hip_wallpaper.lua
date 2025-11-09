-- module to select a random wallpaper from https://hipwallpaper.com/daily-wallpapers/


function InitHipWallpaper()
local mod={}


mod.get=function(self, source)
local S, XML, tag, html, url, category
local items={}

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
			if IsImageURL(url) == true
			then 
      item={}
			item.url=url
			table.insert(items, item) 
			end
		end
		tag=XML:next()
	end
end


return SelectRandomItem(items)
end

return mod
end

