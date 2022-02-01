-- module to download a random image from getwallpapers.com


function InitGetWallpapers()
local mod={}

mod.image_urls={}

mod.div_tag=function(self, data) 
local toks, tok, url
local is_preload=false

toks=strutil.TOKENIZER(data, "\\S")
tok=toks:next()
while tok ~= nil
do
if string.sub(tok, 1, 13) == 'data-fullimg=' then url=strutil.stripQuotes(string.sub(tok, 14)) end
tok=toks:next()
end

if strutil.strlen(url) > 0 then table.insert(self.image_urls, "https://getwallpapers.com" ..  url) end
end


mod.get=function(self, source)
local S, XML, tag, html, url="https://getwallpapers.com/collection/nature-desktop-wallpapers-backgrounds"

if strutil.strlen(source) > 0
then
if string.sub(source, 1, 14)=="getwallpapers:" then url="https://getwallpapers.com/collection/"..string.sub(source, 15) end
end

S=stream.STREAM(url,"r")
if S ~= nil
then
	html=S:readdoc()
	XML=xml.XML(html)
	S:close()

	tag=XML:next()
	while tag ~= nil
	do
		if tag.type=="div" then self:div_tag(tag.data) end
		tag=XML:next()
	end
end

return SelectRandomItem(self.image_urls)
end


return mod
end

