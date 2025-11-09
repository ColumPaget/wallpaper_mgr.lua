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
