require("stream")
require("strutil")
require("xml")
require("process")
require("filesys")
require("hash")
require("net")
require("sys")
require("dataparser")
require("terminal")

prog_version="3.3"


function URLGet(url)
local S

TermOut:puts("~eGET~0: ~c"..url .. "~0")
TermOut:flush()
S=stream.STREAM(url, "r")

if S ~= nil
then
  if string.sub(url, 1, 5)=="http:" or string.sub(url, 1, 6)=="https:" 
  then
    if S:getvalue("HTTP:ResponseCode") ~= "200"
    then
      S:close()
      S=nil
    end
  end
end


if S ~= nil then TermOut:puts(" ... ~gokay~0\n")
else TermOut:puts(" ... ~rfailed~0\n")
end

return S
end


-- 'remote glob' function, currently only works for ssh
function rglob(url)
local S, str
local glob={}


S=stream.STREAM(url, "l")
if S ~= nil
then
  str=S:readln()
  while str ~= nil
  do
  str=strutil.trim(str)
  table.insert(glob, str)
  str=S:readln()
  end

  S:close()
end

return glob
end



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
local val, i, item, url

if choices == nil then return nil end
if #choices < 1 then return nil end

for i=1,10,1
do
val=math.random(#choices)
item=choices[val]
if type(item) == "table" then url=item.url
else url=item
end
if blocklist:check(url) == false then return choices[val] end
end

print("NO SELECT")
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



