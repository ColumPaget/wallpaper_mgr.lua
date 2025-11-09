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



