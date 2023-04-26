AUTHOR
======

wallpaper_mgr.lua, libUseful-lua and libUseful are (C) 2022 Colum Paget. They are released under the Gnu Public License so you may do anything with them that the GPL allows.

Email: colums.projects@gmail.com

DISCLAIMER
==========

This is free software. It comes with no guarentees and I take no responsiblity if it makes your computer explode or opens a portal to the demon dimensions, or does anything at all, or doesn't.


LICENSE
=======

wallpaper_mgr.lua is released under the GPLv3.


SYNOPSIS
========

wallpaper_mgr.lua is a program that downloads randomly selected images from a list of sites that offer desktop wallpapers, and uses a 'setroot' program to display these on the X11 root window. It requires libUseful (https://github.com/ColumPaget/libUseful) and libUseful-lua (https://github.com/ColumPaget/libUseful-lua) to be installed. 

wallpaper_mgr.lua also tries to set the background on the gnome and mate desktops, using  the 'gsettings' or 'dconf' programs.


INSTALL
=======


```
make
make install
```

This will create a script called "wallpaper_mgr.lua" and copy it to /usr/local/bin. This script can then be run with `lua wallpaper_mgr.lua` or you can use linux's "binfmt" system to automatically invoke lua to run lua scripts.


USAGE
=====

```
wallpaper_mgr.lua [options]
options:
  -sources <comma separated list of sources>       list of sources to get images from, overriding the default list.
  +sources <comma separated list of sources>       append to list of sources.
  -list                                            list default sources.
  -add <source>                                    add a source to the list of default sources.
  -del <source>                                    remove an item from the list of default sources.
  -rm <source>                                     remove an item from the list of default sources.
  -remove <source>                                 remove an item from the list of default sources.
  -disable <source>                                disable a source in the list of default sources.
  -enable <source>                                 enable a source in the list of default sources.
  -block <image url>                               block an image url so this image can never be used.
  -block-curr                                      block the current image so it is never used.
  -save-curr  <dest directory>                     save current image to a destination directory.
  -fave-curr  <name>                               save current image to a favorites collection named '<name>'.
  -save <url> <dest directory>                     save image at <url> to a destination directory.
  -fave <url> <name>                               save image at <url> to a favorites collection named '<name>'.
  -info                                            info on current image.
  -title                                           title of current image (or URL if no title).
  -setroot <program name>                          use specified program to set background.
  -exe_path <path>                                 colon-seperated search path for 'setroot' executables. e.g. '-exe_path /usr/X11R7/bin:/usr/bin'.
  -resolution <resolution>                         get images matching <resolution>
  -res <resolution>                                get images matching <resolution>
  -?                                               this help
  -help                                            this help
  --help                                           this help
```


wallpaper_mgr.lua uses xrandr or 'xprop -root' to discover the size of the desktop, and downloads images close to that on sites that support multiple resolutions. If xrandr and xprop aren't available, and the user doesn't supply a resolution on the command line, then it defaults to 1920x1200.

wallpaper_mgr.lua searches for one of the following programs: "feh, display (image magick), xli, qiv, wmsetbg, Esetroot, xv, setwallpaper, setroot" to use for setting the desktop wallpaper. Alternatively the user can specify a program using the '-setroot' option. Unfortunately this likely won't work on GNOME, KDE and Enlightenment desktop systems, which don't have good support for programmatically setting the wallpaper. wallpaper_mgr.lua attempts a 'hail mary' use of the gsettings app to set the wallpaper under GNOME, and also attempts to use the same for the Cinnamon desktop. If dconf is installed, wallpaper_mgr.lua will use that to set background for the MATE desktop (this has been seen to work). 'Esetroot' should work on enlightenment based desktops (but has been seen not to). It should work fine on systems that use a window-manager like jwm, or vtwm, etc.

wallpaper_mgr.lua has a default list of sources consisting of:

   'bing:en-US, bing:en-GB, nasa:apod, wallpapers13:cities-wallpapers, wallpapers13:nature-wallpapers/beach-wallpapers, wallpapers13:nature-wallpapers/waterfalls-wallpapers, wallpapers13:nature-wallpapers/flowers-wallpapers, wallpapers13:nature-wallpapers/sunset-wallpapers, wallpapers13:other-topics-wallpapers/church-cathedral-wallpapers, wallpapers13:nature-wallpapers/landscapes-wallpapers, getwallpapers:ocean-scene-wallpaper, getwallpapers:nature-desktop-wallpapers-backgrounds, getwallpapers:milky-way-wallpaper-1920x1080, getwallpapers:1920x1080-hd-autumn-wallpapers, hipwallpapers:daily, suwalls:flowers, suwalls:beaches, suwalls:abstract, suwalls:nature, suwalls:space, chandra:stars, chandra:galaxy, esahubble:nebulae, esahubble:galaxies, esahubble:stars, esahubble:starclusters, wikimedia:Category:Commons_featured_desktop_backgrounds, wikimedia:Category:Hubble_images_of_galaxies, wikimedia:Category:Hubble_images_of_nebulae, wikimedia:User:Pfctdayelise/wallpapers, wikimedia:User:Miya/POTY/Nature_views2008, wikimedia:Lightning, wikimedia:Fog, wikimedia:Autumn, wikimedia:Sunset, wikimedia:Commons:Featured_pictures/Places/Other, wikimedia:Commons:Featured_pictures/Places/Architecture/Exteriors, wikimedia:Commons:Featured_pictures/Places/Architecture/Cityscapes.

This list includes entries from all supported sites, and other things can be added from these sites by paying attention to the urls of the 'category' pages on each site.


LOCAL SOURCES
=============

There are three types of 'local sources' that wallpaper_mgr.lua supports.


```
local:<dir>         pick files randomly from the directory <dir>
faves:<name>        pick files randomly from the favorites directory named <name>
playlist:<path>     pick files randomly from a list in 'playlist' file <path>
```

Favorites are images that have previously been stored with the '-fave' or '-fave-curr' options. They are generally stored under `~/.local/share/wallpaper/faves/` so:


```
wallpaper_mgr.lua -sources faves:autumn
```

will select a random image from the directory `~/.local/share/wallpaper/faves/`

specifying 'faves:' or 'faves:.' will result in selecting any image stored in any directory under `~/.local/share/wallpaper/faves/`


Playlist files can include http, https, geminii or SSH urls. SSH urls must be set up as hosts stored in the ssh .config file with an ssh key, so that they can log in without needing a password.

For example a playlist file might contain:


```
/home/user1/images/flowers.jpg
/home/user1/images/stars.jpg
https://myhost.com/backgrounds/matrix.jpg
ssh:storage/mybackground.jpg
ssh:storage/grand_canyon.jpg
```

if we then run:

```
wallpaper_mgr.lua -sources playlist:backgrounds.lst 
```

then a random file will be picked from the list and displayed.

If wallpaper_mgr.lua cannot download from the source it chooses, it attempts to 'fallback' to one of the local sources in the source list. Thus the `+sources` command can be used to append local sources to the default list, allowing images to be set from local sources if network sources are not available. e.g.


```
wallpaper_mgr.lua +sources local:/usr/share/backgrounds,faves:*
```




WIKIMEDIA SOURCES
=================

When using image pages listed on wikimedia care must be taken that these are really on wikimedia, not wikipedia or other sites in the wikiverse. Notice also that pages must include any 'category' component to their name, if one exists. 'Commons', 'User' and 'Category' pages must therefore be included as:


```
wikimedia:Commons:Featured_pictures/Places/Architecture/Exteriors
wikimedia:Category:Hubble_images_of_galaxies
wikimedia:User:Miya/POTY/Nature_views2008
```
