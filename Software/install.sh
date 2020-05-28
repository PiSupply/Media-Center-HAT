#!/bin/bash

# ask y/n function
function ask()
{
  while true; do
    read -p "$1 y/n " REPLY

    case "$REPLY" in
      Y*|y*) return 0 ;;
      N*|n*) return 1 ;;
    esac
  done
}


function reboot_system()
{
  echo "Rebooting now..."
  reboot
  exit 0
}

function update_system()
{
  # run update
  apt-get -y update
}

#Get screen rotation from user input and then update /boot/config.txt with the changes
function screen_rotation()
{
  echo "Select one of the options below:"
  echo "[0] - Portrait"
  echo "[90] - Horizontal (Default)"
  echo "[180] - Portrait Reverse"
  echo "[270] - Horizontal Reverse"
  while true; do
          read -p "Option: " rotate
          if [[ "$rotate" == 0 ]] || [[ "$rotate" == 90 ]] || [[ "$rotate" == 180 ]] || [[ "$rotate" == 270 ]]; then
                  break
          fi
  done


  case $rotate in
    0)
      if grep -q "dtoverlay=media-center" /boot/config.txt
      then
        sed -i 's/dtoverlay=media-center,speed=32000000,rotate=.*/dtoverlay=media-center,speed=32000000,rotate='$rotate'/g' "/boot/config.txt"
      else
        cat >> /boot/config.txt <<EOF
dtoverlay=media-center,speed=32000000,rotate=$rotate
EOF
      fi
      if ! grep -q "dtparam=spi=on" "/boot/config.txt"; then
          cat >> /boot/config.txt <<EOF
dtparam=spi=on
EOF
      fi;;
    90)
    if cat /proc/device-tree/hat/product > /dev/null 2>&1; then
          echo "EEPROM Loaded"
          sed -i '/dtoverlay=media-center,speed=32000000,rotate=.*/d' "/boot/config.txt"
    else
          echo "EEPROM not loaded"
          echo "---Updating /boot/config.txt---"
          sed -i 's/dtoverlay=media-center,speed=32000000,rotate=.*/dtoverlay=media-center,speed=32000000,rotate='$rotate'/g' "/boot/config.txt"
    fi

    if ! grep -q "dtparam=spi=on" "/boot/config.txt"; then
        cat >> /boot/config.txt <<EOF
dtparam=spi=on
EOF
    fi ;;
    180)
    if grep -q "dtoverlay=media-center" /boot/config.txt
    then
      sed -i 's/dtoverlay=media-center,speed=32000000,rotate=.*/dtoverlay=media-center,speed=32000000,rotate='$rotate'/g' "/boot/config.txt"
    else
      cat >> /boot/config.txt <<EOF
dtoverlay=media-center,speed=32000000,rotate=$rotate
EOF
    fi
    if ! grep -q "dtparam=spi=on" "/boot/config.txt"; then
        cat >> /boot/config.txt <<EOF
dtparam=spi=on
EOF
    fi;;
    270)
    if grep -q "dtoverlay=media-center" /boot/config.txt
    then
      sed -i 's/dtoverlay=media-center,speed=32000000,rotate=.*/dtoverlay=media-center,speed=32000000,rotate='$rotate'/g' "/boot/config.txt"
    else
      cat >> /boot/config.txt <<EOF
dtoverlay=media-center,speed=32000000,rotate=$rotate
EOF
    fi
    if ! grep -q "dtparam=spi=on" "/boot/config.txt"; then
        cat >> /boot/config.txt <<EOF
dtparam=spi=on
EOF
    fi;;
  esac
}

function install_fbcp()
{
  echo "--- Installing fbcp ---"
  if grep "${osmc}" /etc/passwd >/dev/null 2>&1; then
    echo "Installing FBCP on OMSC"
    apt-get install rbp-userland-dev-osmc
  fi
  cd /tmp
  apt-get install -y git build-essential cmake
  git clone --depth=1 https://github.com/tasanakorn/rpi-fbcp
  mkdir -p rpi-fbcp/build
  cd rpi-fbcp/build
  cmake ..
  make
  install fbcp /usr/local/bin/fbcp
  cd ../..
  rm -r rpi-fbcp

  # ask for automatic startup
  if ask "Enable automatic startup of fbcp on boot?"; then
    echo "Note: The console output on the TFT display will be disabled."
    deactivate_console
    if grep "osmc" /etc/passwd >/dev/null 2>&1
    then
      sed -i -e '$i \sleep 10\nsudo fbcp &\n' /etc/rc.local
    else
      sed -i -e '$i \fbcp &\n' /etc/rc.local
    fi
  else
    sed -i '/fbcp &/d' /etc/rc.local
  fi
}

