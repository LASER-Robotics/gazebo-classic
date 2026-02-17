#!/bin/bash

# =========================================================
# GAZEBO CLASSIC
# =========================================================

set -e

sudo apt remove -y 'ros-jazzy-gazebo*' || true
sudo apt remove -y 'gazebo*' || true

# Dependências
sudo apt update
sudo apt install -y build-essential cmake pkg-config git \
    libprotoc-dev protobuf-compiler \
    libtinyxml2-dev libtinyxml-dev \
    libtbb-dev libboost-all-dev \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    libogre-1.9-dev libtar-dev libcurl4-openssl-dev 

source /opt/ros/jazzy/setup.bash

cd $HOME/git/gazebo-classic
rm -rf build
mkdir -p build
cd build

cmake .. \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="/usr/local;/opt/ros/jazzy" \
    -DBUILD_TESTING=OFF

make -j$(nproc)

sudo make install

sudo ldconfig

sudo apt install -y ros-jazzy-tinyxml-vendor ros-jazzy-tinyxml2-vendor

#if [ $(grep -c "/usr/share/gazebo/setup.sh" ~/.bashrc) -ne 1 ]; then
#  echo "source /usr/share/gazebo/setup.sh" >> ~/.bashrc
#fi

if ! grep -q "GAZEBO CLASSIC LOCAL" ~/.bashrc; then
cat <<EOF >> ~/.bashrc

# ===============================
# GAZEBO CLASSIC LOCAL
# ===============================
export GAZEBO_DIR=/usr/local
export CMAKE_PREFIX_PATH=/usr/local:\$CMAKE_PREFIX_PATH
export LD_LIBRARY_PATH=/usr/local/lib:\$LD_LIBRARY_PATH
export GAZEBO_PLUGIN_PATH=/usr/local/lib:\$GAZEBO_PLUGIN_PATH
export GAZEBO_MODEL_PATH=/usr/local/share/gazebo/models:\$GAZEBO_MODEL_PATH
export PATH=/usr/local/bin:\$PATH
EOF
fi
