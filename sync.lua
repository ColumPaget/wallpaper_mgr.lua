sync={


send_list=function(self, url, list_type, list)
local str, S

str=url.."/wallpaper_mgr-"..sys.hostname().."."..list_type
S=stream.STREAM(str, "w")
if S ~= nil
then
  for key,value in pairs(list)
  do
    str="'"..key.."' '"..value.."'\n"
    S:writeln(str)
  end
S:close()
end

end,



import_list=function(self, S)
local str, toks, url, list_type, catagory

str=S:readln()
while str ~= nil
do
	str=strutil.trim(str)
	toks=strutil.TOKENIZER(str, "\\S", "Q")
	url=toks:next()
	list_type=toks:next()
	
	if string.sub(list_type, 1, 6) == "block:" then blocklist:add(url) 
	elseif string.sub(list_type, 1, 5) == "fave:" 
	then 
	catagory=string.sub(list_type, 6)
	favelist:add(url, catagory)
  SaveWallpaper(url, settings.working_dir.."/faves/".. catagory, settings.working_dir.."/faves/") 
  end

	
	str=S:readln()
end

end,


recv_list=function(self, url)
local S, str
local glob={}

glob=rglob(url .."wallpaper_mgr-*")
for i, item in ipairs(glob)
do
str=url..filesys.basename(item)

S=stream.STREAM(str, "r")
if S ~= nil
then
self:import_list(S)
S:close()
end

end

end,


run=function(self, url)


self:send_list(url, "block", blocklist.items)
self:send_list(url, "fave", favelist.items)
self:recv_list(url)

blocklist:save()
favelist:save()
end


}
