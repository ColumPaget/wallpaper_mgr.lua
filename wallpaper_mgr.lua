require("stream")
require("strutil")
require("xml")
require("process")
require("filesys")
require("hash")
require("net")
require("dataparser")

prog_version="3.2"


function source_parse(input, default_category)
local toks, source, category

if string.find(input, ":") ~= nil 
then
toks=strutil.TOKENIZER(input, ":")
source=toks:next()
category=toks:remaining()
else
category=input
end

if strutil.strlen(category) ==0 then category=default_category end

return category, source
end


function table_join(t1, t2)
local i, item

for i,item in ipairs(t2) do table.insert(t1, item) end
end


function SelectRandomItem(choices)
local val, i

if choices == nil then return nil end
if #choices < 1 then return nil end

for i=1,10,1
do
val=math.random(#choices)
if blocklist:check(choices[val]) == false then return choices[val] end
end

return nil
end



function SelectResolutionItem(choices)
local i, item
local best_res=""
local selected_items={}

if choices == nil then return nil end

for i,item in ipairs(choices)
do
if resolution:select(item.resolution) == true then best_res=item.resolution end
end

if strutil.strlen(best_res) > 0
then
  for i,item in ipairs(choices)
  do 
    if item.resolution == best_res then table.insert(selected_items, item) end 
  end
else
selected_items=choices
end

item=SelectRandomItem(selected_items)

return item, best_res
end




function GetCurrWallpaperDetails()
local dir, S, str, toks
local details={}

dir=process.getenv("HOME").."/.local/share/wallpaper/"
S=stream.STREAM(dir.."wallpapers.curr", "r")
if S ~= nil
then
str=S:readln()
while str ~= nil
do
	str=strutil.trim(str)
	if strutil.strlen(str) > 0
	then
	toks=strutil.TOKENIZER(str, ":")
	details[toks:next()]=strutil.trim(toks:remaining())
	end
	str=S:readln()
end
S:close()
end

return details
end


function ShowCurrWallpaperDetails()
local key, val

for key,val in pairs(GetCurrWallpaperDetails())
do
print(key..": "..val)
end

end


function ShowCurrWallpaperTitle()
local dir,S,str
local title=""

dir=process.getenv("HOME").."/.local/share/wallpaper/"
S=stream.STREAM(dir.."wallpapers.curr", "r")
if S ~= nil
then
  str=S:readln()
	while str ~= nil
	do
	str=strutil.trim(str)
	if string.sub(str, 1, 5) == "url: " then url=string.sub(str, 6) end
	if string.sub(str, 1, 7) == "title: " then title=string.sub(str, 8) end
  str=S:readln()
	end
	S:close()
end

if strutil.strlen(title) > 0 then print(title) 
else print(filesys.basename(url))
end
end



function IsImageURL(url)
local extn, match

if strutil.strlen(url) == 0 then return false end

extn=string.lower(filesys.extn(url))
for i,match in ipairs(settings.filetypes)
do
if match==extn then return true end
end

return false
end



function InitSettings()

settings={}
settings.filetypes={".jpg", ".jpeg", ".png"}
settings.working_dir=process.getenv("HOME").."/.local/share/wallpaper/"
settings.default_sources={
"bing:en-US", "bing:en-GB", "nasa:apod", "wallpapers13:cities", "wallpapers13:nature-wallpapers/beach", "wallpapers13:nature-wallpapers/waterfalls", "wallpapers13:nature-wallpapers/flowers", "wallpapers13:nature-wallpapers/sunset", "wallpapers13:other-topics-wallpapers/church-cathedral", "wallpapers13:nature-wallpapers/landscapes", "getwallpapers:ocean-scene-wallpaper", "getwallpapers:nature-desktop-wallpapers-backgrounds", "getwallpapers:milky-way-wallpaper-1920x1080", "getwallpapers:1920x1080-hd-autumn-wallpapers", "hipwallpapers:nature", "suwalls:flowers", "suwalls:beaches", "suwalls:abstract", "suwalls:nature", "suwalls:space", "wallpaperscraft:nature", "wallpaperscraft:space", "wallhaven:mars", "chandra:stars", "chandra:galaxy", "chandra:clusters", "esahubble:nebulae", "esahubble:galaxies", "esahubble:stars", "esahubble:starclusters", "esawebb:nebulae", "esawebb:galaxies", "esawebb:stars", "esawebb:solarsystem", "esa:earth", "eso:nebula", "eso:galaxy", "eso:telescope", "eso:observatory", "wikimedia:Category:Commons_featured_desktop_backgrounds", "wikimedia:Category:Hubble_images_of_galaxies", "wikimedia:Category:Hubble_images_of_nebulae", "wikimedia:User:Pfctdayelise/wallpapers", "wikimedia:User:Miya/POTY/Nature_views2008", "wikimedia:Lightning", "wikimedia:Fog", "wikimedia:Autumn", "wikimedia:Sunset", "wikimedia:Commons:Featured_pictures/Places/Other", "wikimedia:Commons:Featured_pictures/Places/Architecture/Exteriors", "wikimedia:Commons:Featured_pictures/Places/Architecture/Cityscapes", "archive.org:wallpaperscollection", "archive.org:wallpaper-1.2037", "archive.org:jcorl_white_sands", "archive.org:21590", "archive.org:macwallpapers", "archive.org:macos-wallpapers_202402", "archive.org:android6wallpapers", "archive.org:wallpapers-pack-selected-images", "sourcesplash:galaxy", "sourcesplash:forest"
}
--"chandra:dwarf", "chandra:snr", "chandra:quasars", "chandra:nstars",  "chandra:clusters", "chandra:bh"}

end


function InitBlocklist()
local mod={}

mod.items={}

mod.add=function(self, url)
local S, str

if strutil.strlen(url) == 0 then return false end

