

function InitESA(base_url)
local mod={}

mod.base_url=base_url
mod.images={}


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




-- this reads scripts on the webpage looking for one that
-- starts with "var images = ["
-- that script is mostly a big JSON array of image info objects
mod.hubwebb_read_script=function(self, script)
local JSON, array, item, img

if script == nil then return end

if string.sub(script, 1, 12) == "var images ="
then

  -- clip off 'var images =' to give us a JSON array of image data
  JSON=dataparser.PARSER("json", string.sub(script, 13))
  array=JSON:next()
  item=array:next()
  while item ~= nil
  do

  str=item:value("url")
  if strutil.strlen(str) > 0
  then 
  img={}
  img.url=self.base_url .. str
  img.id=item:value("id")
  img.title=item:value("title")
  img.width=item:value("width")
  img.height=item:value("width")
  table.insert(self.images, img)
  end
  item=array:next()
  end

end

return nil
end





mod.hubwebb_open_page=function(self, category, max_page)
local page, url, S

page=math.random() 

page=page * max_page
page=page + 1 -- pages start at 1, not zero

	if strutil.strlen(category) > 0
	then
	-- https://esahubble.org/images/archive/category/galaxies/page/3/
	url=self.base_url .. "/images/archive/category/".. category .. "/page/"..string.format("%d", math.floor(page)).."/"
	else
	url=self.base_url .. "/images/" .. "/page/"..string.format("%d", math.floor(page)).."/"
	end

print("GET: "..url)
	S=stream.STREAM(url, "r")
	if S == nil then return nil end
	if S:getvalue("HTTP:ResponseCode") ~= "200"
	then
	S:close()
	return nil
	end

	return S
end


mod.hubwebb_get=function(self, source)
local S, html, XML, tag, item, url, category
local max_page=10

category=source_parse(source, "stars")
S=self:hubwebb_open_page(category, max_page)
if S == nil then S=self:hubwebb_open_page(category, 1) end

if S ~= nil
then
	html=S:readdoc()
	XML=xml.XML(html)
	S:close()

	tag=XML:next()
	while tag ~= nil
	do
	  if tag.type == "script" then self:hubwebb_read_script(XML:next().data) end
	  tag=XML:next()
	end
end

item=SelectRandomItem(self.images)
if item == nil then return nil end

return self:get_image_details(item.url)
end


mod.esa_extract_image=function(self, img_data, XML)
local img, tag

	--first extract url of image file
	img={}
	img.url=HtmlTagExtractAttrib(img_data, "src")

  -- now we look through remaining tags for an image title
  -- if we hit '</tr>' then we're at the end of stuff relating 
  -- to this image
	tag=XML:next()
	while tag ~= nil and tag.type ~= "/tr"
	do
		if tag.type=="a"
		then
			tag=XML:next()
			img.title=tag.data
		end
	tag=XML:next()
	end

return img
end


mod.esa_read_article=function(self, XML) 
local tag, str, width, img

tag=XML:next()
while tag ~= nil
do
	if tag.type == "img"
	then
	--some esa earth observation images are very low resolution
  --and do not make good backgrounds. Fortunately they are tagged with a 'width' value of 60
  --which makes them distinguishable from higher-res images that have a width of 100
  --other esa image galleries don't have this width value, and so if width is nil we can also use the image
  	width=HtmlTagExtractAttrib(tag.data, "width")
    if width==nil or tonumber(width) > 60
    then
    	img=self:esa_extract_image(tag.data, XML)
    	table.insert(self.images, img)
  	end
  end
tag=XML:next()
end
	
end


mod.esa_get=function(self, category)
local S, html, XML, tag, item, url


-- there is only 'esa:earth'
--[[
pos=string.find(category, ':')
if pos ~= nil then category=string.sub(category, pos+1) end

if category == "earth" then url=self.base_url .. "/Applications/Observing_the_Earth/Image_archive"
end
]]--

url=self.base_url .. "/Applications/Observing_the_Earth/Image_archive"

print("GET: "..url)
S=stream.STREAM(url, "")
if S ~= nil
then
	html=S:readdoc()
	XML=xml.XML(html)
	S:close()

	tag=XML:next()
	while tag ~= nil
	do
	  if tag.type == "div" and tag.data == "class=\"article__block\"" then self:esa_read_article(XML) end
	  tag=XML:next()
	end
end

item=SelectRandomItem(self.images)
if item == nil then return nil end

return item.url, item.title
end



if mod.base_url == "https://esawebb.org" then mod.get=mod.hubwebb_get
elseif mod.base_url == "https://esahubble.org" then mod.get=mod.hubwebb_get
else mod.get=mod.esa_get
end

return mod
end
