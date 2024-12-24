# Turnip Drivers for Arch Linux ARM
Script to generate DRI3 Mesa Turnip drivers for Arch Linux Arm

# Instructions
Run this command in your terminal:
```
wget https://raw.githubusercontent.com/jamlotrasoiaf/turnip-drivers-arch-arm/refs/heads/main/build.sh && chmod +x build.sh &&./build.sh
```
You should get a file called `mesa-vulkan-drivers-{VERSION}.pkg.tar.xz` in your working directory. Install it with `sudo pacman -U`. And you are done!
