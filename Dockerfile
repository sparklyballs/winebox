# set base os
FROM phusion/baseimage:0.9.16

# Set environment variables for my_init, terminal and apache
ENV DEBIAN_FRONTEND=noninteractive HOME="/root" LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

CMD ["/sbin/my_init"]

# Set the locale
RUN locale-gen en_US.UTF-8 && \

# set common wine configure options as a variable
common_configure="--without-hal \
--without-sane \
--without-xinerama \
--without-opencl \
--without-oss" && \

# set common build deps as a variable
build_depsC="gettext \
prelink \
gcc-multilib \
g++-multilib \
flex \
bison \" && \

# set 64bit build deps as a variable
build_deps64="libx11-xcb-dev:amd64 \
libfreetype6-dev:amd64 \
libxcursor-dev:amd64 \
libxi-dev:amd64 \
libxxf86vm-dev:amd64 \
libxrandr-dev:amd64 \
libxcomposite-dev:amd64 \
libglu1-mesa-dev:amd64 \
libosmesa6-dev:amd64 \
libxml2-dev:amd64 \
libxslt1-dev:amd64 \
libgnutls-dev:amd64 \
libjpeg-dev:amd64 \
libfontconfig1-dev:amd64 \
libtiff5-dev:amd64 \
libpcap-dev:amd64 \
libdbus-1-dev:amd64 \
libmpg123-dev:amd64 \
libv4l-dev:amd64 \
libldap2-dev:amd64 \
libopenal-dev:amd64 \
libcups2-dev:amd64 \
libgphoto2-2-dev:amd64 \
libgsm1-dev:amd64 \
liblcms2-dev:amd64 \
libcapi20-dev:amd64 \
libgstreamer-plugins-base0.10-dev:amd64 \
libncurses5-dev:amd64" && \

# set 32bit build deps as a variable
build_deps32="libx11-xcb-dev:i386 \
libfreetype6-dev:i386 \
libxcursor-dev:i386 \
libxi-dev:i386 \
libxxf86vm-dev:i386 \
libxrandr-dev:i386 \
libxcomposite-dev:i386 \
libglu1-mesa-dev:i386 \
libosmesa6-dev:i386 \
libxml2-dev:i386 \
libxslt1-dev:i386 \
libgnutls-dev:i386 \
libjpeg-dev:i386 \
libfontconfig1-dev:i386 \
libtiff5-dev:i386 \
libpcap-dev:i386 \
libdbus-1-dev:i386 \
libmpg123-dev:i386 \
libv4l-dev:i386 \
libldap2-dev:i386 \
libopenal-dev:i386 \
libcups2-dev:i386 \
libgphoto2-2-dev:i386 \
libgsm1-dev:i386 \
liblcms2-dev:i386 \
libcapi20-dev:i386 \
libncurses5-dev:i386" && \

# set useful tools deps as a variable
useful_tools="wget \
unrar \
unzip \
supervisor \
openjdk-7-jre-headless" && \

# set runtime deps as a variable
runtime_deps="" && \

# set 386 as additional architecture
dpkg --add-architecture i386 && \

# install build-deps , wget and other useful tools
apt-get update -qy && \
apt-get install \
$useful_tools \
$build_deps32 \
$build_deps64 \
$build_depsC -qy && \

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
$common_configure \
--enable-win64 && \
make && \
cd .. && \
cd wine32 && \
../configure \
$common_configure \
--without-x \
--without-freetype \
--with-wine64=../wine64 && \
make && \

# install wine32 and wine64
make install && \	
cd ../wine64 && \
make install && \

# clean up build dependencies
apt-get purge --remove \
$build_depsC \
$build_deps32 \
$build_deps64 -qy && \
apt-get autoremove -qy && \

# clean up
cd / && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


