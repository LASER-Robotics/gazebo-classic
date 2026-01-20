sudo apt update
sudo apt install python3-pip python3-vcstool python3-colcon-common-extensions git

pip install gitman inputs pyyaml --break-system-packages

sudo apt install ros-jazzy-eigen3-cmake-module ros-jazzy-mavlink ros-jazzy-pcl-conversions ros-jazzy-ros2bag ros-jazzy-rosbag2-storage-mcap libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libunwind-dev libgazebo-dev gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly

export PATH=$PATH:$HOME/.local/bin

gitman --version

cd $HOME/git/laser_uav_system
gitman install --force

mkdir -p $HOME/laser_uav_system_ws/src
cd $HOME/laser_uav_system_ws/src

ln -sf $HOME/git/laser_uav_system/ros_packages/* .

rm -rf px4_firmware  # Se existir aqui, removemos pois é compilado separado
rm -rf micro_xrce_dds_agent # Removemos o link, pois vamos compilar o agente real

cd $HOME/git/laser_uav_system/ros_packages/micro_xrce_dds_agent
mkdir -p build
cd build
cmake ..
make
sudo make install
sudo ldconfig /usr/local/lib/

cat <<'EOF' >> ~/.bashrc

# --- Configurações Laser UAV System (Adicionado via Script) ---
export MAKEFLAGS=-j4

# Variáveis do Drone
export UAV_NAME="uav1"
export UAV_TYPE="lr7pro"
export REAL_UAV="false"

# Acados e Bibliotecas
export ACADOS_SOURCE_DIR="$HOME/laser_uav_system_ws/src/laser_uav_controllers/acados"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$HOME/laser_uav_system_ws/src/laser_uav_controllers/acados/lib"

# Gazebo e PX4
export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:$HOME/laser_uav_system_ws/src/px4_firmware/build/px4_sitl_default/build_gazebo-classic
export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$HOME/laser_uav_system_ws/src/px4_firmware/Tools/simulation/gazebo-classic/sitl_gazebo-classic/models:$HOME/laser_uav_system_ws/src/laser_uav_simulation/models:$HOME/laser_uav_system_ws/src/laser_uav_simulation/core/models

# Source do Workspace
source ~/laser_uav_system_ws/install/setup.bash
EOF

source $HOME/.bashrc

cd ~/laser_uav_system_ws/src/laser_uav_controllers/acados

rm -rf build
mkdir build
cd build

cmake -DACADOS_WITH_QPOASES=ON -DCMAKE_INSTALL_PREFIX=".." ..

make install -j4

pip install --user kconfiglib jsonschema future "empy==3.3.4" packaging toml numpy --break-system-packages

cd ~/git/laser_uav_system/.gitman/px4_firmware-ROS2-

make clean
rm -rf build

DONT_RUN=1 make px4_sitl_default
DONT_RUN=1 make px4_sitl_default gazebo-classic

cd $HOME/laser_uav_system_ws
colcon build --symlink-install