for i,item in ipairs(self.items)
do
if item==url then return false end
end

S=stream.STREAM(settings.working_dir.."/blocked.lst", "a")
if S ~= nil
then
S:writeln(url.."\n")
S:close()
end

return true
end

mod.load=function(self)
local S, str

S=stream.STREAM(settings.working_dir.."/blocked.lst", "r")
if S ~= nil
then
	str=S:readln()
	while str ~= nil
	do
	str=strutil.trim(str)
	table.insert(self.items, str)
	str=S:readln()
	end
	S:close()
end

end

mod.check=function(self, url)
local i, item

for i,item in ipairs(self.items)
do
if item==url then return true end
end

return false
end

mod:load()
return mod
end




function InitSources()
local mod={}



mod.parse=function(self, src_list)
local toks, tok
local sources={}

toks=strutil.TOKENIZER(src_list, ",")
tok=toks:next()
while tok ~= nil
do
table.insert(sources, tok)
tok=toks:next()
end

return sources
end



mod.load=function(self, include_disabled)
local S, str
local sources={}

S=stream.STREAM(settings.working_dir .. "/sources.lst", "r")
if S == nil then return nil end

str=S:readln()
while str ~= nil
do
str=strutil.trim(str)
if include_disabled == true or string.sub(str, 1, 2) ~= '#' then table.insert(sources, str) end
str=S:readln()
end
S:close()

return sources
end



mod.save=function(self, sources)
local S, str,i

filesys.mkdirPath(settings.working_dir.."/")
S=stream.STREAM(settings.working_dir .. "/sources.lst", "w")
if S == nil then return nil end

for i, str in ipairs(sources)
do
  if strutil.strlen(str) > 0 then S:writeln(str.."\n") end
end
S:close()

end


mod.select=function(self, source)
local obj

if string.sub(source, 1, 5)=="bing:" then obj=InitBing()
elseif string.sub(source, 1, 5)=="nasa:" then obj=InitNASA()
elseif string.sub(source, 1, 8)=="chandra:" then obj=InitChandra()
elseif string.sub(source, 1, 4)=="eso:" then obj=InitESO()
elseif string.sub(source, 1, 4)=="esa:" then obj=InitESA("https://esa.int")
elseif string.sub(source, 1, 10)=="esahubble:" then obj=InitESA("https://esahubble.org")
elseif string.sub(source, 1, 8)=="esawebb:" then obj=InitESA("https://esawebb.org")
elseif string.sub(source, 1, 13)=="wallpapers13:" then obj=InitWallpapers13()
elseif string.sub(source, 1, 14)=="getwallpapers:" then obj=InitGetWallpapers()
elseif string.sub(source, 1, 13)=="hipwallpaper:" then obj=InitHipWallpaper()
elseif string.sub(source, 1, 14)=="hipwallpapers:" then obj=InitHipWallpaper()
elseif string.sub(source, 1, 10)=="wikimedia:" then obj=InitWikimedia()
elseif string.sub(source, 1, 10)=="wallhaven:" then obj=InitWallhaven()
elseif string.sub(source, 1, 13)=="sourcesplash:" then obj=InitSourceSplash()
elseif string.sub(source, 1, 16)=="wallpaperscraft:" then obj=InitWallpapersCraft()
elseif string.sub(source, 1, 8)=="suwalls:" then obj=InitSUWalls()
elseif string.sub(source, 1, 12)=="archive.org:" then obj=InitArchiveOrg()
elseif string.sub(source, 1, 12)=="archive_org" then obj=InitArchiveOrg()
elseif string.sub(source, 1, 6)=="local:" then obj=InitLocalFiles()
elseif string.sub(source, 1, 6)=="faves:" then obj=InitLocalFiles(filesys.pathaddslash(settings.working_dir).."faves/")
elseif string.sub(source, 1, 9)=="playlist:" then obj=InitPlaylist()
elseif string.sub(source, 1, 4)=="ssh:" then obj=InitSSH()
end

return obj
end


mod.locals=function(self, source_list)
local i, str, stype
local locals_list={}

for i, str in ipairs(source_list)
do
	stype=string.sub(str, 1, 6)
	if stype=="local:" or stype=="faves:" then table.insert(locals_list, str) end
end

return locals_list
end


mod.list=function(self)
local sources

sources=self:load(true)
for i,item in ipairs(sources) do print(tostring(i) .. ": " .. item) end
end


mod.disable=function(self, target)
local sources

sources=self:load(true)
for i,item in ipairs(sources)
do
	if item==target then sources[i]="#"..item end
end
self:save(sources)

end



mod.enable=function(self, target)
local sources

sources=self:load(true)
for i,item in ipairs(sources)
do
	if item == "#"..target then sources[i]=target end
end
self:save(sources)

end


mod.random=function(self, source_list)
local choice

if source_list ~= nil then choice= SelectRandomItem(source_list)
else choice=SelectRandomItem(self.sources)
end

return choice
end



mod.add=function(self, target)
local sources

sources=self:load(true)
table.insert(sources, target)
self:save(sources)

end


mod.remove=function(self, target)
local sources

sources=self:load(true)
for i,item in ipairs(sources)
do
	if item==target then sources[i]="" end
end
self:save(sources)

end



mod.sources=mod:load()
if mod.sources == nil or #mod.sources == 0
then
	mod:save(settings.default_sources)
	mod.sources=mod:load()
end


return mod

end



function HtmlTagExtractAttrib(data, attrib, identifier) 
local toks, tok, value, str, len
local is_target=false

-- include '=' in attrib name, and then we can't match 'href=' with 'hrefwhatever' 
attrib=attrib .. "="
if strutil.strlen(identifier) == 0 then is_target=true end

