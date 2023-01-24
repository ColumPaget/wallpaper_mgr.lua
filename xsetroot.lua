

function SetRoot(image_path)

local programs={"hsetroot -cover", "bgs -z ", "feh --no-fehbg --bg-center --bg-fill", "xsetbg -fill", "display -window root -backdrop", "gm display -window root -backdrop", "imlibsetroot -p c -s ", "xli -fullscreen -onroot -quiet", "qiv --root_s", "wmsetbg -s -S", "Esetroot -scale", "xv -max -smooth -root -quit", "setwallpaper", "setroot"}
local cmd, i, toks, item, str, path

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

if strutil.strlen(cmd) > 0 then cmd=string.gsub(cmd, "%(root_geometry%)", settings.resolution)
else print("ERROR: no suitable command found to set root window background")
end

--if the user has 'gsettings' installed, then assume they have a gnome desktop and set that too
path=filesys.find("gsettings", process.getenv("PATH"))
if strutil.strlen(path) > 0 then os.execute("gsettings set org.gnome.desktop.background picture-uri file://" .. image_path) end

--if the user has 'dconf' installed, then assume they have a mate desktop and set that too
path=filesys.find("dconf", process.getenv("PATH"))
if strutil.strlen(path) > 0 then os.execute("dconf write /org/mate/desktop/background/picture-filename \"'" .. image_path .. "'\"") end


end

if strutil.strlen(cmd) > 0
then
	print(cmd)
	os.execute(cmd)
else
	print("ERROR: no 'setroot' program found")
end

end