disable_fbcp()
{
  sed '/fbcp/d' /etc/rc.local

}

# update xorg.conf
function update_xorg()
{
if [[ -d /usr/share/X11/xorg.conf.d ]]; then
  echo "--- /usr/share/X11/xorg.conf.d/ ---"
  echo
  echo "-layout TFT"
  echo "-layout HDMI (Select for fbcp use)"
  echo "-layout HDMITFT"
  echo "When -layout is not set in lightdm, the first is used: TFT"

  cat > /usr/share/X11/xorg.conf.d/99-fbdev.conf <<EOF
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

  if [ "${rotate}" == "0" ]; then
    invertx="0"
    inverty="0"
    swapaxes="0"
    tmatrix="1 0 0 0 1 0 0 0 1"
  fi
  if [ "${rotate}" == "90" ]; then
    invertx="1"
    inverty="0"
    swapaxes="1"
    tmatrix="0 -1 1 1 0 0 0 0 1"
  fi
  if [ "${rotate}" == "180" ]; then
    invertx="1"
    inverty="1"
    swapaxes="0"
    tmatrix="-1 0 1 0 -1 1 0 0 1"
  fi
  if [ "${rotate}" == "270" ]; then
    invertx="0"
    inverty="1"
    swapaxes="1"
    tmatrix="0 1 0 -1 0 1 0 0 1"
  fi

  filename="/usr/share/X11/xorg.conf.d/99-ads7846-cal.conf"
  if [ ! -f $filename ]
  then
    touch $filename
  fi

  cat > /usr/share/X11/xorg.conf.d/99-ads7846-cal.conf <<EOF
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
  else
    echo "X Server not installed"
fi
}

# download and install xinput-calibrator
function install_xinputcalibrator()
{
  echo "--- Installing xinput-calibrator ---"
  echo

  cd ~

  sudo apt-get install xinput-calibrator -y

  filename="/etc/X11/Xsession.d/xinput_calibrator_pointercal"
  if [ ! -f $filename ]
  then
      touch $filename
  fi

  cat > /etc/X11/Xsession.d/xinput_calibrator_pointercal <<'EOF'
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

  # add touchpanel calibration to LXDE autostart
  if [ -f "/etc/xdg/lxsession/LXDE-pi/autostart" ]; then
    if grep -q "xinput_calibrator_pointercal" "/etc/xdg/lxsession/LXDE-pi/autostart"; then
      echo "xinput_calibrator already in LXDE autostart"
    else
      cat >> /etc/xdg/lxsession/LXDE-pi/autostart <<'EOF'
sudo /bin/sh /etc/X11/Xsession.d/xinput_calibrator_pointercal
EOF
    fi
  fi
}

function deactivate_xinputcalibrator()
{
  if grep -q "xinput_calibrator_pointercal" "/etc/xdg/lxsession/LXDE-pi/autostart"; then
    sed -i '/sudo \/bin\/sh \/etc\/X11\/Xsession.d\/xinput_calibrator_pointercal/d' /etc/xdg/lxsession/LXDE-pi/autostart
  fi
}

function update_lightdm()
{
if [[ -d /usr/share/X11/xorg.conf.d ]]; then
  echo "Select your prefered layout:"
  echo "1. TFT Output Only"
  echo "2. HDMI Output Only (select for fbcp)"
  echo "3. HDMI(Primary) & TFT(extension) "
  while true; do
    read -p "Option(1-3):" value
    if (("$value" < 4)); then
      if [[ "$value" == 1 ]] ; then
        sed -i 's/#xserver-layout=/xserver-layout=TFT/g' /etc/lightdm/lightdm.conf
        sed -i "/xserver-layout=*/c xserver-layout=TFT" /etc/lightdm/lightdm.conf
        #sed -i "55s/fb1/fb0/g" /usr/share/X11/xorg.conf.d/99-fbdev.conf
      elif [[ "$value" == 2 ]] ; then
        sed -i 's/#xserver-layout=/xserver-layout=HDMI/g' /etc/lightdm/lightdm.conf
        sed -i "/xserver-layout=*/c xserver-layout=HDMI" /etc/lightdm/lightdm.conf
      elif [[ "$value" == 3 ]] ; then
        sed -i 's/#xserver-layout=/xserver-layout=HDMITFT/g' /etc/lightdm/lightdm.conf
        sed -i "/xserver-layout=*/c xserver-layout=HDMITFT" /etc/lightdm/lightdm.conf
        #sed -i "55s/fb0/fb1/g" /usr/share/X11/xorg.conf.d/99-fbdev.conf
      fi
      break
    fi
  done
fi
}