str=data
toks=strutil.TOKENIZER(str, "\\S", "Q")
tok=toks:next()
while tok ~= nil
do
	if tok == identifier then is_target=true end

	len=strutil.strlen(attrib)
	if string.sub(tok, 1, len) == attrib
	then 
	 value=strutil.stripQuotes(string.sub(tok, len+1))
	end
tok=toks:next()
end

if is_target == true then return(value) end
return("")
end



function HtmlTagExtractHRef(data, identifier, fname) 

if strutil.strlen(fname) == 0 then fname="href" end

return HtmlTagExtractAttrib(data, fname, identifier)
end


-- module to get daily wallpaper from bing.com


function InitPlaylist()
local mod={}


mod.get=function(self, source)
local S, str
local items={}


if strutil.strlen(source) < 0 then return nil end
S=stream.STREAM(string.sub(source, 10), "r")
if S ~= nil
then
	str=S:readln()
	while str ~= nil
	do
	str=strutil.trim(str)
	if strutil.strlen(str) > 0 then table.insert(items, str) end
	str=S:readln()
	end
	S:close()
end

return SelectRandomItem(items)
end

return mod
end




-- module to get daily wallpaper from bing.com


function InitBing()
local mod={}


mod.base_url="http://www.bing.com/"

mod.get=function(self, source)
local S, XML, tag, page_url, str, category, item

page_url=self.base_url
category=source_parse(source,"")
if strutil.strlen(category) > 0 then page_url=page_url..  "?mkt=" .. category end

print("GET: "..page_url)
S=stream.STREAM(page_url, "r")
if S ~= nil
then
	str=S:readdoc()
	XML=xml.XML(str)
	S:close()

  item={}

	tag=XML:next()
	while tag ~= nil
	do
		if tag.type=="a" 
		then 
			str=HtmlTagExtractAttrib(tag.data, 'class')
			if str == "downloadLink " then item.url=self.base_url .. HtmlTagExtractAttrib(tag.data, 'href') 
			elseif str== "title" then item.title=XML:next().data
      end
		elseif tag.type=='span' and tag.data=='class="text" id="iotd_desc"' then item.description=XML:next().data
		elseif tag.type=='div' and tag.data=='class="copyright" id="copyright"' then item.author=XML:next().data
		-- elseif tag.type=='h3' and tag.data=='class="vs_bs_title" id="iotd_title"' then item.title=XML:next().value
		end
		tag=XML:next()
	end

	print("ITEM: ".. tostring(item.url))
end

return item

end

return mod
end


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
local S, XML, tag, str, html, item

str="https://apod.nasa.gov/apod/astropix.html"
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
		if tag.type=="a"
		then
		 str=self:anchor_tag(tag.data)
		 if IsImageURL(str) == true
		 then
     item={}
		 item.url=str
		 item.title=self.get_title(XML)
		 end
		end
		tag=XML:next()
	end
end

return item
end


return mod
end



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
  if IsImageURL(str) == true
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

item.url=self:get_image_details(item.url)

return item
end





mod.esa_extract_image=function(self, img_data, XML)
local img, tag, url

--first extract url of image file

url=HtmlTagExtractAttrib(img_data, "src")
if IsImageURL(url) == true
then
	img={}
  img.url=url

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
    	if img ~= nil then table.insert(self.images, img) end
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
return item
end



if mod.base_url == "https://esawebb.org" then mod.get=mod.hubwebb_get
elseif mod.base_url == "https://esahubble.org" then mod.get=mod.hubwebb_get
else mod.get=mod.esa_get
end

return mod
end

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

--get images from chandra observatory webpage


function InitChandra()
local mod={}



mod.get=function(self, source)
local S, XML, str, html, item
local title=""
local images={}

category=source_parse(source, "galaxy")
str="https://chandra.harvard.edu/resources/desktops_" .. category .. ".html"

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
	if tag.type=="span" 
	then
	 tag=XML:next()
	 title=tag.data
	elseif tag.type=="a"
	then 
	  str=HtmlTagExtractHRef(tag.data, "")
		if strutil.strlen(str) > 0 
		then
			tag=XML:next()
			if tag==nil then break end

			if string.find(tag.data, ' ') == nil and string.find(tag.data, 'x') ~= nil
			then
			item={}
      item.url="https://chandra.harvard.edu/" .. str
			item.title=title
			item.resolution=tag.data
			table.insert(images, item)
			end
		end
	end
	tag=XML:next()
	end
end


item=SelectResolutionItem(images)
return item

end

return mod
end
-- module to select a random wallpaper from https://hipwallpaper.com/daily-wallpapers/


function InitHipWallpaper()
local mod={}


mod.get=function(self, source)
local S, XML, tag, html, url, category
local items={}

category=source_parse(source, "nature")
url="https://hipwallpaper.com/search?q="..category

print("GET: "..url)
S=stream.STREAM(url,"r")
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
			url=HtmlTagExtractAttrib(tag.data, 'data-bs-src')
			if IsImageURL(url) == true
			then 
      item={}
			item.url=url
			table.insert(items, item) 
			end
		end
		tag=XML:next()
	end
end


return SelectRandomItem(items)
end

return mod
end


--get images from a local directory


function InitLocalFiles(root_dir)
local mod={}

mod.root_dir=""
if strutil.strlen(root_dir) > 0 then mod.root_dir=filesys.pathaddslash(root_dir) end
mod.files={}

mod.get=function(self, source)
local item, path, str, GLOB, len

path=filesys.pathaddslash(self.root_dir..string.sub(source, 7))

print("GET: "..path)

GLOB=filesys.GLOB(path.."*")
item=GLOB:next()
while item ~= nil
do
	if GLOB:info().type == "file"
	then
	 table.insert(self.files, item)
	elseif GLOB:info().type == "directory" and string.sub(item, 1, 1) ~= "."
	then
	 len=strutil.strlen(self.root_dir)
	 if len > 0 and string.sub(item, 1, len)==self.root_dir then str=string.sub(item, len) 
	 else str=item
	 end
	 self:get("local:" .. str)
	end

	item=GLOB:next()
