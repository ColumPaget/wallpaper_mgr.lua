-- get images using the wallhaven API

function InitWallpaperCave()
local mod={}


mod.get=function(self, source)
local S, str, P, items, item
local title=""
local images={}

url=URLWithCategory("https://wallpapercave.com/", "-wallpapers", "arctic-ocean", source)

S=URLGet(url)
if S ~= nil
then
  str=S:readdoc()
  XML=xml.XML(str)
  S:close()

  tag=XML:next()
  while tag ~= nil
  do
      if tag.type=="picture" then self:picture(images, XML) end
      tag=XML:next()
  end


--item=SelectResolutionItem(images)
item=SelectRandomItem(images)
end

return item

end


-- on this site everything we need is in the <div> tag
-- <div id="19687" data-fullimg="/w/full/1/3/3/19687-2560x1600-desktop-hd-sunset-wallpaper-image.jpg" data-or="2560x1600" data-author="rortiz" data-authorslug="rortiz" data-likes="1546" class="flexbox_item wall">
mod.picture=function(self, images, XML) 
local url, image, tag, image

  tag=XML:next()
  while tag ~= nil
  do
      if tag.type=="/picture" then break end
			if tag.type=="img" and HtmlTagExtractAttrib(tag.data, "class") == "wimg"
			then
			image={}
			image.url="https://wallpapercave.com/" .. HtmlTagExtractAttrib(tag.data, "src")
			image.resolution=HtmlTagExtractAttrib(tag.data, "width") .. "x" ..  HtmlTagExtractAttrib(tag.data, "height") 

    	table.insert(images, image)
			end
      tag=XML:next()
  end



end



return mod
end
