FROM centos:centos6
MAINTAINER springdocker
RUN yum -y update

RUN yum -y install gnome-panel | true
RUN yum -y install xorg-x11-server-utils | true
RUN yum -y install xorg-x11-xinit | true
RUN yum -y groupinstall "Japanese Support" | true
RUN yum -y install wget | true
RUN echo 'LANG="ja_JP.UTF-8"' > /etc/sysconfig/i18n
RUN echo 'export LANG=ja_JP.UTF-8' >> ~/.bashrc
RUN echo 'export DISPLAY=:10' >> ~/.bashrc
 
RUN yum -y install firefox | true
RUN dbus-uuidgen > /var/lib/dbus/machine-id
 
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
RUN yum -y install xrdp | true
RUN yum -y install tigervnc-server | true

RUN wget http://www.mail-archive.com/xrdp-devel@lists.sourceforge.net/msg00263/km-e0010411.ini
RUN cp km-e0010411.ini /etc/xrdp/km-0411.ini
RUN cp km-e0010411.ini /etc/xrdp/km-e0200411.ini
RUN cp km-e0010411.ini /etc/xrdp/km-e0210411.ini
RUN rm -f km-e0010411.ini

RUN adduser ${RDP_USER}
RUN echo '${RDP_USER}:${RDP_PASSWORD}' > pass.txt
RUN chpasswd < pass.txt
RUN rm -f pass.txt

RUN mv /etc/xrdp/xrdp.ini xrdp.ini
RUN cp xrdp.ini xrdp.ini.tmp; sed -e "s/username=ask/username=${RDP_USER}/g" xrdp.ini.tmp   > xrdp.ini
RUN cp xrdp.ini xrdp.ini.tmp; sed -e "s/password=ask/password=${RDP_PASSWORD}/g" xrdp.ini.tmp > xrdp.ini
RUN cp xrdp.ini xrdp.ini.tmp; sed -e "s/port=-1/port=5910/g" xrdp.ini.tmp > xrdp.ini
RUN rm xrdp.ini.tmp; cp xrdp.ini /etc/xrdp/

RUN yes ${RDP_PASSWORD} | /usr/bin/vncserver :10 > /dev/null 2>&1
RUN /usr/bin/vncserver -kill :10
RUN echo VNCSERVERS=\"2:${RDP_USER}\" >>  /etc/sysconfig/vncservers
RUN echo VNCSERVERARGS\[2\]=\"-SecurityTypes none -geometry 800x600 -nolisten tcp -localhost\" >>  /etc/sysconfig/vncservers

RUN mkdir /var/app/
COPY bootstrap.sh /bootstrap.sh
RUN chmod +x /bootstrap.sh
CMD /bootstrap.sh
