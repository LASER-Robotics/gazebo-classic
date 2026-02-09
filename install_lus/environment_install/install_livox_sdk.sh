#!/bin/bash

INSTALL_DIR=$HOME/git/submodules
mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

rm -rf Livox-SDK2

git clone https://github.com/Livox-SDK/Livox-SDK2.git
cd Livox-SDK2

sed -i '1i #include <cstdint>' sdk_core/comm/define.h
sed -i '1i #include <cstdint>' sdk_core/logger_handler/file_manager.h
sed -i '1i #include <cstdint>' sdk_core/comm/comm_port.h
sed -i '1i #include <cstdint>' sdk_core/params_check.h
sed -i '1i #include <cstdint>' sdk_core/comm/sdk_protocol.h

rm -rf build
mkdir build
cd build

cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)

sudo make install

sudo ldconfig

if [ $(grep -c "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/lib" ~/.bashrc) -eq 0 ]; then
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib' >> ~/.bashrc
fi

echo "Livox Instalado com Sucesso."
