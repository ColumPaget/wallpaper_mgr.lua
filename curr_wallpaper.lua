
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

