# Media Centre HAT Software

## Software Installation

**NOTE:** When using the Media Center HAT with the PiJuice HAT you will need to change the ID EEPROM address on the PiJuice to 0x52 otherwise both HAT's will conflict with each other and the Media Center HAT will not load the DT overlay file.

### Automated process

Just run the following script in a terminal window and the Media Center HAT will be automatically setup.
```bash
# Run this line and the Media Center HAT will be setup and installed
sudo su -c "bash <(wget -qO- https://pisupp.ly/mediacentersoftware)" root
```

alternatively from the command line:

```bash
git clone https://github.com/PiSupply/Media-Center-HAT.git
sudo bash Media-Centre-HAT/Software/install.sh
```

#### Screen Orientation
```text
Select one of the options below:
[0] - Portrait
[90] - Horizontal (Default)
[180] - Portrait Reverse
[270] - Horizontal Reverse
```
Reply with one of the following values: 0, 90, 180, 270

#### TFT Driver
```text
--- Updating /boot/config.txt ---

Please reboot the system after the installation.

--- Updating /etc/X11/xorg.conf.d ---

-layout TFT
-layout HDMI
-layout HDMITFT
When -layout is not set, the first is used: TFT
```

#### Console
```text
Activate the console on the TFT display? y/n
```
Reply with "Y"

#### Framebuffer (fbcp)
```text
Install fbcp (Framebuffer Copy)? y/n
```
Reply with "Y"

```text
To enable automatic startup of fbcp run:
sudo update-rc.d fbcp defaults
To disable automatic startup of fbcp run:
sudo update-rc.d fbcp remove
```

```text
Enable automatic startup of fbcp on boot? y/n
```
Reply with "Y"

```text
Note: The console output on the TFT display will be disabled.
Set screen blanking time to 10 minutes.
```

#### xinput-calibrator
```text
Install xinput-calibrator? y/n
```
Reply with "Y"

#### Joystick/buttons
```text
Enable onboard Joystick/Buttons? y/n
```
Reply with "Y"

#### MCH IR Remote
```text
Configure MCH IR Remote? y/n
```
Reply with "Y"

#### Reboot
```text
Reboot the system now? y/n
```
Reply with "Y"


### Manual process

#### Changing the screen orientation
If you wish to change the screen orientation without running the installation script you can change the following line in `/boot/config.txt`:

```text
dtoverlay=media-center,speed=32000000,rotate=0
```

and change rotate to 0, 90, 180 or 270.

