#!/bin/sh
#PRJ_HOME=$(realpath $(dirname $0)/../..)
PRJ_NAME=klaudinit
PRJ_HOME=${PRJ_HOME:-"/tmp/$PRJ_NAME"}
PRJ_USER=${PRJ_USER:-vagrant}
PRJ_NODE=${PRJ_NODE:-ctrl01}
PRJ_VPASS=${PRJ_VPASS:-''}
PRJ_NODES=${PRJ_NODES:-''}
PRJ_CTRL=${PRJ_CTRL:-0}
TMP_CTRL=/tmp/ctrl

echo PRJ_HOME=$PRJ_HOME
echo USER=$USER

if [ -f '/etc/selinux/config' ]; then
  sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0
fi

if [ -f '/etc/ssh/sshd_config' ]; then 
  sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
  sed -i 's/^GSSAPIAuthentication.*/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
  systemctl restart sshd
fi

if [ -d $PRJ_HOME ]; then
  echo $PRJ_HOME
  mkdir -p /tmp/klaudinit/vboxs/.ssh
  if [ ! -f /tmp/klaudinit/vboxs/.ssh/id_rsa ]; then
    ssh-keygen -N '' -f /tmp/klaudinit/vboxs/.ssh/id_rsa
  fi
  cp /tmp/klaudinit/vboxs/.ssh/id_rsa     ${TMP_CTRL}.pem
  cp /tmp/klaudinit/vboxs/.ssh/id_rsa.pub ${TMP_CTRL}.pub
  # cp $PRJ_HOME/.vagrant/machines/$PRJ_NODE/virtualbox/private_key ${TMP_CTRL}.pem
fi

rm -rf $HOME/.ssh
if [ ! -d $HOME/.ssh ]; then
  mkdir -p  $HOME/.ssh
  chmod 700 $HOME/.ssh
  cp        /home/$PRJ_USER/.ssh/authorized_keys $HOME/.ssh/authorized_keys
  chmod 600 $HOME/.ssh/authorized_keys
fi

if [ -f ${TMP_CTRL}.pem ]; then
  if [ ! -f ${TMP_CTRL}.pub ]; then
    echo "$(ssh-keygen -y -f ${TMP_CTRL}.pem) $PRJ_USER@$PRJ_NODE" > ${TMP_CTRL}.pub
  fi
  if [ $PRJ_CTRL -gt 0 ]; then
    # cat     ${TMP_CTRL}.pem
    cp        ${TMP_CTRL}.pem $HOME/.ssh/id_rsa
    chmod 600 $HOME/.ssh/id_rsa
    cp        ${TMP_CTRL}.pem /home/$PRJ_USER/.ssh/id_rsa
    chown $PRJ_USER:$PRJ_USER /home/$PRJ_USER/.ssh/id_rsa
    chmod 600 /home/$PRJ_USER/.ssh/id_rsa
  fi
  rm -rf ${TMP_CTRL}.pem
fi

if [ -f ${TMP_CTRL}.pub ]; then
  # cat ${TMP_CTRL}.pub
  cat ${TMP_CTRL}.pub | tee -a $HOME/.ssh/authorized_keys
  cat ${TMP_CTRL}.pub | tee -a /home/$PRJ_USER/.ssh/authorized_keys
  if [ $PRJ_CTRL -gt 0 ]; then
    # cat     ${TMP_CTRL}.pub
    cp        ${TMP_CTRL}.pub $HOME/.ssh/id_rsa.pub
    chmod 644 $HOME/.ssh/id_rsa.pub
  fi
  rm -rf ${TMP_CTRL}.pub
fi 

if [ ! -f $HOME/.ssh/authorized_keys ]; then
  mkdir -p $HOME/.ssh \
    && chmod 700 $HOME/.ssh
  if [ ! -f $HOME/.ssh/id_rsa ]; then
    ssh-keygen -N '' -f $HOME/.ssh/id_rsa
  fi
  cat $HOME/.ssh/id_rsa.pub | tee -a $HOME/.ssh/authorized_keys \
    && chmod 600 $HOME/.ssh/authorized_keys
fi

# rm -rf $PRJ_HOME/vaults/vpassfile
if [ ! -f $PRJ_HOME/vaults/vpassfile ]; then
  vpasslen=8
  vpassstr=$PRJ_VPASS
  [ -z $PRJ_VPASS ] && vpassstr=$(openssl rand -base64 32|cut -c 1-$vpasslen|sed 's/\//=/g')
  mkdir -p $PRJ_HOME/vaults
  touch $PRJ_HOME/vaults/vpassfile
  echo $vpassstr | tee -a $PRJ_HOME/vaults/vpassfile
fi

if [ ! -z "$PRJ_NODES" ]; then
  for node in $PRJ_NODES; do
    name=$(echo $node|awk -F: '{print $1}')
    addr=$(echo $node|awk -F: '{print $2}')
    echo "$addr $name" | tee -a /etc/hosts
    # ssh_nodes='$addr' ssh_user='root' ssh_pass='' sh /vagrant/scripts/nopass.sh
  done
fi
