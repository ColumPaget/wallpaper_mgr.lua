

function URLListInit(name, type)
local mod={}

mod.name=name
mod.type=type
mod.items={}
mod.needs_save=false



mod.add=function(self, url, extra)
local S

--if we are passwd a blank or nil url, don't add
if strutil.strlen(url) == 0 then return false end

--if it already exists, don't add
if self.items[url] ~= nil 
then 
	TermOut:puts("add url ~c" .. url.. "~0 to ~e" .. self.name .. "~0... ~e~malready exists~0\n")
else
  TermOut:puts("add url ~c" .. url.. "~0 to ~e" .. self.name.."~0 ... ~gadded~0\n")
  if extra == nil then extra="" end
  self.items[url]=self.type..":"..extra
  self.needs_save=true
end

return true
end



mod.write_entry=function(self, S, url, extra)

    if extra==nil then extra="" end
    S:writeln("'"..url.."' "..extra.."\n")

end


mod.append=function(self, url, extra)
local S, str

if self:add(url) == true
then
  str=settings.working_dir.."/" .. self.name.. ".lst"
  S=stream.STREAM(str, "a")
  if S ~= nil
  then
    self:write_entry(S, url, extra)
    S:close()
    self.needs_save=false
    return true
  end
end

return false
end



mod.save=function(self)
local S, str, url, path

path=settings.working_dir.."/"..self.name..".lst+"
S=stream.STREAM(path, "w")
if S ~= nil
then

for url, extra in pairs(self.items)
do
self:write_entry(S, url, extra)
end

S:close()

filesys.rename(path, settings.working_dir .. "/".. self.name .. ".lst")
self.needs_save=false
end

return true
end



mod.load=function(self)
local S, str, toks, url, info

S=stream.STREAM(settings.working_dir.."/" .. self.name .. ".lst", "r")
if S ~= nil
then
  str=S:readln()
  while str ~= nil
  do
  str=strutil.trim(str)

  toks=strutil.TOKENIZER(str, "\\S", "Q")
  url=toks:next()
  info=toks:remaining()
  if info==nil then info="" end
  self.items[url]=self.type..":"..info
  
  str=S:readln()
  end
  S:close()
end

end


mod.check=function(self, url)
local i, item

if self.items[url] ~= nil then return true end

return false
end

mod:load()

return mod
end
