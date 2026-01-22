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

rm -rf px4_firmware 
rm -rf micro_xrce_dds_agent 


if [ ! -f "/usr/local/bin/MicroXRCEAgent" ]; then
    cd $HOME/git/laser_uav_system/ros_packages/micro_xrce_dds_agent
    mkdir -p build
    cd build
    cmake ..
    make
    sudo make install
    sudo ldconfig /usr/local/lib/
fi

if ! grep -q "Configurações Laser UAV System" ~/.bashrc; then
    cat <<'EOF' >> ~/.bashrc

# --- Configurações Laser UAV System ---
export MAKEFLAGS=-j4

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
PX4_BUILD_DIR="$HOME/git/laser_uav_system/.gitman/px4_firmware-ROS2-/build/px4_sitl_default/build_gazebo-classic"
PX4_TOOLS_DIR="$HOME/git/laser_uav_system/.gitman/px4_firmware-ROS2-/Tools/simulation/gazebo-classic/sitl_gazebo-classic"

# plugins do Gazebo
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PX4_BUILD_DIR
export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:$PX4_BUILD_DIR

# modelos 3D (Drone + Mundo)
export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$PX4_TOOLS_DIR/models:$HOME/laser_uav_system_ws/src/laser_uav_simulation/models:$HOME/laser_uav_system_ws/src/laser_uav_simulation/core/models

# Source do Workspace ROS
source ~/laser_uav_system_ws/install/setup.bash
EOF
fi

source $HOME/.bashrc

ACADOS_LIB="$HOME/laser_uav_system_ws/src/laser_uav_controllers/acados/lib/libacados.so"
if [ ! -f "$ACADOS_LIB" ]; then
    cd ~/laser_uav_system_ws/src/laser_uav_controllers/acados

    rm -rf build
    mkdir build
    cd build

    cmake -DACADOS_WITH_QPOASES=ON -DCMAKE_INSTALL_PREFIX=".." ..

    make install -j4

fi

PX4_BIN="$HOME/git/laser_uav_system/.gitman/px4_firmware-ROS2-/build/px4_sitl_default/bin/px4"
if [ ! -f "$PX4_BIN" ]; then
    pip install --user kconfiglib jsonschema future "empy==3.3.4" packaging toml numpy --break-system-packages

    cd ~/git/laser_uav_system/.gitman/px4_firmware-ROS2-

    make clean
    rm -rf build

    DONT_RUN=1 make px4_sitl_default
    DONT_RUN=1 make px4_sitl_default gazebo-classic
fi

cd $HOME/laser_uav_system_ws/src
git clone https://github.com/ros-simulation/gazebo_ros_pkgs.git -b ros2

TARGET_FILE="$HOME/laser_uav_system_ws/src/laser_uav_simulation/tmux/one_drone_test/session.yml"
ADDITION="source ~/gazebo_env.sh;"

echo ">>> Verificando arquivo session.yml..."

if [ ! -f "$TARGET_FILE" ]; then
    echo "Verifique se o caminho está correto ou se o repositório foi clonado."
    exit 1
fi

if grep -q "$ADDITION" "$TARGET_FILE"; then

else
    # 3. Aplica a alteração usando SED
    sed -i "s|pre_window: |pre_window: $ADDITION |" "$TARGET_FILE"
    
    echo ">>> Sucesso! Linha adicionada ao pre_window."
    echo ">>> Nova linha:"
    grep "pre_window" "$TARGET_FILE"
fi

cd $HOME/laser_uav_system_ws

colcon build --symlink-install --packages-up-to gazebo_ros_pkgs

colcon build --symlink-install
