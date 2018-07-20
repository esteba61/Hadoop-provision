#!/usr/bin/bash

function sudoAdmin {
	sudo -i
}

function hadoopUser {
	useradd hadoop	
	echo -e "hadoop" | (passwd --stdin hadoop)
}

function installTools {
	yum install -y java-1.8.0-openjdk-devel
	cat > /etc/hosts <<EOF
192.168.92.10 nodemasterx
192.168.92.11 nodea
192.168.92.12 nodeb
EOF

}

echo -e "------sudoAdmin------"
sudoAdmin
echo -e "------hadoopUser------"
hadoopUser
echo -e "------installTools------"
installTools
