sudo apt update
sudo apt install -y ros-jazzy-diagnostic-updater

sudo apt install -y git libssl-dev libusb-1.0-0-dev \
    libudev-dev pkg-config libgtk-3-dev \
    libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev

INSTALL_DIR=$HOME/git/submodules
mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

rm -rf librealsense

git clone https://github.com/IntelRealSense/librealsense.git
cd librealsense

sudo cp config/99-realsense-libusb.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger

mkdir build
cd build

cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DFORCE_RSUSB_BACKEND=true \
    -DBUILD_EXAMPLES=true \
    -DBUILD_GRAPHICAL_EXAMPLES=true \
    -DBUILD_PYTHON_BINDINGS=bool:true \
    -DPYTHON_EXECUTABLE=$(which python3)

make -j$(nproc)

sudo make install

sudo ldconfig

echo "Realsense Instalado."
