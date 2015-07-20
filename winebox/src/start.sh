#!/bin/bash

if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi

mkdir -p /home/ubuntu/unraid
mkdir -p /home/ubuntu/.config/pcmanfm/LXDE

if [ ! -f "/home/ubuntu/.config/pcmanfm/LXDE/desktop-items-0.conf" ]; then
cp  /root/desktop-items-0.conf /home/ubuntu/.config/pcmanfm/LXDE/desktop-items-0.conf
chown ubuntu:users /home/ubuntu/.config/pcmanfm/LXDE/desktop-items-0.conf
chmod 644 /home/ubuntu/.config/pcmanfm/LXDE/desktop-items-0.conf
fi

chown -R ubuntu:users /home/ubuntu/

mkdir  /var/run/sshd
mkdir  /root/.vnc
/usr/bin/supervisord -c /root/supervisord.conf
while [ 1 ]; do
/bin/bash
done
