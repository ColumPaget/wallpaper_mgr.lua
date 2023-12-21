function GetWallpaperOpenURL(url)
local S

S=stream.STREAM(url, "r")
if S ~= nil
then
	if string.sub(url, 1, 5)=="http:" or string.sub(url, 1, 6)=="https:" 
	then
		if S:getvalue("HTTP:ResponseCode") ~= "200"
		then
			S:close()
			return(nil)
		end
  end
end

return S
end



function GetWallpaper(url, source, title, description) 
local S, fname
local result=false

if url==nil then return false end

print("GET: "..url)

fname=filesys.pathaddslash(settings.working_dir) .. "current-wallpaper.jpg"
filesys.mkdirPath(fname)

S=GetWallpaperOpenURL(url)
if S ~= nil
then
	if S:copy(fname) > 0 then result=true end
	S:close()

  if strutil.strlen(process.getenv("DISPLAY"))==0 then process.setenv("DISPLAY", ":0") end
  SetRoot(fname)

  S=stream.STREAM(settings.working_dir.."wallpapers.log", "a")
  if S ~= nil
  then
	  str=url.." source='"..source.."'"
	  if strutil.strlen(title) > 0 then str=str.." title='"..title.."'" end
	  str=str.."\n"
	  S:writeln(str)
	  S:close()
  end

  S=stream.STREAM(settings.working_dir.."wallpapers.curr", "w")
  if S ~= nil
  then
	  S:writeln("url: "..url.."\n")
	  S:writeln("source: "..source.."\n")
	  if strutil.strlen(title) > 0 then S:writeln("title: "..title.."\n") end
	  if strutil.strlen(description) > 0 then S:writeln("description: "..description.."\n") end
	  S:close()
  end
end


return result
end

