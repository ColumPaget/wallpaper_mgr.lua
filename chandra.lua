
--get images from chandra observatory webpage


function InitChandra()
local mod={}

mod.image_urls={}




mod.select=function(self, items)
local i, item
local best_res=""
local selected_items={}

for i,item in ipairs(items)
do
if resolution:select(item.resolution) == true then best_res=item.resolution end
end


for i,item in ipairs(items)
do 
if item.resolution == best_res then table.insert(selected_items, item) end 
end

item=SelectRandomItem(selected_items)
if item ~= nil then print("selected resolution: "..tostring(best_res).." url:"..tostring(item.url))
else print("fail: can't find image from chandra.harvard.edu")
end

return item
end



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
			item.url=str
			item.title=title
			item.resolution=tag.data
			table.insert(images, item)
			end
		end
	end
	tag=XML:next()
	end
end


item=self:select(images)
if item==nil then return nil end
return "https://chandra.harvard.edu/" .. item.url, item.title
end

return mod
end
