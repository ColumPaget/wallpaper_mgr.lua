-- pull images from wikimedia


function InitWikimedia()
local mod={}

mod.pages={}

mod.get_image=function(self, page)
local S, html, XML, str, tag
local url=""

if strutil.strlen(page) > 0
then
S=stream.STREAM("https://commons.wikimedia.org/"..page)
if S ~= nil
then
	html=S:readdoc()
	S:close()

	XML=xml.XML(html)
	tag=XML:next()
	while tag ~= nil
	do
	if tag.type == 'a'
	then
		str=HtmlTagExtractHRef(tag.data, '')
		tag=XML:next()
		if tag.data == "Original file" then url=str 
		end
	end
	tag=XML:next()
	end
end
end

return url
end

mod.get_page=function(self, page)
local S, html, XML, str, tag
local next_page=""

if strutil.strlen(page) ==0 then return nil end
S=stream.STREAM("https://commons.wikimedia.org"..page)
if S ~= nil
then
	html=S:readdoc()
	S:close()

	XML=xml.XML(html)
	tag=XML:next()
	while tag ~= nil
	do
	if tag.type == 'a'
	then
		url=HtmlTagExtractHRef(tag.data, 'class="galleryfilename galleryfilename-truncate"')
		if strutil.strlen(url) > 0 then table.insert(mod.pages, url) 
		else
			url=HtmlTagExtractHRef(tag.data, 'class="image"')
			if strutil.strlen(url) > 0 then table.insert(mod.pages, url) 
			else
				url=HtmlTagExtractHRef(tag.data, '')
				tag=XML:next()
				if tag.data=="next page" then next_page=url end
			end
		end
	end
	tag=XML:next()
	end
end

return next_page
end


mod.get=function(self, source)
local next_page, page

page=string.sub(source, 11)
if strutil.strlen(page) == 0 then page="Category:Commons_featured_desktop_backgrounds" end

next_page=mod.get_page(self, "/wiki/".. page)
while strutil.strlen(next_page) > 0
do
next_page=mod.get_page(source, next_page)
end

return self:get_image(SelectRandomItem(mod.pages))
end



return mod
end
