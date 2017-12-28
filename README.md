# Media Center HAT
Resources for the Media Center HAT

# Set Up Media Center HAT
## Auto Installation
Just run the following script in a terminal window and the Media Center HAT will be automatically setup.
```bash
# Run this line and the Media Center HAT will be setup and installed
curl -sSL https://pisupp.ly/mediacentersoftware | sudo bash
```

ADD NOTES ABOUT HOW TO NAVIGATE AUTO INSTALLER? OR AUTO-CONFIG WITH DEFAULTS?

## Manual Installation

ADD CONTENT

## Notes

It is possible that eeprom is not programmed, or is programmed with different dt than does not match gpio sel jumper default configuration which is 12.
EEPROM shoud be programmed using dtbo for gpio12 file from drive. They can try to switch gpio sel jumper to position 18 and see if it works. If not they can try to
enable device tree in config.txt by putting SD into PC, adding two lines:

dtoverlay=lirc-rpi,gpio_in_pin=5,gpio_out_pin=6
dtoverlay=rpi-display,speed=32000000,rotate=90

# Thank you!

This software and product is based on and uses a number of open source libraries and we wanted to thank the creators here. This product wouldn't be possible without their efforts!

- [Notro FBTFT](https://github.com/notro/fbtft/wiki)
- [Watterott RPi-Display](https://github.com/watterott/RPi-Display)
- [Wiring Pi](http://wiringpi.com/)
- [Lirc](http://www.lirc.org/)
