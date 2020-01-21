#!/bin/bash -e

fastboot erase modemst1
fastboot erase modemst2
fastboot erase userdata
fastboot format cache
#fastboot reboot