end

return SelectRandomItem(self.files)
end



mod.add_image=function(self, url, source)
local path, str

path=string.sub(source, 7).."/"
filesys.mkdirPath(path)
print("mkdir: " .. path)
str=hash.hashstr(url, "md5", "p64") .. "-" .. filesys.basename(url)
print("fave:" .. path..str)
filesys.copy(url, path..str)
end

return mod
end
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
local S, XML, tag, url, str, res
local selected_res=""

if page_url==nil then return end

print("GET: "..page_url)
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
		str=self:extract_url(tag.data) 
		if IsImageURL(str) == true then url=str end
	end
	if tag.type == "/tag" then break end

	tag=XML:next()
	end
end

return url, title
end


mod.get=function(self, source)
local S, XML, html, tag, item
local url="https://www.wallpapers13.com/category/cities-wallpapers"

if strutil.strlen(source)
then
category=source_parse(source, "cities")
len=strutil.strlen(category)
if string.sub(category, len-11) ~= "-wallpapers" then category=category .. "-wallpapers" end
url="https://www.wallpapers13.com/category/"..category.."/" 
end

print("GET: "..url)
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
if strutil.strlen(url) > 0
then
item={}
item.url,item.title=self:get_image(url, source)
end

return item
end

return mod
end

-- module to download a random image from getwallpapers.com


function InitGetWallpapers()
local mod={}

mod.base_url="https://getwallpapers.com/"


mod.div_tag=function(self, data) 
local str, item

str=HtmlTagExtractAttrib(data, "data-fullimg")
if strutil.strlen(str) > 0 
then 
item={}
item.url=self.base_url .. strutil.stripQuotes(str)
end

return item
end


mod.get=function(self, source)
local S, XML, tag, html, str, item
local items={}

str=source_parse(source, "nature-desktop-wallpapers-backgrounds")
url=self.base_url .. "/collection/" .. str

print("GET: "..url)
S=stream.STREAM(url,"r")
if S ~= nil
then
	html=S:readdoc()
	XML=xml.XML(html)
	S:close()

	tag=XML:next()
	while tag ~= nil
	do
		if tag.type=="div" 
		then 
				item=self:div_tag(tag.data) 
				if item ~= nil then table.insert(items, item) end
		end
		tag=XML:next()
	end
end

return SelectRandomItem(items)
end


return mod
end

-- get images using the sourcesplash API

function InitSourceSplash()
local mod={}


mod.get=function(self, source)
local S, str, P, items, item
local title=""
local images={}


category=source_parse(source, "galaxy")
url="https://www.sourcesplash.com/api/search?q=" .. category

print("GET: "..url)
S=stream.STREAM(url, "r")
if S ~= nil
then
	str=S:readdoc()
	P=dataparser.PARSER("json", str)
	S:close()

	items=P:open("photos")
	item=items:next()
	while item ~= nil
  do
  image={}
  image.title=item:value("description")
  image.url=strutil.unQuote(item:value("url"))
  image.resolution=item:value("width") .. "x" ..item:value("height")
  image.author=item:value("author")

	table.insert(images, image)
	item=items:next()
  end
end

--item=SelectResolutionItem(images)
item=SelectRandomItem(images)


if item==nil
then
  print("fail: can't find image from sourcesplash.com")
  return nil
else
  return item
end

end


return mod
end

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
local S, html, str, XML, category, item

category=source_parse(source, "nature")
str="https://suwalls.com/" .. category
print("GET: "..str)

S=stream.STREAM(str, "")
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
item={}
item.url=self:get_image(str)

return item
end

return mod
end

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
-- get images using the wallhaven API

function InitWallhaven()
local mod={}


mod.get=function(self, source)
local S, str, P, items, item
local title=""
local images={}


category=source_parse(source, "nature")
url="https://wallhaven.cc/api/v1/search?q=" .. category

print("GET: "..url)
S=stream.STREAM(url, "r")
if S ~= nil
then
	str=S:readdoc()
	P=dataparser.PARSER("json", str)
	S:close()

	items=P:open("data")
	item=items:next()
	while item ~= nil
  do
  url=strutil.unQuote(item:value("path"))

  if IsImageURL(url) == true
	then
    image={}
    image.url=url
    image.title=item:value("id")
    image.resolution=item:value("resolution")

  	table.insert(images, image)
	end

	item=items:next()
  end
end

--item=SelectResolutionItem(images)
item=SelectRandomItem(images)

return item

end


return mod
end
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
local next_page, page, url, item

page=source_parse(source, "Category:Commons_featured_desktop_backgrounds")

next_page=mod.get_page(self, "/wiki/".. page)
while strutil.strlen(next_page) > 0
do
next_page=mod.get_page(source, next_page)
end


for i=0,5,1
do

url=self:get_image(SelectRandomItem(mod.pages))
if IsImageURL(url) == true
then
item={}
item.url=url
break
end

end

return item
end



return mod
end



--get images from 'wallpaper collections' posted at archive.org


function InitArchiveOrg()
local mod={}

mod.image_urls={}



mod.get=function(self, source)
local S, XML, str, html, item, root, item
local collection
local images={}

if strutil.strlen(source) ==0 then return nil end

collection=source_parse(source, "wallpaperscollection")
root="https://archive.org/download/" .. collection


print("GET: "..root)
S=stream.STREAM(root, "r")
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
	  str=HtmlTagExtractHRef(tag.data, "")
		if strutil.strlen(str) > 0  and IsImageURL(str) == true and string.find(str, "thumb") == nil
		then
			table.insert(images, str)
		end
	end
	tag=XML:next()
	end
