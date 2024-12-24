# get latest version and extract it
wget https://gitlab.freedesktop.org/mesa/mesa/-/archive/main/mesa-main.tar.gz
tar xf mesa-main.tar.gz
rm mesa-main.tar.gz
cd mesa-main

# install mesa dependencies
sudo pacman -S --needed make cmake git wget vulkan-tools mesa-utils meson clang gcc python python-packaging python-mako python-yaml flex bison

# apply patches
patch -p1 < ../dri3.patch
patch -p1 < ../fix-for-anon-file.patch
patch -p1 < ../fix-for-getprogname.patch

# install build dependencies
sudo pacman -S --needed zlib expat libdrm libx11 libxcb libxext libxdamage libxshmfence libxxf86vm libxrandr wayland wayland-protocols egl-wayland

# build and install
meson setup build -Dprefix=/usr -Dcpp_rtti=false -Dgbm=disabled -Dopengl=false -Dllvm=disabled -Dshared-llvm=disabled -Dplatforms=x11,wayland -Dgallium-drivers= -Dxmlconfig=disabled -Dvulkan-drivers=freedreno -Dfreedreno-kmds=msm,kgsl
meson compile -C build
meson install -C build --destdir=output

# determine architecture of cpu and set version code
if [[ $SHELL == *"fish"* ]]
then
  set arch $(uname -r)
  set version $(cat VERSION)
else
  arch=$(uname -r)
  version=$(cat VERSION)
fi

# create PKGBUILD
cd output
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
        mkdir -p \"${pkgdir}/usr/lib\"
        mkdir -p \"${pkgdir}/usr/share/vulkan/icd.d\"
        cp \"${srcdir}/usr/lib/libvulkan_freedreno.so\" \"${pkgdir}/usr/lib/libvulkan_freedreno.so\"
        cp \"${srcdir}/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json\" \"${pkgdir}/usr/share/vulkan/icd.d/freedreno_icd.aarch64.json\"
}" > PKGBUILD
makepkg
