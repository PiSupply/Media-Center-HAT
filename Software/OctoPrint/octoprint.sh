#!/bin/bash

cd ~
sudo apt update
sudo apt install python-pip python-dev python-setuptools python-virtualenv git libyaml-dev build-essential
mkdir OctoPrint && cd OctoPrint
virtualenv venv
source venv/bin/activate
pip install pip --upgrade
pip install octoprint
sudo usermod -a -G tty pi
sudo usermod -a -G dialout pi
wget https://github.com/foosel/OctoPrint/raw/master/scripts/octoprint.init && sudo mv octoprint.init /etc/init.d/octoprint
wget https://github.com/foosel/OctoPrint/raw/master/scripts/octoprint.default && sudo mv octoprint.default /etc/default/octoprint
sudo chmod +x /etc/init.d/octoprint
sed -i 's/#DAEMON=/home/pi/OctoPrint/venv/bin/octoprint/DAEMON=/home/pi/OctoPrint/venv/bin/octoprint/g' /etc/default/octoprint

cat >> /etc/xdg/lxsession/LXDE-pi/autostart <<'EOF'
sudo bash /home/pi/octoprint_ui.sh
EOF
wget
sudo chmod+x octoprint_ui.sh

cd /tmp
apt-get install -y git build-essential cmake
git clone --depth=1 https://github.com/tasanakorn/rpi-fbcp
mkdir -p rpi-fbcp/build
cd rpi-fbcp/build
cmake ..
make
install fbcp /usr/local/bin/fbcp
cd ../..
sudo rm -r rpi-fbcp
sed -i '/fbcp &/d' /etc/rc.local

cat >> /boot/config.txt <<EOF
hdmi_group=2
hdmi_mode=4
EOF