end


str=SelectRandomItem(images)
if str ~= nil
then
item={}
item.url=root .. "/" .. str
end

return item
end

return mod
end
-- module to download the current daily astronomy picture from apod.nasa.gov


function InitSSH()
local mod={}


mod.readdir=function(self, source, url_list, dir_list)
local line, path
local S

S=stream.STREAM(source.."/*", "l")
if S ~= nil
then
	line=S:readln()
	while line ~= nil
	do
	line=strutil.trim(line)
	path=source.."/"..filesys.basename(line)
	if extn ~= nil and IsImageURL(line)==true
	then
    table.insert(url_list, path)
  elseif dir_list ~= nil
	then
	  table.insert(dir_list, path)
	end
	line=S:readln()
	end

S:close()
end

end


mod.get=function(self, source)
local url_list={}
local dir_list={}
local str

self:readdir(source, url_list)

print("GET: "..source)
str=source .."/*"
self:readdir(str, url_list)

return SelectRandomItem(url_list)
end


return mod
end


function ROXDesktopSetRoot(cmd, image_path)
local P, S, str, path


path=filesys.find("rox", process.getenv("PATH"))
if strutil.strlen(path) == 0 then path=filesys.find("roxfiler", process.getenv("PATH")) end
if strutil.strlen(path) == 0 then path=filesys.find("rox-filer", process.getenv("PATH")) end

if strutil.strlen(path) > 0
then
  P=process.PROCESS(path .. " --RPC", "")
  if P ~= nil
  then
  print("setting background for ROX desktop")
  str="<?xml version=\"1.0\"?>\n<env:Envelope xmlns:env=\"http://www.w3.org/2001/12/soap-envelope\">\n<env:Body xmlns=\"http://rox.sourceforge.net/SOAP/ROX-Filer\">\n<SetBackdrop>\n<Filename>" .. image_path .. "</Filename>\n<Style>Stretch</Style>\n</SetBackdrop>\n</env:Body>\n</env:Envelope>\n"
  P:send(str)
  P:flush()
  
  cmd="rox"
  end
end

return cmd
end


function XFCE4SetRoot(cmd, image_path)
local P, str, prop_name, path

path=filesys.find("xconf-query", process.getenv("PATH"))
if strutil.strlen(path) > 0
then
  P=process.PROCESS(path .. " --channel xfce4-desktop --list", "")
  if P ~= nil
  then
    prop_name=P:readln()
    while prop_name ~= nil
    do
       prop_name=strutil.trim(prop_name)
       if strutil.pmatch("/backdrop/*/last-image", prop_name) == true 
       then 
       str="xfconf-query --channel xfce4-desktop --property '" .. prop_name .. "' --set '" .. image_path .."'"
       print("setting background for XFCE desktop using: ".. str)
       os.execute(str)
       end
  
       prop_name=P:readln()
    end
   cmd="xfconf-query"
  end
end

return cmd
end


function GenericAppSetRoot(found, filename, invocation, title, image_path)
local path

--if the user has 'dconf' installed, then assume they have a mate desktop and set that too
path=filesys.find(filename, process.getenv("PATH"))
if strutil.strlen(path) > 0
then
print(filename .. " command found at " .. path ..". " .. title)
os.execute(path .. invocation ..  "\"" .. image_path .. "\"") 
found=filename
end

return found
end


function X11SetRootFindProgram()
local programs={"hsetroot -cover", "feh --no-fehbg --bg-center --bg-fill", "xsetbg -fill", "display -window root -backdrop", "gm display -window root -backdrop", "imlibsetroot -p c -s ", "xli -fullscreen -onroot -quiet", "qiv --root_s", "wmsetbg -s -S", "Esetroot -scale", "xv -max -smooth -root -quit", "setwallpaper", "setroot", "bgs -z "}
local i, item, toks, str, path, cmd

for i,item in ipairs(programs)
do
	toks=strutil.TOKENIZER(item, "\\S")
	str=toks:next()
	path=filesys.find(str, process.getenv("PATH"))
	if strutil.strlen(path) > 0
	then 
  cmd=path.." "..toks:remaining() .. " " 
	break
	end
end

return cmd
end


function X11SetRoot(image_path)
local cmd

if strutil.strlen(settings.setroot) > 0 then cmd=settings.setroot .. " " .. image_path
else cmd=X11SetRootFindProgram()
end

-- if we found an x11 command then use it
if strutil.strlen(cmd) > 0 
then
cmd=string.gsub(cmd, "%(root_geometry%)", settings.resolution)
print("setting X11 root window with: "..cmd)
os.execute(cmd .. image_path)
end

return cmd
end


function SetRoot(image_path)
local cmd, i, str, path

--try to detect if anything went wrong with getting the image
if image_path==nil or filesys.size(image_path) < 100 then return end

-- first try standard 'X11' background setters
cmd=X11SetRoot(image_path)

--if the user has 'gsettings' installed, then assume they have a gnome desktop and set that too
path=filesys.find("gsettings", process.getenv("PATH"))
if strutil.strlen(path) > 0 
then 
print("gsettings command found at ".. path ..". Setting background for gnome desktop")
os.execute("gsettings set org.gnome.desktop.background picture-uri file:///" .. image_path) 
print("gsettings command found at ".. path ..". Setting background for cinnamon desktop")
os.execute("gsettings set org.cinnamon.desktop.background picture-uri file:///" .. image_path) 
cmd="gsettings"
end

cmd=XFCE4SetRoot(cmd, image_path)
cmd=ROXDesktopSetRoot(cmd, image_path)

