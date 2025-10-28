import os
from pystyle import Colors, Colorate, Center, Write
import pyfiglet
import time

text = "Dear Wallpaper"
ascii_art = pyfiglet.figlet_format(text, font="slant")

styled_text = Colorate.Horizontal(Colors.blue_to_purple, ascii_art)
print(styled_text)

Write.Print("Initializing Secure Environment...\n", Colors.blue, interval=0.03)
time.sleep(0.5)
Write.Print("Dear Wallpaper: done building targets.\n\n", Colors.blue_to_purple, interval=0.02)

signature = Colorate.Horizontal(Colors.red_to_purple, "Dear Wallpaper - Powered by @El3tek")
print(Center.XCenter(signature))

os.chdir("Core/wallpaper_engine")
os.system("scons -j8 target=template_debug")
os.chdir("../..")