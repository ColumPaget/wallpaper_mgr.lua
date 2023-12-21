
function XFCE4SetRoot(image_path)
local S, str, prop_name

S=process.PROCESS("xfconf-query --channel xfce4-desktop --list", "")
if S ~= nil
then
  prop_name=S:readln()
  while prop_name ~= nil
  do
     prop_name=strutil.trim(prop_name)
     if strutil.pmatch("/backdrop/*/last-image", prop_name) == true 
     then 
     str="xfconf-query --channel xfce4-desktop --property '" .. prop_name .. "' --set '" .. image_path .."'"
     os.execute(str)
     end

     prop_name=S:readln()
  end
end
end


function SetRoot(image_path)

local programs={"hsetroot -cover", "bgs -z ", "feh --no-fehbg --bg-center --bg-fill", "xsetbg -fill", "display -window root -backdrop", "gm display -window root -backdrop", "imlibsetroot -p c -s ", "xli -fullscreen -onroot -quiet", "qiv --root_s", "wmsetbg -s -S", "Esetroot -scale", "xv -max -smooth -root -quit", "setwallpaper", "setroot"}
local cmd, i, toks, item, str, path

--try to detect if anything went wrong with getting the image
if image_path==nil or filesys.size(image_path) < 100 then return end
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


-- if we found an x11 command then use it
if strutil.strlen(cmd) > 0 
then
cmd=string.gsub(cmd, "%(root_geometry%)", settings.resolution)
print("setting X11 root window with: "..cmd)
os.execute(cmd)
end


--if the user has 'gsettings' installed, then assume they have a gnome desktop and set that too
path=filesys.find("gsettings", process.getenv("PATH"))
if strutil.strlen(path) > 0 
then 
print("gsettings command found at ".. path ..". Setting background for gnome desktop")
os.execute("gsettings set org.gnome.desktop.background picture-uri file:///" .. image_path) 
print("gsettings command found at ".. path ..". Setting background for cinnamon desktop")
os.execute("gsettings set org.cinnamon.desktop.background picture-uri file:///" .. image_path) 
cmd="gsettings"
end

--if the user has 'dconf' installed, then assume they have a mate desktop and set that too
path=filesys.find("dconf", process.getenv("PATH"))
if strutil.strlen(path) > 0
then
print("deconf command found at " .. path ..". Setting background for mate desktop")
os.execute("dconf write /org/mate/desktop/background/picture-filename \"'" .. image_path .. "'\"") end
cmd="dconf"
end

path=filesys.find("xfconf-query", process.getenv("PATH"))
if strutil.strlen(path) > 0
then
print("xfconf-query command found at " .. path .. ". Setting background for xfce4 desktop")
XFCE4SetRoot(image_path)
cmd="xfconf-query"
end

if strutil.strlen(cmd) == 0 then print("ERROR: no suitable command found to set root window background") end

end

