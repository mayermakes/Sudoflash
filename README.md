# Sudoflash
Flashing tool for Sudosom
CC-BY-SA
tested on Ubuntu 22.04LTS
may work with WSL under Win10- we do not support any non free (as in freedom) operating systems.

compatible with Sudosom-S3 ALPHA/BETA
may also work with other ESP32-S3 based boards.
use only at own risk

installation:
download files.
put into same folder as the binaries you need to flash.
esp-idf has to be installed on the system in path $HOME/esp/esp-idf (standard installation path)
please refer to the original documentation: https://docs.espressif.com/projects/esp-idf/en/latest/esp32s3/get-started/index.html
in terminal run:

sudo chmod +x sudoflash-S3.sh

usage:
Connect Esp32-S3 module via UART & native USB (best results with both ports connected at the same time)
open terminal in the folder containing binaries and sudoflash
run:

. ./sudoflash-S3.sh

follow instructions as prompted (filenames can be copy-pasted, they are listed in the terminal in the step before asked to enter specific filenames)
most common port is /dev/ttyUSB0

Video: https://youtu.be/sPnQViSGZeY

TODO: make a compile script possibly using zig https://www.youtube.com/watch?v=kuZIzL0K4o4
