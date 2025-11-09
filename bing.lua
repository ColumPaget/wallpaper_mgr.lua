

-- module to get daily wallpaper from bing.com


function InitBing()
local mod={}


mod.base_url="http://www.bing.com/"

mod.get=function(self, source)
local S, XML, tag, page_url, str, category, item

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

  item={}

	tag=XML:next()
	while tag ~= nil
	do
		if tag.type=="a" 
		then 
			str=HtmlTagExtractAttrib(tag.data, 'class')
			if str == "downloadLink " then item.url=self.base_url .. HtmlTagExtractAttrib(tag.data, 'href') 
			elseif str== "title" then item.title=XML:next().data
      end
		elseif tag.type=='span' and tag.data=='class="text" id="iotd_desc"' then item.description=XML:next().data
		elseif tag.type=='div' and tag.data=='class="copyright" id="copyright"' then item.author=XML:next().data
		-- elseif tag.type=='h3' and tag.data=='class="vs_bs_title" id="iotd_title"' then item.title=XML:next().value
		end
		tag=XML:next()
	end

	print("ITEM: ".. tostring(item.url))
end

return item

end

return mod
end


