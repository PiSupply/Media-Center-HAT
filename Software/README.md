# Media Centre HAT Software

## Software Installation

*Note that the overlays needed for the MCH are only available as of Kernel 4.9.79. Before continuing with the installation make sure you are at the right kernel level*
*You can update to the right version by:*
```bash
sudo apt-get update && sudo apt-get upgrade
sudo rpi-update 5c80565c5c0c7f820258c792a98b56f22db2dd03
```

This update will provide the dtoverlay media-center and also add the dtoverlay gpio-key which enables the mapping of keyboard functions to the onboard buttons and joystick.

After the update is finished you can reboot and proceed with the rest of the installation.

If you need to run your system without updating as shown above please follow [these steps](https://github.com/PiSupply/Media-Center-HAT/tree/master/Software#additional-steps-for-older-kernels).

### Automated process

Just run the following script in a terminal window and the Media Center HAT will be automatically setup.
```bash
# Run this line and the Media Center HAT will be setup and installed
curl -sSL https://pisupp.ly/mediacentersoftware | sudo bash
```

alternatively from the command line:

```bash
git clone https://github.com/PiSupply/Media-Center-HAT.git
```

then:
```bash
sudo Media-Centre-HAT/Software/media-center.sh 0
```
Use:
* **0** for portrait (SD Card side)
* **90** for landscape (HDMI side)
* **180** for portrait (USB side)
* **270** for landscape (GPIO side)

#### TFT driver
```text
Enable TFT display driver and activate X windows on TFT display? y/n
```
Reply with "Y"
```text
--- Updating /boot/config.txt ---

Please reboot the system after the installation.

--- Updating /etc/X11/xorg.conf.d ---

startx -- -layout TFT
startx -- -layout HDMI
startx -- -layout HDMITFT
When -layout is not set, the first is used: TFT
```

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

#### Touchscreen library
```text
Install tslib (touchscreen library)? y/n
```
Reply with "N"

Finally reboot the system.

### Manual process

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

You can also temporarily konfigure the keys at runtime without needing to alter the main configuration file by running a command like:

```bash
sudo dtoverlay gpio-key gpio=13 keycode=59 label="KEY_F1"
```

This will map GPIO13 to the F1 key of the keuboard.

*Note that should you wish to use buttons which are wired in a different way than the ones we provided on the MCH you will need to take in consideration that you will need to use the `gpio_pull` option on the command you run. The default pull=2 is safer, of course, otherwise the line will float which may cause spurious readings. We use gpio_pull=0 because the MCH has hardware pullups and won't need to use the Raspberry Pi ones.*

*Example `sudo dtoverlay gpio-key gpio=21 keycode=4 label="KEY_4" gpio_pull=0` 2:up 1:down 0:none*

### Additional steps for older kernels

Should you not wish to update bare in mind that the installation will still enable the screen but with a default rotation of 90° despite running `sudo Media-Centre-HAT/Software/media-center.sh 0`.
In order to compensate this behaviour you will also need to change the installation script so that the touchscreen is not affected by this.

Change the `function update_xorg()` function in `Media-Centre-HAT/Software/media-center.sh` to

```text
  if [ "${rotate}" == "0" ]; then
    invertx="1"
    inverty="0"
    swapaxes="1"
    tmatrix="0 -1 1 1 0 0 0 0 1"
  fi
  if [ "${rotate}" == "90" ]; then
    invertx="1"
    inverty="1"
    swapaxes="0"
    tmatrix="-1 0 1 0 -1 1 0 0 1"
  fi
  if [ "${rotate}" == "180" ]; then
    invertx="0"
    inverty="1"
    swapaxes="1"
    tmatrix="0 1 0 -1 0 1 0 0 1"
  fi
  if [ "${rotate}" == "270" ]; then
    invertx="0"
    inverty="0"
    swapaxes="0"
    tmatrix="1 0 0 0 1 0 0 0 1"
  fi
```  

## Touchscreen calibration

You can launch the xinput_calibrator directly via the GUI:

![xinput_calibration](https://user-images.githubusercontent.com/16068311/36484231-77d98194-1710-11e8-8dc9-caaf13e0bd40.png "xinput_calibration")

or from a terminal within the GUI by running:
```bash
xinput_calibrator
```

or from an SSH session:

```bash
DISPLAY=:0 xinput_calibrator
```


## LIRC configuration

As of Stretch and Lirc 0.9.4 part of the configuration is done via the DT overlays. As the MCH has an onboard eeprom with a DT Blob in it the OS will load the right module on startup and will configure the GPIO pins correctly.

At the command line install Lirc:
```bash
sudo apt-get install lirc
```

Then edit `/etc/lirc/lirc_options.conf` and change:
```text
driver  = devinput
device  = auto
```
to
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