function activate_console()
{
  # set parameters
  #  fonts: MINI4x6, ProFont6x11, VGA8x8 - note: newer FBTFT has no built-in fonts
  if [ -f "/boot/cmdline.txt" ]; then
    if ! grep -q "fbcon=map:10" "/boot/cmdline.txt"; then
      sed -i 's/rootwait/rootwait fbcon=map:10 fbcon=font:VGA8x8 consoleblank=0/g' "/boot/cmdline.txt"
    fi
  fi
}

function deactivate_console()
{
  if [ -f "/boot/cmdline.txt" ]; then
    sed -i 's/rootwait fbcon=map:10 fbcon=font:VGA8x8 consoleblank=0/rootwait/g' "/boot/cmdline.txt"
  fi
}

function update_configtxt_joy()
{
  echo "--- Configuring Joystick/Buttons ---"
  echo

  # Device Tree -> use GPIO-Key DT-Overlay
  if grep -q "dtoverlay=gpio-key" "/boot/config.txt"; then
    sed -i 's/dtoverlay=gpio-key,gpio=13,keycode=.*/dtoverlay=gpio-key,gpio=13,keycode=103,label="KEY_UP"/g' "/boot/config.txt"
    sed -i 's/dtoverlay=gpio-key,gpio=17,keycode=.*/dtoverlay=gpio-key,gpio=17,keycode=105,label="KEY_LEFT"/g' "/boot/config.txt"
    sed -i 's/dtoverlay=gpio-key,gpio=22,keycode=.*/dtoverlay=gpio-key,gpio=22,keycode=108,label="KEY_DOWN"/g' "/boot/config.txt"
    sed -i 's/dtoverlay=gpio-key,gpio=26,keycode=.*/dtoverlay=gpio-key,gpio=26,keycode=106,label="KEY_RIGHT"/g' "/boot/config.txt"
    sed -i 's/dtoverlay=gpio-key,gpio=27,keycode=.*/dtoverlay=gpio-key,gpio=27,keycode=28,label="KEY_ENTER"/g' "/boot/config.txt"
  else
    cat >> /boot/config.txt <<EOF
dtoverlay=gpio-key,gpio=13,keycode=103,label="KEY_UP"
dtoverlay=gpio-key,gpio=17,keycode=105,label="KEY_LEFT"
dtoverlay=gpio-key,gpio=22,keycode=108,label="KEY_DOWN"
dtoverlay=gpio-key,gpio=26,keycode=106,label="KEY_RIGHT"
dtoverlay=gpio-key,gpio=27,keycode=28,label="KEY_ENTER"
EOF

  fi
}

function configure_ir()
{
cat >> /boot/config.txt <<EOF
dtoverlay=gpio-ir,gpio_pin=5
EOF
if grep "${osmc}" /etc/passwd >/dev/null 2>&1; then
  wget https://raw.githubusercontent.com/PiSupply/Media-Center-HAT/master/Software/LIRC/OSMC/MCH-1-ir-remote.lircd.conf
  mv MCH-1-ir-remote.lircd.conf /etc/lirc/
else
  apt install lirc -y
  cp /etc/lirc/lirc_options.conf.dist /etc/lirc/lirc_options.conf
  apt install lirc -y
  sed -i "/driver =*/c driver = default" /etc/lirc/lirc_options.conf
  sed -i "/device =*/c device = /dev/lirc0" /etc/lirc/lirc_options.conf
  wget https://raw.githubusercontent.com/PiSupply/Media-Center-HAT/master/Software/LIRC/OSMC/MCH-1-ir-remote.lircd.conf
  mv MCH-1-ir-remote.lircd.conf /etc/lirc/lircd.conf
fi
}

# main function
update_system
screen_rotation
update_xorg
update_lightdm

if ask "Activate the console on the TFT display?"; then
  activate_console
else
  deactivate_console
fi

if ask "Install fbcp (Framebuffer Copy)?"; then
  install_fbcp
fi

if ask "Install xinput-calibrator?"; then
  install_xinputcalibrator
else
  deactivate_xinputcalibrator
fi

if ask "Enable onboard Joystick/Buttons?"; then
  update_configtxt_joy
fi

if ask "Configure MCH IR Remote?"; then
  configure_ir
fi

if ask "Reboot the system now?"; then
  reboot_system
fi
