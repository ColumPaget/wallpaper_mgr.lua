
--get images from ESA Hubble page


function InitESAHubble()
local mod={}

mod.image_urls={}


mod.get_image_details=function(self, page) 
local S, str, html
local best_res=""
local title=""
local url=""


S=stream.STREAM(page, "")
html=S:readdoc()
XML=xml.XML(html)
tag=XML:next()
while tag ~= nil
do
if tag.type == 'title'
then
	tag=XML:next()
	title=tag.data
elseif tag.type == 'a'
then
	str=HtmlTagExtractHRef(tag.data, "")
	tag=XML:next()
	if resolution:select(tag.data) == true then url=str; best_res=tag.data end
end
tag=XML:next()
end
S:close()

print("selected resolution: "..tostring(best_res).." url: "..tostring(url))
return url, title
end


mod.get_images_links=function(self, S) 
local str
local pages={}

str=S:readln()
while str ~= nil
do
	str=strutil.trim(str)
	if string.sub(str, 1,  14) == "url: '/images/"
	then
		str=string.sub(str, 5, string.len(str)-1)
		table.insert(pages, str)
	end
  str=S:readln()
end

str=SelectRandomItem(pages)
return self:get_image_details("https://esahubble.org" .. strutil.stripQuotes(str))
end


mod.get=function(self, source)
local S, str
local url=""
local title=""

if strutil.strlen(source) > 0 
then
str="https://esahubble.org/images/archive/category/"..string.sub(source, 11) .. "/page/1/"
else
str="https://esahubble.org/images/archive/category/nebulae/page/1/"
end

print(str)
S=stream.STREAM(str, "r")
str=S:readln()
while str ~= nil
do
str=strutil.trim(str)
if str=="var images = [" then url,title=mod:get_images_links(S) end
str=S:readln()
end

return url,title
end

return mod
end
