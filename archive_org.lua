
--get images from chandra observatory webpage


function InitArchiveOrg()
local mod={}

mod.image_urls={}



mod.get=function(self, source)
local S, XML, str, html, item, root
local title=""
local images={}

root="https://archive.org/download/wallpaperscollection"
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
		if strutil.strlen(str) > 0  and filesys.extn(str)==".jpg" and string.find(str, "thumb") == nil
		then
			table.insert(images, str)
		end
	end
	tag=XML:next()
	end
end


item=SelectRandomItem(images)
if item==nil then return nil end

return root .. "/" .. item


end

return mod
end