#### Configure video driver
fbdev is an Xorg driver for framebuffer devices. You need to edit the file `/usr/share/X11/xorg.conf.d` and add the following:
```text
Section "ServerLayout"
    Identifier "TFT"
    Option "BlankTime" "10"
    Screen 0 "ScreenTFT"
EndSection

Section "ServerLayout"
    Identifier "HDMI"
    Option "BlankTime" "10"
    Screen 0 "ScreenHDMI"
EndSection

Section "ServerLayout"
    Identifier "HDMITFT"
    Option "BlankTime" "10"
    Screen 0 "ScreenHDMI"
    Screen 1 "ScreenTFT" RightOf "ScreenHDMI"
#   Screen 1 "ScreenTFT" LeftOf "ScreenHDMI"
#   Screen 1 "ScreenTFT" Above "ScreenHDMI"
#   Screen 1 "ScreenTFT" Below "ScreenHDMI"
#   Screen 1 "ScreenTFT" Relative "ScreenHDMI" x y
#   Screen 1 "ScreenTFT" Absolute x y
EndSection

Section "Screen"
    Identifier "ScreenHDMI"
    Monitor "MonitorHDMI"
    Device "DeviceHDMI"
Endsection

Section "Screen"
    Identifier "ScreenTFT"
    Monitor "MonitorTFT"
    Device "DeviceTFT"
Endsection

Section "Monitor"
    Identifier "MonitorHDMI"
Endsection

Section "Monitor"
    Identifier "MonitorTFT"
Endsection

Section "Device"
    Identifier "DeviceHDMI"
    Driver "fbturbo"
    Option "fbdev" "/dev/fb0"
    Option "SwapbuffersWait" "true"
EndSection

Section "Device"
    Identifier "DeviceTFT"
    Driver "fbturbo"
    Option "fbdev" "/dev/fb1"
EndSection
EOF
```
#### Touchscreen configuration
Edit the file `/usr/share/X11/xorg.conf.d/99-ads7846-cal.conf` and add the following:
```text
Section "InputClass"
  Identifier "calibration"
  MatchProduct "ADS7846 Touchscreen"
  Option "EmulateThirdButton" "1"
  Option "EmulateThirdButtonButton" "3"
  Option "EmulateThirdButtonTimeout" "1500"
  Option "EmulateThirdButtonMoveThreshold" "30"
  Option "InvertX" "$invertx"
  Option "InvertY" "$inverty"
  Option "SwapAxes" "$swapaxes"
  Option "TransformationMatrix" "$tmatrix"
EndSection
EOF
```
Where $invertx, inverty, $swapaxes and $tmatrix is replace with one of the following values depending on the screen orientation:
```text
0 degrees (Portrait)
invertx="0"
inverty="0"
swapaxes="0"
tmatrix="1 0 0 0 1 0 0 0 1"

90 degrees (Horizontal (Default))
invertx="1"
inverty="0"
swapaxes="1"
tmatrix="0 -1 1 1 0 0 0 0 1"

180 degrees (Portrait reverse)
invertx="1"
inverty="1"
swapaxes="0"
tmatrix="-1 0 1 0 -1 1 0 0 1"

270 degrees (Horizontal reverse)
invertx="0"
inverty="1"
swapaxes="1"
tmatrix="0 1 0 -1 0 1 0 0 1"
```

#### Install Xinput Calibrator
Xinput calibrator can be used to fine tune the touchscreen calibration for the screen.

```bash
sudo apt-get install xinput-calibrator -y
```

Point the values recorded of Xinput calibrator to `99-ads7846-cal.conf` file by editing `/etc/X11/Xsession.d/xinput_calibrator_pointercal` and adding the following:
```text
#!/bin/sh
PATH="/usr/bin:$PATH"
BINARY="xinput_calibrator"
CALFILE="/usr/share/X11/xorg.conf.d/99-ads7846-cal.conf"
LOGFILE="/var/log/xinput_calibrator.pointercal.log"

CALDATA=`grep -o 'Option[[:space:]]*"MinX".*' $CALFILE`
if [ ! -z "$CALDATA" ] ; then
    echo "Using calibration data stored in $CALFILE"
    exit 0
fi

CALDATA=`DISPLAY=:0.0 $BINARY --output-type xorg.conf.d --device 'ADS7846 Touchscreen' | tee $LOGFILE | grep -i 'MinX\|MaxX\|MinY\|MaxY'`
if [ ! -z "$CALDATA" ] ; then
    sed -i "/MinX/d;/MaxX/d;/MinY/d;/MaxY/d;/EndSection/d" "$CALFILE"
    cat >> "$CALFILE" <<EOD
$CALDATA
EndSection
EOD
    echo "Calibration data stored in $CALFILE (log in $LOGFILE)"
fi
EOF
```

Add touchpanel calibration to startup by editing `/etc/xdg/lxsession/LXDE-pi/autostart` and add the following line:
```text
sudo /bin/sh /etc/X11/Xsession.d/xinput_calibrator_pointercal
```
#### Update lightdm for Buster
Raspbian Buster uses lightdm to control the X server. We need to edit the `/etc/lightdm/lightdm.conf` file and edit the comment our line:
For TFT only:
`xserver-layout=TFT`

For HDMI only
`xserver-layout=HDMI`

For HDMI with TFT extended
`xserver-layout=HDMITFT`

#### Install fbcp
This program is used to copy the primary framebuffer copy to a secondary framebuffer. Usually to copy the output of the HDMI of the Raspberry Pi to a TFT display.

