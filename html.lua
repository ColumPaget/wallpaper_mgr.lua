
function HtmlTagExtractAttrib(data, attrib, identifier) 
local toks, tok, value, str, len
local is_target=false

-- include '=' in attrib name, and then we can't match 'href=' with 'hrefwhatever' 
attrib=attrib .. "="
if strutil.strlen(identifier) == 0 then is_target=true end

str=data
toks=strutil.TOKENIZER(str, "\\S", "Q")
tok=toks:next()
while tok ~= nil
do
	if tok == identifier then is_target=true end

	len=strutil.strlen(attrib)
	if string.sub(tok, 1, len) == attrib
	then 
	 value=strutil.stripQuotes(string.sub(tok, len+1))
	end
tok=toks:next()
end

if is_target == true then return(value) end
return("")
end



function HtmlTagExtractHRef(data, identifier, fname) 

if strutil.strlen(fname) == 0 then fname="href" end

return HtmlTagExtractAttrib(data, fname, identifier)
end
