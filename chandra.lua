
--get images from chandra observatory webpage


function InitChandra()
local mod={}

mod.image_urls={}


mod.get=function(self, source)
local S, XML, str, html, item
local resolution="1280x1024"
local title=""


if strutil.strlen(source) > 0 then str="https://chandra.harvard.edu/resources/desktops_" .. string.sub(source, 9) .. ".html"
else str="https://chandra.harvard.edu/resources/desktops_galaxy.html"
end

print(str)
S=stream.STREAM(str, "r")
if S ~= nil
then
	html=S:readdoc()
	XML=xml.XML(html)
	S:close()

	tag=XML:next()
	while tag ~= nil
	do
	if tag.type=="span" 
	then
	 tag=XML:next()
	 title=tag.data
	elseif tag.type=="a"
	then 
	  str=HtmlTagExtractHRef(tag.data, "")
		if strutil.strlen(str) > 0 
		then
			tag=XML:next()
			if tag==nil then break end
			if tag.data == resolution
			then 
			item={}
			item.url=str
			item.title=title
			table.insert(self.image_urls, item)
			end
		end
	end
	tag=XML:next()
	end
end


item=SelectRandomItem(self.image_urls)
return "https://chandra.harvard.edu/" .. item.url, item.title
end

return mod
end
