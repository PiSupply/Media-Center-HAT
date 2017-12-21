# Media-Center-HAT
Resources for the Media Center HAT

## Notes

It is possible that eeprom is not programmed, or is programmed with different dt than does not match gpio sel jumper default configuration which is 12.
EEPROM shoud be programmed using dtbo for gpio12 file from drive. They can try to switch gpio sel jumper to position 18 and see if it works. If not they can try to
enable device tree in config.txt by putting SD into PC, adding two lines:

dtoverlay=lirc-rpi,gpio_in_pin=5,gpio_out_pin=6
dtoverlay=rpi-display,speed=32000000,rotate=90
