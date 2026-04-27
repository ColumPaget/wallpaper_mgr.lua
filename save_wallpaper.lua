
function SaveWallpaper(url, dest, root_dir)
local obj

if strutil.strlen(dest)==0 
then
print("ERROR: no destination directory given")
else
  if url=="current" then url=GetCurrWallpaperDetails().url end
  obj=InitLocalFiles(root_dir)
  obj:add_image(url, "local:"..dest) 
  return true
end

return false
end


function AddToFavesList(url, category)
local S, curr

if url == "current"
then
 curr=GetCurrWallpaperDetails()
 url=curr.url
end

if strutil.strlen(url) > 0 then favelist:append(url, category) end

end



function FaveWallpaper(url, dest)
if strutil.strlen(dest)==0 
then
print("ERROR: no favorites category given")
else
if SaveWallpaper(url, settings.working_dir.."/faves/"..dest, settings.working_dir.."/faves/") == true then AddToFavesList(url, dest) end

end

end


