sudo apt update
sudo apt install python3-pip python3-vcstool python3-colcon-common-extensions git libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libdart-dev gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly  ros-jazzy-eigen3-cmake-module ros-jazzy-mavlink ros-jazzy-pcl-conversions ros-jazzy-ros2bag ros-jazzy-rosbag2-storage-mcap libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libunwind-dev libgazebo-dev gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly

pip install --user gitman inputs pyyaml  symforce pyros-genmsg lxml kconfiglib jsonschema future "empy==3.3.4" packaging toml numpy jinja2 --break-system-packages


export PATH=$PATH:$HOME/.local/bin

gitman --version

cd $HOME/git/laser_uav_system
gitman install --force

mkdir -p $HOME/laser_uav_system_ws/src
cd $HOME/laser_uav_system_ws/src

ln -sf $HOME/git/laser_uav_system/ros_packages/* .

rm -rf px4_firmware micro_xrce_dds_agent 

if [ ! -f "/usr/local/bin/MicroXRCEAgent" ]; then
    cd $HOME/git/laser_uav_system/ros_packages/micro_xrce_dds_agent
    mkdir -p build
    cd build
    cmake ..
    make
    sudo make install
    sudo ldconfig /usr/local/lib/
fi

ACADOS_LIB="$HOME/laser_uav_system_ws/src/laser_uav_controllers/acados/lib/libacados.so"
ACADOS_DIR="$HOME/laser_uav_system_ws/src/laser_uav_controllers/acados"
export ACADOS_SOURCE_DIR="$ACADOS_DIR"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$ACADOS_DIR/lib"

if [ ! -f "$ACADOS_LIB" ]; then
    cd ~/laser_uav_system_ws/src/laser_uav_controllers/acados

    git submodule update --recursive --init

    rm -rf build
    mkdir build
    cd build

    cmake -DACADOS_WITH_QPOASES=ON \
          -DACADOS_WITH_OSQP=OFF \
          -DACADOS_INSTALL_DIR=".." \
          -DBUILD_SHARED_LIBS=ON \
          ..

    make install -j$(nproc)

fi


sudo apt update
sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
sudo apt install gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav

if [ -f /usr/local/share/gazebo/setup.sh ]; then
    source /usr/local/share/gazebo/setup.sh
else
    source /usr/share/gazebo/setup.sh
fi

PX4_DIR="$HOME/git/laser_uav_system/ros_packages/px4_firmware"
if [ -d "$PX4_DIR" ]; then 
    cd $PX4_DIR
    
    rm -rf build
    make clean

    export CMAKE_PREFIX_PATH=/usr/local:$CMAKE_PREFIX_PATH
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
    export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
    
    DONT_RUN=1 make px4_sitl_default gazebo-classic -j$(nproc)

else
    echo "Diretório do PX4 não encontrado: $PX4_DIR"
    exit 1
fi

AUTODIFF_DIR="$HOME/laser_uav_system_ws/src/laser_uav_estimators/autodiff"
if [ -d "$AUTODIFF_DIR" ]; then
    cd $AUTODIFF_DIR
    git submodule update --recursive --init

    rm -rf build
    mkdir -p build
    cd build

    cmake -DAUTODIFF_BUILD_TESTS=OFF -DAUTODIFF_BUILD_PYTHON=OFF ..
    sudo make install -j$(nproc)

else
    echo "Diretorio do autodiff não encontrado: $AUTODIFF_DIR"
    exit 1
fi

export CMAKE_PREFIX_PATH=/usr/local:$CMAKE_PREFIX_PATH
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Variáveis do PX4 compilado
export PX4_BUILD_DIR="$PX4_DIR/build/px4_sitl_default/build_gazebo-classic"
export PX4_TOOLS_DIR="$PX4_DIR/Tools/simulation/gazebo-classic/sitl_gazebo-classic"
export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:$PX4_BUILD_DIR
export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$PX4_TOOLS_DIR/models



cd $HOME/laser_uav_system_ws/src
if [ ! -d "gazebo_ros_pkgs" ]; then
    git clone https://github.com/ros-simulation/gazebo_ros_pkgs.git -b ros2
fi

if ! grep -q "Configurações Laser UAV System" ~/.bashrc; then
    cat <<'EOF' >> ~/.bashrc

# --- Configurações Laser UAV System ---

export MAKEFLAGS=-j4

export QT_QPA_PLATFORM=xcb


# Variáveis do Drone

export UAV_NAME="uav1"

export UAV_TYPE="lr7pro"

export REAL_UAV="false"


# Configurações de Log e Rede ROS 2 (Seus adicionais)

export COLCON_LOG_LEVEL=30

export RCUTILS_COLORIZED_OUTPUT=1

export RCUTILS_LOGGING_BUFFERED_STREAM=1

export RCUTILS_CONSOLE_OUTPUT_FORMAT='[{severity}] [{time}] [{name}]: {message} ({function_name}() at {file_name}:{line_number})'

export PYTHONWARNINGS='ignore:::setuptools.command.install,ignore:::setuptools.command.easy_install,ignore:::pkg_resources'

export ROS_DOMAIN_ID=168

export ROS_LOCALHOST_ONLY=0


# Configuração do Acados

export ACADOS_SOURCE_DIR="$HOME/laser_uav_system_ws/src/laser_uav_controllers/acados"

# Acados

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$HOME/laser_uav_system_ws/src/laser_uav_controllers/acados/lib"


# Configuração do Gazebo + PX4

# PX4 compilado

export PX4_DIR="$HOME/git/laser_uav_system/ros_packages/px4_firmware"
export PX4_BUILD_DIR="$PX4_DIR/build/px4_sitl_default/build_gazebo-classic"
export PX4_TOOLS_DIR="$PX4_DIR/Tools/simulation/gazebo-classic/sitl_gazebo-classic"


export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PX4_BUILD_DIR

export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:$PX4_BUILD_DIR


# modelos 3D (Drone + Mundo)

export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$PX4_TOOLS_DIR/models:$HOME/laser_uav_system_ws/src/laser_uav_simulation/models:$HOME/laser_uav_system_ws/src/laser_uav_simulation/core/models


# Source do Workspace ROS

source /usr/local/share/gazebo/setup.bash
source /opt/ros/jazzy/setup.bash
source ~/laser_uav_system_ws/install/setup.bash 
EOF
fi

source $HOME/.bashrc

cd $HOME/laser_uav_system_ws
source /opt/ros/jazzy/setup.bash

rm -rf build install log

colcon build --symlink-install --packages-up-to gazebo_ros_pkgs

source install/setup.bash

colcon build --symlink-install

source install/setup.bash
