import os

os.chdir("Core/wallpaper_engine")
os.system("scons -j8 target=template_debug")
os.chdir("../..")