

function HtmlTagExtractHRef(data, identifier, fname) 
local toks, tok, url, str, len
local is_target=false

if strutil.strlen(fname) == 0 then fname="href=" end
if strutil.strlen(identifier) == 0 then is_target=true end

str=data
toks=strutil.TOKENIZER(str, "\\S", "Q")
tok=toks:next()
while tok ~= nil
do
	if tok == identifier then is_target=true end

	len=strutil.strlen(fname)
	if string.sub(tok, 1, len) == fname
	then 
	 url=strutil.stripQuotes(string.sub(tok, len+1))
	end
tok=toks:next()
end

if is_target == true then return url end
return("")
end

