#!/bin/bash

#==================================================
# Instalação do ROS 2 (Jazzy) 
#==================================================
echo "ROS2 Jazzy"

sudo apt-get update
sudo apt-get install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

sudo apt-get install -y software-properties-common curl gnupg lsb-release
sudo add-apt-repository -y universe

# Baixa a chave do ROS
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

# Adiciona a fonte do ROS 2
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

echo "ROS 2 Jazzy e Simulation Tools"
sudo apt-get update
sudo apt-get install -y \
    ros-jazzy-desktop-full \
    ros-dev-tools \
    python3-colcon-common-extensions \
    git \
    python3-rosdep \
    python3-pip

# Inicializa rosdep se necessário
if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
    sudo rosdep init
fi
rosdep update

if ! grep -q "source /opt/ros/jazzy/setup.bash" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# ROS 2 Jazzy" >> ~/.bashrc
    echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
fi

sudo apt install python3-colcon-clean -y

sudo apt install python3-colcon-common-extensions -y
sudo apt install ros-jazzy-eigen3-cmake-module -y

pip install --user -U empy==3.3.4 pyros-genmsg setuptools==75.8.0 --break-system-packages
pip install -U colcon-common-extensions --break-system-packages

if [ $(grep -c "/opt/ros/jazzy/setup.bash" ~/.bashrc) -ne 1 ]; then
  source /opt/ros/jazzy/setup.bash && echo -e "\n# source ROS Jazzy\nsource /opt/ros/jazzy/setup.bash" >> ~/.bashrc
fi

if [ $(grep -c "COLCON_LOG_LEVEL" ~/.bashrc) -ne 1 ]; then
  echo -e "# reduce colcon spam\nexport COLCON_LOG_LEVEL=30" >> ~/.bashrc
fi

if [ $(grep -c "RCUTILS_COLORIZED_OUTPUT" ~/.bashrc) -ne 1 ]; then
  echo -e "# make logs colorful\nexport RCUTILS_COLORIZED_OUTPUT=1" >> ~/.bashrc
fi

if [ $(grep -c "RCUTILS_LOGGING_BUFFERED_STREAM" ~/.bashrc) -ne 1 ]; then
  echo -e "# force logging output to be buffered\nexport RCUTILS_LOGGING_BUFFERED_STREAM=1" >> ~/.bashrc
fi

if [ $(grep -c "RCUTILS_CONSOLE_OUTPUT_FORMAT" ~/.bashrc) -ne 1 ]; then
  echo -e "# format logs in terminal\nexport RCUTILS_CONSOLE_OUTPUT_FORMAT='[{severity}] [{time}] [{name}]: {message} ({function_name}() at {file_name}:{line_number})'" >> ~/.bashrc
fi

if [ $(grep -c "PYTHONWARNINGS" ~/.bashrc) -ne 1 ]; then
  echo -e "# reduce depraction warning spam in colcon\nexport PYTHONWARNINGS='ignore:::setuptools.command.install,ignore:::setuptools.command.easy_install,ignore:::pkg_resources'" >> ~/.bashrc
fi

if [ $(grep -c "ROS_DOMAIN_ID" ~/.bashrc) -ne 1 ]; then
  resp=0
  [[ -t 0 ]] && { read -p $'\e[1;32mChoice a number between 46 and 232 for ROS domain ID :\e[0m\n' resp ; }
  echo -e "# always set ROS domain id\nexport ROS_DOMAIN_ID="$resp"" >> ~/.bashrc
fi

if [ $(grep -c "ROS_LOCALHOST_ONLY" ~/.bashrc) -ne 1 ]; then
  echo -e "# always set ROS localhost only\nexport ROS_LOCALHOST_ONLY=0" >> ~/.bashrc
fi

if [ $(grep -c "/usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" ~/.bashrc) -ne 1 ]; then
  source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash && echo -e "# colcon tab completion\nsource /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc
fi
