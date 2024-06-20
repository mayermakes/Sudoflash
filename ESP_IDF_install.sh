#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"


echo -e "${GREEN}updating Linux dependencies${ENDCOLOR}"
sudo apt-get install git wget flex bison gperf python3 python3-pip python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0 
echo -e "${GREEN}creating directory for Installation:${ENDCOLOR}"
mkdir -p $HOME/esp && echo -e "${GREEN}directory created${ENDCOLOR}" || echo -e "${RED}directory already exists ${ENDCOLOR}"
echo -e "${GREEN}Cloning latest ESP-IDF Repo${ENDCOLOR}"
git clone -b v5.2.2 --recursive https://github.com/espressif/esp-idf.git $HOME/esp && echo -e "${GREEN}ESP idf downloaded${ENDCOLOR}" || echo -e "${RED}cannot reach github repo ${ENDCOLOR}" 
echo -e "${GREEN}make install script executable${ENDCOLOR}"
sudo chmod + x $HOME/esp/esp-idf/install.sh
echo -e "${GREEN}run installation${ENDCOLOR}"
sudo $HOME/esp/esp-idf/install.sh esp32s3 && echo -e "${GREEN}ESP idf installed${ENDCOLOR}" || echo -e "${RED}Error during installation -> check if $HOME/esp/esp-idf/./install.sh is set executable! ${ENDCOLOR}"
sudo python3 $HOME/esp/esp-idf/tools/idf_tools.py install && echo -e "${GREEN}Tools installed${ENDCOLOR}" || echo -e "${RED}Error during tool installation${ENDCOLOR}"
echo -e "${GREEN}make export script executable${ENDCOLOR}"
sudo chmod + x $HOME/esp/esp-idf/export.sh


