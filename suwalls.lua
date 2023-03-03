
function InitSUWalls()
local mod={}

mod.pages={}


mod.is_image_page=function(self, str, category)
local path

if strutil.strlen(str) < 1 then return false end

path="/" .. category .. "/" 
if string.sub(str, 1, strutil.strlen(path) ) == path
then 
	path=path.."page/"
	if string.sub(str, 1, strutil.strlen(path) ) == path then return false end
	return true
end

return false
end


mod.get_image=function(self, page)
local S, html, XML, tag 
local url=""
local title=""

if strutil.strlen(page) == 0 then return nil end
S=stream.STREAM("https://suwalls.com" .. page, "")
if S ~= nil
then
	html=S:readdoc()
	XML=xml.XML(html)
	S:close()

	tag=XML:next()
	while tag ~= nil
	do
	if tag.type == "title"
	then
	title=XML:next().value
	elseif tag.type == "a"
	then
		str=HtmlTagExtractHRef(tag.data, 'class="dlink"') 
		if strutil.strlen(str) > 0 then url=str end
	end
	tag=XML:next()
	end
end

return url, title
end


mod.get=function(self, source)
local S, html, str, XML, category

category=string.sub(source, 9)
S=stream.STREAM("https://suwalls.com/" .. category, "")
if S ~= nil
then
	html=S:readdoc()
	XML=xml.XML(html)
	S:close()

	tag=XML:next()
	while tag ~= nil
	do
	if tag.type == "a"
	then
		str=HtmlTagExtractHRef(tag.data,"")
		if str ~= nil
		then
		if self:is_image_page(str, category) then table.insert(self.pages, str) end
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
