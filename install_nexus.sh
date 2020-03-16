#!/bin/bash

USER=nexus
GROUP=nexus
SERVICE_NAME=nexus
WORK_DIR=/mnt/nexus_data/nexus
NEXUS_NAME=nexus
URL_SONATYPE=https://download.sonatype.com/nexus/3/latest-unix.tar.gz

sudo yum update -y
sudo yum install wget -y
sudo yum install java-1.8.0-openjdk.x86_64 -y

if  [ ! -d "$WORK_DIR" ];  then     
    echo "Carpeta WORK_DIR ya existe"
    sudo mkdir $WORK_DIR && cd $WORK_DIR && mkdir sonatype-work
fi

#Validamos si ya existe la carpeta del instalador de nexus descargada
if  [ -d "$WORK_DIR/$NEXUS_NAME" ]; then
    echo "Carpeta NEXUS_NAME ya existe"
else
    sudo wget -O nexus.tar.gz $URL_SONATYPE
    sudo tar -xvf nexus.tar.gz
    sudo mv nexus-3* $NEXUS_NAME
fi

#Validamos si ya existe el usuario para nexus
if ! getent passwd $USER > /dev/null 2>&1; then
    sudo adduser $USER
    sudo chown -R $USER:$GROUP $WORK_DIR/$NEXUS_NAME
    sudo chown -R $USER:$GROUP $WORK_DIR/sonatype-work
fi

sudo echo  run_as_user="$USER" > $WORK_DIR/$NEXUS_NAME/bin/nexus.rc
sudo echo "$WORK_DIR/$NEXUS_NAME/etc/nexus.properties"

sudo echo "PRUEBA"
sudo cat <<EOF > $WORK_DIR/$NEXUS_NAME/etc/nexus.properties

## DO NOT EDIT - CUSTOMIZATIONS BELONG IN $WORK_DIR/$NEXUS_NAME/etc/nexus.properties
##
# Jetty section
application-port=8081
application-host=0.0.0.0
nexus-context-path=/

# Nexus section
nexus-edition=nexus-pro-edition
nexus-features=\
nexus-pro-feature
nexus.hazelcast.discovery.isEnabled=true

EOF


sudo echo "PRUEBA2"
#sudo touch /etc/systemd/system/$SERVICE_NAME.service
sudo cat <<EOF > /etc/systemd/system/$SERVICE_NAME.service
[Unit]
Description=nexus service
After=network.target
 
[Service]
Type=forking
LimitNOFILE=65536
User=$USER
Group=$GROUP
ExecStart=$WORK_DIR/$NEXUS_NAME/bin/nexus start
ExecStop=$WORK_DIR/$NEXUS_NAME/bin/nexus stop
User=$USER
Restart=on-abort
 
[Install]
WantedBy=multi-user.target

EOF

sudo chkconfig $SERVICE_NAME on

sudo systemctl start $SERVICE_NAME