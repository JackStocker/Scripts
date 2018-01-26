#!/bin/sh
#Full system backup script

curDate=$(date +%d%m%Y)

tar cvpzf /media/RAID/Server/SysBackup_$curDate.tgz --exclude=/proc --exclude=/lost+found --exclude=/mnt --exclude=/sys --exclude=/media /
