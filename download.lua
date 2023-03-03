function GetWallpaper(url, source, title, description) 
local S, fname
local result=false

print("GET: "..url)

fname=settings.working_dir.."/current-wallpaper.jpg"
filesys.mkdirPath(fname)

S=stream.STREAM(url, "r")
if S ~= nil and S:getvalue("HTTP:ResponseCode")=="200"
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

