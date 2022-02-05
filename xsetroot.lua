

function SetRoot(image_path)

local programs={"feh --no-fehbg --bg-center --bg-fill", "display -window root", "xli -fullscreen -onroot -quiet", "qiv --root_s", "wmsetbg -s -S", "Esetroot -scale", "xv -max -smooth -root -quit", "setwallpaper", "setroot"}

if strutil.strlen(settings.setroot) > 0
then
	cmd=settings.setroot .. " " .. image_path
else

for i,item in ipairs(programs)
do
	toks=strutil.TOKENIZER(item, "\\S")
	str=toks:next()
	path=filesys.find(str, process.getenv("PATH"))
	if strutil.strlen(path) > 0
	then
	cmd=path.." "..toks:remaining() .. " " .. image_path
	break
	end
end

--if the user has 'gesettings' installed, then assume they have a gnome desktop and set that too
path=filesys.find("gsettings", process.getenv("PATH"))
if strutil.strlen(path) > 0 then os.execute("gsettings set org.gnome.desktop.background picture-uri file://" .. image_path) end

end

if strutil.strlen(cmd) > 0
then
	print(cmd)
	os.execute(cmd)
else
	print("ERROR: no 'setroot' program found")
end

end

