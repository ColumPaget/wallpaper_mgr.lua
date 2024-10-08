
function InitHDQWalls()
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
	if tag.type == "meta"
	then
		str=HtmlTagExtractHRef(tag.data, 'property="og:image"', "content=") 
		if strutil.strlen(str) > 0 then url=str end

		str=HtmlTagExtractHRef(tag.data, 'property="og:title"', "content=") 
		if strutil.strlen(str) > 0 then title=str end
	end
	tag=XML:next()
	end
end

return url, title
end


mod.get=function(self, source)
local S, html, str, XML, category, len

category=string.sub(source, 10)
len=strutil.strlen(category)
if string.sub(category, len - 10) ~= "-wallpapers" then category=category .. "-wallpapers" end

str=string.format("https://hdqwalls.com/category/%s/page/%d", category, math.random(10))
S=stream.STREAM(str, "")
if S == nil or S:getvalue("HTTP:ResponseCode") ~= "200"
then
str=string.format("https://hdqwalls.com/category/%s-wallpapers", category)
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
	if tag.type == "div" and string.sub(tag.data, 1, 17) == "class=\"wall-resp "
	then
		
		tag=XML:next()
		if tag.type=="a"
		then
		str=HtmlTagExtractHRef(tag.data,"")
		if str ~= nil then table.insert(self.pages, str) end
		end
	end
	tag=XML:next()
	end
end

str=SelectRandomItem(self.pages)
return self:get_image(str)
end

return mod
end
