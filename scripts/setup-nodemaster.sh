#!/usr/bin/bash

function sudoAdmin {
	sudo -i
}

function hadoopUser {
	useradd hadoop	
	echo -e "hadoop" | (passwd --stdin hadoop)
}

function installTools {
	yum install -y java-1.8.0-openjdk-devel sshpass
	cat > /etc/hosts <<EOF
192.168.92.10 nodemasterx
192.168.92.11 nodea
192.168.92.12 nodeb
EOF
}

function sshkey {
	sshpass -p 'hadoop' ssh -o StrictHostKeyChecking=no hadoop@nodemasterx 'ssh-keygen -b 4096 -N "" -f /home/hadoop/.ssh/id_rsa'
	sshpass -p 'hadoop' ssh-copy-id -o StrictHostKeyChecking=no -i /home/hadoop/.ssh/id_rsa.pub hadoop@nodemasterx
	sshpass -p 'hadoop' ssh-copy-id -o StrictHostKeyChecking=no -i /home/hadoop/.ssh/id_rsa.pub hadoop@nodea
	sshpass -p 'hadoop' ssh-copy-id -o StrictHostKeyChecking=no -i /home/hadoop/.ssh/id_rsa.pub hadoop@nodeb
}

function downloadHadoop {
	su -l hadoop -c "wget http://apache.uniminuto.edu/hadoop/common/hadoop-3.0.2/hadoop-3.0.2.tar.gz > .null;
	tar -xzf hadoop-3.0.2.tar.gz > .null;
	mv hadoop-3.0.2 hadoop"
}

function setEnvVar {
	echo "export HADOOP_HOME=/home/hadoop/hadoop
export HADOOP_MAPRED_HOME=\$HADOOP_HOME
export HADOOP_COMMON_HOME=\$HADOOP_HOME
export HADOOP_HDFS_HOME=\$HADOOP_HOME
export YARN_HOME=\$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:\$HADOOP_HOME/bin
export LD_LIBRARY_PATH=/home/hadoop/hadoop/lib/native/:\$LD_LIBRARY_PATH
export HADOOP_INSTALL=\$HADOOP_HOME
PATH=/home/hadoop/hadoop/bin:/home/hadoop/hadoop/sbin:\$PATH" >> /home/hadoop/.bashrc
	source /home/hadoop/.bashrc
	sed -i "s/# export JAVA_HOME=.*/export JAVA_HOME=\/usr\/lib\/jvm\/java-1.8.0-openjdk\/jre/" /home/hadoop/hadoop/etc/hadoop/hadoop-env.sh
}

function setCore-site {

	sed -i "s/<configuration>.*/<configuration>\n	<property>\n		<name>fs.default.name<\/name>\n		<value>hdfs:\/\/nodemasterx:9000<\/value>\n	<\/property>/" /home/hadoop/hadoop/etc/hadoop/core-site.xml
}

function setHdfs-site {

	sed -i "s/<configuration>.*/<configuration>\n	<property>\n		<name>dfs.namenode.name.dir<\/name>\n		<value>\/home\/hadoop\/data\/nameNode<\/value>\n	<\/property>\n	<property>\n		<name>dfs.datanode.data.dir<\/name>\n		<value>\/home\/hadoop\/data\/dataNode<\/value>\n	<\/property>\n	<property>\n		<name>dfs.replication<\/name>\n		<value>1<\/value>\n	<\/property>/" /home/hadoop/hadoop/etc/hadoop/hdfs-site.xml
}

