-- module to download the current daily astronomy picture from apod.nasa.gov


function InitNASA()
local mod={}

mod.anchor_tag=function(self, data) 
local toks, tok, url
local is_preload=false

toks=strutil.TOKENIZER(data, "\\S")
tok=toks:next()
while tok ~= nil
do
if string.sub(tok, 1, 12) == 'href="image/' then url=strutil.stripQuotes(string.sub(tok, 6)) end
tok=toks:next()
end

if strutil.strlen(url) > 0 then return "https://apod.nasa.gov/apod/" ..  url end
return ""
end


mod.get_title=function(XML)
local tag

	tag=XML:next()
	while tag ~= nil
	do
	if tag.type=="b" then return XML:next().data end
	tag=XML:next()
	end

return ""
end

mod.get=function(self, source)
local S, XML, tag, str, html
local url=""
local title=""

S=stream.STREAM("https://apod.nasa.gov/apod/astropix.html","r")
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
		 str=self:anchor_tag(tag.data)
		 if strutil.strlen(str) > 0
		 then
		 url=str
		 title=self.get_title(XML)
		 end
		end
		tag=XML:next()
	end
end

return url, title
end


return mod
end

