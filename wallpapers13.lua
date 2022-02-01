-- module for pulling a random wallpaper from https://www.wallpapers13.com/


function InitWallpapers13()
local mod={}


mod.image_urls={}

mod.is_image_div=function(self, tag) 
local toks, tok, url
local is_image=false

if tag.type ~= 'div' then return false end

toks=strutil.TOKENIZER(tag.data, "\\S", "Q")
tok=toks:next()
while tok ~= nil
do
if tok == 'class="grid-100 tablet-grid-100 mobile-grid-100 grid-parent px-featuredimg"' then return true end
tok=toks:next()
end

return false
end


mod.extract_url=function(self, data)
local toks, tok

toks=strutil.TOKENIZER(data, "\\S", "Q")
tok=toks:next()
while tok ~= nil
do
	if string.sub(tok, 1, 5) == 'href='
	then 
		return strutil.stripQuotes(string.sub(tok, 6))
	end
	tok=toks:next()
end

return ""
end


mod.find_image=function(self, XML)
local tag, url

	tag=XML:next()
	while tag ~= nil
	do
	if tag.type == "a" 
	then 
		url=HtmlTagExtractHRef(tag.data, "") 
		table.insert(self.image_urls, url)
		break
	end
	if tag.type == "/tag" then break end

	tag=XML:next()
	end

end



mod.get_image=function(self, page_url, source)
local S, XML, tag, url
--local resolution="1280x1024"
local resolution="1920x1080"

S=stream.STREAM(page_url, "r")
if S ~= nil
then
	XML=xml.XML(S:readdoc())
	S:close()

	tag=XML:next()
	while tag ~= nil
	do
	if tag.type == "title"
	then
		title=XML:next().data
	elseif tag.type == "a" 
	then 
		url=self:extract_url(tag.data) 
		if string.find(url, resolution..".jpg") ~= nil
		then
		   break
		end
	end
	if tag.type == "/tag" then break end

	tag=XML:next()
	end
end

return url, title
end


mod.get=function(self, source)
local S, XML, html, tag, url="https://www.wallpapers13.com/category/cities-wallpapers"

if strutil.strlen(source)
then
	if string.sub(source, 1, 13) == "wallpapers13:" then url="https://www.wallpapers13.com/category/"..string.sub(source, 14).."/" end
	if string.sub(source, 1, 5) == "wp13:" then url="https://www.wallpapers13.com/category/"..string.sub(source, 6).."/" end
end

S=stream.STREAM(url, "r")
if S ~= nil
then
	html=S:readdoc()
	XML=xml.XML(html)
	S:close()

	tag=XML:next()
	while tag ~= nil
	do
		if self:is_image_div(tag) == true
		then 
			self:find_image(XML)
		end
		tag=XML:next()
	end
end

url=SelectRandomItem(self.image_urls)
return self:get_image(url, source)

end

return mod
end

