#!/bin/sh
PRJ_HOME=$(realpath $(dirname $0)/..)
CWD=$(pwd)
PRJ_NAME=${PRJ_NAME:-"alicloud"}
PRJ_TF_HOME=$PRJ_HOME/vboxs/$PRJ_NAME
PRJ_RC=$HOME/.terraform.d/.${PRJ_NAME}.rc
[ ! -d "$PRJ_TF_HOME" ] && echo "! $PRJ_NAME not exists." && exit 1
[ ! -f $PRJ_RC ] && echo "! $PRJ_RC not exists." && exit 1
[ -f $PRJ_RC ] && . $PRJ_RC

cd $PRJ_TF_HOME
terraform $@
cd $CWD
