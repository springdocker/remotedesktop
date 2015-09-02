FROM centos:centos6
MAINTAINER springdocker

ENV TARGET=app

WORKDIR /$TARGET
RUN mkdir /opt/$TARGET && \
    mkdir /opt/$TARGET/conf && \
    mkdir /opt/$TARGET/data && \
    mkdir /var/$TARGET
COPY ./env ./env

RUN yum -y update && \
    yum -y install gnome-panel \
      xorg-x11-server-utils \
      xorg-x11-xinit \
      wget | true && \
    yum -y groupinstall "Japanese Support" | true

RUN echo 'LANG="ja_JP.UTF-8"' > /etc/sysconfig/i18n && \
    echo 'export LANG=ja_JP.UTF-8' >> ~/.bashrc && \
    echo 'export DISPLAY=:10' >> ~/.bashrc

RUN yum -y install firefox | true && \
    dbus-uuidgen > /var/lib/dbus/machine-id

RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm && \
    yum -y install xrdp tigervnc-server | true

RUN wget http://www.mail-archive.com/xrdp-devel@lists.sourceforge.net/msg00263/km-e0010411.ini && \
    cp km-e0010411.ini /etc/xrdp/km-0411.ini && \
    cp km-e0010411.ini /etc/xrdp/km-e0200411.ini && \
    cp km-e0010411.ini /etc/xrdp/km-e0210411.ini

COPY ./user ./user
RUN source ./user && \
    useradd ${RDP_USER} && \
    echo ${RDP_USER}:${RDP_PASS} | chpasswd && \
    \
    sed -ri "s/username=ask/username=${RDP_USER}/g" /etc/xrdp/xrdp.ini && \
    sed -ri "s/password=ask/password=${RDP_PASS}/g" /etc/xrdp/xrdp.ini && \
    sed -ri "s/port=-1/port=5910/g" /etc/xrdp/xrdp.ini && \
    \
    yes ${RDP_PASS} | /usr/bin/vncserver :10 > /dev/null 2>&1 && \
    /usr/bin/vncserver -kill :10  && \
    echo VNCSERVERS=\"2:${RDP_USER}\" >>  /etc/sysconfig/vncservers && \
    echo VNCSERVERARGS\[2\]=\"-SecurityTypes none -geometry 800x600 -nolisten tcp -localhost\" >>  /etc/sysconfig/vncservers

COPY bootstrap.sh /bootstrap.sh
RUN chmod +x /bootstrap.sh
CMD /bootstrap.sh
