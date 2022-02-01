

function HtmlTagExtractHRef(data, identifier) 
local toks, tok, url, str
local is_target=false

if strutil.strlen(identifier) == 0 then is_target=true end

str=data
toks=strutil.TOKENIZER(str, "\\S", "Q")
tok=toks:next()
while tok ~= nil
do
	if tok == identifier then is_target=true end
	if string.sub(tok, 1, 5) == 'href='
	then 
	 url=strutil.stripQuotes(string.sub(tok, 6))
	end
tok=toks:next()
end

if is_target == true then return url end
return("")
end

