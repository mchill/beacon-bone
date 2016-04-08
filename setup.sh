# Disable web services
sudo systemctl disable cloud9.service
sudo systemctl disable gateone.service
sudo systemctl disable bonescript.service
sudo systemctl disable bonescript.socket
sudo systemctl disable bonescript-autorun.service
sudo systemctl disable avahi-daemon.service
sudo systemctl disable gdm.service
sudo systemctl disable mpd.service

# Disable firewall
sudo apt-get -y install ufw
sudo ufw disable

# Synchronize internal server time
export TZ=America/New_York
sudo ntpdate pool.ntp.org
sudo apt-get -y install ntp-date

# Install development tools
sudo apt-get -y install build-essential nodejs

# Install noble dependencies
sudo apt-get -y install bluetooth bluez libbluetooth-dev libudev-dev

# Install Cairo dependencies
sudo apt-get -y install libcairo2-dev libjpeg8-dev libpango1.0-dev libgif-dev

# Install global npm dependencies
sudo npm install -g coffee-script mosca bunyan
