import os

os.chdir("gd_extensions/wallpaper_engine")
os.system("scons -j8 target=template_debug")
os.chdir("../..")