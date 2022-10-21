-- pigeonholed is a server that stores lists and values for other apps. We use it to sync our blocklist and favorites

function PigeonholedSendBlocklist(S)
local i, url, str;

	S:writeln("array wallpaper_mgr blocklist\n");
	str=S:readln()
	for i,url in ipairs(blocklist.items)
	do
	S:writeln("write wallpaper_mgr blocklist " .. url ..  "\n");
	str=S:readln()
	end
end


function PigeonholedReadBlocklist(S)
local item, toks, str;

	S:writeln("read wallpaper_mgr blocklist\n");
	str=S:readln()
	toks=strutil.TOKENIZER(str, "\\S", "Q")
	if toks:next() == "+OK"
	then
		item=toks:next()
		while item ~= nil
		do
		if blocklist:add(item) then print("blocklist add: "..item) end
		item=toks:next()
		end
	end

end



function PigeonholedSync(ph_server)
local S

S=stream.STREAM(ph_server)
if S ~= nil
then
	PigeonholedSendBlocklist(S)
	PigeonholedReadBlocklist(S)
	S:close()
end

end
