
function ROXDesktopSetRoot(cmd, image_path)
local P, S, str, path


path=filesys.find("rox", process.getenv("PATH"))
if strutil.strlen(path) == 0 then path=filesys.find("roxfiler", process.getenv("PATH")) end
if strutil.strlen(path) == 0 then path=filesys.find("rox-filer", process.getenv("PATH")) end

if strutil.strlen(path) > 0
then
  P=process.PROCESS(path .. " --RPC", "")
  if P ~= nil
  then
  print("setting background for ROX desktop")
  str="<?xml version=\"1.0\"?>\n<env:Envelope xmlns:env=\"http://www.w3.org/2001/12/soap-envelope\">\n<env:Body xmlns=\"http://rox.sourceforge.net/SOAP/ROX-Filer\">\n<SetBackdrop>\n<Filename>" .. image_path .. "</Filename>\n<Style>Stretch</Style>\n</SetBackdrop>\n</env:Body>\n</env:Envelope>\n"
  P:send(str)
  P:flush()
  
  cmd="rox"
  end
end

return cmd
end


function XFCE4SetRoot(cmd, image_path)
local P, str, prop_name, path

path=filesys.find("xconf-query", process.getenv("PATH"))
if strutil.strlen(path) > 0
then
  P=process.PROCESS(path .. " --channel xfce4-desktop --list", "")
  if P ~= nil
  then
    prop_name=P:readln()
    while prop_name ~= nil
    do
       prop_name=strutil.trim(prop_name)
       if strutil.pmatch("/backdrop/*/last-image", prop_name) == true 
       then 
       str="xfconf-query --channel xfce4-desktop --property '" .. prop_name .. "' --set '" .. image_path .."'"
       print("setting background for XFCE desktop using: ".. str)
       os.execute(str)
       end
  
       prop_name=P:readln()
    end
   cmd="xfconf-query"
  end
end

return cmd
end


function GenericAppSetRoot(found, filename, invocation, title, image_path)
local path

--if the user has 'dconf' installed, then assume they have a mate desktop and set that too
path=filesys.find(filename, process.getenv("PATH"))
if strutil.strlen(path) > 0
then
print(filename .. " command found at " .. path ..". " .. title)
os.execute(path .. invocation ..  "\"" .. image_path .. "\"") 
found=filename
end

return found
end


function X11SetRootFindProgram()
local programs={"hsetroot -cover", "feh --no-fehbg --bg-center --bg-fill", "xsetbg -fill", "display -window root -backdrop", "gm display -window root -backdrop", "imlibsetroot -p c -s ", "xli -fullscreen -onroot -quiet", "qiv --root_s", "wmsetbg -s -S", "Esetroot -scale", "xv -max -smooth -root -quit", "setwallpaper", "setroot", "bgs -z "}
local i, item, toks, str, path, cmd

for i,item in ipairs(programs)
do
	toks=strutil.TOKENIZER(item, "\\S")
	str=toks:next()
	path=filesys.find(str, process.getenv("PATH"))
	if strutil.strlen(path) > 0
	then 
  cmd=path.." "..toks:remaining() .. " " 
	break
	end
end

return cmd
end


function X11SetRoot(image_path)
local cmd

if strutil.strlen(settings.setroot) > 0 then cmd=settings.setroot .. " " .. image_path
else cmd=X11SetRootFindProgram()
end

-- if we found an x11 command then use it
if strutil.strlen(cmd) > 0 
then
cmd=string.gsub(cmd, "%(root_geometry%)", settings.resolution)
print("setting X11 root window with: "..cmd)
os.execute(cmd .. image_path)
end

return cmd
end


function SetRoot(image_path)
local cmd, i, str, path

--try to detect if anything went wrong with getting the image
if image_path==nil or filesys.size(image_path) < 100 then return end

-- first try standard 'X11' background setters
cmd=X11SetRoot(image_path)

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

cmd=XFCE4SetRoot(cmd, image_path)
cmd=ROXDesktopSetRoot(cmd, image_path)

cmd=GenericAppSetRoot(cmd, "dconf",  " write /org/mate/desktop/background/picture-filename ", "Setting background for icewm desktop", "'" .. image_path .. "'")
cmd=GenericAppSetRoot(cmd, "icewmbg",  " -r -p -i ", "Setting background for icewm desktop", image_path)
cmd=GenericAppSetRoot(cmd, "zzzfm",  " --set-wallpaper ", "Setting background for zzzfm/antiX desktop", image_path)
cmd=GenericAppSetRoot(cmd, "spacefm", " --set-wallpaper ", "Setting background for spacefm desktop", image_path)
cmd=GenericAppSetRoot(cmd, "pcmanfm", " --wallpaper-mode=\"fit\" --set-wallpaper=", "Setting background for pcmanfm desktop", image_path)


if strutil.strlen(cmd) == 0 then print("ERROR: no suitable command found to set root window background") end

end

