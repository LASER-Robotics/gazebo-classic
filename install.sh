#!/bin/bash

set -e

BASE_DIR=~/git/submodules
GZ_DIR=$BASE_DIR/gazebo_deps
THIS_DIR=$(pwd)

mkdir -p $GZ_DIR

echo "Installing dependencies..."

sudo apt update
sudo apt install -y build-essential cmake pkg-config \
    libprotoc-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libuuid1 \
    uuid-dev \
    libfreeimage-dev \
    libtinyxml2-dev \
    libtinyxml-dev \
    libtbb-dev \
    libogre-1.9-dev \
    libgts-dev \
    libboost-all-dev \
    libjsoncpp-dev \
    libswscale-dev \
    libavformat-dev \
    libavcodec-dev \
    libzmq3-dev \
    libgts-dev \
    libltdl-dev \
    libtar-dev \
    libssl-dev \
    libudev-dev \
    libgtk-3-dev \
    libglfw3-dev \
    libglu1-mesa-dev \
    libqwt-qt5-dev \
    libgraphviz-dev \
    xsltproc

cd $GZ_DIR

echo " Verificando e apagando pastas antigas..."
    
    # Lista explícita de tudo que será instalado nessa pasta
    rm -rf ign-cmake
    rm -rf ign-math
    rm -rf ign-tools
    rm -rf ign-common
    rm -rf ign-msgs
    rm -rf gz-fuel-tools
    rm -rf ign-transport
    rm -rf sdformat
    
    echo " Limpeza concluída. Começando do zero."

#============================================
#               IGNITION_CMAKE
#============================================

echo "IGNITION_CMAKE"

git clone https://github.com/gazebosim/gz-cmake.git -b ign-cmake2 ign-cmake
mkdir ign-cmake/build
cd ign-cmake/build

rm -rf *

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local

make -j$(nproc)
sudo make install

cd $GZ_DIR

#============================================
#              IGNITION_MATH
#============================================

echo "IGNITION_MATH"

git clone https://github.com/gazebosim/gz-math.git -b ign-math6 ign-math
mkdir ign-math/build
cd ign-math/build

rm -rf *

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local

make -j$(nproc)
sudo make install

cd $GZ_DIR

#============================================
#           IGNITION_TOOLS
#============================================

echo "IGNITION_TOOLS"

git clone https://github.com/gazebosim/gz-tools.git -b ign-tools1 ign-tools
mkdir ign-tools/build
cd ign-tools/build

rm -rf *

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local

make -j$(nproc)
sudo make install

cd $GZ_DIR

#============================================
#           IGNITION_COMMON
#============================================

echo "IGNITION_COMMON"

git clone https://github.com/gazebosim/gz-common.git -b ign-common3 ign-common
mkdir ign-common/build
cd ign-common/build

rm -rf *

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local

make -j$(nproc)
sudo make install

cd $GZ_DIR

#============================================
#           IGNITION_MSGS
#============================================

echo "IGNITION_MSGS"

git clone https://github.com/gazebosim/gz-msgs.git -b ign-msgs5 ign-msgs
mkdir ign-msgs/build
cd ign-msgs/build

rm -rf *

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local

make -j$(nproc)
sudo make install

cd $GZ_DIR

#=============================================
#           GZ-FUEL-TOOLS
#=============================================

echo "GZ-FUEL-TOOLS"

git clone https://github.com/gazebosim/gz-fuel-tools.git -b ign-fuel-tools4
mkdir gz-fuel-tools/build
cd gz-fuel-tools/build

rm -rf *

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local

make -j$(nproc)
sudo make install

cd $GZ_DIR

#============================================
#           IGNITION_TRANSPORT
#============================================

echo "IGNITION_TRANSPORT"

git clone https://github.com/gazebosim/gz-transport.git -b ign-transport8 ign-transport
mkdir ign-transport/build
cd ign-transport/build

rm -rf *

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local

make -j$(nproc)
sudo make install

cd $GZ_DIR

#============================================
#           SDFORMAT
#============================================

echo "SDFORMAT"

git clone https://github.com/gazebosim/sdformat.git -b sdf9 sdformat
mkdir sdformat/build
cd sdformat/build

rm -rf *

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local

make -j$(nproc)
sudo make install

cd $THIS_DIR

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

source ~/.bashrc

echo "Finished"

# No src do workspace aplicar o comando git clone https://github.com/ros-simulation/gazebo_ros_pkgs.git -b ros2
# antes de executar o colcon build padrão, executar colcon build --packages-up-to gazebo_ros_pkgs
# Garante que o sistema saiba que os plugins existam