function setMapred-site {

	sed -i "s/<configuration>.*/<configuration>\n	<property>\n		<name>yarn.app.mapreduce.am.env<\/name>\n		<value>HADOOP_MAPRED_HOME=\/home\/hadoop\/hadoop<\/value>\n	<\/property>\n	<property>\n		<name>mapreduce.map.env<\/name>\n		<value>HADOOP_MAPRED_HOME=\/home\/hadoop\/hadoop<\/value>\n	<\/property>\n	<property>\n		<name>mapreduce.reduce.env<\/name>\n		<value>HADOOP_MAPRED_HOME=\/home\/hadoop\/hadoop<\/value>\n	<\/property>\n	<property>\n		<name>mapreduce.framework.name<\/name>\n		<value>yarn<\/value>\n	<\/property>\n	<property>\n		<name>yarn.app.mapreduce.am.resource.mb<\/name>\n		<value>512<\/value>\n	<\/property>\n	<property>\n		<name>mapreduce.map.memory.mb<\/name>\n		<value>256<\/value>\n	<\/property>\n	<property>\n		<name>mapreduce.reduce.memory.mb<\/name>\n		<value>256<\/value>\n	<\/property>/" /home/hadoop/hadoop/etc/hadoop/mapred-site.xml
}

function setYarn-site {

	sed -i "s/<configuration>.*/<configuration>\n	<property>\n		<name>yarn.acl.enable<\/name>\n		<value>0<\/value>\n	<\/property>\n	<property>\n		<name>yarn.resourcemanager.hostname<\/name>\n		<value>nodemasterx<\/value>\n	<\/property>\n	<property>\n		<name>yarn.nodemanager.aux-services<\/name>\n		<value>mapreduce_shuffle<\/value>\n	<\/property>\n	<property>\n		<name>yarn.nodemanager.resource.memory-mb<\/name>\n		<value>1536<\/value>\n	<\/property>\n	<property>\n		<name>yarn.scheduler.maximum-allocation-mb<\/name>\n		<value>1536<\/value>\n	<\/property>\n	<property>\n		<name>yarn.scheduler.minimum-allocation-mb<\/name>\n		<value>128<\/value>\n	<\/property>\n	<property>\n		<name>yarn.nodemanager.vmem-check-enabled<\/name>\n		<value>false<\/value>\n	<\/property>/" /home/hadoop/hadoop/etc/hadoop/yarn-site.xml
}

function addWorkers {

	echo "nodea
nodeb" >> /home/hadoop/hadoop/etc/hadoop/workers
}

function setupWorkers {
	su -l hadoop -c "scp -o StrictHostKeyChecking=no hadoop-*.tar.gz hadoop@nodea:/home/hadoop"
	su -l hadoop -c "scp -o StrictHostKeyChecking=no hadoop-*.tar.gz hadoop@nodeb:/home/hadoop"
	for node in nodea nodeb; do
		sshpass -p 'hadoop' ssh -o StrictHostKeyChecking=no hadoop@$node 'tar -xzf hadoop-3.0.2.tar.gz; mv hadoop-3.0.2 hadoop';
	done
	su -l hadoop -c "scp -o StrictHostKeyChecking=no -r /home/hadoop/hadoop/etc/hadoop/* hadoop@nodea:/home/hadoop/hadoop/etc/hadoop/"
	su -l hadoop -c "scp -o StrictHostKeyChecking=no -r /home/hadoop/hadoop/etc/hadoop/* hadoop@nodeb:/home/hadoop/hadoop/etc/hadoop/"
}

function HDFSandDFS {
	su -l hadoop -c "hdfs namenode -format"
	su -l hadoop -c "start-dfs.sh"
	su -l hadoop -c "start-yarn.sh"
}

echo -e "START SETUP"

echo -e "------SUDOADMIN------"
sudoAdmin
echo -e "------HADOOPUSER------"
hadoopUser
echo -e "------INSTALLTOOLS------"
installTools
echo -e "------SSHKEY------"
sshkey
echo -e "------DOWNLOADHADOOP------"
downloadHadoop
echo -e "------SETENVVAR------"
setEnvVar
echo -e "------SETCORE-SITE------"
setCore-site
echo -e "------SETHDFS-SITE------"
setHdfs-site
echo -e "------SETMAPRED-SITE------"
setMapred-site
echo -e "------SETYARN-SITE------"
setYarn-site
echo -e "------ADDWORKES------"
addWorkers
echo -e "------SETUPWORKES------"
setupWorkers
echo -e "------HDFSANDDFS------"
HDFSandDFS

echo -e "END ALL"
