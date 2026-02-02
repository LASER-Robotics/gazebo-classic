#!/bin/bash

# =========================================================
# GAZEBO CLASSIC
# =========================================================

# Dependências
sudo apt update
sudo apt install -y build-essential cmake pkg-config git \
    libprotoc-dev protobuf-compiler \
    libtinyxml2-dev libtinyxml-dev \
    libtbb-dev libboost-all-dev \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    libogre-1.9-dev libtar-dev libcurl4-openssl-dev \
    ros-jazzy-gazebo-dev ros-jazzy-gazebo-ros-pkgs

source /opt/ros/jazzy/setup.bash

cd $HOME/git/gazebo-classic
rm -rf build
mkdir -p build
cd build

cmake .. \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="/usr;/opt/ros/jazzy" \
    -DPKG_CONFIG_PATH=/usr/lib/pkgconfig:$PKG_CONFIG_PATH

make -j$(nproc)

sudo make install

sudo ldconfig

sudo apt install -y ros-jazzy-tinyxml-vendor ros-jazzy-tinyxml2-vendor

if [ $(grep -c "/usr/share/gazebo/setup.sh" ~/.bashrc) -ne 1 ]; then
  echo "source /usr/share/gazebo/setup.sh" >> ~/.bashrc
fi
