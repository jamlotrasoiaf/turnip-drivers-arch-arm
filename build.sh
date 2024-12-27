#!/bin/bash

# okay im just here to say FISH DIE. RUINING MY PRETTY SCRIPT. MF

#install basics
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm base-devel make cmake git wget vulkan-tools mesa-utils meson clang gcc python python-packaging python-mako python-yaml flex bison

# get latest version and extract it
wget https://gitlab.freedesktop.org/mesa/mesa/-/archive/main/mesa-main.tar.gz
tar xf mesa-main.tar.gz
rm mesa-main.tar.gz
cd mesa-main

# apply patches
wget https://raw.githubusercontent.com/jamlotrasoiaf/turnip-drivers-arch-arm/refs/heads/main/dri3.patch
wget https://raw.githubusercontent.com/jamlotrasoiaf/turnip-drivers-arch-arm/refs/heads/main/fix-for-anon-file.patch
wget https://raw.githubusercontent.com/jamlotrasoiaf/turnip-drivers-arch-arm/refs/heads/main/fix-for-getprogname.patch
patch -p1 < dri3.patch
patch -p1 < fix-for-anon-file.patch
patch -p1 < fix-for-getprogname.patch
rm *.patch

# install build dependencies
sudo pacman -S --needed --noconfirm zlib expat libdrm libx11 libxcb libxext libxdamage libxshmfence libxxf86vm libxrandr wayland wayland-protocols egl-wayland

# build and install
meson setup build -Dprefix=/usr -Dcpp_rtti=false -Dgbm=disabled -Dopengl=false -Dllvm=disabled -Dshared-llvm=disabled -Dplatforms=x11,wayland -Dgallium-drivers= -Dxmlconfig=disabled -Dvulkan-drivers=freedreno -Dfreedreno-kmds=msm,kgsl
meson compile -C build
meson install -C build --destdir=output

# set cpu architecture and version code
arch="$(uname -m)"
long="$(cat VERSION)"
version="${long:0:6}"

# create PKGBUILD
cd build/output
tar czf usr.tar.gz usr/
rm -rf usr/

echo "pkgname=\"mesa-vulkan-drivers\"
pkgver=\"$version\"
pkgrel=1
pkgdesc=\"Mesa Freedreno Turnip Drivers\"
arch=('$arch')
license=('custom')
source=(\"usr.tar.gz\")
sha512sums=(\"SKIP\")

package() {
        tar xvf \"${srcdir}/usr.tar.gz\"
        rm \"${srcdir}/usr.tar.gz\"
        mkdir -p \"${pkgdir}/usr\"
        mv \"${srcdir}/usr/* \"${pkgdir}/usr/\"
}" > PKGBUILD
makepkg

# return to start, clean up dirs
mv *.tar.xz ../../../
rm -rf mesa-main/
