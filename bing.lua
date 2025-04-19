

-- module to get daily wallpaper from bing.com


function InitBing()
local mod={}


mod.base_url="http://www.bing.com/"

mod.get=function(self, source)
local S, XML, tag, page_url, str, category
local url=""
local title=""
local description=""
local author=""

page_url=self.base_url
category=source_parse(source,"")
if strutil.strlen(category) > 0 then page_url=page_url..  "?mkt=" .. category end

print("GET: "..page_url)
S=stream.STREAM(page_url, "r")
if S ~= nil
then
	str=S:readdoc()
	XML=xml.XML(str)
	S:close()

	tag=XML:next()
	while tag ~= nil
	do
		if tag.type=="a" 
		then 
			str=HtmlTagExtractAttrib(tag.data, 'class')
			if str == "downloadLink " then url=self.base_url .. HtmlTagExtractAttrib(tag.data, 'href') 
			elseif str== "title" then title=XML:next().data
      end
		elseif tag.type=='span' and tag.data=='class="text" id="iotd_desc"' then description=XML:next().data
		elseif tag.type=='div' and tag.data=='class="copyright" id="copyright"' then author=XML:next().data
		-- elseif tag.type=='h3' and tag.data=='class="vs_bs_title" id="iotd_title"' then title=XML:next().value
		end
		tag=XML:next()
	end

end

return url,title,description,author

end

return mod
end


