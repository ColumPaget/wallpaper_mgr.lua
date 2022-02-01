

-- module to get daily wallpaper from bing.com


function InitBing()
local mod={}



mod.get=function(self, source)
local S, XML, tag, page_url, str
local url=""
local title=""
local description=""

page_url="http://www.bing.com/"
if strutil.strlen(source) > 0
then
  if string.sub(source, 1, 5) == "bing:" then page_url=page_url..  "?mkt=" .. string.sub(source, 6) end
end

S=stream.STREAM(page_url,"r")
if S ~= nil
then
	str=S:readdoc()
	XML=xml.XML(str)
	S:close()

	tag=XML:next()
	while tag ~= nil
	do
		if tag.type=="link" 
		then 
			str=HtmlTagExtractHRef(tag.data, 'id="preloadBg"')
			if strutil.strlen(str) > 0 then url="http://www.bing.com" .. str end
		elseif tag.type=='span' and tag.data=='class="text" id="iotd_desc"' then description=XML:next().value
		-- elseif tag.type=='h3' and tag.data=='class="vs_bs_title" id="iotd_title"' then title=XML:next().value
		elseif tag.type=='a' 
		then
						if string.find(tag.data, 'class="title"') then title=XML:next().value end
		end
		tag=XML:next()
	end

end

return url

end

return mod
end


