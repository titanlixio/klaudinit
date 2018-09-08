#!/bin/sh
#PRJ_HOME=$(realpath $(dirname $0)/../..)
PRJ_NAME=klaudinit
PRJ_HOME=${PRJ_HOME:-"/tmp/$PRJ_NAME"}
echo PRJ_HOME=$PRJ_HOME
echo USER=$USER

if [ ! -f $HOME/.ssh/authorized_keys ]; then
  mkdir -p $HOME/.ssh \
    && chmod 700 $HOME/.ssh
  if [ ! -f $HOME/.ssh/id_rsa ]; then
    ssh-keygen -N '' -f $HOME/.ssh/id_rsa
  fi
  cat $HOME/.ssh/id_rsa.pub | tee -a $HOME/.ssh/authorized_keys \
    && chmod 600 $HOME/.ssh/authorized_keys
fi

if [ ! -f $PRJ_HOME/vaults/vpassfile ]; then
  vpasslen=8
  vpassstr=$(openssl rand -base64 32|cut -c 1-$vpasslen|sed 's/\//=/g')
  mkdir -p $PRJ_HOME/vaults
  touch $PRJ_HOME/vaults/vpassfile
  echo $vpassstr | tee -a $PRJ_HOME/vaults/vpassfile
fi
