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

cd $BASE_DIR

#============================================
#                AUTODIFF
#============================================

echo "AUTODIFF"

rm -rf autodiff

git clone https://github.com/autodiff/autodiff.git
mkdir autodiff/build
cd autodiff/build

rm -rf *

cmake .. -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_INSTALL_PREFIX=/usr/local \
         -DAUTODIFF_BUILD_PYTHON=OFF 

make -j$(nproc)
sudo make install

cd $BASE_DIR

#============================================
#               REALSENSE
#============================================

echo "REALSENSE"

rm -rf librealsense

git clone https://github.com/IntelRealSense/librealsense.git
cd librealsense

sudo cp config/99-realsense-libusb.rules /etc/udev/rules.d/

sudo udevadm control --reload-rules && sudo udevadm trigger

mkdir build
cd build

cmake .. -DCMAKE_BUILD_TYPE=Release -DFORCE_RSUSB_BACKEND=true -DBUILD_EXAMPLES=true -DBUILD_GRAPHICAL_EXAMPLES=true

make -j$(nproc)

sudo make install

cd $THIS_DIR

#==========================================
#               GAZEBO-CLASSIC
#==========================================

echo "GAZEBO-CLASSIC"

rm -rf build

mkdir -p build
cd build

cmake .. -DCMAKE_INSTALL_PREFIX=~/gazebo_install -DCMAKE_BUILD_TYPE=Release

make -j$(nproc)

make install

sudo ldconfig

#===========================================
#               RUNTIME_ENV_CONFIG
#===========================================

cat << EOF > ~/gazebo_env.sh

#!/bin/bash

# 1. Configurações do Gazebo Local
export GAZEBO_PREFIX=~/gazebo_install
export PATH=$GAZEBO_PREFIX/bin:$PATH
export LD_LIBRARY_PATH=$GAZEBO_PREFIX/lib:$LD_LIBRARY_PATH
export GAZEBO_PLUGIN_PATH=$GAZEBO_PREFIX/lib/gazebo-11/plugins
export GAZEBO_RESOURCE_PATH=$GAZEBO_PREFIX/share/gazebo-11

# 2. Configurações do ROS e Workspace
source /opt/ros/jazzy/setup.bash
source ~/laser_uav_system_ws/install/setup.bash

# 3. Adiciona os Recursos do Projeto (Drones, Mundos)
export GAZEBO_RESOURCE_PATH=$GAZEBO_RESOURCE_PATH:~/laser_uav_system_ws/install/laser_gazebo_resources/share/laser_gazebo_resources
export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:~/laser_uav_system_ws/build/gazebo_plugins

# 4. Fix Gráfico
export QT_QPA_PLATFORM=xcb

EOF

chmod +x ~/gazebo_env.sh

echo "Finished"

# No Arquivo session.yaml do laser_uav_simulation adicionar no pre_window o comando source ~/gazebo_env.sh
# Necessário para o ROS enxergar as variáveis de ambiente

# No src do workspace aplicar o comando git clone https://github.com/ros-simulation/gazebo_ros_pkgs.git -b ros2
# antes de executar o colcon build padrão, executar colcon build --packages-up-to gazebo_ros_pkgs
# Garante que o sistema saiba que os plugins existam
