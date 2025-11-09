
--get images from chandra observatory webpage


function InitChandra()
local mod={}



mod.get=function(self, source)
local S, XML, str, html, item
local title=""
local images={}

category=source_parse(source, "galaxy")
str="https://chandra.harvard.edu/resources/desktops_" .. category .. ".html"

print("GET: "..str)
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

			if string.find(tag.data, ' ') == nil and string.find(tag.data, 'x') ~= nil
			then
			item={}
      item.url="https://chandra.harvard.edu/" .. str
			item.title=title
			item.resolution=tag.data
			table.insert(images, item)
			end
		end
	end
	tag=XML:next()
	end
end


item=SelectResolutionItem(images)
return item

end

return mod
end
