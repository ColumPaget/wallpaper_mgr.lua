-- get images using the wallhaven API

function InitCharlieWaite()
local mod={}


mod.get=function(self, source)
local S, str, P, items, item, url
local title=""
local images={}

url=URLWithCategory("https://charliewaite.com/", "", "colour-landscapes", source)

S=URLGet(url)
if S ~= nil
then
  str=S:readdoc()
  XML=xml.XML(str)
  S:close()

  tag=XML:next()
  while tag ~= nil
  do
      if tag.type=="noscript" 
      then 
      tag=XML:next()
      if tag.type == "img" then self:img_tag(images, tag.data) end
      end
      tag=XML:next()
  end


--item=SelectResolutionItem(images)
item=SelectRandomItem(images)
end

return item

end


-- on this site everything we need is in the <div> tag
-- <div id="19687" data-fullimg="/w/full/1/3/3/19687-2560x1600-desktop-hd-sunset-wallpaper-image.jpg" data-or="2560x1600" data-author="rortiz" data-authorslug="rortiz" data-likes="1546" class="flexbox_item wall">
mod.img_tag=function(self, images, data) 
local url, image

url=HtmlTagExtractAttrib(data, "src")
if strutil.strlen(url) > 0
then

    image={}
    image.url=url
    image.author="Charlie Waite (https://charliewaite.com)"
    image.description=HtmlTagExtractAttrib(data, "alt")

    table.insert(images, image)
end


end



return mod
end
