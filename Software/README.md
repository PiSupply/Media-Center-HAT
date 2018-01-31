# Media Centre HAT Software

## Software Installation
### Automated process
Just run the following script in a terminal window and the Media Center HAT will be automatically setup.
```bash
# Run this line and the Media Center HAT will be setup and installed
curl -sSL https://pisupp.ly/mediacentersoftware | sudo bash
```

### Manual process

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


