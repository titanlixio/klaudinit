#!/bin/sh

#[ ! -x /usr/bin/go ] && sudo yum install -y golang

GOPATH=/tmp/golang

mkdir -p $GOPATH/src
mkdir -p $GOPATH/tmp

function install_golang {
VERSION=${1:-'1.10.4'}
export GOPATH=$GOPATH
[ ! -f $GOPATH/tmp/go1.10.4.linux-amd64.tar.gz ] && \
wget -O $GOPATH/tmp/go1.10.4.linux-amd64.tar.gz \
  https://dl.google.com/go/go1.10.4.linux-amd64.tar.gz
mkdir -p $GOPATH/opt
[ ! -d $GOPATH/opt/go ] && \
tar xzf $GOPATH/tmp/go1.10.4.linux-amd64.tar.gz \
  -C $GOPATH/opt
[ -d $GOPATH/opt/go/bin ] && \
export PATH=$GOPATH/opt/go/bin:$PATH
}

function build_tencentcloud {
VERSION=${1:-'1.2.1'}
export GOPATH=$GOPATH
[ ! -f $GOPATH/tmp/terraform-provider-tencentcloud-v${VERSION}.tar.gz ] && \
wget -O $GOPATH/tmp/terraform-provider-tencentcloud-v${VERSION}.tar.gz \
  https://github.com/tencentyun/terraform-provider-tencentcloud/archive/v${VERSION}.tar.gz
mkdir -p $GOPATH/src/github.com/tencentyun
[ -f $GOPATH/src/github.com/tencentyun/terraform-provider-tencentcloud/terraform-provider-tencentcloud ] && \
  ls -l $GOPATH/src/github.com/tencentyun/terraform-provider-tencentcloud/terraform-provider-tencentcloud \
  && mkdir -p /usr/local/terraform.d/plugins/linux_amd64 \
  && cp -rf $GOPATH/src/github.com/tencentyun/terraform-provider-tencentcloud/terraform-provider-tencentcloud \
     /usr/local/terraform.d/plugins/linux_amd64/terraform-provider-tencentcloud_v${VERSION} \
  && return
rm -rf $GOPATH/src/github.com/tencentyun/*
tar xzf $GOPATH/tmp/terraform-provider-tencentcloud-v${VERSION}.tar.gz \
  -C $GOPATH/src/github.com/tencentyun
cd $GOPATH/src/github.com/tencentyun
[ -d terraform-provider-tencentcloud-$VERSION ] && \
mv terraform-provider-tencentcloud-$VERSION  terraform-provider-tencentcloud
cd terraform-provider-tencentcloud
go get github.com/kardianos/govendor
$GOPATH/bin/govendor sync -v
go build -o terraform-provider-tencentcloud
mkdir -p /usr/local/terraform.d/plugins/linux_amd64 \
  && cp -rf $GOPATH/src/github.com/tencentyun/terraform-provider-tencentcloud/terraform-provider-tencentcloud \
  /usr/local/terraform.d/plugins/linux_amd64/terraform-provider-tencentcloud_v${VERSION}
}

function build_alicloud {
VERSION=${1:-'1.15.0'}
export GOPATH=$GOPATH
[ ! -f $GOPATH/tmp/terraform-provider-alicloud-v${VERSION}.tar.gz ] && \
wget -O $GOPATH/tmp/terraform-provider-alicloud-v${VERSION}.tar.gz \
  https://github.com/terraform-providers/terraform-provider-alicloud/archive/v${VERSION}.tar.gz
mkdir -p $GOPATH/src/github.com/terraform-providers
[ -f $GOPATH/src/github.com/terraform-providers/terraform-provider-alicloud/bin/terraform-provider-alicloud ] && \
  ls -l $GOPATH/src/github.com/terraform-providers/terraform-provider-alicloud/bin/terraform-provider-alicloud \
  && mkdir -p /usr/local/terraform.d/plugins/linux_amd64 \
  && cp -rf $GOPATH/src/github.com/terraform-providers/terraform-provider-alicloud/bin/terraform-provider-alicloud \
     /usr/local/terraform.d/plugins/linux_amd64/terraform-provider-alicloud_v${VERSION} \
  && return
rm -rf $GOPATH/src/github.com/terraform-providers/*alicloud*
tar xzf $GOPATH/tmp/terraform-provider-alicloud-v${VERSION}.tar.gz \
  -C $GOPATH/src/github.com/terraform-providers
cd $GOPATH/src/github.com/terraform-providers
[ -d terraform-provider-alicloud-$VERSION ] && \
mv terraform-provider-alicloud-$VERSION  terraform-provider-alicloud
cd terraform-provider-alicloud
# go get golang.org/x/tools/cmd/goimports
# make build
$GOPATH/bin/govendor sync -v
CGO_ENABLED=1 go build -o bin/terraform-provider-alicloud
mkdir -p /usr/local/terraform.d/plugins/linux_amd64 \
&& cp -rf $GOPATH/src/github.com/terraform-providers/terraform-provider-alicloud/bin/terraform-provider-alicloud \
  /usr/local/terraform.d/plugins/linux_amd64/terraform-provider-alicloud_v${VERSION}
}

function main {
install_golang
TF_PROVIDERS="tencentcloud alicloud"
for prov in $TF_PROVIDERS; do
  echo "# build $prov"
  [ 'tencentcloud' = $prov ] && build_tencentcloud
  [ 'alicloud' = $prov ] && build_alicloud
done
}

main $@