cmd=GenericAppSetRoot(cmd, "dconf",  " write /org/mate/desktop/background/picture-filename ", "Setting background for icewm desktop", "'" .. image_path .. "'")
cmd=GenericAppSetRoot(cmd, "icewmbg",  " -r -p -i ", "Setting background for icewm desktop", image_path)
cmd=GenericAppSetRoot(cmd, "zzzfm",  " --set-wallpaper ", "Setting background for zzzfm/antiX desktop", image_path)
cmd=GenericAppSetRoot(cmd, "spacefm", " --set-wallpaper ", "Setting background for spacefm desktop", image_path)
cmd=GenericAppSetRoot(cmd, "pcmanfm", " --wallpaper-mode=\"fit\" --set-wallpaper=", "Setting background for pcmanfm desktop", image_path)


if strutil.strlen(cmd) == 0 then print("ERROR: no suitable command found to set root window background") end

end

function GetWallpaperOpenURL(url)
local S

S=stream.STREAM(url, "r")
if S ~= nil
then
	if string.sub(url, 1, 5)=="http:" or string.sub(url, 1, 6)=="https:" 
	then
		if S:getvalue("HTTP:ResponseCode") ~= "200"
		then
			S:close()
			return(nil)
		end
  end
end

return S
end



function GetWallpaper(url, source, title, description, author) 
local S, fname
local result=false

if url==nil then return false end

print("GET: "..url)

fname=filesys.pathaddslash(settings.working_dir) .. "current-wallpaper.jpg"
filesys.mkdirPath(fname)

S=GetWallpaperOpenURL(url)
if S ~= nil
then
	if S:copy(fname) > 0 then result=true end
	S:close()

  if strutil.strlen(process.getenv("DISPLAY"))==0 then process.setenv("DISPLAY", ":0") end
  SetRoot(fname)

  S=stream.STREAM(settings.working_dir.."wallpapers.log", "a")
  if S ~= nil
  then
	  str=url.." source='"..source.."'"
	  if strutil.strlen(title) > 0 then str=str.." title='"..title.."'" end
	  str=str.."\n"
	  S:writeln(str)
	  S:close()
  end

  S=stream.STREAM(settings.working_dir.."wallpapers.curr", "w")
  if S ~= nil
  then
	  S:writeln("url: "..url.."\n")
	  S:writeln("source: "..source.."\n")
	  if strutil.strlen(title) > 0 then S:writeln("title: "..title.."\n") end
	  if strutil.strlen(description) > 0 then S:writeln("description: "..description.."\n") end
	  if strutil.strlen(author) > 0 then S:writeln("author: "..author.."\n") end
	  S:close()
  end
end


return result
end



function InitResolution()
local mod={}

mod.best_resolution=""



mod.xrandr_resolution=function(self)
local S, str, toks
local resolution=""

S=stream.STREAM("cmd:xrandr", "");
if S ~= nil
then
  str=S:readln()
  toks=strutil.TOKENIZER(str, ",")
  str=toks:next()
  while str ~= nil
  do
  str=strutil.trim(str)
  if string.sub(str, 1, 8) == "current "
  then
  str=string.sub(str, 9)
  resolution=string.gsub(str, ' ', '')
  end
  
  str=toks:next()
  end
  S:close()
end

return resolution
end



mod.xwininfo_resolution=function(self)
local S, str, pos
local resolution=""

S=stream.STREAM("cmd:xwininfo -root", "")
if S ~= nil
then
	str=S:readln()
	while str ~= nil
	do
	str=strutil.trim(str)
	if string.sub(str,1,10) == "-geometry "
	then
print(str)
		resolution=string.sub(str, 11)
		pos=string.find(resolution, '+')
		if pos ~= nil then resolution=string.sub(resolution, 1, pos-1) end
	end
	str=S:readln()
	end
end

print(resolution)
return resolution
end



mod.xprop_resolution=function(self)
local S, str, toks
local resolution=""

if strutil.strlen(resolution) ==0
then
S=stream.STREAM("cmd:xprop -root", "");
if S ~= nil
then
str=S:readln()
while str ~= nil
do
	str=strutil.trim(str)
	if string.sub(str, 1, 33) == "_NET_DESKTOP_GEOMETRY(CARDINAL) ="
	then
	str=string.sub(str, 34)
	resolution=string.gsub(str, ' ', '')
	resolution=string.gsub(resolution, ',', 'x')
	end
str=S:readln()
end
S:close()
end

end

return resolution
end



mod.get=function(self)
local S, str, resolution

if strutil.strlen(settings.resolution) > 0 then return settings.resolution end

resolution=self:xrandr_resolution()
if strutil.strlen(resolution) == 0 then resolution=self:xwininfo_resolution() end
if strutil.strlen(resolution) == 0 then resolution=self:xprop_resolution() end
if strutil.strlen(resolution) == 0 then resolution="1280x1024" end

return resolution
end


mod.calc_diff=function(self, target, new)
local xdiff, ydiff, target_toks, new_toks
local val1, val2

	target_toks=strutil.TOKENIZER(target, "x")
	new_toks=strutil.TOKENIZER(new, "x")
	val=tonumber(new_toks:next())
	if val == nil then return nil end
	xdiff=tonumber(target_toks:next()) - val
	val=tonumber(new_toks:next())
	if val == nil then return nil end
	ydiff=tonumber(target_toks:next()) - val
	if xdiff < 0 then xdiff=0 - xdiff end
	if ydiff < 0 then ydiff=0 - ydiff end

return (xdiff+ydiff)
end


mod.select=function(self, res)
local better=false
local new_diff, best_diff

if res==nil then return false end
if string.find(res, 'x') == nil then return false end

if mod.best_resolution==""
then
	better=true
else
	new_diff=self:calc_diff(settings.resolution, res) 
	best_diff=self:calc_diff(settings.resolution, mod.best_resolution)
	if new_diff == nil then better=false
	elseif best_diff == nil then better=true
	elseif new_diff < best_diff then better=true
	end
