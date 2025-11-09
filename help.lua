function PrintHelp()
local str, i, item

print("")
print("wallpaper_mgr.lua [options]")
print("options:")
print("  -sources <comma separated list of sources>       list of sources to get images from, overriding the default list.")
print("  +sources <comma separated list of sources>       add sources to list (either add to default list, or a list supplied with -sources)")
print("  -list                                            list default sources.")
print("  -list-sources                                    list default sources.")
print("  -add <source>                                    add a source to the list of default sources.")
print("  -del <source>                                    remove an item from the list of default sources.")
print("  -rm <source>                                     remove an item from the list of default sources.")
print("  -remove <source>                                 remove an item from the list of default sources.")
print("  -disable <source>                                disable a source in the list of default sources.")
print("  -enable <source>                                 enable a source in the list of default sources.")
print("  -block <image url>                               block an image url so this image can never be used.")
print("  -block-curr                                      block the current image so it is never used.")
print("  -save-curr  <dest directory>                     save current image to a destination directory.")
print("  -fave-curr  <name>                               save current image to a favorites collection named '<name>'.")
print("  -save <url> <dest directory>                     save image at <url> to a destination directory.")
print("  -fave <url> <name>                               save image at <url> to a favorites collection named '<name>'.")
print("  -info                                            info on current image.")
print("  -title                                           title of current image (or URL if no title).")
print("  -setroot <program name>                          use specified program to set background.")
print("  -resolution <resolution>                         get images matching <resolution>")
print("  -exe_path <path>                                 colon-separated search path for 'setroot' programs. e.g. -exec_path /usr/X11R7/bin:/usr/bin")
print("  -res <resolution>                                get images matching <resolution>")
print("  -proxy <url>                                     use given proxy server")
print("  -filetypes <list>                                comma-seperated list of file extensions to accept from image sources, e.g. '.jpg,.jpeg' or 'jpg,jpeg'. Be wary that most sites return .jpg, so if you leave that out of the list, you will get few (or no) images. Default is '.jpg,.jpeg,.png'")
print("  -?                                               this help")
print("  -help                                            this help")
print("  --help                                           this help")
print("")
print("wallpaper_mgr.lua uses xrandr or 'xprop -root' to discover the size of the desktop, and downloads images close to that on sites that support multiple resolutions. If xrandr and xprop aren't available, and the user doesn't supply a resolution on the command line, then it defaults to 1920x1200.")
print("")
print("-sources and +sources do not effect the default list, they only apply for the current program invocation")
print("")
print("wallpaper_mgr.lua has a default list of sources consisting of:")
print("")

str=""
for i,item in ipairs(settings.default_sources)
do
str=str .. item .. ", "
end
print(str)

print("")
print("This list includes entries from all supported sites, and other things can be added from these sites by paying attention to the urls of the 'category' pages on each site.")
print("")
print("wallpapers can be pulled from a local directory with a source of the format 'local:<dir>'.");
print("wallpapers can be pull from previously saved 'faves' with a source of the format 'faves:<name>' (where 'name' is the category/collection-name).");
print("wallpapers selected from a 'playlist file' of urls using a source of the format 'playlist:<path>' where 'path' points to a file containing a list of urls.");
print("")
print("Wallpapers can be pulled from an ssh server using a source of the form: 'ssh:<host>/<path>'. 'host' must be an entry configured in the '~/.ssh/config' file and 'path' is a file path from the login directory. wallpaper_mgr will search in 'path' and one level of subfolders of 'path' for files ending in .jpeg, .jpg or .png, and picks one at random to use as wallpaper.")
print("")
print("Using either the -proxy command or setting the PROXY_SERVER environment variable allows setting a proxy server to use. Proxy server urls can be of the form:")
print("   https:<username>:<password>@<host>:<port>")
print("   socks:<username>:<password>@<host>:<port>")
print("   sshtunnel:<ssh host>")
print("<ssh host> is usually matching and entry in the ~/.ssh/config file")

end

