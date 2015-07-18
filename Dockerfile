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

# set build deps as a variable
build_deps="gettext \
prelink \
gcc-multilib \
g++-multilib \
flex \
bison \
libx11-xcb-dev \
libfreetype6-dev \
libxcursor-dev \
libxi-dev \
libxxf86vm-dev \
libxrandr-dev \
libxcomposite-dev \
libglu1-mesa-dev \
libosmesa6-dev \
libxml2-dev \
libxslt1-dev \
libgnutls-dev \
libjpeg-dev \
libfontconfig1-dev \
libtiff5-dev \
libpcap-dev \
libdbus-1-dev \
libmpg123-dev \
libv4l-dev \
libldap2-dev \
libopenal-dev \
libcups2-dev \
libgphoto2-2-dev \
libgsm1-dev \
liblcms2-dev \
libcapi20-dev \
libgstreamer-plugins-base0.10-dev \
libncurses5-dev" && \

# set useful tools deps as a variable
useful_tools="wget \
unrar \
unzip \
supervisor \
openjdk-7-jre-headless" && \

# install build-deps , wget and other useful tools
apt-get update -qy && \
apt-get install \
$useful_tools \
$build_deps -qy && \

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

# clean up
cd / && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


