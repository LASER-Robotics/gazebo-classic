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

cd $BASE_DIR

#=========================================
#               LIVOX
#=========================================

echo "LIVOX"

rm -rf Livox-SDK2

git clone git@github.com:Livox-SDK/Livox-SDK2.git
cd Livox-SDK2

sed -i '1i #include <cstdint>' sdk_core/comm/define.h
sed -i '1i #include <cstdint>' sdk_core/logger_handler/file_manager.h
sed -i '1i #include <cstdint>' sdk_core/comm/comm_port.h
sed -i '1i #include <cstdint>' sdk_core/params_check.h
sed -i '1i #include <cstdint>' sdk_core/comm/sdk_protocol.h

mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)

sudo make install

sudo ldconfig

echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib' >> ~/.bashrc

cd $BASE_DIR

#=========================================
#               ACADOS
#=========================================

rm -rf acados 

git clone https://github.com/acados/acados.git
cd acados

git submodule update --recursive --init

mkdir -p build
cd build

cmake .. -DACADOS_WITH_QPOASES=ON -DCMAKE_INSTALL_PREFIX=..

make -j$(nproc)
make install

cd $THIS_DIR

#==========================================
#               GAZEBO-CLASSIC
#==========================================

echo "GAZEBO-CLASSIC"

rm -rf build

mkdir -p build
cd build

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH

cmake .. -DCMAKE_INSTALL_PREFIX=~/gazebo_install -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/usr/local -DPKG_CONFIG_PATH=/usr/local/lib/pkgconfig

make -j$(nproc)

make install

sudo ldconfig

sudo apt update

sudo apt install -y ros-jazzy-tinyxml-vendor ros-jazzy-tinyxml2-vendor


#===========================================
#               RUNTIME_ENV_CONFIG
#===========================================

cat << 'EOF' > ~/gazebo_env.sh

#!/bin/bash

# 1. Configurações do Gazebo Local
export GAZEBO_PREFIX="$HOME/gazebo_install"
export PATH="$GAZEBO_PREFIX/bin:$PATH"

export LD_LIBRARY_PATH="$GAZEBO_PREFIX/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"

export GAZEBO_PLUGIN_PATH="$GAZEBO_PREFIX/lib/gazebo-11/plugins"
export GAZEBO_RESOURCE_PATH="$GAZEBO_PREFIX/share/gazebo-11"

if [ -d "$GAZEBO_PREFIX/lib/cmake/gazebo-11" ]; then
    export gazebo_DIR="$GAZEBO_PREFIX/lib/cmake/gazebo-11"
else
    export gazebo_DIR="$GAZEBO_PREFIX/lib/cmake/gazebo"
fi

export CMAKE_PREFIX_PATH="$GAZEBO_PREFIX:$CMAKE_PREFIX_PATH"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$GAZEBO_PREFIX/lib/pkgconfig"

# 2. Configurações do ROS e Workspace
source /opt/ros/jazzy/setup.bash
source ~/laser_uav_system_ws/install/setup.bash

# 3. Adiciona os Recursos do Projeto (Drones, Mundos)
export GAZEBO_RESOURCE_PATH=$GAZEBO_RESOURCE_PATH:~/laser_uav_system_ws/install/laser_gazebo_resources/share/laser_gazebo_resources
export GAZEBO_PLUGIN_PATH="$GAZEBO_PLUGIN_PATH:$HOME/laser_uav_system_ws/install/gazebo_plugins/lib"

# 4. Fix Gráfico
export QT_QPA_PLATFORM=xcb

EOF

chmod +x ~/gazebo_env.sh

if ! grep -q "source ~/gazebo_env.sh" ~/.bashrc; then
    echo 'source ~/gazebo_env.sh' >> ~/.bashrc
    echo "Adicionado ao .bashrc"
fi

source ~/.bashrc

echo "Finished"

# No Arquivo session.yaml do laser_uav_simulation adicionar no pre_window o comando source ~/gazebo_env.sh
# Necessário para o ROS enxergar as variáveis de ambiente

# No src do workspace aplicar o comando git clone https://github.com/ros-simulation/gazebo_ros_pkgs.git -b ros2
# antes de executar o colcon build padrão, executar colcon build --packages-up-to gazebo_ros_pkgs
# Garante que o sistema saiba que os plugins existam
