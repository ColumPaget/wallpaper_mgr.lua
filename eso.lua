
--get images from European Southern Observatory observatory webpage


function InitESO()
local mod={}

mod.images={}

mod.consider_script=function (self, script)
local P, item, img

if string.sub(script, 1, 14) == "var images = ["
then
 P=dataparser.PARSER("json", string.sub(script, 14))
 item=P:next()
 while item ~= nil and strutil.strlen(item:value("id")) > 0
 do
 img={}
 img.id=item:value("id")
 img.title=item:value("title")
 img.resolution=item:value("width").."x"..item:value("height")
 img.page=item:value("url")
 table.insert(self.images, img)
 item=P:next()
 end
end

end


mod.get_image_url=function(self, item)
local S

return "https://cdn.eso.org/images/wallpaper4/"..item.id..".jpg"
end


mod.get=function(self, source)
local S, XML, str, html, item
local title=""

category=source_parse(source, "nebula")
str="https://www.eso.org/public/images/?search=" .. category 

print("GET: "..str)
S=stream.STREAM(str, "r")
if S ~= nil
then
	html=S:readdoc()
	XML=xml.XML(html)
	S:close()

	tag=XML:next()
	while tag ~= nil
	do
	  if tag.type=="script" then self:consider_script(XML:next().data)end
	  tag=XML:next()
	end
end

item=SelectRandomItem(self.images)
if item ~= nil then item.url=self:get_image_url(item) end

return item

end

return mod
end
