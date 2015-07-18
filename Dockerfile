# set base os
FROM phusion/baseimage:0.9.16

# Set environment variables for my_init, terminal and apache
ENV DEBIAN_FRONTEND=noninteractive HOME="/root" LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

CMD ["/sbin/my_init"]

# Add local files
ADD src/ /root/

# set workdir 
WORKDIR /

# Expose ports 
EXPOSE 6080 5900 3389

# Set the locale
RUN locale-gen en_US.UTF-8 && \

# set startup file
mv /root/firstrun.sh /etc/my_init.d/firstrun.sh && \
chmod +x /etc/my_init.d/firstrun.sh && \

# add repository for wine build-deps
add-apt-repository ppa:ubuntu-wine/ppa && \

# update apt
apt-get update -qq && \

# install wine64 build-deps
apt-get build-dep wine1.6 -qy && \

# install wine32 build-deps, wget and other useful tools 
apt-get install \
gcc-multilib \
g++-multilib \
openjdk-7-jre-headless \
wget \
unrar \
unzip -qy && \

# fetch wine source
cd /tmp && \
wget http://prdownloads.sourceforge.net/wine/wine-1.7.47.tar.bz2 && \
bzip2 -d wine-* && \
tar xvf wine-* && \
cd wine-* && \

# configure and make wine32 and wine64
mkdir wine32 wine64 && \
cd wine64 && \
../configure \
--enable-win64 && \
make && \
cd .. && \
cd wine32 && \
../configure \
--without-x \
--without-freetype \
--with-wine64=../wine64 && \
make && \

# install wine32 and wine64
make install && \	
cd ../wine64 && \
make install && \

# install mate desktop and rdp dependencies
mv /root/excludes /etc/dpkg/dpkg.cfg.d/excludes && \
apt-add-repository ppa:ubuntu-mate-dev/ppa && \
apt-add-repository ppa:ubuntu-mate-dev/trusty-mate && \
apt-get update -qq && \
apt-get install \
xrdp \
supervisor \
sudo \
net-tools \
x11vnc \
xvfb \
mate-desktop-environment-core -qy && \

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

# clean up
cd / && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
/usr/share/man /usr/share/groff /usr/share/info \
/usr/share/lintian /usr/share/linda /var/cache/man && \
(( find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true )) && \
(( find /usr/share/doc -empty|xargs rmdir || true ))


