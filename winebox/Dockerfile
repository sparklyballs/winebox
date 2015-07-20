# set base os
FROM sparklyballs/winebase

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive HOME="/root" TERM=xterm

# add local files
ADD src/ /root/

# set workdir 
WORKDIR /

# Expose ports 
EXPOSE 6080 5900 3389

# install packages
RUN apt-get update -qq && \
apt-get install \
--no-install-recommends \
supervisor \
openjdk-7-jre-headless \
xrdp \
sudo \
nano \
net-tools \
x11vnc \
gtk2-engines-murrine \
net-tools \
lxde \
xvfb -qy && \

# create ubuntu user
useradd --create-home --shell /bin/bash --user-group --groups adm,sudo ubuntu && \
echo "ubuntu:PASSWD" | chpasswd && \

# set user ubuntu to same uid and guid as nobody:users in unraid
usermod -u 99 ubuntu && \
usermod -g 100 ubuntu && \

# swap in modified xrdp.ini
mv /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.original && \
mv /root/xrdp.ini /etc/xrdp/xrdp.ini && \
chown root:root /etc/xrdp/xrdp.ini && \

# fix up start file and make executable
mv /root/start.sh /home/ubuntu/start.sh && \
chmod +x /home/ubuntu/start.sh && \

# clean up
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["/home/ubuntu/start.sh"]
