# set base os
FROM debian:wheezy

# Set environment variables
#ENV DEBIAN_FRONTEND=noninteractive HOME="/root" TERM=xterm

# add local files
ADD glibconfig.h.diff /tmp/

# install some prebuild packages
RUN apt-get update && \
apt-get install \
wget \
git -qy && \

# clone wine git repository 
cd /tmp && \
git clone git://source.winehq.org/git/wine.git /tmp/wine-git && \

# add ubuntu wine ppa repository
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F9CB8DB0 && \
echo "deb http://ppa.launchpad.net/ubuntu-wine/ppa/ubuntu trusty main" >> /etc/apt/sources.list && \
echo "deb-src http://ppa.launchpad.net/ubuntu-wine/ppa/ubuntu trusty main" >> /etc/apt/sources.list && \

# update apt and install misc packages
apt-get update -qq && \
apt-get install \
libsane-dev \
wine-gecko2.36 \
wine-mono4.5.6 \
libtiff4-dev -qy && \

# install main body of wine build-deps 
apt-get build-dep wine1.7 -y && \
apt-get install \
libgstreamer-plugins-base0.10-dev \
libhal-dev \
liblcms2-dev \
libosmesa6-dev \
ocl-icd-opencl-dev -qy && \

# install 32 bit dependencies
dpkg --add-architecture i386 && \
apt-get update -qq && \
apt-get install \
gcc-multilib \
libasound2-dev:i386 \
libgsm1-dev:i386 \
libjpeg8-dev:i386 \
liblcms2-dev:i386 \
libldap2-dev:i386 \
libmpg123-dev:i386 \
libopenal-dev:i386 \
libv4l-dev:i386 \
libx11-dev:i386 \
libxinerama-dev:i386 \
libxml2-dev:i386 \ 
zlib1g-dev:i386 -qy && \

# install more 32 bit dependencies
apt-get install \
libcapi20-dev:i386 \
libcups2:i386 \
libdbus-1-3:i386 \
libfontconfig:i386 \
libfreetype6:i386 \
libglu1-mesa:i386 \
libgnutls26:i386 \
libgphoto2-2:i386 \
libncurses5:i386 \
libosmesa6:i386 \
libsane:i386 \
libxcomposite1:i386 \
libxcursor1:i386 \
libxi6:i386 \
libxrandr2:i386 \
libxslt1.1:i386 \
ocl-icd-libopencl1:i386 -qy && \

# symlink some packages
cd /usr/lib/i386-linux-gnu && \
ln -s libcups.so.2 libcups.so && \
ln -s libexif.so.12 libexif.so && \
ln -s libfontconfig.so.1 libfontconfig.so && \
ln -s libfreetype.so.6 libfreetype.so && \
ln -s libGL.so.1 libGL.so && \
ln -s libGLU.so.1 libGLU.so && \
ln -s libgnutls.so.26 libgnutls.so && \
ln -s libgphoto2.so.2 libgphoto2.so && \
ln -s libgphoto2_port.so.0 libgphoto2_port.so && \
ln -s libOSMesa.so.6 libOSMesa.so && \
ln -s libsane.so.1 libsane.so && \
ln -s libtiff.so.4 libtiff.so && \
ln -s libXcomposite.so.1 libXcomposite.so && \
ln -s libXcursor.so.1 libXcursor.so && \
ln -s libXi.so.6 libXi.so && \ 
ln -s libXrandr.so.2 libXrandr.so && \
ln -s libXrender.so.1 libXrender.so && \
ln -s libxslt.so.1 libxslt.so && \
ln -s libXxf86vm.so.1 libXxf86vm.so && \
ln -s /lib/i386-linux-gnu/libdbus-1.so.3 libdbus-1.so && \
ln -s /lib/i386-linux-gnu/libpng12.so.0 libpng12.so && \
ln -s /lib/i386-linux-gnu/libtinfo.so.5 libtinfo.so && \
ln -s libpng12.so libpng.so && \
echo 'INPUT(libncurses.so.5 -ltinfo)' >libncurses.so && \

# install remaining dependencies
apt-get install \
libgstreamer-plugins-base0.10-0:i386  -qy && \

# more smylinking
cd /usr/lib/i386-linux-gnu && \
ln -s libgstapp-0.10.so.0 libgstapp-0.10.so && \
ln -s libgstbase-0.10.so.0 libgstbase-0.10.so && \
ln -s libgstreamer-0.10.so.0 libgstreamer-0.10.so && \
ln -s libgobject-2.0.so.0 libgobject-2.0.so && \
ln -s libgmodule-2.0.so.0 libgmodule-2.0.so && \
ln -s libgthread-2.0.so.0 libgthread-2.0.so && \
ln -s /lib/i386-linux-gnu/libglib-2.0.so.0 libglib-2.0.so && \

# apply gstreamer patch
cd /usr/lib/x86_64-linux-gnu/glib-2.0/include && \
patch </tmp/glibconfig.h.diff && \

# compile and install wine builds
cd /tmp && \
mkdir wine64 && \
cd wine64 && \
../wine-git/configure \
--without-hal \
--enable-win64 && \
make > make.log 2>&1 && \
cd .. && \
mkdir wine32 && \
cd wine32 && \
../wine-git/configure \
--without-hal \
--without-sane \
--without-pcap \
--with-wine64=../wine64 && \
make > make.log 2>&1 && \
make install && \
cd ../wine64 && \
make install && \

# clean up
cd / && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

