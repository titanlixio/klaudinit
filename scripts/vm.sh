#!/bin/sh
PRJ_HOME=$(realpath $(dirname $0)/..)
cd $PRJ_HOME
ACTION=${1:-"help"}
SCRIPT=$0
shift

if [ -d $PRJ_HOME/vboxs/ ]; then
  if [ ! -f $PRJ_HOME/vboxs/.ssh/id_rsa ]; then
    mkdir -p $PRJ_HOME/vboxs/.ssh
    ssh-keygen -N '' -C "$USER@ctrl01" -f $PRJ_HOME/vboxs/.ssh/id_rsa
  fi
fi


if [ $ACTION = 'help' ]; then
  echo "Usage:"
  echo "  $SCRIPT down [machine]"
  echo "  $SCRIPT up [machine]"
fi

if [ $ACTION = 'up' ]; then
  vagrant up $@
fi

if [ $ACTION = 'down' ]; then
  vagrant destroy $@ -f
  machine=${1:-''}
  if [ -z $machine ]; then
    echo "==> clean $PRJ_HOME/.vagrant"
    rm -rf "$PRJ_HOME/.vagrant"
  elif [ -d "$PRJ_HOME/.vagrant/machines/$machine" ]; then
    echo "==> clean $PRJ_HOME/.vagrant/machines/$machine"
    rm -rf "$PRJ_HOME/.vagrant/machines/$machine"
  fi
fi