end

if better==true then mod.best_resolution=res end

return better
end


settings.resolution=mod:get()

return mod
end
-- pigeonholed is a server that stores lists and values for other apps. We use it to sync our blocklist and favorites

function PigeonholedSendBlocklist(S)
local i, url, str;

	S:writeln("array wallpaper_mgr blocklist\n");
	str=S:readln()
	for i,url in ipairs(blocklist.items)
	do
	S:writeln("write wallpaper_mgr blocklist " .. url ..  "\n");
	str=S:readln()
	end
end


function PigeonholedReadBlocklist(S)
local item, toks, str;

	S:writeln("read wallpaper_mgr blocklist\n");
	str=S:readln()
	toks=strutil.TOKENIZER(str, "\\S", "Q")
	if toks:next() == "+OK"
	then
		item=toks:next()
		while item ~= nil
		do
		if blocklist:add(item) then print("blocklist add: "..item) end
		item=toks:next()
		end
	end

end



function PigeonholedSync(ph_server)
local S

S=stream.STREAM(ph_server)
if S ~= nil
then
	PigeonholedSendBlocklist(S)
	PigeonholedReadBlocklist(S)
	S:close()
end

end
function PrintHelp()
local str, i, item

print("")
print("wallpaper_mgr.lua [options]")
print("options:")
print("  -sources <comma separated list of sources>       list of sources to get images from, overriding the default list.")
print("  +sources <comma separated list of sources>       add sources to list (either add to default list, or a list supplied with -sources)")
print("  -list                                            list default sources.")
print("  -list-sources                                    list default sources.")
print("  -add <source>                                    add a source to the list of default sources.")
print("  -del <source>                                    remove an item from the list of default sources.")
print("  -rm <source>                                     remove an item from the list of default sources.")
print("  -remove <source>                                 remove an item from the list of default sources.")
print("  -disable <source>                                disable a source in the list of default sources.")
print("  -enable <source>                                 enable a source in the list of default sources.")
print("  -block <image url>                               block an image url so this image can never be used.")
print("  -block-curr                                      block the current image so it is never used.")
print("  -save-curr  <dest directory>                     save current image to a destination directory.")
print("  -fave-curr  <name>                               save current image to a favorites collection named '<name>'.")
print("  -save <url> <dest directory>                     save image at <url> to a destination directory.")
print("  -fave <url> <name>                               save image at <url> to a favorites collection named '<name>'.")
print("  -info                                            info on current image.")
print("  -title                                           title of current image (or URL if no title).")
print("  -setroot <program name>                          use specified program to set background.")
print("  -resolution <resolution>                         get images matching <resolution>")
print("  -exe_path <path>                                 colon-separated search path for 'setroot' programs. e.g. -exec_path /usr/X11R7/bin:/usr/bin")
print("  -res <resolution>                                get images matching <resolution>")
print("  -proxy <url>                                     use given proxy server")
print("  -filetypes <list>                                comma-seperated list of file extensions to accept from image sources, e.g. '.jpg,.jpeg' or 'jpg,jpeg'. Be wary that most sites return .jpg, so if you leave that out of the list, you will get few (or no) images. Default is '.jpg,.jpeg,.png'")
print("  -?                                               this help")
print("  -help                                            this help")
print("  --help                                           this help")
print("")
print("wallpaper_mgr.lua uses xrandr or 'xprop -root' to discover the size of the desktop, and downloads images close to that on sites that support multiple resolutions. If xrandr and xprop aren't available, and the user doesn't supply a resolution on the command line, then it defaults to 1920x1200.")
print("")
print("-sources and +sources do not effect the default list, they only apply for the current program invocation")
print("")
print("wallpaper_mgr.lua has a default list of sources consisting of:")
print("")

str=""
for i,item in ipairs(settings.default_sources)
do
str=str .. item .. ", "
end
print(str)

print("")
print("This list includes entries from all supported sites, and other things can be added from these sites by paying attention to the urls of the 'category' pages on each site.")
print("")
print("wallpapers can be pulled from a local directory with a source of the format 'local:<dir>'.");
print("wallpapers can be pull from previously saved 'faves' with a source of the format 'faves:<name>' (where 'name' is the category/collection-name).");
print("wallpapers selected from a 'playlist file' of urls using a source of the format 'playlist:<path>' where 'path' points to a file containing a list of urls.");
print("")
print("Wallpapers can be pulled from an ssh server using a source of the form: 'ssh:<host>/<path>'. 'host' must be an entry configured in the '~/.ssh/config' file and 'path' is a file path from the login directory. wallpaper_mgr will search in 'path' and one level of subfolders of 'path' for files ending in .jpeg, .jpg or .png, and picks one at random to use as wallpaper.")
print("")
print("Using either the -proxy command or setting the PROXY_SERVER environment variable allows setting a proxy server to use. Proxy server urls can be of the form:")
print("   https:<username>:<password>@<host>:<port>")
print("   socks:<username>:<password>@<host>:<port>")
print("   sshtunnel:<ssh host>")
print("<ssh host> is usually matching and entry in the ~/.ssh/config file")

end




function GetWallpaperFromSite(source)
local url, item
local result=false


mod=sources:select(source)
if mod ~= nil
then 
item=mod:get(source) 

if item ~= nil and strutil.strlen(item.url) > 0 
then
if blocklist:check(item.url) == false then result=GetWallpaper(item.url, source, item.title, item.description, item.author) 
else print("BLOCKED: " .. item.url .. ". Never use this image.")
end

end
end

return result
end



function WallpaperFromRandomSource(source_list)
local i, item 
local result=false

