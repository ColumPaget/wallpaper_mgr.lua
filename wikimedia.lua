-- pull images from wikimedia


function InitWikimedia()
local mod={}


mod.base_url="https://commons.wikimedia.org"
mod.pages={}

mod.get_image=function(self, page)
local S, html, XML, str, tag
local url=""

print("GET: "..page)
if strutil.strlen(page) > 0
then
S=stream.STREAM(page)
if S ~= nil
then
	html=S:readdoc()
	S:close()

	XML=xml.XML(html)
	tag=XML:next()
	while tag ~= nil
	do
	if tag.type == 'div' and tag.data == 'class="fullImageLink" id="file"'
	then
	  tag=XML:next()
		url=HtmlTagExtractHRef(tag.data)
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

str="https://commons.wikimedia.org"..page
print("GET: "..str)

S=stream.STREAM(str, "r")
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
		url=HtmlTagExtractHRef(tag.data, 'class="mw-file-description"')
		if strutil.strlen(url) > 0 then table.insert(mod.pages, self.base_url .. url) 
		end
	end
	tag=XML:next()
	end
end

return next_page
end


mod.get=function(self, source)
local next_page, page

page=source_parse(source, "Category:Commons_featured_desktop_backgrounds")

next_page=mod.get_page(self, "/wiki/".. page)
while strutil.strlen(next_page) > 0
do
next_page=mod.get_page(source, next_page)
end

return self:get_image(SelectRandomItem(mod.pages))
end



return mod
end


