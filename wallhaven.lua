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
