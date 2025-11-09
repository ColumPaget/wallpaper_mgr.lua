
function InitWallpapersCraft()
local mod={}

mod.pages={}


mod.get_image=function(self, page)
local S, html, XML, tag 
local url=""
local title=""

if strutil.strlen(page) == 0 then return nil end
S=stream.STREAM(page, "")
if S ~= nil
then
	html=S:readdoc()
	XML=xml.XML(html)
	S:close()

	tag=XML:next()
	while tag ~= nil
	do
  	  if tag.type == "img"
	  then
	    str=HtmlTagExtractHRef(tag.data, 'class="wallpaper__image"', "src") 
	    if strutil.strlen(str) > 0 then url=str end
	  elseif tag.type == "title"
	  then
	    tag=XML:next()
	    title=tag.data
	  end
	tag=XML:next()
	end
end

return url, title
end


mod.get=function(self, source)
local S, html, str, XML, category, len, item

category=source_parse(source, "cities")
str=string.format("https://wallpaperscraft.com/catalog/%s/1920x1080/page%d", category, math.random(100))

print("GET: ".. str)
S=stream.STREAM(str, "")

if S == nil or S:getvalue("HTTP:ResponseCode") ~= "200"
then
str=string.format("https://wallpaperscraft.com/catalog/%s/1920x1080", category)
S=stream.STREAM(str, "")
end

if S ~= nil
then
	html=S:readdoc()
	XML=xml.XML(html)
	S:close()

	tag=XML:next()
	while tag ~= nil
	do
	if tag.type == "a" and string.sub(tag.data, 1, 24) == 'class="wallpapers__link"'
	then
		
		str=HtmlTagExtractHRef(tag.data,"")
		if str ~= nil then table.insert(self.pages, str) end
	end
	tag=XML:next()
	end
end

str=SelectRandomItem(self.pages)
if strutil.strlen(str) > 0
then
item={}
item.url=self:get_image("https://wallpaperscraft.com/" .. str)
end

return item
end

return mod
end
