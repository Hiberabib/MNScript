#!/bin/bash

#stop_daemon function
function stop_daemon {
    if pgrep -x 'hiberad' > /dev/null; then
        echo -e "${YELLOW}Attempting to stop hiberad${NC}"
        hibera-cli stop
        sleep 30
        if pgrep -x 'hiberad' > /dev/null; then
            echo -e "${RED}hiberad daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            sudo pkill -9 hiberad
            sleep 30
            if pgrep -x 'hiberad' > /dev/null; then
                echo -e "${RED}Can't stop hiberad! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}


echo "Your HIBERA Masternode Will be Updated To The Latest Version v1.0.1 Now" 
sudo apt-get -y install unzip

#remove crontab entry to prevent daemon from starting
crontab -l | grep -v 'hiberaauto.sh' | crontab -

#Stop hiberad by calling the stop_daemon function
stop_daemon

rm -rf /usr/local/bin/hibera*
mkdir BIB_1.0.1
cd BIB_1.0.1
wget https://github.com/Hiberabib/bib/releases/download/v1.0.1/BIB-1.0.1-ubuntu-daemon.tar.gz
tar -xzvf BIB-1.0.1-ubuntu-daemon.tar.gz
mv hiberad /usr/local/bin/hiberad
mv hibera-cli /usr/local/bin/hibera-cli
chmod +x /usr/local/bin/hibera*
rm -rf ~/.hibera/blocks
rm -rf ~/.hibera/chainstate
rm -rf ~/.hibera/sporks
rm -rf ~/.hibera/zerocoin
rm -rf ~/.hibera/peers.dat
cd ~/.hibera/
wget https://github.com/Hiberabib/bib/releases/download/v1.0.1/bootstrap.zip
unzip bootstrap.zip

cd ..
rm -rf ~/.hibera/bootstrap.zip ~/BIB_1.0.1

# add new nodes to config file
sed -i '/addnode/d' ~/.hibera/hibera.conf

echo "addnode=216.128.182.223
addnode=155.138.137.113
addnode=149.248.59.199
addnode=216.128.179.240
addnode=149.248.61.97
addnode=216.128.179.249" >> ~/.hibera/hibera.conf

#start hiberad
hiberad -daemon

printf '#!/bin/bash\nif [ ! -f "~/.hibera/hibera.pid" ]; then /usr/local/bin/hiberad -daemon ; fi' > /root/hiberaauto.sh
chmod -R 755 /root/hiberaauto.sh
#Setting auto start cron job for HIBERA
if ! crontab -l | grep "hiberaauto.sh"; then
    (crontab -l ; echo "*/5 * * * * /root/hiberaauto.sh")| crontab -
fi

echo "Masternode Updated!"
echo "Please wait a few minutes and start your Masternode again on your Local Wallet"