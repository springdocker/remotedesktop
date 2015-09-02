#!/bin/bash

echo "ENTRY" > /var/app/log.txt
 
case ${APP_EXEC_MODE} in
  product)
    ;;
  develop)
    ;;
  *)
    ;;
esac

echo "PROCESS" >> /var/app/log.txt
source ~/.bashrc
firefox &

echo "PROCESS" >> /var/app/log.txt
/usr/sbin/xrdp-sesman
/usr/bin/vncserver :10
/usr/sbin/xrdp -nodaemon

echo "EXIT" >> /var/app/log.txt
