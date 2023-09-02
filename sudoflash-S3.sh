#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "SUDOFLASH - a tool to Flash Linux to Sudosom-S3"
echo " may also work for other ESP32-S3 boards "
echo "_______________________________________________"
echo "Binaries must be in the same folder as this script."
echo "toolchain must be installed in $HOME/esp/esp-idf/"


cd $HOME/esp/esp-idf/
sudo ./install.sh esp32s3
. $HOME/esp/esp-idf/export.sh
cd $SCRIPT_DIR

echo going back to : $SCRIPT_DIR
echo " Files present:"
echo "______________________________________________________"
ls
echo "______________________________________________________"
echo "Put your Sudosom in Download mode--> close Jumper (GPIO0 to GND)"
echo "and connect it to this computer(in doubt connect all USB-C ports"
echo "----------------------------------------------------------------"

read -p "Enter the COM Port the UART is connected to(F.E.: ttyUSB0)" port
echo $port : set
read -p "bootloader file?(bootloader.bin)" bootloader
echo $bootloader : bootloader set
read -p "network_adapter file?(network_adapter.bin)" network_adapter
echo $network_adapter : network_adapter set
read -p "partition-table file?(partition-table.bin)" partition
echo $partition : partition-table set
read -p "xipImage file?(xipImage)" xipImage
echo $xipImage : xipImage set
read -p "rootfs.cramfs file?(rootfs.cramfs)" rootfs
echo $rootfs : rootfs.cramfs set
read -p "etc.jffs2 file?(etc.jffs2)" jffs2
echo $jffs2 : etc.jffs2 set


python $HOME/esp/esp-idf/components/esptool_py/esptool/esptool.py --chip esp32s3 -p /dev/$port -b 921600 --before=default_reset --after=hard_reset write_flash 0x0 $bootloader 0x10000 $network_adapter 0x8000 $partition
echo "binaries flashed"
echo "---------------------------------"

python $HOME/esp/esp-idf/components/partition_table/parttool.py write_partition --partition-name linux --input $xipImage
echo "xipImage flashed"
echo "---------------------------------"

python $HOME/esp/esp-idf/components/partition_table/parttool.py write_partition --partition-name rootfs --input $rootfs
echo "rootfs flashed"
echo "---------------------------------"

python $HOME/esp/esp-idf/components/partition_table/parttool.py write_partition --partition-name etc --input $jffs2
echo "jffs2 flashed"
echo "---------------------------------"
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "finished. I hope this worked"
echo "remove the jumper and reboot, a shell should boot on UART0"
echo "Use a terminal Emulator (putty) same tty port you used to flash @ 115200 baud"
echo "have fun!"


