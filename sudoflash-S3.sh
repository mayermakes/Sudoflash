#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"

cd "$(dirname "$0")"
SCRIPT_DIR="$(pwd)"
echo "Script directory: $SCRIPT_DIR"

#SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo -e "${GREEN}SUDOFLASH - a tool to Flash Linux to Sudosom-S3"
echo -e " may also work for other ESP32-S3 boards ${ENDCOLOR}"
echo -e "_______________________________________________"
echo -e "${RED}Binaries must be in the same folder as this script."
echo -e "ESP toolchain will be automatically installed/updated to: $HOME/esp/esp-idf/${ENDCOLOR}"

echo -e "${GREEN}updating Linux dependencies${ENDCOLOR}"
apt-get install git wget flex bison gperf python3 python3-pip python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0 
echo -e "${GREEN}creating directory for Installation:${ENDCOLOR}"
mkdir -p $HOME/esp && echo -e "${GREEN}directory created${ENDCOLOR}" || echo -e "${RED}directory already exists ${ENDCOLOR}"
echo -e "${GREEN}Cloning latest ESP-IDF Repo${ENDCOLOR}"
git clone -b v5.2.2 --recursive https://github.com/espressif/esp-idf.git $HOME/esp && echo -e "${GREEN}ESP idf downloaded${ENDCOLOR}" || echo -e "${RED}cannot reach github repo/ already cloned ${ENDCOLOR}" 
echo -e "${GREEN}make install script executable${ENDCOLOR}"
chmod +x $HOME/esp/esp-idf/install.sh
echo -e "${GREEN}run installation${ENDCOLOR}"
cd $HOME/esp/esp-idf/
. $HOME/esp/esp-idf/install.sh all && echo -e "${GREEN}ESP idf installed${ENDCOLOR}" || echo -e "${RED}Error during installation -> check if $HOME/esp/esp-idf/./install.sh is set executable! ${ENDCOLOR}"
python3 $HOME/esp/esp-idf/tools/idf_tools.py install && echo -e "${GREEN}Tools installed${ENDCOLOR}" || echo -e "${RED}Error during tool installation${ENDCOLOR}"
echo -e "${GREEN}make export script executable${ENDCOLOR}"
chmod +x $HOME/esp/esp-idf/export.sh
. $HOME/esp/esp-idf/export.sh && echo -e "${GREEN}toolchain activated${ENDCOLOR}" || echo -e "${RED}error during toolchain activation${ENDCOLOR}"

cd "$SCRIPT_DIR"

echo -e going back to : $SCRIPT_DIR
echo -e " Files present:"
echo -e "______________________________________________________"
ls
echo -e "______________________________________________________"
echo -e "${RED}Put your Sudosom in Download mode--> close Jumper (GPIO0 to GND)"
echo -e "and connect it to this computer(always connect both USB-C ports${ENDCOLOR}"
echo -e "----------------------------------------------------------------"

read -p "Enter the COM Port the UART is connected to [ttyUSB0]" -i "ttyUSB0" -e port

echo -e $port :  port set
read -p "bootloader file? [bootloader.bin]" -i "bootloader.bin" -e bootloader

echo -e $bootloader : bootloader set
read -p "network_adapter file? [network_adapter.bin]" -i "network_adapter.bin" -e network_adapter

echo -e $network_adapter : network_adapter set
read -p "partition-table file? [partition-table.bin]" -i "partition-table.bin" -e partition

echo -e $partition : partition-table set
read -p "xipImage file? [xipImage]" -i "xipImage" -e xipImage

echo -e $xipImage : xipImage set
read -p "rootfs.cramfs file? [rootfs.cramfs]" -i "rootfs.cramfs" -e rootfs

echo -e $rootfs : rootfs.cramfs set
read -p "etc.jffs2 file? [etc.jffs2]" -i "etc.jffs2" -e  jffs2

echo $jffs2 : etc.jffs2 set


python3 $HOME/esp/esp-idf/components/esptool_py/esptool/esptool.py --chip esp32s3 -p /dev/$port -b 921600 --before=default_reset --after=hard_reset write_flash 0x0 $bootloader 0x10000 $network_adapter 0x8000 $partition && echo -e "${GREEN}$partition flashed${ENDCOLOR}" || echo -e "${RED}FAIL${ENDCOLOR}"



python3 $HOME/esp/esp-idf/components/partition_table/parttool.py write_partition --partition-name linux --input $xipImage && echo -e "${GREEN}$xipImage flashed${ENDCOLOR}" || echo -e "${RED}FAIL${ENDCOLOR}"


python3 $HOME/esp/esp-idf/components/partition_table/parttool.py write_partition --partition-name rootfs --input $rootfs && echo -e "${GREEN}$rootfs flashed${ENDCOLOR}" || echo -e "${RED}FAIL${ENDCOLOR}"


python3 $HOME/esp/esp-idf/components/partition_table/parttool.py write_partition --partition-name etc --input $jffs2 && echo -e "${GREEN}$jffs2 flashed${ENDCOLOR}" || echo -e "${RED}FAIL${ENDCOLOR}"



echo -e "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo -e "${GREEN}finished. If all processes reported  flashed, the process has worked.${ENDCOLOR}"
echo -e "remove the jumper and reboot, a shell should boot on UART0"
echo -e "Use a terminal Emulator (putty) same tty port you used to flash @ 115200 baud"
echo -e "${RED}If you see only debug output ,you are connected to the physical wrong USB port!"
echo -e "If the shell is blank, try sending a few commands until it reacts.${ENDCOLOR}"
echo -e "have fun!"
