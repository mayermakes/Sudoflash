#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"



SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "${GREEN}SUDOFLASH - a tool to Flash Linux to Sudosom-S3"
echo " may also work for other ESP32-S3 boards ${ENDCOLOR}"
echo "_______________________________________________"
echo "${RED}Binaries must be in the same folder as this script."
echo "toolchain must be installed in $HOME/esp/esp-idf/${ENDCOLOR}"


cd $HOME/esp/esp-idf/
sudo ./install.sh esp32s3
. $HOME/esp/esp-idf/export.sh
cd $SCRIPT_DIR

echo going back to : $SCRIPT_DIR
echo " Files present:"
echo "______________________________________________________"
ls
echo "______________________________________________________"
echo "${RED}Put your Sudosom in Download mode--> close Jumper (GPIO0 to GND)"
echo "and connect it to this computer(always connect both USB-C ports${ENDCOLOR}"
echo "----------------------------------------------------------------"

read -p "Enter the COM Port the UART is connected to [ttyUSB0]" port
port = ${port:-ttyUSB0}
echo $port : set
read -p "bootloader file? [bootloader.bin]" bootloader
bootloader = ${bootloader:-bootloader.bin}
echo $bootloader : bootloader set
read -p "network_adapter file? [network_adapter.bin]" network_adapter
network_adapter = ${network_adapter:-network_adapter.bin}
echo $network_adapter : network_adapter set
read -p "partition-table file? [partition-table.bin]" partition
partition = ${partition:-partition-table.bin}
echo $partition : partition-table set
read -p "xipImage file? [xipImage]" xipImage
xipImage = ${xipImage:-xipImage}
echo $xipImage : xipImage set
read -p "rootfs.cramfs file? [rootfs.cramfs]" rootfs
rootfs = ${rootfs:-rootfs.cramfs}
echo $rootfs : rootfs.cramfs set
read -p "etc.jffs2 file? [etc.jffs2]" jffs2
jffs2 = ${jffs2:-etc.jffs2}
echo $jffs2 : etc.jffs2 set


python $HOME/esp/esp-idf/components/esptool_py/esptool/esptool.py --chip esp32s3 -p /dev/$port -b 921600 --before=default_reset --after=hard_reset write_flash 0x0 $bootloader 0x10000 $network_adapter 0x8000 $partition
if [ $? -eq 0 ]; then
    echo "${GREEN}$partition flashed${ENDCOLOR}"
    echo "---------------------------------"
else
    echo "${RED}FAIL${ENDCOLOR}"


python $HOME/esp/esp-idf/components/partition_table/parttool.py write_partition --partition-name linux --input $xipImage
if [ $? -eq 0 ]; then
    echo "${GREEN}$xipImage flashed${ENDCOLOR}"
    echo "---------------------------------"
else
    echo "${RED}FAIL${ENDCOLOR}"


python $HOME/esp/esp-idf/components/partition_table/parttool.py write_partition --partition-name rootfs --input $rootfs
if [ $? -eq 0 ]; then
    echo "${GREEN}$rootfs flashed${ENDCOLOR}"
    echo "---------------------------------"
else
    echo "${RED}FAIL${ENDCOLOR}"

python $HOME/esp/esp-idf/components/partition_table/parttool.py write_partition --partition-name etc --input $jffs2
if [ $? -eq 0 ]; then
    echo "${GREEN}$jffs2 flashed${ENDCOLOR}"
    echo "---------------------------------"
else
    echo "${RED}FAIL${ENDCOLOR}"



echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "${GREEN}finished. If all processes reported  flashed, the process has worked.${ENDCOLOR}"
echo "remove the jumper and reboot, a shell should boot on UART0"
echo "Use a terminal Emulator (putty) same tty port you used to flash @ 115200 baud"
echo "${RED}If you see only debug output ,you are connected to the physical wrong USB port!"
echo "If the shell is blank, try sending a few ls commands until it reacts.${ENDCOLOR}"
echo "have fun!"
fi


