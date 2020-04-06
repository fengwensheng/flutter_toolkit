#!/system/bin/sh
export PATH=/system/bin:$PATH

mount -o rw,remount /system
mkdir /system/usr/Nightmare
busybox unzip /sdcard/Nightmare/Nightmare.zip -d /system/usr/Nightmare -o\n
chmod -R 0755 /system/usr/Nightmare/*