#### Activate the console
If you are using Raspbian Lite or booting to the command line in the Deskop version then you will need to activate the console display by editing `/boot/cmdline.txt` and add the following at the end of the file:
```text
rootwait fbcon=map:10 fbcon=font:VGA8x8 consoleblank=0
```

#### Configure dtoverlay for the buttons

The default configuration for the buttons and the joystick is to map to the arrow keys and to the enter key. Should you wish to alter the mapping you can change the mapping in `/boot/config.txt`

By default if you have enabled the joystick during install you should find the following:
```text
dtoverlay=gpio-key,gpio=13,keycode=103,label="KEY_UP"
dtoverlay=gpio-key,gpio=17,keycode=105,label="KEY_LEFT"
dtoverlay=gpio-key,gpio=22,keycode=108,label="KEY_DOWN"
dtoverlay=gpio-key,gpio=26,keycode=106,label="KEY_RIGHT"
dtoverlay=gpio-key,gpio=27,keycode=28,label="KEY_ENTER"
```

you can change the keycode and the label according to the [input-event-codes.h](https://github.com/torvalds/linux/blob/v4.12/include/uapi/linux/input-event-codes.h)

You can also temporarily configure the keys at runtime without needing to alter the main configuration file by running a command like:

```bash
sudo dtoverlay gpio-key gpio=13 keycode=59 label="KEY_F1"
```

This will map GPIO13 to the F1 key of the keyboard.

You can check that the mapping is what you expect by using the command line tool `evtest`. Simply install it via `apt-get install evtest` and run it. You will be prompted with something similar to:

```text
No device specified, trying to scan all of /dev/input/event*
Not running as root, no devices may be available.
Available devices:
/dev/input/event0:      1b.button
/dev/input/event1:      1a.button
/dev/input/event2:      16.button
/dev/input/event3:      11.button
/dev/input/event4:      d.button
/dev/input/event5:      ADS7846 Touchscreen
Select the device event number [0-5]:
```
In the case above the first 5 events are registered to each of the buttons.
1b for example is associated with GPIO 27. 0x1B is 27 in decimal, 0x1A is 26 and so on.

You can test each button by choosing the corresponding event from the list.
Press CTRL^C to terminate.

*Note that should you wish to use buttons which are wired in a different way than the ones we provided on the MCH you will need to take in consideration that you will need to use the `gpio_pull` option on the command you run. The default pull=2 is safer, of course, otherwise the line will float which may cause spurious readings. We use gpio_pull=0 because the MCH has hardware pullups and won't need to use the Raspberry Pi ones.*

*Example `sudo dtoverlay gpio-key gpio=21 keycode=4 label="KEY_4" gpio_pull=0` 2:up 1:down 0:none*


## LIRC configuration

Before you begin to install and configure LIRC you need to make sure that the gpio-ir driver is loaded by adding the followig line to the `/boot/config.txt` file:
```bash
dtoverlay=gpio-ir,gpio_pin=5
```

At the command line install Lirc:
```bash
sudo apt-get install lirc
```

Then edit `/etc/lirc/lirc_options.conf` and change:
```text
driver  = devinput
device  = auto
```

to:

```text
driver  = default
device  = /dev/lirc0
```

After a reboot you can test that the IR receiver is properly configured by running (*CTRL^C to interrupt*):

```bash
mode2 --driver default --device /dev/lirc0
```

and start pressing the buttons of a remote. You should get some output on screen like the following:

```text
space 1625
pulse 593
space 1650
pulse 598
space 538
pulse 601
space 1647
pulse 622
space 514
pulse 605
space 1670
pulse 577
space 559
pulse 571
```

You can now proceed to record the configuration of the IR remote you wish to use or use our default ones:
* MCH-1.lircd.conf
* MCH-2.lircd.conf

Save the original configuration file and copy the new one in it's place.
```bash
sudo mv /etc/lirc/lircd.conf /etc/lirc/lircd.conf.org
sudo cp ~/MCH-2.lircd.conf /etc/lirc/lircd.conf
```

Finally restart the service:
```bash
sudo systemctl restart lircd.service
```

### Train a new remote
You can train pretty much any IR remote to work with the MCH.
Run the following command and follow the instructions to generate a new lircd.conf.
```bash
sudo irrecord -n -d /dev/lirc0 ~/lircd.conf
```
Once done you will have to copy it to sudo `/etc/lirc/`

```bash
sudo cp ~/NEW-REMOTE.lircd.conf /etc/lirc/lircd.conf
```
Restart the service to get the new configuration running.

### User the MCH as a remote
With the MCH you can also control other appliances like TV sets, game consoles, media centres, etc.

To find out which IR remotes configurations are available run
```bash
irsend "" "" LIST
```
Then find out which control are available for the remote you intend to use:
```bash
irsend list MCH-2 ""
```
Which will show something like this
```text
0000000000ffa25d Power
0000000000ff629d Enter
0000000000ffe21d Mode
0000000000ff22dd CH-
0000000000ff02fd CH+
0000000000ffc23d EQ
0000000000ffe01f Previous
0000000000ffa857 Next
0000000000ff906f Play/Pause
0000000000ff6897 Vol-
0000000000ff9867 Vol+
0000000000ffb04f 0
0000000000ff30cf 1
0000000000ff18e7 2
0000000000ff7a85 3
0000000000ff10ef 4
0000000000ff38c7 5
0000000000ff5aa5 6
0000000000ff42bd 7
0000000000ff4ab5 8
0000000000ff52ad 9
```

Finally run the control you need:
```bash
irsend SEND_ONCE MCH-2 Power
```

### Troubleshooting
You should be able to check that all is working fine by issuing the following commands:

```bash
lsmod | grep lirc
```
```text
which should return something similar to this
lirc_rpi                9032  0
lirc_dev               10583  1 lirc_rpi
rc_core                24377  1 lirc_dev
```

```bash
ls /var/run/lirc/
```
```text
lircd  lircd.pid  lircm
```

```bash
mode2 --driver default --list-devices
```
```text
/dev/lirc0
```

```bash
dmesg | grep lirc
```
```text
[    3.134395] lirc_dev: IR Remote Control driver registered, major 243
[    3.148485] lirc_rpi: module is from the staging directory, the quality is unknown, you have been warned.
[    4.219536] lirc_rpi: auto-detected active low receiver on GPIO pin 5
[    4.220011] lirc_rpi lirc_rpi: lirc_dev: driver lirc_rpi registered at minor = 0
[    4.220017] lirc_rpi: driver registered!
[    6.345325] input: lircd-uinput as /devices/virtual/input/input1
```

```bash
sudo vcdbg log msg |& grep -v -E "(HDMI|gpioman|clock|brfs)"
```
```text
001444.756: *** Restart logging
001446.035: Read command line from file 'cmdline.txt'
dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=PARTUUID=17d7977b-02 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait quiet splash plymouth.ignore-serial-consoles
001755.940: Loading 'kernel7.img' to 0x8000 size 0x45e6c8
002069.795: No kernel trailer - assuming DT-capable
002073.619: Loading 'bcm2710-rpi-3-b.dtb' to 0x4666c8 size 0x44d8
002196.868: Loaded HAT overlay
002196.885: dtparam: i2c_arm=on
002206.431: dtparam: spi=off
002352.910: Loaded overlay 'lirc-rpi'
002352.926: dtparam: gpio_in_pin=5
002353.446: dtparam: gpio_out_pin=6
002354.009: dtparam: audio=on
002419.661: Loaded overlay 'rpi-display'
002419.677: dtparam: speed=32000000
002420.719: dtparam: rotate=270
003759.247: Device tree loaded to 0x2effb100 (size 0x4e31)
004897.205: vchiq_core: vchiq_init_state: slot_zero = 0xfad80000, is_master = 1
004906.638: TV service:host side not connected, dropping notification 0x00000002, 0x00000002, 0x00000009
```