if source_list ~= nil
then
  for i=1,5,1
  do
    item=sources:random(source_list)
    result=GetWallpaperFromSite(item) 
    if result == true then break end
  end

  -- fall back to only local sources if above didn't work
  if result==false
  then
    locals=sources:locals(source_list)
    item=sources:random(locals)
    if item ~= nil then result=GetWallpaperFromSite(item) end
  end
end

end


function SaveWallpaper(url, dest, root_dir)
local obj

if strutil.strlen(dest)==0 
then
print("ERROR: no destination directory given")
else
	if url=="current" then url=GetCurrWallpaperDetails().url end
	obj=InitLocalFiles(root_dir)
	obj:add_image(url, "local:"..dest) 
end
end

function FaveWallpaper(url, dest)
if strutil.strlen(dest)==0 
then
print("ERROR: no favorites category given")
else
SaveWallpaper(url, settings.working_dir.."/faves/"..dest, settings.working_dir.."/faves/")
end

end


function ProxySetup()
local str=""

if strutil.strlen(settings.proxy) > 0 then str=settings.proxy
else str=process.getenv("PROXY_SERVER")
end

if strutil.strlen(str) then net.setProxy(str) end

end

function ParseFileTypes(config)
local toks, tok
local filetypes={}
toks=strutil.TOKENIZER(config, ",")
tok=toks:next()
while tok ~= nil
do
if string.sub(tok, 1, 1) ~= '.' then tok="." .. tok end
table.insert(filetypes, tok)
tok=toks:next()
end

return filetypes
end


function ParseCommandLine()
local i, str, list, source_list, src_url
local act="random"
local target=""

source_list=sources:load()
for i,str in ipairs(arg)
do
if strutil.strlen(str) > 0
then
	if str=="-sources" then source_list=sources:parse(arg[i+1])  ; arg[i+1]=""
	elseif str=="+sources" then list=table_join(source_list, sources:parse(arg[i+1]))  ; arg[i+1]=""
	elseif str=="-info" then act="info" 
	elseif str=="-title" then act="title" 
	elseif str=="-list" then act="list" 
	elseif str=="-list-sources" then act="list" 
	elseif str=="-add" then act="add" ; target=arg[i+1] ; arg[i+1]=""
	elseif str=="-del" then act="remove" ; target=arg[i+1] ; arg[i+1]=""
	elseif str=="-rm" then act="remove" ; target=arg[i+1] ; arg[i+1]=""
	elseif str=="-remove" then act="remove" ; target=arg[i+1] ; arg[i+1]=""
	elseif str=="-disable" then act="disable" ; target=arg[i+1] ; arg[i+1]=""
	elseif str=="-enable" then act="enable" ; target=arg[i+1] ; arg[i+1]=""
	elseif str=="-block" then act="block" ; target=arg[i+1] ; arg[i+1]=""
	elseif str=="-block-curr" then act="block-curr"
	elseif str=="-save-curr" then act="save-curr"; target=arg[i+1]; arg[i+1]=""
	elseif str=="-fave-curr" then act="fave-curr"; target=arg[i+1]; arg[i+1]=""
	elseif str=="-save" then act="save"; src_url=arg[i+1]; target=arg[i+2]; arg[i+1]=""; arg[i+2]=""
	elseif str=="-fave" then act="fave"; src_url=arg[i+1]; target=arg[i+2]; arg[i+1]=""; arg[i+2]=""
	elseif str=="-setroot" then settings.setroot=arg[i+1]; arg[i+1]=""
	elseif str=="-resolution" then settings.resolution=arg[i+1]; arg[i+1]=""
	elseif str=="-res" then settings.resolution=arg[i+1]; arg[i+1]=""
	elseif str=="-exe_path" then process.setenv("PATH", arg[i+1]); arg[i+1]=""
	elseif str=="-sync" then act="sync"; target=arg[i+1]; arg[i+1]=""
	elseif str=="-proxy" then settings.proxy=arg[i+1]; arg[i+1]=""
	elseif str=="-filetypes" then settings.filetypes=ParseFileTypes(arg[i+1]); arg[i+1]=""
	elseif str=="-?" then act="help" 
	elseif str=="-help" then act="help"
	elseif str=="--help" then act="help"
	elseif str=="--version" or str=="-version" then act="version"
	else act="error"; print("unknown option '"..str.."'")
	end
end
end

if source_list==nil then source_list=settings.default_sources end

return act,target,src_url,source_list
end


-- seed random number generator so it doesn't produce the same
-- pattern of values!
math.randomseed(os.time()+process.getpid())


InitSettings()
sources=InitSources()
blocklist=InitBlocklist()

process.lu_set("HTTP:UserAgent", "wallpaper.lua (colum.paget@gmail.com)")


act,target,src_url,source_list=ParseCommandLine()

--if a proxy has been asked for on the command line or via
--environment variables, then handle it
ProxySetup()

if act=="help" then PrintHelp()
elseif act=="version" then print("wallpaper_mgr version: " .. prog_version)
elseif act=="info" then ShowCurrWallpaperDetails()
elseif act=="title" then ShowCurrWallpaperTitle()
elseif act=="list" then sources:list()
elseif act=="disable" then sources:disable(target)
elseif act=="enable" then sources:enable(target)
elseif act=="add" then sources:add(target)
elseif act=="remove" then sources:remove(target)
elseif act=="block-curr" then blocklist:add(GetCurrWallpaperDetails().url) 
elseif act=="save-curr" then SaveWallpaper("current", target)
elseif act=="fave-curr" then FaveWallpaper("current", target)
elseif act=="block" then blocklist:add(target) 
elseif act=="save" then SaveWallpaper(src_url, target)
elseif act=="fave" then FaveWallpaper(src_url, target)
elseif act=="sync" then PigeonholedSync(target)
elseif act=="random"
then
  resolution=InitResolution()
  WallpaperFromRandomSource(source_list)
else print("unrecognized command-line.")
end

