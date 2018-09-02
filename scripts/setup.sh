#!/bin/sh

PRJ_TOOL=${1:-""}
CWD=$(pwd)

function setup_terraform_provider_tencentcloud {
TENCENTCLOUD_VER=${TENCENTCLOUD_VER:-"1.2.1"}
TENCENTCLOUD_PROVIDER=${TENCENTCLOUD_PROVIDER:-"https://github.com/tencentyun/terraform-provider-tencentcloud/archive/v${TENCENTCLOUD_VER}.tar.gz"}
[ ! -x /usr/bin/go ] && yum install -y golang
GOPATH=${GOPATH:-/tmp/golang}
export GOPATH=$GOPATH
mkdir -p $GOPATH/bin
mkdir -p $GOPATH/tmp
mkdir -p $GOPATH/src/github.com/tencentyun
rm -rf   $GOPATH/src/github.com/tencentyun/*
wget  -O $GOPATH/tmp/terraform-provider-tencentcloud-${TENCENTCLOUD_VER}.tar.gz $TENCENTCLOUD_PROVIDER
tar xzf  $GOPATH/tmp/terraform-provider-tencentcloud-${TENCENTCLOUD_VER}.tar.gz -C $GOPATH/src/github.com/tencentyun
PATH=$GOPATH/bin:$PATH
cd $GOPATH/src/github.com/tencentyun
mv terraform-provider-tencentcloud* terraform-provider-tencentcloud
cd terraform-provider-tencentcloud
go get github.com/kardianos/govendor/
govendor sync -v
go build -o terraform-provider-tencentcloud
mkdir -p /usr/local/terraform.d/plugins/linux_amd64
cp terraform-provider-tencentcloud "/usr/local/terraform.d/plugins/linux_amd64/terraform-provider-tencentcloud_v$TENCENTCLOUD_VER"
ls -la "/usr/local/terraform.d/plugins/linux_amd64/terraform-provider-tencentcloud_v$TENCENTCLOUD_VER"
}

if [ -z "$PRJ_TOOL" ]; then
echo Usage: 
echo   [sudo] $0 vagrant   --cloud=vbox         --env=dev
echo   [sudo] $0 terraform --cloud=tencentcloud --env=test
echo   [sudo] $0 terraform --cloud=aws          --env=prod   --no-docker
exit 0
fi

if [ "vagrant" = "$PRJ_TOOL" ]; then
VBOX_VER=${VBOX_VER:-"5.2"}
VBOX_PKG=${VBOX_PKG:-"VirtualBox-${VBOX_VER}"}
VAGRANT_VER=${VAGRANT_VER:-"2.1.4"}
VAGRANT_PKG=${VAGRANT_PKG:-"https://releases.hashicorp.com/vagrant/${VAGRANT_VER}/vagrant_${VAGRANT_VER}_x86_64.rpm"}
yum install -y "$VBOX_PKG"
yum install -y "$VAGRANT_PKG"
vagrant plugin install vagrant-vbguest
fi

if [ "terraform" = "$PRJ_TOOL" ]; then
TERRAFORM_BIN=${TERRAFORM_BIN:-/usr/local/bin}
TERRAFORM_TMP=${TERRAFORM_TMP:-/tmp/terraform}
TERRAFORM_VER=${TERRAFORM_VER:-"0.11.8"}
TERRAFORM_PKG=${TERRAFORM_PKG:-"https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip"}
mkdir -p $TERRAFORM_TMP
cd $TERRAFORM_TMP
wget -O  terraform_${TERRAFORM_VER}_linux_amd64.zip "$TERRAFORM_PKG"
unzip terraform_${TERRAFORM_VER}_linux_amd64.zip
mv terraform ${TERRAFORM_BIN}/
chmod +x ${TERRAFORM_BIN}/terraform
setup_terraform_provider_tencentcloud
cd $CWD
fi
